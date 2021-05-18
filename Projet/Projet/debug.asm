; file	wire1_temp2.asm		
; purpose Dallas 1-wire(R) temperature sensor interfacing: temperature
; module: M5, input port: PORTB

.org 0
	jmp temp_reset

.include	"Libraries\macros.asm"		; include macro definitions
.include	"macro_projet.asm"
.include	"Libraries\definitions.asm"	; include register/constant definitions
.include	"Libraries\lcd.asm"			; include LCD driver routines
.include	"Libraries\wire1.asm"		; include Dallas 1-wire(R) routines
.include	"Libraries\printf.asm"		; include formatted printing routines	

; routine called to reset 1-wire<
temp_reset:
	LDSP RAMEND
	rcall LCD_init

	rcall	wire1_init				;init. 1-wire interface
	rcall	wire1_reset
	CA		wire1_write,recallE2	;recall the th and conf. from EEPROM

	OUTI	DDRB,0xff				; configure portB to output

	rjmp update_temp

; routine used to update temperature
update_temp:

	rcall	wire1_reset				; send a reset pulse
	CA		wire1_write, skipROM	; skip ROM identification
	CA		wire1_write, convertT	; initiate temp conversion
	WAIT_MS	750						; wait 750 msec
	
	rcall	wire1_reset				; send a reset pulse
	CA		wire1_write, skipROM
	CA		wire1_write, readScratchpad	
	rcall	wire1_read				; read temperature LSB
	mov		c0,a0
	rcall	wire1_read				; read temperature MSB
	mov		a1,a0
	mov		a0,c0

	rcall LCD_home
	PRINTF LCD
	.db "temp=",FFRAC2+FSIGN,a,4,$42,"     ",LF,0

	mov c1,a1

	ldi b0, 24
add_loop:
	add a0, c0
	adc a1, c1
	subi b0, 1
	brne add_loop

	DIV22B a0, a1

	DIV22B a0, a1
	DIV22B a0, a1
	DIV22B a0, a1
	DIV22B a0, a1

	ldi w, low(1375)
	ldi _w, high(1375)
	add a0, w
	adc a1, _w

	PRINTF	LCD				; print formatted
	.db	"pulse=",FDEC2,a,"usec    ",CR,0

	; moteur
	P1	PORTB,SERVO1		; pin=4
loop_motor:
	SUBI2	a1,a0,0x1
	brne	loop_motor
	P0	PORTB,SERVO1	; pin=4
	WAIT_US	20000

	rjmp update_temp
