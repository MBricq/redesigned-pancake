; file affichage.asm   target ATmega128L-4MHz-STK300
; purpose display on the LCD screen the correct menu


; ====	Display Routine ====

affichage:
	rcall	LCD_clear
	rcall	LCD_home

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
	; affiche music
	sbrc	m,3
	rjmp	music_choice

	PRINTF	LCD
	.db		"Music",0
	rjmp music_on_off
	

menu_jeu:			
	; affiche jeu
	sbrc	m,3
	rjmp	jeu
	
	PRINTF	LCD
	.db		"Jeu",0
	jmp		main

menu_set_temp:		
	; affiche temp lim
	sbrc	m,3
	rjmp	print_limit

	PRINTF LCD
	.db		"Temperatures",LF,"limites",0
	jmp		main

menu_temp:			
	; affiche temp	
	sbrc	m,3
	rjmp	degre

	PRINTF LCD
	.db		"Temperature",0
	jmp		main

; ==== Menu Choix Unite Temperature ====
degre:
	PRINTF	LCD
	.db		"Degre :",LF,0

	sbrc	m,2
	rjmp	print_f

print_c:			
	; affiche Celsius
	PRINTF	LCD
	.db		"Celsius",0
	rjmp	main

print_f:			
	; affiche Fahrenheit
	PRINTF	LCD
	.db		"Fahrenheit",0
	rjmp	main


; ==== Menu Limite Temperature ====
print_limit:		;affiche Limite
	lds		r19, unit_addr
	lds		r17, th_addr
	lds		r18, tl_addr
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
	PRINTF LCD
	.db		"Ici y a un jeu",0
	jmp		main

; ==== Menu Musique ====
music_on_off:
	ldi		a0, 0x0f
	rcall	LCD_pos
	sbrs	m, 5
	rjmp	print_off

	ldi		a0,1
	rcall	LCD_putc
	jmp		main

print_off:
	ldi		a0,2
	rcall	LCD_putc
	jmp		main

music_choice:
	PRINTF	LCD
	.db		"Quelle musique ?",LF,0

	mov		w, m
	andi	w, 0b11000000

	cpi		w, 0b00000000
	breq	music1
	cpi		w, 0b01000000
	breq	music2
	cpi		w, 0b10000000
	breq	music3
	cpi		w, 0b11000000
	breq	music4

music1:
	PRINTF	LCD
	.db		"Fur Elise",0
	jmp		main

music2:
	PRINTF	LCD
	.db		"Frere Jacques",0
	jmp		main

music3:
	PRINTF	LCD
	.db		"Au clair de la lune",0
	jmp		main

music4:
	PRINTF	LCD
	.db		"Alarme",0
	jmp		main


note_music:
.db 0b00000100, 0b00000110, 0b00000101, 0b00000101, 0b00000100, 0b00011100, 0b00011100, 0b00000000

note_music_off:
.db 0b11111011, 0b11111001, 0b11111010, 0b11111010, 0b11111011, 0b11100011, 0b11100011, 0b11111111

store_custom_char: 
	lds		u, LCD_IR	
	JB1		u,7,store_custom_char	
	
	ldi		r16, 0b01001000
	sts		LCD_IR,r16
	ldi		zl,low(2*note_music)
	ldi		zh,high(2*note_music)
	ldi		r18,8
	rcall	store_lcd_loop

store_music_off_char:
	lds		u, LCD_IR	
	JB1		u,7,store_music_off_char

	ldi		r16, 0b01010000
	sts		LCD_IR,r16
	ldi		zl,low(2*note_music_off)
	ldi		zh,high(2*note_music_off)
	ldi		r18,8
	rcall	store_lcd_loop

	ret

store_lcd_loop: 
  	lds		u, LCD_IR	
	JB1		u,7,store_lcd_loop	
	lpm
	mov		r16,r0
	adiw	zl,1
	sts		LCD_DR, r16
	dec		r18
	brne	store_lcd_loop
	rcall	LCD_home	
	ret