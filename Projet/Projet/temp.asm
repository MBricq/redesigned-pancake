; file	wire1_temp2.asm		
; purpose Dallas 1-wire(R) temperature sensor interfacing: temperature
; module: M5, input port: PORTB
	
.include	"Libraries\math_speed.asm"
.include	"Libraries\lcd.asm"			; include LCD driver routines
.include	"Libraries\wire1.asm"		; include Dallas 1-wire(R) routines
.include	"Libraries\printf.asm"		; include formatted printing routines
.include	"macro_projet.asm"

; routine called to reset 1-wire
temp_reset:
	rcall	wire1_init				;init. 1-wire interface
	rcall	wire1_reset
	CA		wire1_write,recallE2	;recall the th and conf. from EEPROM

	rcall	load_t_eeprom

	OUTI	DDRB,0xff				; configure portB to output

	ret

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
	mov		c1,a1

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

	; moteur
	mov b0, a0
	mov b1, a1
	ldi b2, 20

recall_motor:
	mov a0, b0
	mov a1, b1
	P1	PORTB,SERVO1		; pin=4
loop_motor:
	SUBI2	a1,a0,0x1
	brne	loop_motor

	P0	PORTB,SERVO1	; pin=4
	WAIT_US	20000

	subi b2, 1
	brne recall_motor

	ret


save_t_eeprom:
	ldi xh, high(th_eep)
	ldi xl, low(th_eep)
	lds a0, th_addr
	rcall	eeprom_store

	ldi xh, high(tl_eep)
	ldi xl, low(tl_eep)
	lds a0, tl_addr
	rcall	eeprom_store

	sbrc m,2
	rjmp conv_to_c

	lds d0, th_addr
	lds d1, tl_addr

back_to_save:
	rcall	wire1_reset			; send a reset pulse
	CA		wire1_write, skipROM
	CA		wire1_write, writeScratchpad
	mov		a0,d0
	rcall 	wire1_write
	mov		a0,d1
	rcall 	wire1_write
	ldi		a0,0b01111111
	rcall 	wire1_write

	rcall	wire1_reset
	CA		wire1_write, skipROM
	CA		wire1_write, copyScratchpad
	ret
conv_to_c:
	lds a0, th_addr
	rcall fahr_to_c
	push a0
	lds a0, tl_addr
	rcall fahr_to_c
	mov d1,a0
	pop d0
	rjmp back_to_save

load_t_eeprom:
	ldi xh, high(th_eep)
	ldi xl, low(th_eep)
	rcall eeprom_load
	mov d0,a0
	ldi xh, high(tl_eep)
	ldi xl, low(tl_eep)
	rcall eeprom_load
	mov d1,a0

	sts th_addr, d0
	sts tl_addr, d1
	ret

; in a0
cel_to_f:
	bst		a0,7
	cpi		a0, 0
	brpl	mul_c_f

; a0 is negative, we take its absolute value
	com a0
	subi a0, (-1)

mul_c_f:
	ldi b0, 9
	rcall mul11
	mov a0,c0
	mov a1,c1
	ldi b0, 5
	clr b1
	rcall div22
	
	mov a0,c0
	brtc	add_c_f

; a0 is turned back into a negative number
	com a0
	subi a0, (-1)

add_c_f:
	subi a0, (-32) ; a0 : T in F
	ret

; in a0
fahr_to_c:
	subi a0, 32 

	bst		a0,7
	cpi		a0, 0
	brpl	mul_f_c

; a0 is negative, we take its absolute value
	com a0
	subi a0, (-1)

mul_f_c:
	ldi b0, 5
	rcall mul11
	mov a0,c0
	mov a1,c1
	ldi b0, 9
	clr b1
	rcall div22
	
	mov a0,c0
	brtc	end_f_c

; a0 is turned back into a negative number
	com a0
	subi a0, (-1)

end_f_c:
	ret