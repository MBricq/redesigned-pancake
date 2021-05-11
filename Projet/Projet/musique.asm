
.include	"macros.asm"	
.include	"definitions.asm"

reset:
		LDSP	RAMEND
		sbi		DDRE,SPEAKER
		rjmp	main

.include	"sound.asm"

;---- music score----

elise:
.db		mi3,rem3
.db		mi3,rem3,mi3,si2,re3,do3,   la2,mi,la,do2,mi2,la2
.db		si2,mi,som,mi2,som,si2,     do3,mi,la,mi2,mi3,rem3
.db		mi3,rem3,mi3,si2,re3,do3,   la2,mi,la,do2,mi2,la2
.db		si2,mi,som,re2,do3,si2,		la2,mi,la,si2,do3,re3

.db		mi3,so,do2,so2,fa3,mi3,		re3,so,si,fa2,mi3,re3
.db		do3,so,do2,so2,fa3,mi3,		si2,mi,mi2,mi2,mi3,mi2
.db		mi3,mi2,mi3,rem3,mi3,rem3,	mi3,rem3,mi3,rem3,mi3,rem3,
.db		mi3,rem3,mi3,si2,re3,do3,	la2,mi,la,do2,mi2,la2,
.db		si2,mi,som,mi2,som2,si,		do3,mi,lami2,mi3,rem3,
.db		mi3,rem3,mi3,si2,re3,do3,	la2,mi,la,do2,mi2,la2,
.db		si2,mi,som,re2,do3,si2,		la2,mi,la,si2,do3,re3,
.db		0 ; 

main:	
	ldi		zl, low(2*elise)
	ldi		zh, high(2*elise)
play:
	lpm
	adiw	zl,1
	tst		r0
	breq	end
	mov		a0,r0
	ldi		b0,100
	rcall	sound
	rjmp	play
end:
	rjmp	end
