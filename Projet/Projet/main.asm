; file main.asm   target ATmega128L-4MHz-STK300
; purpose runs the main loop of the program, calling each parts

; ==== Include Libraries ==== 

.include	"Libraries\macros.asm"		; include macro definitions
.include	"Libraries\definitions.asm"	; include register/constant definitions

; ==== Definitions ==== 

.def	m = r6					; menu register
.equ	th_addr = 0x0200		; address to store the high temp
.equ	tl_addr = 0x0201		; address to store the low temp
.equ	unit_addr = 0x0202		; address to store the unit
.equ	counter_addr = 0x0203	; address to store the counter for the interrupt
.equ	alarm_addr = 0x0204		; address to store the alarm 
.equ	on_off_addr = 0x205		; address to store if screen is on/off

.equ	m_eep_addr = 0x0000		; eeprom address to store the menu register
.equ	th_eep = 0x0001			; eeprom address to store the high temp
.equ	tl_eep = 0x0002			; eeprom address to store the low temp

;==== Interrupt Vectors ====

.org	0
	jmp		reset
.org	0x10
	jmp ext_int7
.org	OVF0addr				;overflow timer 0
	jmp		ovf0



; ==== Include Other Files ==== 

.include	"temp.asm"
.include	"remote.asm"
.include	"Libraries\eeprom.asm"
.include	"affichage.asm"
.include	"ir_button.asm"

; ==== Code ==== 

ext_int7:
	push	w
	in		_sreg, SREG
	ldi		w, 0
	sts		alarm_addr,w
	out		SREG,_sreg
	pop		w
	reti

ovf0:
	; this counter is used to slow down the timer to 40s instead of 8s						
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

	; push and pop and call the routine to read the temp 
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
	
	; get the menu register from the eeprom at reset
	ldi		xh,	high(m_eep_addr)
	ldi		xl, low(m_eep_addr)
	rcall	eeprom_load
	mov		m,a0

	; set up values in the SRAM
	ldi		w,1
	sts		unit_addr,w
	ldi		w,5
	sts		counter_addr,w
	ldi		w,0
	sts		alarm_addr,w
	ldi		w,0
	sts		on_off_addr,w

	; set up interrupt
	OUTI	EIMSK, 0b10000000
	OUTI	EICRB, 0b10000000

	; call the reset 
	rcall	remote_reset
	rcall	temp_reset	
	rcall	LCD_init		; initialize LCD
	rcall	store_custom_char

	; set up timer
	OUTI	ASSR, (1<<AS0)	; clock from TOSC1 (external)
	OUTI	TCCR0,7			; CS0=7 CK/1024
	OUTI	TIMSK, 1<<TOIE0 ; set up the timer as overflow
	sei		

	rcall	update_temp

	rjmp	affichage		; turn on the screen

main:

	lds		w, alarm_addr	; load the value indicating if the alarm needs to ring (in the 5th bit)
	and		w, m			; the 5th bit of m indicates if the alarm is activated by user
	sbrc	w, 5			; if one of the two is 0, no need to play alarm	
	rcall	play			; otherwise, play

	sbic	PINIR,IR		; if the remote is sending a code, it needs to be read
	rjmp	main			; otherwise, wait in main

	cli						; The NEC signals have to be read without interrupt
	rcall	read_remote		; wait for the user to press a button
	sei						; the interrupt is disabled in read_remote we reactivate it here

	cpi		b0,0			; if its 0, then it's a repeat or an error
	breq	main

	rjmp	menu_bouton

