.include	"Libraries\macros.asm"		; include macro definitions
.include	"Libraries\definitions.asm"	; include register/constant definitions
.include	"macro_projet.asm"

.org	0
	rjmp	reset

.equ	max_speed = 2000			

.equ	eep_addr = 0x0000

reset:
	LDSP RAMEND
	rcall	LCD_init	; initialize LCD
	OUTI	DDRD,0x00


	rjmp main

.include "Libraries\lcd.asm"
.include "Libraries\printf.asm"
.include "Libraries\math_speed.asm"

main:

	_LDI d1, 3
	_LDI d0, 37

	push d0
	mov a0, d1
	rcall cel_to_f
	mov d1, a0
	pop a0
	push d1
	rcall cel_to_f
	mov d0,a0
	pop d1



	rjmp	main


cel_to_f:
	bst		a0,7
	cpi		a0, 0
	brpl	mul_c_f

; a0 is negative, we take its absolute value
	com a0
	subi a0, (-1)

mul_c_f:
	ldi b0, 9
	rcall mul11
	mov a0,c0
	mov a1,c1
	ldi b0, 5
	clr b1
	rcall div22
	
	mov a0,c0
	brtc	add_c_f

; a0 is turned back into a negative number
	com a0
	subi a0, (-1)

add_c_f:
	subi a0, (-32) ; a0 : T in F
	ret