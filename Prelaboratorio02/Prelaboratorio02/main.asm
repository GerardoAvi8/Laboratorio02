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

//-------------------------------------------------------------------------//
//Configuracion de Set Up
SETUP:
//Desabilitamos los bits de comunicacion serial
	LDI		R17, 0x00
	STS		UCSR0B, R17

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
	LDI		R18, 0xFF
	OUT		PORTD, R18			//Todos encendidos

	LDI		CONT, 0x00

//---------------------------------------------------------------------//
//LOOP
MAIN:
	IN		R16, TIFR0			//Leemos registro de interrupcion
	SBRS	R16, TOV0			//Saltar si existe overflow
	RJMP	MAIN				//Regresar a MAIN
	SBI		TIFR0, TOV0			//Apagamos el bit de overflow
	LDI		R16, 178			//Cargamos nuevamente valor inicial
	OUT		TCNT0, R16			//Valor inicial al registro
	INC		CONT				//Incrementamos nuestro contador
	CPI		CONT, 18			//Encender y apagar cada 500ms
	BRNE	MAIN
	CLR		CONT
	CALL	INCREMENTO
	RJMP	MAIN

//Subrutinas
START_TMR0:
	LDI		R16, (1<<CS02)		//Cargarmos 1 al registro y lo corremos tres bits a la izquierda
	OUT		TCCR0B, R16			//Colocamos Prescaler de 256
	LDI		R16, 178
	OUT		TCNT0, R16			//Cargamos valor inicial 
	RET

INCREMENTO:
	INC		R19
	ANDI	R19, 0x0F
	OUT		PORTC, R19
	RET

