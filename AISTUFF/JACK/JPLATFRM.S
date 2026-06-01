;platform which moves when BUbsy is on it only..


JPLAT_FRAME		equ	86

JPLATFORMAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPY				; in range y
	
	jsr	OBJECTISLAND
	
	
	
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.not_on_me
	
	move.w	OBJAUX0(a5),d2
	ext.l	d2
	asl.l	#8,d2
	add.l	d2,BUBX
	add.l	d2,OBJX(a5)
	
	
	
	move.w	OBJAUX2(a5),d1
	ext.l	d1
	asl.l	#8,d1
	sub.l	d1,OBJY(a5)
.not_on_me
	jmp	DRAW_COMPLEX_SPRITE
	
	
jplatform_dma
	dc.l	.frame0
	
.frame0	dc.w	1,0,0,-1
	dc.w	-16,0,JPLAT_FRAME
	
JPLATFORMMAP
	dc.w	0,0
	dc.l	0
	dc.w	15,31
	dc.w	4,4
	rept	4
	dc.w	0,0
	endr




