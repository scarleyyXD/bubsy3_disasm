FLAMINGO_KILL_BUBSY	macro
	move.w	#$0601,d6
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm


FLAMINGO_WALK_SPEED	equ	7
FLAMINGO_WALK_FRAMES	equ	6
FLAMINGO_WALK_OFFSET	equ	-30
FLAMINGO_WALK_DX	equ	4

FLAMINGOAI
	jsr	OBJRANGEBIG
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM
.inrange
	jsr	CLIPY
	
	FLAMINGO_KILL_BUBSY

	tst.b	OBJFLAGS(a5)
	bne.s	.already_set_up
	

	add.w	#16,OBJY(a5)
	moveq	#0,d1
	move.w	OBJX(a5),d0
	sub.w	BUBX,d0
	bpl.s	.facing_right
	moveq	#8,d1
.facing_right
	move.b	d1,OBJOAM0(A5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.b	#~ANCHORFLAG,OBJFLAGS(a5)
	jmp	DRAW_COMPLEX_SPRITE

.already_set_up
	subq.b	#1,OBJAUX0(a5)
	bpl	.no_change
	move.b	#FLAMINGO_WALK_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	move.b	#FLAMINGO_WALK_FRAMES-1,OBJAUX1(a5)
.no_wrap
	moveq	#0,d6
	move.b	OBJAUX1(a5),d6
	move.b	d6,OBJFRAME(a5)
	move.b	.walkoffset(pc,d6.w),d6
	moveq	#FLAMINGO_WALK_OFFSET,d1
	add.w	d6,d1
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d1
	neg.w	d6
.going_right
	move.w	d1,TEMP5
	add.w	OBJX(a5),d1
	moveq	#-8,d2
	add.w	OBJY(a5),d2
	jsr	GETATTRIB
	move.w	d0,d7			;asve the attribute
	
	move.w	TEMP5,d1
	add.w	OBJX(a5),d1
	moveq	#8,d2
	add.w	OBJY(a5),d2
	jsr	GETATTRIB
	or.w	d7,d0
	beq.s	.turn_around
	and.w	#~ATTR_WHAT,d0
	bne.s	.turn_around
	sub.w	d6,OBJX(A5)
	
	jsr	STICKOBJECTTOPLAYFIELD
.no_change
	jmp	DRAW_COMPLEX_SPRITE

.turn_around
	eor.b	#8,OBJOAM0(A5)
	jmp	DRAW_COMPLEX_SPRITE
.walkoffset
	dc.w	$0D,$0A,$0C,$0C,$0B,$0B 	
	
	even


flamingo_dma
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0

.frame0	dc.w	2,0,1,0
	dc.w	$FFD9,$FFAC,$0014
	dc.w	$FFE3,$FFCB,$0015

.frame1	dc.w	2,0,1,0
	dc.w	$FFD4,$FFB0,$0016
	dc.w	$FFE3,$FFCE,$0017

.frame2	dc.w	2,0,1,0
	dc.w	$FFD3,$FFAE,$0018
	dc.w	$FFE3,$FFCD,$0019


.frame3	dc.w	2,0,1,0
	dc.w	$FFD9,$FFAE,$001A
	dc.w	$FFE3,$FFCC,$001B


.frame4	dc.w	2,0,1,0
	dc.w	$FFD4,$FFB0,$001C
	dc.w	$FFE3,$FFCE,$001d


.frame5	dc.w	2,0,1,0
	dc.w	$FFD4-1,$FFAE+1,$001E
	dc.w	$FFE3,$FFCD,$001F


FLAMINGOMAP
	rept	6
	Soff	8,0,-22,3,21,8,27,45,5,45,-18,50,-22,77
	endr
