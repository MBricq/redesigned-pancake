; file affichage.asm   target ATmega128L-4MHz-STK300
; purpose display on the LCD screen the correct menu


; ====	Display Routine ====

affichage:
	rcall	LCD_clear		;clear LCD
	rcall	LCD_home

	lds		w, on_off_addr	;load the address ON/OFF in w
	cpi		w, 0			;compare with 0, if w = 0 go to main 
	breq	PC+2
	rjmp	main

	mov		_w, m			; load m in _w
	andi	_w, 0b11		; select the two last bits of m 
	_CPI	_w, 0		
	breq	menu_set_temp	; if their are 00 -> menu set temp
	_CPI	_w, 1		
	breq	menu_temp		; if their are 01 ->	menu temp
	_CPI	_w, 2
	breq	menu_music		; if their are 10 ->	menu music
	_CPI	_w, 3
	breq	menu_jeu		; if their are 11 -> menu jeu

	rjmp	main

menu_music:			
	; print music
	sbrc	m,3
	rjmp	music_choice

	PRINTF	LCD
	.db		"Music",0
	rjmp	music_on_off
	

menu_jeu:			
	; print jeu
	sbrc	m,3
	rjmp	jeu
	
	PRINTF	LCD
	.db		"Jeu",0
	jmp		main

menu_set_temp:		
	; print temp lim
	sbrc	m,3
	rjmp	print_limit

	PRINTF	LCD
	.db		"Temperatures",LF,"limites",0
	jmp		main

menu_temp:			
	; print temp	
	sbrc	m,3
	rjmp	degre

	PRINTF LCD
	.db		"Echelle de",LF,"temperature",0
	jmp		main

; ==== Menu Choix Unite Temperature ====
degre:
	PRINTF	LCD
	.db		"Degre :",LF,0

	sbrc	m,2
	rjmp	print_f

print_c:			
	; print Celsius
	PRINTF	LCD
	.db		"Celsius",0
	rjmp	main

print_f:			
	; print Fahrenheit
	PRINTF	LCD
	.db		"Fahrenheit",0
	rjmp	main


; ==== Menu Limite Temperature ====
print_limit:		
	; print Limite
	lds		r19, unit_addr				;load the unit in r19 
	lds		r17, th_addr				;load the high temp in r17 
	lds		r18, tl_addr				;load the low temp in r18
	PRINTF	LCD
	.db		"Th: ",FDEC|FSIGN,17,"  u:",FDEC,19,LF,"Tl: ",FDEC|FSIGN,18,0

	jmp		display_cursor

display_cursor:		
	; show in which sub menu we are: <
	ldi		w, 0x40
	ldi		a0, 0x0f
	sbrc	m, 4
	add		a0, w
	rcall	LCD_pos
	ldi		a0, 127
	rcall	LCD_putc
	jmp		main

; ==== Menu Jeu ====
jeu:
	PRINTF	LCD
	.db		"Ici y a un jeu",0
	jmp		main

; ==== Menu Musique ====
music_on_off:
	; print	a music note
	ldi		a0, 0x0f	;set the cursor position 
	rcall	LCD_pos		
	sbrs	m, 5		
	rjmp	print_off	

	ldi		a0,1		
	rcall	LCD_putc	
	jmp		main		

print_off:
	; print a reversed music note
	ldi		a0,2		
	rcall	LCD_putc
	jmp		main

music_choice:
	;print the music choice
	PRINTF	LCD
	.db		"Quelle musique ?",LF,0

	mov		w, m				;load the menu register in w
	andi	w, 0b11000000		;select the two highest bits of w with a mask

	cpi		w, 0b00000000		;music 1 correspond to 00
	breq	music1
	cpi		w, 0b01000000		;music 2 correspond to 01
	breq	music2
	cpi		w, 0b10000000		;music 3 correspond to 10
	breq	music3
	cpi		w, 0b11000000		;music 4 correspond to 11
	breq	music4

music1:	
	; print Für Elise
	PRINTF	LCD
	.db		"Fur Elise",0
	jmp		main

music2:
	; print Frêre Jacques
	PRINTF	LCD
	.db		"Frere Jacques",0
	jmp		main

music3:
	; print Clair de lune
	PRINTF	LCD
	.db		"Clair de lune",0
	jmp		main

music4:
	; print Alarme
	PRINTF	LCD
	.db		"Alarme",0
	jmp		main


note_music:
.db	0b00000100, 0b00000110, 0b00000101, 0b00000101, 0b00000100, 0b00011100, 0b00011100, 0b00000000

note_music_off:
.db 0b11111011, 0b11111001, 0b11111010, 0b11111010, 0b11111011, 0b11100011, 0b11100011, 0b11111111

store_custom_char: 
	lds		u, LCD_IR					; load the address LCD instruction reg in u
	JB1		u,7,store_custom_char		; print a music note if the 7th bit of u is 1
	
	ldi		r16, 0b01001000				
	sts		LCD_IR,r16					; store direct to SRAM at the address LCD instruction
	ldi		zl,low(2*note_music)
	ldi		zh,high(2*note_music)
	ldi		r18,8						; load 8 in r18
	rcall	store_lcd_loop

store_music_off_char:
	lds		u, LCD_IR					; load the address LCD instruction reg in u
	JB1		u,7,store_music_off_char	; print a reversed music note if the 7th bit of u is 1

	ldi		r16, 0b01010000
	sts		LCD_IR,r16					; store r16 direct to SRAM at the address LCD instruction
	ldi		zl,low(2*note_music_off)
	ldi		zh,high(2*note_music_off)
	ldi		r18,8						; load 8 in r18
	rcall	store_lcd_loop

	ret

store_lcd_loop: 
  	lds		u, LCD_IR					; load the value from LCD_IR in u 
	JB1		u,7,store_lcd_loop			; loop if the 7th bit of u is 1
	lpm									; load program memory
	mov		r16,r0
	adiw	zl,1						; add immediate to word
	sts		LCD_DR, r16					; store r16 direct to SRAM at the address LCD data register
	dec		r18							; decrement r18
	brne	store_lcd_loop				; loop if r18 not equal to 0 
	rcall	LCD_home	
	ret