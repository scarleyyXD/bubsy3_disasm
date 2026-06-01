PIE_MAX_SPLAT	equ	6
PIE_FLING_X	equ	4
PIE_SPLAT_SPEED	equ	5

PIE_SCORE	equ	4
Piescore:	dc.l	$100*PIE_SCORE

.macro	PIE_KILL_BUBSY_SPLAT
	moveq	#DEADFLAG,D1					;if bubsy dead then no collision
	and.b	BUBSYFLAGS,D1
	bne.w	.no_collide	;bne.s->bne.w

	jsr	NOBOPCOLLIDE
	bcc.w	.no_collide	;bcc.s->bcc.w
	
	move.w	INVTIMER,d0					;set then pie can't kill bubsy
	or.w	SHADOWTIMER,d0
	bne.s	.inv
	
	btst	#bANCHORFLAG,BUBSYFLAGS				;check if we are on the ground
	bne.w	.bubsy_on_ground	;bne.s->bne.w

	move.w	BUBVY,d0					;and is he moving up screen
	bmi.w	.bubsy_going_up	;bmi.s->bmi.w
	
.inv:	lea	Piescore,a4					;give bubsy some points
	jsr	add_to_score
	
	move.l	#PIE_SCORE,d5					;display sprite for score
	jsr	ADD_CENTI_SCORE
	
	MOVE.w	OBJKEY(A5),D0
	JSR	OBJENINDEX
	LEA	OBJENFLAGS,A0
	OR.B	D0,(A0,D6.W)					;kill object

	MOVE.L	#BOPAI,a0
	move.l	a0,OBJAI(A5)					;set up explode AI and initial DMA vector
	MOVE.L	#CRATE10001,OBJINITDMA(A5)
	move.l	#CRATEMAP,OBJMAP(a5)
	MOVE.B	#1,OBJFRAME(A5)	
	jmp	(a0)
	
.bubsy_on_ground:
.bubsy_going_up:
	moveq	#FALLBACKSTATE,d0
	jsr	KILLBUBSY
	st	OBJAUX0(a5)
.no_collide:
	.endm

PIEAI:
	jsr	OBJRANGE
	bcc.s	.inx
	jmp	CLEAROBJWVRAM
.inx:	jsr	CLIPY

	tst.b	OBJAUX0(a5)
	bne	.splattered
	
	PIE_KILL_BUBSY_SPLAT
	
	move.w	#PIE_FLING_X,d0
	tst.b	OBJOAM0(a5)
	beq.s	.moving_right
	neg.w	d0
.moving_right:	
	add.w	d0,OBJX(A5)
	
	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	and.w	#WALL_CTRL,d0
	sne	OBJAUX0(a5)
.same_frame:
	JMP	DRAW_COMPLEX_SPRITE
	
.splattered:
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.same_frame
	move.b	#PIE_SPLAT_SPEED-1,OBJAUX1(a5)
	
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#PIE_MAX_SPLAT,OBJFRAME(a5)
	bne.s	.same_frame
	
	JSR	OBJENINDEX
	LEA	OBJENFLAGS,A0
	OR.B	D0,(A0,D6.W)				;kill object
	
	jmp	CLEAROBJWVRAM

pie_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4
	dc.l	.frame5

.frame0:	dc.w	1,0,-42,0
	dc.w	0,0,52
.frame1:	dc.w	1,0,-42,0
	dc.w	0,0,53
.frame2:	dc.w	1,0,-42,0
	dc.w	0,0,54
.frame3:	dc.w	1,0,-42,0
	dc.w	0,0,55
.frame4:	dc.w	1,0,-42,0
	dc.w	0,0,56
.frame5:	dc.w	5,0+10,-42+10,-1
	dc.w	7,-29,57
	dc.w	24,-36,58
	dc.w	13,4,59
	dc.w	10,13,60
	dc.w	-23,13,61

PIEMAP:
	Soff	-10,0,0,0,3,8,4,16,4,27,3,35,0,42
	
	rept	5
	dcb.b	32,0
	endr
