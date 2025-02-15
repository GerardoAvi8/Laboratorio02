/*
 Prelaboratorio02.asm;
 Created: 10/02/2025 21:26:44
 Author : Gerardo Avila
 Descripcion: Contador con TMR0
*/

//Encabezado (Definición de registros, variables y constantes)
.include "M328PDEF.inc"

.cseg
.org	0x0000
.def	CONT = R20

//Configuracion de la pila
LDI		R16, LOW(RAMEND)
OUT		SPL, R16			//Cargar 0xff a SPL
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16			//CARGAR 0x00 a SPL

//Tabla de Display
table_DIS:	.DB		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67,	0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

//-------------------------------------------------------------------------//
//Configuracion de Set Up
SETUP:
//Desabilitamos los bits de comunicacion serial
	LDI		R18, 0x00
	STS		UCSR0B, R18

//Configuracion de oscilador externo
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16			//Habilitamos cambiar PRESCALER
	LDI		R16, 0b00000011
	STS		CLKPR, R16			//Configuramos el Prescaler a 8 => 2MHz

//Iniciamos el TMR0
	CALL	START_TMR0

//Configuracion de salidas
	LDI		R18, 0xFF
	OUT		DDRC, R18			//Puerto C como salida (TMR0)
	LDI		R18, 0b00000000		
	OUT		PORTC, R18			//Todos apagados

	LDI		R18, 0xFF
	OUT		DDRD, R18			//Puerto D como salida (Display)
	LDI		R18, 0x00
	OUT		PORTD, R18			//Todos encendidos

//Configuracion de entradas
	LDI		R18, 0x00
	OUT		DDRB, R18			//Puerto B como entrada
	LDI		R18, 0b00000011
	OUT		PORTB, R18			//Habilitamos Pullups

	LDI		R17, 0b00000011		//Guardamos estado inicial de R18

	LDI		CONT, 0x00			//Iniciamos contador en 0

//Configuracion de direccionamiento indirecto
	LDI		ZL, LOW(table_DIS<<1)
	LDI		ZH, HIGH(table_DIS<<1)		//Cargamos nuestra tabla al registro Z completo
	LPM		R24, Z						//Guardamos el valor de Z en un registro normal
	OUT		PORTD, R24					//Mostramos el valor actual de Z en el puerto D

//---------------------------------------------------------------------//
//LOOP
MAIN:
	IN		R16, TIFR0			//Leemos registro y lo guardamos en R16
	SBRC	R16, TOV0	
	CALL	TMR0
	CALL	BOTONES

	RJMP	MAIN

BOTONES:
	IN		R18, PINB		//Leemos el puerto B
	CP		R17, R18		//Comparamos valor guardado con valor actual
	BREQ	MAIN			//Si son iguales regresamos al inicio
	CALL	WAIT			//Esperamos 0.5segundos para confirmar lectura
	IN		R18, PINB		//Leemos el puerto B
	CP		R17, R18		//Comparamos valor guardado con valor actual
	BREQ	MAIN			//Si son iguales regresamos al incio
	MOV		R17, R18

	SBRS	R18, 0
	CALL	INCREMENTO
	SBRS	R18, 1
	CALL	DECREMENTO

	RET

TMR0:
	SBI		TIFR0, TOV0
	LDI		R16, 178
	OUT		TCNT0, R16
	INC		CONT
	CPI		CONT, 18
	BRNE	FIN
	CLR		CONT
	CALL	INCREMENTO_tmr0
	FIN:
	RET

//Subrutinas

WAIT:
	LDI		R22, 0			//Empieza la cuenta en 0
WAIT1:
	INC		R22				//Empieza el primer contador
	CPI		R22, 0			//Verificamos que la cuenta termin?
	BRNE	WAIT1			//Si la cuenta no ha terminado que siga contando
	LDI		R22, 0			//De haber terminado, volver a cargar 0
WAIT2:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT2
	LDI		R22, 0
WAIT3:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT3			
	LDI		R22, 0
WAIT4:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT4			
	LDI		R22, 0
WAIT5:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT5			
	LDI		R22, 0
WAIT6:
	INC		R22			
	CPI		R22, 0			
	BRNE	WAIT6			
	LDI		R22, 0
WAIT7:
	INC		R22			
	CPI		R22, 0			
	BRNE	WAIT7			
	LDI		R22, 0
WAIT8:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT8			
	LDI		R22, 0
WAIT9:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT9			
	LDI		R22, 0
WAIT10:
	INC		R22				
	CPI		R22, 0			
	BRNE	WAIT10			
	RET						//Regresamos a MAIN

START_TMR0:
	LDI		R16, (1<<CS02)		//Cargarmos 1 al registro y lo corremos tres bits a la izquierda
	OUT		TCCR0B, R16			//Colocamos Prescaler de 256
	LDI		R16, 178
	OUT		TCNT0, R16			//Cargamos valor inicial 
	RET

INCREMENTO_tmr0:
	INC		R19
	ANDI	R19, 0x0F
	OUT		PORTC, R19
	RET

INCREMENTO:
	INC		R21
	ADIW	Z, 1
	LPM		R20, Z
	OUT		PORTD, R20
	RET

DECREMENTO:
	DEC		R21
	SBIW	Z, 1
	LPM		R20, Z
	OUT		PORTD, R20
	RET

