;
; Robotic arm.asm
;
; Created: 22/11/2021 07:12:37 a. m.
; Author : Alan Samuel Aguirre Salazar
;

.include "m16def.inc"     
 
	.org 0x0000
	jmp RESET

	.org 0x0026   
	rjmp TIM0_COMP

RESET:
	;Primero inicializamos el stack pointer...
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16 

	// Puerto B, C y D como salida
	ldi R16, 0b1111_1111
	out DDRB, R16
	out DDRC, R16
	out DDRD, R16

	ldi R16, 0b0000_0000
	out PORTB, R16
	out PORTC, R16
	out PORTD, R16

	// Puerto A como entrada
	out DDRA, R16

	ldi R16, 0b1111_1111
	out PORTA, R16 

	//Activar Interrupciones
	sei

	// OCR0
	ldi R16, 124
	out OCR0, R16

	// TIFR
	ldi R16, 0b0000_0011
	out TIFR, R16

	// TIMSK
	ldi R16, 0b0000_0010
	out TIMSK, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16


	clr R16						// Registro todologo
	ldi R17, 0b0000_0001		// Registro de motores
	clr R18						// Registro Blanco o Negro
	clr R20						// Numero de motor
	clr R21						// Contador milesimas
	clr R22						// Contador decimas


CHECK:
	sbis PINA, 3
		rjmp ACTIVAR

	rjmp CHECK


ACTIVAR:
	rcall RETARDO
	TRABA_ACTIVAR:
		sbis PINA, 3
			rjmp TRABA_ACTIVAR
	rcall RETARDO

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0000_1010
	out TCCR0, R16

	rjmp MOTOR1PREV


//-----------------------------INICIO-----------------------------

//--------------------MOTOR 1--------------------

MOTOR1PREV:

	clr R21
	clr R22
	ldi R17, 0b0000_0001
	rjmp MOTOR1

MOTOR1:
	cpi R22, 22
		breq SENSOR
	out PORTB, R17
	rcall RETARDO10m
	lsl R17
	cpi R17, 0b0001_0000
		breq RTOEIGHT1
	rjmp MOTOR1

RTOEIGHT1:
	ldi R17, 0b0000_0001
	rjmp MOTOR1

//--------------------NEGRO O BLANCO--------------------

SENSOR:

	clr R16
	out PORTB, R16

	sbis PINA, 0
		rjmp BLANCO
	sbic PINA, 0
		rjmp NEGRO
	rjmp SENSOR

BLANCO:
	ldi R18, 1
	rjmp MOTOR2PREV

NEGRO:
	ldi R18, 0
	rjmp MOTOR2PREV
	
//--------------------MOTOR 2--------------------

MOTOR2PREV:

	clr R16
	out PORTB, R16

	clr R21
	clr R22
	ldi R17, 0b0000_1000
	rjmp MOTOR2

MOTOR2:
	cpi R22, 25
		breq MOTOR1PREVREGRESO1
	out PORTC, R17
	rcall RETARDO10m
	lsr R17
	cpi R17, 0b0000_0000
		breq RTOEIGHT2
	rjmp MOTOR2

RTOEIGHT2:
	ldi R17, 0b0000_1000
	rjmp MOTOR2


//--------------------MOTOR 1--------------------

MOTOR1PREVREGRESO1:

	clr R16
	out PORTC, R16
	clr R21
	clr R22
	ldi R17, 0b0000_1000
	rjmp MOTOR1REGRESO1

MOTOR1REGRESO1:
	cpi R22, 10
		breq MOTOR3PREV
	out PORTB, R17
	rcall RETARDO10m
	lsr R17
	cpi R17, 0b0000_0000
		breq RTOEIGHT1REGRESO1
	rjmp MOTOR1REGRESO1

RTOEIGHT1REGRESO1:
	ldi R17, 0b0000_1000
	rjmp MOTOR1REGRESO1


//--------------------MOTOR 3--------------------

MOTOR3PREV:	

	clr R16
	out PORTB, R16

	cpi R18, 0					// Es negro
		breq MOTOR3NEGROPREV
	cpi R18, 1					//Es blanco
		breq MOTOR3BLANCOPREV

MOTOR3NEGROPREV:
	clr R21
	clr R22
	ldi R17, 0b0000_1000
	rjmp MOTOR3NEGRO

MOTOR3NEGRO:
	cpi R22, 50
		breq MOTOR2PREVREGRESO
	out PORTD, R17
	rcall RETARDO10m
	lsr R17
	cpi R17, 0b0000_0000
		breq RTOEIGHT3NEGRO
	rjmp MOTOR3NEGRO

RTOEIGHT3NEGRO:
	ldi R17, 0b0000_1000
	rjmp MOTOR3NEGRO


MOTOR3BLANCOPREV:
	clr R21
	clr R22
	ldi R17, 0b0000_0001
	rjmp MOTOR3BLANCO

MOTOR3BLANCO:
	cpi R22, 50
		breq MOTOR2PREVREGRESO
	out PORTD, R17
	rcall RETARDO10m
	lsl R17
	cpi R17, 0b0001_0000
		breq RTOEIGHT3BLANCO
	rjmp MOTOR3BLANCO

RTOEIGHT3BLANCO:
	ldi R17, 0b0000_0001
	rjmp MOTOR3BLANCO

//-----------------------------REGRESO-----------------------------

//--------------------MOTOR 2--------------------

MOTOR2PREVREGRESO:

	clr R16
	out PORTD, R16

	clr R21
	clr R22
	ldi R17, 0b0000_0001
	rjmp MOTOR2REGRESO

MOTOR2REGRESO:
	cpi R22, 20
		breq MOTOR1PREVREGRESO2
	out PORTC, R17
	rcall RETARDO10m
	lsl R17
	cpi R17, 0b0001_0000
		breq RTOEIGHT2REGRESO
	rjmp MOTOR2REGRESO

RTOEIGHT2REGRESO:
	ldi R17, 0b0000_0001
	rjmp MOTOR2REGRESO


//--------------------MOTOR 1--------------------

MOTOR1PREVREGRESO2:

	clr R16
	out PORTC, R16
	clr R21
	clr R22
	ldi R17, 0b0000_1000
	rjmp MOTOR1REGRESO2

MOTOR1REGRESO2:
	cpi R22, 12
		breq MOTOR3PREVREGRESO
	out PORTB, R17
	rcall RETARDO10m
	lsr R17
	cpi R17, 0b0000_0000
		breq RTOEIGHT1REGRESO2
	rjmp MOTOR1REGRESO2

RTOEIGHT1REGRESO2:
	ldi R17, 0b0000_1000
	rjmp MOTOR1REGRESO2



//--------------------MOTOR 3--------------------

MOTOR3PREVREGRESO:	
	clr R16
	out PORTB, R16

	cpi R18, 0					// Es negro
		breq MOTOR3NEGROPREVREGRESO
	cpi R18, 1					//Es blanco
		breq MOTOR3BLANCOPREVREGRESO

MOTOR3NEGROPREVREGRESO:
	clr R21
	clr R22
	ldi R17, 0b0000_0001
	rjmp MOTOR3NEGROREGRESO

MOTOR3NEGROREGRESO:
	cpi R22, 50
		breq REINICIARREGISTROS
	out PORTD, R17
	rcall RETARDO10m
	lsl R17
	cpi R17, 0b0001_0000
		breq RTOEIGHT3NEGROREGRESO
	rjmp MOTOR3NEGROREGRESO

RTOEIGHT3NEGROREGRESO:
	ldi R17, 0b0000_0001
	rjmp MOTOR3NEGROREGRESO


MOTOR3BLANCOPREVREGRESO:

	clr R21
	clr R22
	ldi R17, 0b0000_1000
	rjmp MOTOR3BLANCOREGRESO

MOTOR3BLANCOREGRESO:
	cpi R22, 50
		breq REINICIARREGISTROS
	out PORTD, R17
	rcall RETARDO10m
	lsr R17
	cpi R17, 0b0000_0000
		breq RTOEIGHT3BLANCOREGRESO
	rjmp MOTOR3BLANCOREGRESO

RTOEIGHT3BLANCOREGRESO:
	ldi R17, 0b0000_1000
	rjmp MOTOR3BLANCOREGRESO


REINICIARREGISTROS:
	clr R16						// Registro todologo
	ldi R17, 0b0000_0001		// Registro de motores
	clr R18						// Registro Blanco o Negro
	clr R20						// Numero de motor
	clr R21						// Contador milesimas
	clr R22						// Contador decimas

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	out TCCR0, R16

	// Salidas
	out PORTB, R16
	out PORTC, R16
	out PORTD, R16

	rjmp CHECK



TIM0_COMP:
	inc R21
	cpi R21, 100
		breq UNADECIMA
	reti

UNADECIMA:
	 clr R21
	 inc R22
	 reti


RETARDO:
			  ldi  R29, $E1
	WGLOOP0:  ldi  R30, $EC
	WGLOOP1:  dec  R30
			  brne WGLOOP1
			  dec  R29
			  brne WGLOOP0
			  ldi  R29, $08
	WGLOOP2:  dec  R29
			  brne WGLOOP2
			  nop
	ret

RETARDO10m:
		ldi  R29, $21
	A:  ldi  R30, $64
	B:  dec  R30
			  brne B
			  dec  R29
			  brne A
			  nop
	ret


















