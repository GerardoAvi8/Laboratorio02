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
T7S:	.DB		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67,	0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

//-------------------------------------------------------------------------//
//Configuracion de Set Up
SETUP:
//Desabilitamos los bits de comunicacion serial
	LDI			R16, 0x00
	STS			UCSR0B, R16

//Configuracion de oscilador externo
	LDI			R16, (1 << CLKPCE)
	STS			CLKPR, R16			//Habilitamos cambiar PRESCALER
	LDI			R16, 0b00000011
	STS			CLKPR, R16			//Configuramos el Prescaler a 8 => 2MHz

//Iniciamos el TMR0
	LDI			R16, (1<<CS02) | (1<<CS00)		//Cargarmos 1 al registro y lo corremos tres bits a la izquierda
	OUT			TCCR0B, R16			//Colocamos Prescaler de 1024
	LDI			R22, 60
	OUT			TCNT0, R22

//Configuracion de salidas/entradas
	//TMR0
	LDI			R16, 0xFF
	OUT			DDRC, R16			//Puerto C como salida (TMR0)
	LDI			R16, 0b00000000		
	OUT			PORTC, R16			//Todos apagados
	//DISPLAY
	LDI			R16, 0xFF
	OUT			DDRD, R16			//Puerto D como salida (Display)
	LDI			R16, 0x00
	OUT			PORTD, R16			//Todos encendidos
	//BOTONES
	LDI			R17, 0x00
	OUT			DDRB, R17
	LDI			R17, 0b00001100
	OUT			PORTB, R17

//Cargar tabla de display de siete segmentos
	LDI			ZL, LOW(T7S<<1)
	LDI			ZH, HIGH(T7S<<1)
	LPM			R24, Z
	OUT			PORTD, R24					//Mostramos el valor actual de Z en el puerto D

//Configuracion de registros
	LDI			R18, 0b00001100
	LDI			CONT, 0x00
	LDI			R16, 0x00
	LDI			R21, 0x00
	LDI			R24, 0x00
	LDI			R25, 0x00


//---------------------------------------------------------------------//
//LOOP
MAIN:

	RCALL		TMR0
	CALL		BOTONES
	RJMP		MAIN

BOTONES:
	IN			R17, PINB		//Leemos el puerto B
	CP			R18, R17		//Comparamos valor guardado con valor actual
	BREQ		FIN_BOTONES			//Si son iguales regresamos al inicio
	RCALL		WAIT			//Esperamos 0.5segundos para confirmar lectura
	IN			R17, PINB		//Leemos el puerto B
	CP			R18, R17		//Comparamos valor guardado con valor actual
	BREQ		FIN_BOTONES			//Si son iguales regresamos al incio
	MOV			R18, R17

	SBRS		R17, 2
	RCALL		INCREMENTO
	SBRS		R17, 3
	RCALL		DECREMENTO
FIN_BOTONES:
	RET

TMR0:
	IN			R16, TIFR0			//Leemos registro y lo guardamos en R16
	SBRS		R16, TOV0	
	RET
	SBI			TIFR0, TOV0
	LDI			R22, 60
	OUT			TCNT0, R22
	INC			CONT
	CPI			CONT, 10
	BRNE		FIN
	CLR			CONT
	RCALL		INCREMENTO_tmr0
FIN:
	RET

//Subrutinas

//DELAY INVESTIGADO		No se uso ya que queria probar mi delay original
/*WAIT:
	LDI			R19, 255
WAIT1:
	DEC			R19
	BRNE		WAIT1
	RET*/

//DELAY
WAIT:
	LDI			R19, 0			//Empieza la cuenta en 0
WAIT1:	
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT1			
	LDI			R19, 0
WAIT2:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT2
	LDI			R19, 0
WAIT3:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT3			
	LDI			R19, 0
WAIT4:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT4			
	LDI			R19, 0
WAIT5:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT5			
	LDI			R19, 0
WAIT6:
	INC			R19			
	CPI			R19, 0			
	BRNE		WAIT6			
	LDI			R19, 0
WAIT7:
	INC			R19			
	CPI			R19, 0			
	BRNE		WAIT7			
	LDI			R19, 0
WAIT8:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT8			
	LDI			R19, 0
WAIT9:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT9			
	LDI			R19, 0
WAIT10:
	INC			R19				
	CPI			R19, 0			
	BRNE		WAIT10			
	RET							//Regresamos a MAIN

INCREMENTO_tmr0:
	INC			R21
	ANDI		R21, 0x0F
	OUT			PORTC, R21
	RCALL		ACTUALIZAR
	RET

INCREMENTO:
	INC			R24
	ANDI		R24, 0x0F
	RCALL		ACTUALIZAR
	RET

DECREMENTO:
	DEC			R24
	ANDI		R24, 0x0F
	RCALL		ACTUALIZAR
	RET

ACTUALIZAR:
	LDI			ZL, LOW(T7S<<1)
	LDI			ZH, HIGH(T7S<<1)
	ADD			ZL, R24
	LPM			R25, Z
	OUT			PORTD, R25
	RET

