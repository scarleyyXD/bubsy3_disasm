
musicoff:
	jsr	FADEDOWN
	moveq	#127,d0
	jsr	waitvbls
	jsr	STOP_MOD
	sf	musloaded
	rts

DISABLETIMER:
*	bclr	#TIMERINTBIT,intmask
	sf	mus
	rts

mus:	dcb.w	1,0


ENABLETIMER:
*	bset	#TIMERINTBIT,intmask
	st	mus
	rts

LOAD_MUSIC:
	cmp.l	last_music_loaded,a0
	bne.s	.load_it_in
	rts
.load_it_in:
	move.l	a0,last_music_loaded
	
	
	jsr	FADEDOWN
	moveq	#70,d0
	jsr	waitvbls
	jsr	STOP_MOD
	jsr	waitvbl
	
	
	sf	musloaded
	
	move.l	last_music_loaded,a0	;filename
	lea	mod_load_addr,a1	;addr to load
	jsr	file_load		;load the file
	
	lea	mod_load_addr,a0	;addr to load
	jsr	PT_MOD_INIT		;setup song and player

.turned_off:
.exit:	st	musloaded
	rts
	bra.s	.exit
musloaded:	dc.b	0
	even
last_music_loaded:	dc.l	0
