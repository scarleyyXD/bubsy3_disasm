ANT_RUN_SPEED	equ	5

ANT_KILL_BUBSY_EH	macro
	move.w	#$0901,d6				;see if BUBSY has bopped the ANT
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm


ANTAI
	jsr	OBJRANGEBIG						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPY
	ANT_KILL_BUBSY_EH

	moveq	#0,d0							;move the ANT first of all
	move.b	OBJAUX3(a5),d0
	addq.b	#1,d0
	cmp.b	#ANT_RUN_SPEED,d0
	beq.s	.INCREMENT
	move.b	d0,OBJAUX3(a5)
	bra	.NOINCREMENT


.walk_offset
	dc.b	14,7,4,16,7,3
	
.INCREMENT
	move.w	OBJY(a5),d0						;set up y to check if we will walk over the dege
	add.w	#8,d0
	move.w	d0,d2
	sub.w	#16,d0
	move.w	d0,TEMP5						;set up for checking for floor

	moveq	#0,d1
	move.b	.walk_offset(pc,d1.w),d1
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	beq.s	.WALKLEFT
	neg.w	d1
.WALKLEFT
	move.w	d1,d6
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB						;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP6,d1
	move.w	TEMP5,d2
	jsr	GETATTRIB						;x+dx,y-5
	or.w	TEMP7,d0
	tst.w	d0
	beq.s	.change_direction
.use_this_one
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	beq.s	.all_ok
.CHECKWALL
	and.w	#~ATTR_MASK,d7						;see if any control is on this block
	beq.s	.all_ok
.change_direction
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move
.all_ok
	add.w	d6,OBJX(a5)						;move the ANT by d6
.no_move
.DONETHIS
	moveq	#0,d0
	move.b	OBJFRAME(a5),d0
	addq.b	#1,d0
	cmp.b	#6,d0
	bne.s	.no_wrap
	moveq	#0,d0
.no_wrap	
	move.b	d0,OBJFRAME(a5)						;pointer to frame number
	sf	OBJAUX3(a5)
	jsr	STICKOBJECTTOPLAYFIELD
.NOINCREMENT
	bra	DRAW_COMPLEX_SPRITE


ant_dma	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0

.frame0	dc.w	2,0,0,0
	dc.w	-24-1+3,-1-27,17
	dc.w	0,-$2d,18

.frame1	dc.w	2,0,0,0
	dc.w	-24-1+5,0-27,17
	dc.w	0,-$2c,19

.frame2	dc.w	2,0,0,0
	dc.w	-24-1+7,0-27,17
	dc.w	0,-$2c,20

.frame3	dc.w	2,0,0,0
	dc.w	-24-1+3,0-27,17
	dc.w	0,-$2e,21

.frame4	dc.w	2,0,0,0
	dc.w	-24-1+5,0-27,17
	dc.w	0,-$2c,22

.frame5	dc.w	2,0,0,0
	dc.w	-24-1+8,0-27,17
	dc.w	0,-$2c,23

ANTMAP	
	rept	6
	Soff	22,18,0,0,11,9,33,1,40,25,43,-18,60,12
	endr