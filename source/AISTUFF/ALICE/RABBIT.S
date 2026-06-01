.macro	RABBIT_KILL_BUBSY
	move.w	#$0601,d6
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

RABBIT_WALK_SPEED	equ	5
RABBIT_WALK_FRAMES	equ	6
RABBIT_WALK_OFFSET	equ	10
RABBIT_WALK_DX		equ	4

RABBITAI:
	jsr	OBJRANGEBIG
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPY
	
	RABBIT_KILL_BUBSY

	tst.b	OBJFLAGS(a5)
	bne.s	.already_set_up

	add.w	#16,OBJY(a5)
	
	moveq	#0,d1
	move.w	OBJX(a5),d0
	sub.w	BUBX,d0
	bpl.s	.facing_right
	moveq	#8,d1

.facing_right:
	move.b	d1,OBJOAM0(A5)
	move.b	#~ANCHORFLAG,OBJFLAGS(a5)
	bra.s	.just_stick_and_draw

.already_set_up:
	subq.b	#1,OBJAUX0(a5)
	bpl	.no_change
	move.b	#RABBIT_WALK_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	move.b	#RABBIT_WALK_FRAMES-1,OBJAUX1(a5)

.no_wrap:
	moveq	#0,d6
	move.b	OBJAUX1(a5),d6
	move.b	d6,OBJFRAME(a5)
	move.b	.walk_offset(pc,d6.w),d6
	tst.b	d6
	beq.s	.just_stick_and_draw
	moveq	#RABBIT_WALK_OFFSET,d1
	add.w	d6,d1
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d1
	neg.w	d6

.going_right:
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
	add.w	d6,OBJX(A5)
	
.just_stick_and_draw:
	jsr	STICKOBJECTTOPLAYFIELD

.no_change:
	jmp	DRAW_COMPLEX_SPRITE

.turn_around:
	eor.b	#8,OBJOAM0(A5)
	jmp	DRAW_COMPLEX_SPRITE

.walk_offset:	dc.b	17,3,0,20,4,0
	even

rabbit_dma:
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0

.frame0:
	dc.w	1,0,0,0
	dc.w	-21,-51,124
.frame1:
	dc.w	1,0,0,0
	dc.w	-18,-54,125
.frame2:
	dc.w	1,0,0,0
	dc.w	-22,-57,126
.frame3:
	dc.w	1,0,0,0
	dc.w	-20,-53,127
.frame4:
	dc.w	1,0,0,0
	dc.w	-17,-51,128
.frame5:
	dc.w	1,0,0,0
	dc.w	-14,-49,129

RABBITMAP:
	Soff	15,0,0,0,34,6,18,12,28,21,26,33,19,40		;5
	Soff	15,4,0,0,24,-6,16,13,27,18,25,30,16,41		;4
	Soff	17,0,0,0,35,4,25,14,15,17,28,28,27,47		;3
	Soff	17,0,0,0,10,19,18,25,10,32,18,36,15,49		;2
	Soff	17,6,0,0,26,-6,20,11,31,17,22,24,27,41		;1
	Soff	17,0,0,0,36,6,20,14,30,20,29,32,21,40		;0