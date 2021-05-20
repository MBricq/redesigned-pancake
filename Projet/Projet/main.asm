; file main.asm   target ATmega128L-4MHz-STK300
; purpose runs the main loop of the program, calling each parts

; 
.include	"Libraries\macros.asm"		; include macro definitions
.include	"Libraries\definitions.asm"	; include register/constant definitions

.def	m = r6					;registre de travail
.equ	th_addr = 0x0200		;address to store the high temp
.equ	tl_addr = 0x0201		;address to store the low temp
.equ	unit_addr = 0x0202		;address to store the unit
.equ	counter_addr = 0x0203
.equ	m_eep_addr = 0x0000
.equ	th_eep = 0x0001
.equ	tl_eep = 0x0002


.org	0
	jmp		reset

.org	OVF0addr
	jmp		ovf0

.include	"temp.asm"
.include	"remote.asm"
.include	"Libraries\eeprom.asm"
.include	"affichage.asm"

ovf0:
	push	w
	lds		w, counter_addr
	subi	w, 1
	sts		counter_addr, w
	cpi		w,0
	breq	PC+3
	pop		w
	reti

	ldi		w,5
	sts		counter_addr, w

	push	_w
	push	a0
	push	a1
	push	b0
	push	b1
	push	b2
	push	c0
	push	c1
	push	d0
	push	d1
	push	xh
	push	xl
	in		_sreg,SREG
	rcall	update_temp
	out		SREG,_sreg
	pop		xl
	pop		xh
	pop		d1
	pop		d0
	pop		c1
	pop		c0
	pop		b2
	pop		b1
	pop		b0
	pop		a1
	pop		a0
	pop		_w
	pop		w
	reti

reset:	
	LDSP	RAMEND			; load stack pointer (SP)
	
	ldi		xh,	high(m_eep_addr)
	ldi		xl, low(m_eep_addr)
	rcall	eeprom_load
	mov		m,a0

	ldi		w,1
	sts		unit_addr,w

	ldi		w,5
	sts		counter_addr,w

	rcall	temp_reset	
	rcall	LCD_init		; initialize LCD

	OUTI	ASSR, (1<<AS0)	; clock from TOSC1 (external)
	OUTI	TCCR0,7			; CS0=7 CK/1024
	OUTI	TIMSK, 1<<TOIE0
	sei		
	rcall	update_temp

	rjmp	affichage

.include	"ir_button.asm"

main:
	rcall	read_remote
	sei

	cpi		b0,0
	breq	error

	rjmp	menu_bouton

error:
	rjmp	main
