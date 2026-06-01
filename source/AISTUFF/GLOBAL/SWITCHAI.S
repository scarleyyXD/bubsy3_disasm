SWITCHAI:
	jsr	DOINITIALDMA
	
	jsr	OBJRANGE
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY
	jsr	ENEMYCOLLIDE
	bcc.s	.NOCOLLIDE

	moveq	#OBJBOPPED,d0
	and.b	OBJFLAGS(a5),d0
	bne.s	.ANIMATE
	or.b	#OBJBOPPED,OBJFLAGS(a5)

	move.w	OBJAUX2(a5),d0
	bne.s	.ANIMATE
	addq.w	#1,OBJAUX2(a5)

	moveq	#CHINK,d0
	jsr	STARTSOUND
	bra.s	.ANIMATE

.NOCOLLIDE:							;we did not collide, check if we are far away enough to reset contact
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bpl.s	.CHECKDISTANCE
	neg.w	d0

.CHECKDISTANCE:
	cmpi.w	#48,d0
	bcs.s	.ANIMATE

	andi.b	#~OBJBOPPED,OBJFLAGS(a5)

.ANIMATE:
	move.w	OBJAUX2(a5),d0
	beq.s	.GETFRAME

	moveq	#3,d0
	and.w	STIMER,d0
	bne.s	.GETFRAME

	addq.w	#1,OBJAUX2(a5)

.GETFRAME:
	move.w	OBJAUX2(a5),d6

	move.b	.FRAMETABLE(pc,d6.w),d0
	bpl.s	.STOREFRAME
	
	clr.w	OBJAUX2(a5)					;we are done with animation reset and toggle switch flag
	move.b	OBJAUX0(a5),d0
	eor.b	d0,SWITCHES

.STOREFRAME:
	move.b	d0,OBJFRAME(a5)

.DRAWFRAME:
	moveq	#0,d1
	move.b	SWITCHES,d0
	and.b	OBJAUX0(a5),d0
	beq.s	.ok
	moveq	#1,d1
	
.ok:
	move.b	d1,OBJFRAME(a5)
	jmp	DRAW_COMPLEX_SPRITE

.FRAMETABLE:	dc.b	%00000000,%00000001,%00000001,%00000000,$FF
.FLIPTABLE:		dc.b	%00000000,%00000000,%00000000,%00001000
	even

switch_dma:	dc.l	.frame0
			dc.l	.frame1
	
.frame0:	dc.w	1,-12,-37+16,-1
			dc.w	0,0,175
	
.frame1:	dc.w	1,-12,-37+16,-1
			dc.w	0,0,176
		
SWITCHMAP:
	Soff	0,0,-12,-10,-12,-20,-12,-30,12,-10,12,-20,12,-30
	Soff	0,0,-12,-10,-12,-20,-12,-30,12,-10,12,-20,12,-30
	even