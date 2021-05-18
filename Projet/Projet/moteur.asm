/*
 * moteur.asm
 *
 *  Created: 20.04.2021 13:55:16
 *   Author: Administrateur
 */ 
.include	"macro_projet.asm"

motor_reset:
	OUTI	DDRB,0xff		; configure portC to output
	ret			
	
; turn_moteur -----------------
;this routine execute a certain rotation of an angle
;in a1:a0 angle in byte
;mod:
turn_moteur:
	
	ldi b0, 30
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
	ret