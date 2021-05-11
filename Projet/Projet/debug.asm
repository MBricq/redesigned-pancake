.include	"Libraries\macros.asm"		; include macro definitions
.include	"Libraries\definitions.asm"	; include register/constant definitions
.include	"macro_projet.asm"

.org	0
	rjmp	reset

.equ	max_speed = 2000			

.equ	eep_addr = 0x0000

reset:
	LDSP RAMEND
	rcall	LCD_init	; initialize LCD
	OUTI	DDRD,0x00

	ldi xh, high(eep_addr)
	ldi xl, low(eep_addr)
	rcall eeprom_load
	mov b0,a0


	rjmp main

.include "Libraries\lcd.asm"
.include "Libraries\printf.asm"
.include "Libraries\eeprom.asm"

main:
	rcall LCD_home
	PRINTF LCD
	.db FDEC,b,"     ",0

	in w, PIND
	com w
	cpi w, 0
	breq main

	mov b0, w
	ldi xh, high(eep_addr)
	ldi xl, low(eep_addr)
	mov a0,b0
	rcall	eeprom_store

	rjmp	main