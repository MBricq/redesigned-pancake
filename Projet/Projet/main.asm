.include	"Libraries\macros.asm"		; include macro definitions
.include	"Libraries\definitions.asm"	; include register/constant definitions

.def	m = r6					;registre de travail
.equ	th_addr = 0x0200		;address to store the high temp
.equ	tl_addr = 0x0201		;address to store the low temp
.equ	unit_addr = 0x0202		;address to store the unit
.equ	m_eep_addr = 0x0000
.equ	th_eep = 0x0001
.equ	tl_eep = 0x0002

.org	0
	jmp	reset

.org OVF0addr
	jmp	ovf0

.include	"temp.asm"
.include	"remote.asm"
.include	"Libraries\eeprom.asm"
.include	"affichage.asm"

ovf0:
	push	 w
	push	_w
	push	a0
	push	a1
	push	b0
	push	b1
	in		_sreg,SREG
	rcall	update_temp
	out		SREG,_sreg
	pop		b1
	pop		b0
	pop		a1
	pop		a0
	pop		_w
	pop		w
	reti

reset:	
	LDSP	RAMEND			; load stack pointer (SP)
	
	ldi xh, high(m_eep_addr)
	ldi xl, low(m_eep_addr)
	rcall eeprom_load
	mov m,a0

	ldi		w,1
	sts		unit_addr,w

	rcall	temp_reset	
	rcall	LCD_init		; initialize LCD

	OUTI	ASSR, (1<<AS0)	; clock from TOSC1 (external)
	OUTI	TCCR0,7			; CS0=7 CK/1024
	OUTI	TIMSK, 1<<TOIE0
	sei		
	rcall	update_temp

	rjmp	affichage


main:
	rcall	read_remote
	sei

	cpi		b0,0
	breq	error

	rjmp	main

error:
	rjmp	main


gestion_bouton:				;button code to their function
	cpi		b0, 0x22		
	breq	mode_button		;>|
	cpi		b0, 0xC2		
	breq	next_menu		;>>|
	cpi		b0, 0x02
	breq	previous_menu	;|<<
	cpi		b0, 0x98
	breq	switch_button	;double arrow
	cpi		b0, 0x90
	breq	plus_button		;+
	cpi		b0, 0xa8
	breq	minus_button	;-

	jmp		num_pad_buttons

next_menu:					;change menu (two last bits of m) to the right
	sbrc	m,3				;enter in the sub menu 
	rjmp	change_sub

	mov		_w, m			;save the m register in _w
	andi	_w, 0b00000011	;save the two la bits of m and clear the other
	subi	_w, -1			;change the two last bits of m by adding 1: 00-01-10-11-00-...
	andi	_w, 0b00000011	;save the two last bits of m and clear the other
	_ANDI	m, 0b11111100	;clear the two lastbits of m with a mask
	add		m,_w			;assemble the unmodified part with the last two bits
	jmp		save_m_eeprom

previous_menu:				;change menu (two last bits of m) to the left
	sbrc	m,3				;enter in the sub menu 
	rjmp	change_sub

	mov		_w, m			;save the m register in _w 
	andi	_w, 0b00000011	;save the two la bits of m and clear the other
	subi	_w, 1			;change the two last bits of register m by substracting 1: 00-11-10-01-00-...
	andi	_w, 0b00000011	;save the two last bits of m and clear the other 
	_ANDI	m, 0b11111100	;clear the two lastbits of m with a mask
	add		m,_w			;assemble the unmodified part with the last two bits
	jmp		save_m_eeprom

change_sub:					;change the sub menu (4th bit of m)
	ldi		w, 0b00010000	;load the 4th bit in w
	eor		m, w			;change the 4th bit of m
	jmp		save_m_eeprom

mode_button:				;enter or exit the sub menu (3rd bit of m)
	ldi		w, 0b00001000	;load the 3rd bit in w
	eor		m, w			;change the 3rd bit of m
	jmp		save_m_eeprom

switch_button:				;choose btw Celcius and Fahrenheit
	mov		w, m			;load m in w
	andi	w, 0b00001011	;use a mask to keep only the bits 0,1,3
	cpi		w, 0b00001001	;see if we are in the the correct sub menu
	breq	PC+2			
	jmp		affichage		;we are in the wrong sub menu
	ldi		w, 0b00000100	;correct sub menu, load the 2nd bit in w
	eor		m, w			;modify the 2nd bit of m
	jmp		save_m_eeprom

plus_button:					;button used to increase the temp value
	CHECK_MENU_LIMIT
	lds		w, unit_addr
	rjmp	change_temp

minus_button:					;button used to lower the temp value
	CHECK_MENU_LIMIT
	lds		w, unit_addr
	com		w					;start reversing bits
	subi	w, (-1)				;add 1 so that all bits are inverted
	rjmp	change_temp

change_temp:
	sbrc	m, 4
	rjmp	load_tl

	lds		a0, th_addr
	rjmp	new_t

load_tl:
	lds		a0, tl_addr

new_t:
	add		a0, w

	sbrc	m,4
	rjmp	store_tl

	sts		th_addr,a0
	rjmp	save_t

store_tl:
	sts		tl_addr,a0

save_t:
	rcall	save_t_eeprom
	jmp		affichage


num_pad_buttons:				;button code to their function
	CHECK_MENU_LIMIT
	cpi		b0, 0x30
	breq	button_one		;1
	cpi		b0, 0x18
	breq	button_two		;2
	cpi		b0, 0x7a
	breq	button_three	;3
	cpi		b0, 0x10
	breq	button_four		;4
	cpi		b0, 0x38
	breq	button_five		;5
	cpi		b0, 0x5a
	breq	button_six		;6
	cpi		b0, 0x42
	breq	button_seven	;7
	cpi		b0, 0x4a
	breq	button_eight	;8
	cpi		b0, 0x52
	breq	button_nine		;9
	cpi		b0, 0x68
	breq	button_zero		;0

	jmp		affichage

button_one:							;button used to change to 1 the unit to add/remove at the temp lim
	ldi		w,1
	rjmp	change_unit

button_two:							;button used to change to 2 the unit to add/remove at the temp lim
	ldi		w,2
	rjmp	change_unit

button_three:						;button used to change to 3 the unit to add/remove at the temp lim
	ldi		w,3
	rjmp	change_unit
	
button_four:						;button used to change to 4 the unit to add/remove at the temp lim
	ldi		w,4
	rjmp	change_unit

button_five:						;button used to change to 5 the unit to add/remove at the temp lim
	ldi		w,5
	rjmp	change_unit

button_six:							;button used to change to 6 the unit to add/remove at the temp lim
	ldi		w,6
	rjmp	change_unit

button_seven:						;button used to change to 7 the unit to add/remove at the temp lim
	ldi		w,7
	rjmp	change_unit

button_eight:						;button used to change to 8 the unit to add/remove at the temp lim
	ldi		w,8
	rjmp	change_unit

button_nine:						;button used to change to 9 the unit to add/remove at the temp lim
	ldi		w,9
	rjmp	change_unit

button_zero:						;button used to change to 10 the unit to add/remove at the temp lim
	ldi		w,10
	rjmp	change_unit

change_unit:						;change the value of the unit in the address
	sts		unit_addr, w
	jmp		affichage

save_m_eeprom:
	ldi xh, high(m_eep_addr)
	ldi xl, low(m_eep_addr)
	mov a0,m
	rcall	eeprom_store
	jmp affichage