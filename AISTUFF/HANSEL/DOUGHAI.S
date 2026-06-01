
DOUGHNUT_KILL_BUBSY_EH	macro
	move.w	#$0901,d6				;see if BUBSY has bopped the KNIGHT
	move.w	#SPLATSOUND,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#SQUISHSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm

DOUGHNUT_SPEED		equ	7
DOUGHNUT_WALK		equ	12
DOUGHNUT_LOOK_AHEAD	equ	16
DOUGHNUT_MAX_FRAME	equ	8
START_DOUGHNUT_FRAME	equ	23

DOUGHNUTAI
	jsr	OBJRANGE
	bcc.s	.inx
	jmp	CLEAROBJWVRAM
.inx	jsr	CLIPY

	DOUGHNUT_KILL_BUBSY_EH

	subq.b	#1,OBJAUX0(a5)
	bpl	.nothing
	
	move.b	#DOUGHNUT_SPEED,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	
	move.b	#DOUGHNUT_MAX_FRAME-1,OBJFRAME(a5)
.no_wrap
	jsr	DRAW_COMPLEX_SPRITE
	
	move.w	OBJY(a5),d0						;set up y to check if we will walk over the dege
	add.w	#15,d0
	move.w	d0,d2
	sub.w	#30,d0
	move.w	d0,TEMP5						;set up for checking for floor
	
	moveq	#DOUGHNUT_LOOK_AHEAD,d1
	moveq	#DOUGHNUT_WALK,d6
	
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	bne.s	.WALKLEFT
	neg.w	d6
	neg.w	d1
.WALKLEFT
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB						;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP5,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB						;x+dx,y-5
	or.w	d0,d0
	bne.s	.use_this_one
	or.w	TEMP7,d0
.use_this_one
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL
	and	d0,d0							;0 then it must be nothing
	beq.s	.change_direction
	bra.s	.all_ok
.CHECKWALL								;check if we will hit a wall
	and.w	#WALL_CTRL,d7
	beq.s	.all_ok

.change_direction
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move
.all_ok
	add.w	d6,OBJX(a5)						;move the ANT by d6
.no_move
.DONETHIS
	jmp	STICKOBJECTTOPLAYFIELD
.nothing
	JMP	DRAW_COMPLEX_SPRITE



**************************************************************

doughnut_dma
	dc.l	.frame7
	dc.l	.frame6
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0

.frame0	dc.w	1,0,0,0
	dc.w	-28,-43,23
.frame1	dc.w	1,0,0,0
	dc.w	-25,-48,24
.frame2	dc.w	1,0,0,0
	dc.w	-25,-53,25
.frame3	dc.w	1,0,0,0
	dc.w	-25,-48,26
.frame4	dc.w	1,0,0,0
	dc.w	-27,-43,39
.frame5	dc.w	1,0,0,0
	dc.w	-25,-48,40
.frame6	dc.w	1,0,0,0
	dc.w	-25,-47,41
.frame7	dc.w	1,0,0,0
	dc.w	-28,-43,42
	
	
**************************************************************



DOUGHNUTMAP
	Soff	0,0,0,0,-20,5,-21,33,0,43,22,32,23,8
	Soff	0,0,0,0,-19,7,-19,38,0,47,18,37,19,10
	Soff	0,0,0,0,-19,7,-19,38,0,47,18,37,19,10
	Soff	0,0,0,0,-20,5,-21,33,0,43,22,32,23,8
	Soff	0,0,0,0,-19,7,-19,38,0,47,18,37,19,10
	Soff	0,0,0,0,-21,11,-21,42,0,53,19,41,21,14
	Soff	0,0,0,0,-19,7,-19,38,0,47,18,37,19,10
	Soff	0,0,0,0,-20,5,-21,33,0,43,22,32,23,8

