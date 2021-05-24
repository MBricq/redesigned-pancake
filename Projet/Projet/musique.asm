; file musique.asm   target ATmega128L-4MHz-STK300
; purpose send frequency to the buzzer to produce a music 

.include	"Libraries/sound.asm"

;---- music score----

elise:
.db		mi3,rem3
.db		mi3,rem3,mi3,si2,re3,do3,		la2,mi,la,do2,mi2,la2
.db		si2,mi,som,mi2,som,si2,			do3,mi,la,mi2,mi3,rem3
.db		mi3,rem3,mi3,si2,re3,do3,		la2,mi,la,do2,mi2,la2
.db		si2,mi,som,re2,do3,si2,			la2,mi,la,si2,do3,re3

.db		mi3,so,do2,so2,fa3,mi3,			re3,so,si,fa2,mi3,re3
.db		do3,so,do2,so2,fa3,mi3,			si2,mi,mi2,mi2,mi3,mi2
.db		mi3,mi2,mi3,rem3,mi3,rem3,		mi3,rem3,mi3,rem3,mi3,rem3
.db		mi3,rem3,mi3,si2,re3,do3,		la2,mi,la,do2,mi2,la2
.db		si2,mi,som,mi2,som2,si,			do3,mi,la,mi2,mi3,rem3
.db		mi3,rem3,mi3,si2,re3,do3,		la2,mi,la,do2,mi2,la2
.db		si2,mi,som,re2,do3,si2,			la2,mi,la,si2,do3,re3
.db		soupir, soupir, 0

jacques:
.db		do3,re3,mi3,do3,soupir,do3,		re3,mi3,do3,soupir,mi3,fa3
.db		so3,so3,soupir,mi3,fa3,so3,		so3,soupir,so3,la3,so3,fa3,mi3,do3
.db		soupir,so3,la3,so3,fa3,mi3,		do3,soupir,do3,do3,so,so
.db		do3,do3,soupir,do3,do3,so,		so,do3,do3,soupir,soupir,0

clair:
.db		do2,do2,do2,re2,mi2,mi2,		re2,re2,do2,mi2,re2,re2
.db		do2,do2,do2,do2,soupir,			do2,do2,do2
.db		re2,mi2,mi2,re2,re2,do2,		mi2,re2,re2,do2,do2,do2
.db		do2,soupir,re2,re2,re2,re2,		la,la,la,la,re2,do2
.db		si,la,so,so,soupir,soupir,		do2,do2,do2,re2,mi2,mi2
.db		re2,re2,do2,mi2,re2,re2,		do2,do2,soupir,soupir,soupir,soupir, 0

alarme:
.db		do2, fa2, la2, la2, fa2, do2, 0


play:
	mov		w, m
	andi	w, 0b11000000

	cpi		w, 0b00000000
	breq	load_music1
	cpi		w, 0b01000000
	breq	load_music2
	cpi		w, 0b10000000
	breq	load_music3
	cpi		w, 0b11000000
	breq	load_music4

load_music1:
	ldi		zl, low(2*elise)
	ldi		zh, high(2*elise)
	rjmp play_loop

load_music2:
	ldi		zl, low(2*jacques)
	ldi		zh, high(2*jacques)
	rjmp play_loop

load_music3:
	ldi		zl, low(2*clair)
	ldi		zh, high(2*clair)
	rjmp play_loop

load_music4:
	ldi		zl, low(2*alarme)
	ldi		zh, high(2*alarme)
	rjmp play_loop

play_loop:
	lds		w, alarm_addr	; load the value indicating if the alarm needs to ring (in the 5th bit)
	sbrs	w, 5
	rjmp end

	lpm
	adiw	zl,1
	tst		r0
	breq	play
	mov		a0,r0

	ldi		b0,100
	cpi		a0, 1
	brne	PC+2
	ldi		b0, 25
	
	rcall	sound
	rjmp	play_loop

end:
	ldi		w, 0
	sts		alarm_addr, w
	ret
