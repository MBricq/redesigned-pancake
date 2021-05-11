/*
 * moteur.asm
 *
 *  Created: 20.04.2021 13:55:16
 *   Author: Administrateur
 */ 
.include	"macro_projet.asm"

.equ	max_speed = 2000			
.equ	min_speed = 1000

motor_reset:
	OUTI	DDRB,0xff		; configure portC to output
	ret			
	
; turn_moteur -----------------
;this routine execute a certain rotation of an angle
;in a1:a0 angle in byte
;mod:
turn_moteur:
	P0	PORTB,SERVO1

	rcall	LCD_clear
	rcall	LCD_home
	PRINTF	LCD
	.db		FFRAC2+FSIGN,a,4,$42,LF,0
	
	mov		w, a0
	mov		_w, a1
	DIV22B	a0, a1
	add		a0, w
	adc		a1, _w
	DIV22B	a0, a1

	sbrc	a1, 7
	rjmp	negative_angle	

positive_angle:
;	shift right 4X
	DIV22B	a0, a1
	DIV22B	a0, a1
	DIV22B	a0, a1
	DIV22B	a0, a1
	mov		b0, a0

	ldi		a0, low(max_speed)
	ldi		a1, high(max_speed)
	rjmp	check_zero

negative_angle:
	COM2B	a0,a1
	;	shift right 4X
	DIV22B	a0, a1
	DIV22B	a0, a1
	DIV22B	a0, a1
	DIV22B	a0, a1
	mov		b0, a0
	ldi		a0, low(min_speed)
	ldi		a1, high(min_speed)
	rjmp	check_zero	

; in a1:a0, a2 out void, mod a2,w
; purpose execute arbitrary rotation
check_zero:
	PRINTF	LCD
	.db		FBIN,b,0
	cpi		b0,0
	breq	stop
store_value:
	PRINTF	LCD
	.db		"!=0",0
	sts		0x1070, c0
	sts		0x1072, c1
motor_loop:
	rcall	servoreg_pulse
	dec		b0
	brne	motor_loop

	rjmp	stop

; servoreg_pulse, in a1,a0, out servo port, mod a3,a2
; purpose generates pulse of length a1,a0
servoreg_pulse:
	WAIT_US	20000
	MOV2	a3,a2, a1,a0
	P1		PORTB,SERVO1		; pin=1	
lpssp01:	
	SUBI2	a3,a2,0x1
	brne	lpssp01
	P0		PORTB,SERVO1		; pin=0
	ret

stop:
	PRINTF	LCD
	.db		"=0",0
	ret