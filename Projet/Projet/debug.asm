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
	rjmp update_temp

; routine used to update temperature
update_temp:
	nop	
	com w

	rjmp update_temp
