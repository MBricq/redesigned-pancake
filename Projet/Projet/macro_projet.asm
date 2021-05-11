
.macro		DIV22B
	bst		@1,7
	lsr		@1
	ror		@0
	bld		@1,7	
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

.macro 		ANGLEC			; in: registers @1:@0 which are a temperature in C, out: @1:@0 angle corresponding, mod: w, _w
	bst		@1, 7			;save msb sign
	mov		w, @0
	mov		_w, @1
	lsl		w				;mult by 2
	rol		_w		
	add		@0, w
	adc		@1, _w
	lsr		@1				;div by 2: (2*x+x)/2 = 1.5x
	ror		@0
	bld		@1, 7			;load back msb
	ldi		w, 0b11010000	;add 45 
	add		@0, w
	ldi		w, 0b10
	adc		@1, w
.endmacro	

.macro ANGLEF	; in: registers @1:@0 which are a temperature in C, out: @1:@0 angle corresponding, mod: w, _w
	ANGLEC	@0, @1
	COM2B	@0, @1
	subi	@0, 0b11000000
	ldi		w, 0b11
	sbc		@1, w
.endmacro

.macro CEL_TO_FAHR ; in @
	
.endmacro