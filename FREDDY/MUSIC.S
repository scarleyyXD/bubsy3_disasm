LOAD_MUSIC2: 	jsr	FADEDOWN
	moveq	#70,d0
	jsr	wait_some_vbls
	jsr	STOP_MOD
	jsr	wait_a_vbl
	
	moveq	#1,d1
	move.w	#$bf,d0
	jsr	SET_VOLU
	moveq	#0,d1
	move.w	#$bf,d0
	jsr	SET_VOLU
	
	jsr	PT_MOD_INIT		;setup song and player
	tst.b	musictoggle
	bne.s	.dont_start
	jsr	START_MOD	
.dont_start:	
.exit:	st	musloaded
	rts

musictoggle:	equ	mustype
	even