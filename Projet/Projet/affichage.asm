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
	jmp		main

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
	ldi		a0, '<'
	rcall	LCD_putc
	jmp		main

; ==== Menu Jeu ====
jeu:
	PRINTF LCD
	.db		"Ici y a un jeu",0
	jmp		main

; ==== Menu Musique ====
music_choice:
	PRINTF LCD
	.db		"Quelle musique ?",0
	jmp		main