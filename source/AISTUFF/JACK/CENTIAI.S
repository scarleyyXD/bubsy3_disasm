CENTI_SCORE_1	equ	1
CENTI_SCORE_2	equ	6

CENTI_SCORE_X_OFFSET	equ	-16
CENTI_SCORE_Y_OFFSET	equ	-10

;The centipede moves in a direction - like the guard and is made up of segments

centi_body_score		equ	$100
centi_head_score		equ	$600

CENTI_ANIM_SPEED		equ	6
CENTI_RUN_SPEED			equ	15
CENTI_DIST_SPEED		equ	8
CENTI_EXPLODE_FRAMES	equ	5
CENTI_EXPLODE_SPEED		equ	10
JCENTI_EXPLODE_FRAME	equ	87

CENTIAI:
	jsr	OBJRANGEBIG						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY

	move.w	OBJX(a5),TEMP3
	move.w	OBJY(a5),TEMP2	;copy the x and y for the moment
	move.w	OBJOAM0(a5),TEMP1
		
	sf	OBJAUX6(a5)
	move.b	OBJAUX4(a5),OBJAUX5(a5)
	
.main_loop:
	jsr	STICKOBJECTTOPLAYFIELD
	tst.b	OBJAUX3(A5)
	bne.s	.cont
	tst.b	OBJAUX6(a5)
	bne.s	.cont
	cmp.b	#1,OBJAUX5(a5)
	beq.s	.the_head_kill
	bsr	.CENT_BODY_KILL
	bra.s	.cont
.the_head_kill:
	bsr	.CENT_HEAD_KILL
	
.cont:
	tst.b	OBJAUX3(a5)
	beq.s	.nocount
	subq.b	#1,OBJAUX3(A5)

.nocount:
	sf	OBJAUX7(a5)
	moveq	#CENTI_RUN_SPEED,d1
	moveq	#CENTI_RUN_SPEED,d6
	bsr	.walk
	subq.b	#1,OBJAUX5(a5)
	bne.s	.main_loop

	move.w	TEMP1,OBJOAM0(a5)
	move.w	TEMP2,OBJY(a5)
	move.w	TEMP3,OBJX(a5)
	
	subq.b	#1,OBJAUX2(a5)
	bpl.s	.old_frame
	
	st	OBJAUX7(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	moveq	#CENTI_DIST_SPEED,d1
	moveq	#CENTI_DIST_SPEED,d6
	bsr	.walk

	move.b	#CENTI_ANIM_SPEED,OBJAUX2(a5)
	
	move.b	OBJFRAME(a5),d0
	addq.b	#1,d0
	and.b	#3,d0
	move.b	d0,OBJFRAME(a5)						;pointer to frame number

.old_frame:
	rts

.walk:
	move.w	d1,-(sp)
	move.w	d6,-(sp)
.NOINCREMENT:
	tst.b	OBJAUX7(a5)
	bne.s	.INCREMENT
.okdraw:
	cmp.b	#1,OBJAUX5(a5)					;offset to the index number
	bne.s	.body
	addq.b	#4,OBJFRAME(a5)
	jsr	DRAW_COMPLEX_SPRITE
	subq.b	#4,OBJFRAME(a5)
	bra.s	.INCREMENT
.body:
	jsr	DRAW_COMPLEX_SPRITE

.INCREMENT:
	move.w	(sp)+,d6
	move.w	(sp)+,d1

	moveq	#-7,d2
	add.w	OBJY(a5),d2						;set up y to check if we will walk over the edge
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	beq.s	.WALKRIGHT
	neg.w	d1
	neg.w	d6
.WALKRIGHT:
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP4
	jsr	GETATTRIB						;x+dx,y-5
	tst.w	d0
	bne.s	.use_this_one
	move.w	TEMP4,d1
	moveq	#7,d2
	add.w	OBJY(a5),d2						;set up y to check if we will walk over the dege
	jsr	GETATTRIB						;x+dx,y-5
	tst.w	d0
	beq.s	.change_direction
.use_this_one:
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL

	and.w	d0,d0							;0 then it must be nothing
	bne.s	.all_ok
	bra.s	.change_direction

.CHECKWALL:
	and.w	#~ATTR_MASK,d7						;see if any control is on this block
	beq.s	.all_ok
.change_direction:
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move
.all_ok:
	add.w	d6,OBJX(a5)						;move the ANT by d6
.no_move:
.DONETHIS:
	rts

.CENT_BODY_KILL:
	moveq	#0,d0
	jsr	NOBOPCOLLIDE					;has BUBSY hit this area
	bcc	.no_detection
	
	st	OBJAUX6(a5)
	btst	#bANCHORFLAG,BUBSYFLAGS				;check if we are on the ground
	bne.s	.centi_ground_contact_body

	move.w	BUBVY,d0					;and is he moving up screen
	bpl.s	.falling_down_screen
	
.centi_ground_contact_body:
	moveq	#POPSTATE,d0
	jmp	KILLBUBSY

.falling_down_screen:	
	move.w	#$F800,BUBVY
	subq.b	#1,OBJAUX4(a5)					;reduce length by 1 as it is the it is not killed as head exists

	lea	Centiscore1,a4
	bsr	add_to_score
	
	moveq	#CENTI_SCORE_1,d5
	bsr	ADD_CENTI_SCORE
	
	move.l	a5,a6
	
	move.w	#$7fff,d6
	jsr	FINDFIRSTFREEOBJ
	bcs.s	.no_puff
	
	move.w	OBJX(A6),OBJX(a5)
	move.w	OBJY(A6),OBJY(a5)
	move.w	d6,OBJKEY(a5)
	move.l	#CENTI_EXPLODEAI,OBJAI(A5)
	move.l	#jcenti_explode_dma,OBJINITDMA(a5)
	move.l	#CENTI_EXPLODE_MAP,OBJMAP(a5)	
	sf	OBJAUX0(a5)
	st	OBJFRAME(a5)

.no_puff:
	move.l	a6,a5

	moveq	#0,d1
	move.b	OBJAUX5(a5),d1
	beq.s	.no_new_body
	move.b	OBJAUX4(a5),d0				;whats left = length - todo
	sub.b	d1,d0
	beq.s	.no_new_body
	bmi.s	.no_new_body
	
	move.b	d0,TEMP7
	move.l	a5,a6
	move.w	#$7fff,d6
	jsr	FINDFIRSTFREEOBJ
	bcs	.no_free_space
	
	move.w	OBJX(a6),OBJX(A5)
	move.w	OBJY(a6),OBJY(A5)
	move.b	OBJAUX5(a6),OBJAUX4(a5)				;copy length of cenipede
	move.w	d6,OBJKEY(a5)
	move.l	OBJINITDMA(a6),OBJINITDMA(a5)
	move.l	OBJMAP(a6),OBJMAP(a5)
	move.l	OBJAI(a6),OBJAI(a5)
	move.b	TEMP7,d0
	move.b	d0,OBJAUX4(a5)
	sub.b	d0,OBJAUX4(a6)
	sf	OBJAUX2(A5)
	sf	OBJFRAME(A5)
	move.b	OBJOAM0(a6),d0
	eor.b	#8,d0
	move.b	d0,OBJOAM0(a5)					;change the direction
	
.no_free_space:
	move.l	a6,a5

.no_new_body:
.no_detection:
	rts

.CENT_HEAD_KILL:
	moveq	#0,d0
	jsr	NOBOPCOLLIDE					;has BUBSY hit this area
	bcc.w	.no_head_detection	;bcc.s->bcc.w
	
	btst	#bANCHORFLAG,BUBSYFLAGS				;check if we are on the ground
	bne.s	.centi_ground_contact_head

	move.w	BUBVY,d0					;and is he moving up screen
	bpl.s	.head_falling_down_screen

.centi_ground_contact_head:
	moveq	#POPSTATE,d0
	jmp	KILLBUBSY

.head_falling_down_screen:
	lea	Centiscore2,a4
	bsr	add_to_score
	
	move.w	#$F800,BUBVY
	move.b	#1,OBJAUX5(a5)
	
	MOVE.w	OBJKEY(A5),D0
	JSR	OBJENINDEX
	LEA	OBJENFLAGS,A0
	OR.B	D0,(A0,D6.W)					;kill object

	move.w	TEMP2,OBJY(a5)					;reset the REAL posiotion of the centipede
	move.w	TEMP3,OBJX(a5)
	move.l	#CENTI_EXPLODE_MULTI_AI,OBJAI(A5)		;next time around go into exploding frames
	move.l	#jcenti_explode_dma,OBJINITDMA(a5)		;just graphics
	move.l	#CENTI_EXPLODE_MAP,OBJMAP(a5)			;better have a map for the detection routines
	sf	OBJAUX0(a5)
	st	OBJFRAME(A5)

	moveq	#CENTI_SCORE_2,d5
	bsr	ADD_CENTI_SCORE
	
	lea	4(sp),sp					;return to sender ..
	
.no_head_detection:
	rts

add_to_score:
	lea	SCORE+4,a0					;give bubsy 500 points
	addq	#4,a4						;point past the score
	and	#~FlagX,ccr
	abcd	-(a4),-(a0)
	abcd	-(a4),-(a0)
	abcd	-(a4),-(a0)
	abcd	-(a4),-(a0)
	rts	

CENTI_EXPLODEAI:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#CENTI_EXPLODE_SPEED,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#CENTI_EXPLODE_FRAMES,OBJFRAME(a5)
	bne.s	.ok
	jmp	CLEAROBJWVRAM
.ok:
.same_frame:
	jmp	DRAW_COMPLEX_SPRITE

CENTI_EXPLODE_MULTI_AI:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#CENTI_EXPLODE_SPEED,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#CENTI_EXPLODE_FRAMES,OBJFRAME(a5)
	bne.s	.ok
	jmp	CLEAROBJWVRAM
.ok:
.same_frame:
	move.w	OBJX(a5),-(sp)
	move.w	OBJY(a5),-(sp)
	
	move.b	OBJAUX4(a5),OBJAUX5(a5)

.main_loop:
	jsr	STICKOBJECTTOPLAYFIELD
	bsr	.walk_no_draw
	subq.b	#1,OBJAUX5(a5)
	bne.s	.main_loop
	
	move.w	(sp)+,OBJY(a5)
	move.w	(sp)+,OBJX(a5)
	rts

.walk_no_draw:
	pea	(a5)
	jsr	DRAW_COMPLEX_SPRITE
	move.l	(sp)+,a5

.INCREMENT:
	moveq	#CENTI_RUN_SPEED,d1
	moveq	#CENTI_RUN_SPEED,d6
	moveq	#-7,d2
	add.w	OBJY(a5),d2						;set up y to check if we will walk over the edge
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	beq.s	.WALKRIGHT
	neg.w	d1
	neg.w	d6

.WALKRIGHT:
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP4
	jsr	GETATTRIB						;x+dx,y-5
	tst.w	d0
	bne.s	.use_this_one
	move.w	TEMP4,d1
	moveq	#7,d2
	add.w	OBJY(a5),d2						;set up y to check if we will walk over the dege
	jsr	GETATTRIB						;x+dx,y-5
	tst.w	d0
	beq.s	.change_direction

.use_this_one:
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL

	and.w	d0,d0							;0 then it must be nothing
	bne.s	.all_ok
	bra.s	.change_direction

.CHECKWALL:
	and.w	#~ATTR_MASK,d7						;see if any control is on this block
	beq.s	.all_ok

.change_direction:
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move

.all_ok:
	add.w	d6,OBJX(a5)						;move the ANT by d6

.no_move:
.DONETHIS:
	rts

ADD_CENTI_SCORE:
	move.l	a5,a6
	move.w	#$5fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.no_way
	move.w	#$7f00,OBJKEY(A5)
	move.l	#BOPAI,OBJAI(A5)
	move.l	#SCOREMAP,OBJMAP(a5)
	move.l	#CRATE10006,OBJINITDMA(A5)
	move.b	d5,OBJFRAME(A5)
	move.b	#1,OBJAUX2(a5)
	
	moveq	#CENTI_SCORE_X_OFFSET,d0
	moveq	#CENTI_SCORE_Y_OFFSET,d1
	add.w	OBJX(A6),d0
	add.w	OBJY(A6),d1
	move.w	d0,OBJX(A5)
	move.w	d1,OBJY(A5)
.no_way:
	move.l	a6,a5
	rts

Centiscore1:	dc.l	centi_body_score
Centiscore2:	dc.l	centi_head_score

centi_dma:
	dc.l	.frame0			;body
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4			;head
	dc.l	.frame5
	dc.l	.frame6
	dc.l	.frame7

.frame0:
	dc.w	1,0,0,0
	dc.w	-10,-23,82
.frame1:
	dc.w	1,0,0,0
	dc.w	-10,-24,83
.frame2:
	dc.w	1,0,0,0
	dc.w	-10,-23,84
.frame3:
	dc.w	1,0,0,0
	dc.w	-10,-24,83
.frame4:
	dc.w	1,0,0,0
	dc.w	-10,-33,79
.frame5:
	dc.w	1,0,0,0
	dc.w	-10,-33,80
.frame6:
	dc.w	1,0,0,0
	dc.w	-10,-33,81
.frame7:
	dc.w	1,0,0,0
	dc.w	-10,-33,80

CENTIMAP:
	rept	8
	dc.l	0,0
 	dc.w	$ffff&($FFFC+8),($FFF2-8)&$ffff
 	dc.w	$0004+8,($FFF2-8)&$ffff
 	dc.w	$0007+8,($FFF8-8)&$ffff
 	dc.w	$0004+8,($FFFE-8)&$ffff
 	dc.w	$ffff&($FFFC+8),($FFFE-8)&$ffff
 	dc.w	$ffff&($FFF9+8),($FFF8-8)&$ffff
	endr

CENTI_EXPLODE_MAP:
	rept	CENTI_EXPLODE_FRAMES
	dcb.b	32,0
	endr

jcenti_explode_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4

.frame0:
	dc.w	1,0,0,-1
	dc.w	-10,-20,JCENTI_EXPLODE_FRAME
.frame1:
	dc.w	1,0,0,-1
	dc.w	-10,-20,JCENTI_EXPLODE_FRAME+1
.frame2:
	dc.w	1,0,0,-1
	dc.w	-10,-20,JCENTI_EXPLODE_FRAME+2
.frame3:
	dc.w	1,0,0,-1
	dc.w	-10,-20,JCENTI_EXPLODE_FRAME+3
.frame4:
	dc.w	1,0,0,-1
	dc.w	-10,-20,JCENTI_EXPLODE_FRAME+4
