; file remote.asm   target ATmega128L-4MHz-STK300
; purpose get the codes sent by the remote

.include "musique.asm"

.equ	T2 = 14906*(1+0.034)		; start timout, T2 = (14906 + (14906 * Terr2)) 
									;>with Terr2 = 3.4% observed with the oscilloscope
.equ	T1 = 1125*(1+0.040)			; bit period, T1 = (1125 + (1125 * Terr1)) with 
									;>Terr1 = 4% observed with the oscilloscope
.equ	PINIR = PINE							

; Init the remote 
remote_reset:
	cbi		DDRE,IR			; set IR as input
	sbi		DDRE,SPEAKER	; set buzzer as output
	ldi		w, 0
	sts		alarm_addr, w
	ret

; reads the remote signal from PINIR
; out : b0 the code pressed or 0 if there is an error or repeat
; mod : a0, a1, b1, b2, d0, d1, d3, u, w
read_remote:
	CLR2	b1,b0			; clear 2-byte register
	CLR2	a1,a0
	ldi		b2,16

	WAIT_US	T2				; wait for timeout
	clc						; clearing carry
	
addr: 
	P2C		PINIR,IR		; move Pin to Carry (P2C, 4 cycles)
	ROL2	b1,b0			; roll carry into 2-byte reg (ROL2, 2 cycles)
	sbrc	b0,0			; (branch not taken, 1 cycle; taken 2 cycles)
	rjmp	rdz_a			; (rjmp, 2 cycles)
	WAIT_US	(T1 - 2)
	DJNZ	b2,addr			; Decrement and Jump if Not Zero (true, 2 cycles; false, 1 cycle)
	jmp		next_a			; (jmp, 3 cycles)
rdz_a:						; read a zero
	WAIT_US	(2*T1 - 3)
	DJNZ	b2,addr			; Decrement and Jump if Not Zero

next_a: 
	MOV2	d1,d0, b1, b0	; store current address
	MOV2	a1,a0,b1,b0
	ldi		b2,16			; load bit-counter
	clc
	CLR2	b1,b0

data: 
	P2C		PINIR,IR		; PINE to carry	
	ROL2	b1,b0			; rotate left through carry
	sbrc	b0,0			; skip bit in reg clear
	rjmp	rdz_d			; if LSB from b0 = 0 go to rdz_d
	WAIT_US	(T1 - 2)		; wait a certain time
	DJNZ	b2,data			; decrement and jump if not zero
	jmp		next_b			; go to next_b
		
rdz_d:							
	WAIT_US	(2*T1 - 3)		; wait a certain time
	DJNZ	b2,data			; decrement and jump if not zero

next_b:
	MOV2	d3,d2,b1, b0	; store current command

 data_proc01:				; detect repeated code
	_CPI		d3, 0xff
	brne	data_proc02
	_CPI		d2, 0xff
	brne	data_proc02
	_CPI		d1, 0xff 
	brne	data_proc02
	_CPI		d0, 0xff
	brne	data_proc02 

code_repeat:
	ldi		b0, 0
	ret

data_proc02:				; detect transmission error
	com		d1
	cpse	d0, d1
	brne	code_error
	com		d3
	cpse	d2, d3
	brne	code_error
	
code_correct:			;bitwise complement
	com		b0
	ret						

code_error:
	ldi		b0, 0
	ret