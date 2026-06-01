GINGERHEAD_KILL_BUBSY	macro
	move.w	#$0901,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm


GINGERHEAD_SPEED	equ	6
GINGERHEAD_FRAMES	equ	8

GINGERHEADAI
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE
	JSR	CLIPY
	
	GINGERHEAD_KILL_BUBSY

	tst.b	OBJFLAGS(A5)
	bne.s	.ground_found
	
	move.w	OBJY(a5),OBJAUX6(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	OBJY(a5),d0
	move.w	d0,OBJAUX4(a5)
	sub.w	OBJAUX6(a5),d0
	move.w	d0,OBJAUX6(a5)
	st	OBJFLAGS(a5)
	
.ground_found	
	
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.no_change
	move.b	#GINGERHEAD_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	move.b	#GINGERHEAD_FRAMES-1,OBJFRAME(a5)
.no_wrap
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	add.b	OBJAUX2(a5),d0
	and.w	#127,d0
	move.b	d0,OBJAUX2(a5)
	jsr	GETSIN				;d0 == 0 -> 512 ( 0 to 180 degrees - horizontal )
	muls.w	OBJAUX6(a5),d0
	asr.l	#8,d0
	neg.w	d0
	add.w	OBJAUX4(a5),d0
	move.w	d0,OBJY(a5)
.no_change
	jmp DRAW_COMPLEX_SPRITE
	
	
GINGERHEADMAP
	rept	GINGERHEAD_FRAMES
	Soff	0,0,-10,4,-16,16,-10,28,10,4,16,16,10,28
	endr


gingerhead_dma
	dc.l	.frame7
	dc.l	.frame6
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0


.frame0	dc.w	1,0,0,-1
	dc.w	-16,-31,31
.frame1	dc.w	1,0,0,-1
	dc.w	-16,-31,32
.frame2	dc.w	1,0,0,-1
	dc.w	-16,-31,33
.frame3	dc.w	1,0,0,-1
	dc.w	-16,-31,34
.frame4	dc.w	1,0,0,-1
	dc.w	-16,-31,35
.frame5	dc.w	1,0,0,-1
	dc.w	-16,-31,36
.frame6	dc.w	1,0,0,-1
	dc.w	-16,-31,37
.frame7	dc.w	1,0,0,-1
	dc.w	-16,-31,38


