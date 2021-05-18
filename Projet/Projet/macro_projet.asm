
.macro		DIV22B
	bst		@1,7
	lsr		@1
	ror		@0
	bld		@1,7	
.endmacro

.macro		MUL22B
	lsl		@0
	rol		@1
.endmacro

.macro		COM2B
	ldi		w, 0xff
	eor		@0, w
	eor		@1, w
	ldi		w, 1
	add		@0, w
	clr		w
	adc		@1, w
.endmacro

.macro CHECK_MENU_LIMIT	
	mov		w, m			;load m in w
	andi	w, 0b00001011	;use a mask to keep only the bits 0,1,3
	cpi		w, 0b00001000	;see if we are in the the correct sub menu
	breq	PC+2			
	jmp		affichage		;we are in the wrong sub menu
.endmacro