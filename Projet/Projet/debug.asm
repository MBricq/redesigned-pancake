; file	wire1_temp2.asm		
; purpose Dallas 1-wire(R) temperature sensor interfacing: temperature
; module: M5, input port: PORTB

.org 0
	jmp temp_reset

.include	"Libraries\macros.asm"		; include macro definitions
.include	"Libraries\definitions.asm"	; include register/constant definitions
.include	"Libraries\math_speed.asm"
.include	"Libraries\lcd.asm"			; include LCD driver routines
.include	"Libraries\wire1.asm"		; include Dallas 1-wire(R) routines
.include	"Libraries\printf.asm"		; include formatted printing routines
.include	"moteur.asm"	

; routine called to reset 1-wire<
temp_reset:
	LDSP RAMEND
	rcall LCD_init


	rcall	wire1_init				;init. 1-wire interface
	rcall	wire1_reset
	CA		wire1_write,recallE2	;recall the th and conf. from EEPROM

	ldi		a0,0
	ldi		a1,0
	sts		0x1070, a0
	sts		0x1072, a1

	rcall	motor_reset

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

	ANGLEC	a0,a1
	mov		c0, a0
	mov		c1, a1

	lds		b0, 0x1070
	lds		b1, 0x1072

	rcall LCD_home
	rcall LCD_clear
	PRINTF LCD
	.db FFRAC2+FSIGN,a,4,$42,FFRAC2+FSIGN,b,4,$42,CR,0

	sub		a0, b0
	sbc		a1, b1
	
	rcall turn_moteur

	;rcall	wire1_reset
	;CA		wire1_write, skipROM
	;CA		wire1_write,alarmSearch
	;rcall	wire1_read	
	;mov		r16, a0
	;out		PORTB,r16

	WAIT_MS 1000
	rjmp update_temp
