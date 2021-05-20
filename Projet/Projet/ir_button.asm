; file ir_button.asm   target ATmega128L-4MHz-STK300
; purpose link each button from the remote to its function

 menu_bouton:				;button code to their function
	cpi		b0, 0x22		
	breq	mode_button		;>|
	cpi		b0, 0xC2		
	breq	next_menu		;>>|
	cpi		b0, 0x02
	breq	previous_menu	;|<<
	
	jmp temp_buttons

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


temp_buttons:
	cpi		b0, 0x98
	breq	switch_button	;double arrow
	cpi		b0, 0x90
	breq	plus_button		;+
	cpi		b0, 0xa8
	breq	minus_button	;-

	jmp		num_pad_buttons

switch_button:				;choose btw Celcius and Fahrenheit
	mov		w, m			;load m in w
	andi	w, 0b00001011	;use a mask to keep only the bits 0,1,3
	cpi		w, 0b00001001	;see if we are in the the correct sub menu
	breq	PC+2			
	jmp		affichage		;we are in the wrong sub menu
	ldi		w, 0b00000100	;correct sub menu, load the 2nd bit in w
	eor		m, w			;modify the 2nd bit of m

	lds a0, th_addr

	sbrc m, 2
	rjmp change_to_fahr

change_to_cels:
	rcall fahr_to_c
	sts th_addr, a0
	lds a0, tl_addr
	rcall fahr_to_c
	sts tl_addr, a0
	rjmp end_of_switch

change_to_fahr:
	rcall cel_to_f
	sts th_addr, a0
	lds a0, tl_addr
	rcall cel_to_f
	sts tl_addr, a0

end_of_switch:
	rcall	save_t_eeprom
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
	lds		a0, th_addr
	lds		a1, tl_addr
	
	sbrc	m, 4
	rjmp	change_tl

change_th:
	add a0, w

	brvc PC+2
	ldi a0, 125
	
	ldi w, 50
	sbrc m, 2
	ldi w, 125

	cp a0, w
	
	brlt PC+2
	mov a0, w

	cp a1, a0
	brlt save_t

	mov a0, a1
	subi a0, -1
	rjmp save_t

change_tl:
	add		a1, w

	brvc PC+2
	ldi a1, 125

	ldi w, -30
	sbrc m, 2
	ldi w, -25

	cp a1, w
	
	brge PC+2
	mov a1, w

	cp a1, a0
	brlt save_t

	mov a1, a0
	subi a1, 1

save_t:
	sts th_addr, a0
	sts tl_addr, a1

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