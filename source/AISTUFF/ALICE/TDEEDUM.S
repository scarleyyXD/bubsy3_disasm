TT_WAIT_DULL		equ	6
BALLOON_PAUSE_PERIOD	equ	120
TT_KILL_XRANGE		equ	140
TT_KILL_YRANGE		equ	40
TT_YOY_KILL_FRAMES	equ	10
TT_YO_SPEED		equ	6
FIRST_YOYO_FRAME	equ	1
TT_BALL_POP_SPEED	equ	6

TBALL_XOFFSET		equ	30
TBALL_YOFFSET		equ	-40

.macro	TT_KILL_BUBSY
	move.w	d0,TEMP7
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	move.b	#POPSTATE,d0
	jsr	KILLBUBSY
	bra.s	.cont1

.no_collide:
	move.w	TEMP7,d0
	move.b	OBJFRAME(a5),TEMP7
	eor.b	#8,OBJAUX0(a5)
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide2
	move.b	#POPSTATE,d0
	jsr	KILLBUBSY
	bra.s	.no_collide3

.no_collide2:
	move.b	#10,OBJFRAME(a5)
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide3
	move.b	#POPSTATE,d0
	jsr	KILLBUBSY

.no_collide3:
	move.b	TEMP7,OBJFRAME(a5)
	eor.b	#8,OBJAUX0(a5)
.cont1:
	.endm

.macro	TBALL_KILL_BUBSY
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide
	st	OBJAUX7(a5)
	move.b	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:	
	.endm

TDEEDUMAI:
	jsr	OBJRANGE
	bcc.s	.inrange

.end_it_all:
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPY

	TT_KILL_BUBSY

	tst.b	OBJFLAGS(a5)
	bne.s	.stuck
	st	OBJFLAGS(a5)
	add.w	#16,OBJY(a5)
	jsr	STICKOBJECTTOPLAYFIELD

.stuck:
	sf	OBJOAM0(a5)
	
	subq.b	#1,OBJAUX7(a5)
	bpl	.just_wait
	move.b	#TT_WAIT_DULL-1,OBJAUX7(A5)
	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.to_right
	neg.w	d0
	move.b	#8,OBJOAM0(A5)

.to_right:
	cmp.w	#TT_KILL_XRANGE,d0
	blt	.think_about_killing
	
.no_kill:
.just_wait:
	subq.b	#1,OBJAUX5(a5)
	bpl.s	.no_new_balloon
	move.b	#BALLOON_PAUSE_PERIOD-1,OBJAUX5(a5)
	
	move.b	OBJAUX6(a5),d1
	addq.b	#1,OBJAUX6(a5)
	and.w	#3,d1
	move.w	OBJKEY(a5),d6
	lsl.b	#2,d6
	add.b	d1,d6
	
	add.w	#$0100,d6
	move.l	a5,a6
	jsr	FINDFREEOBJ
	bcs.s	.no_object_available

	move.w	d6,OBJKEY(A5)

	move.l	#TBALL_AI,OBJAI(a5)			;set up object data
	move.l	#TBALL_MAP,OBJMAP(A5)
	move.l	#tball_dma,OBJINITDMA(A5)
	sf	OBJFRAME(A5)
	
	move.w	#TBALL_XOFFSET,d0
	move.w	#TBALL_YOFFSET,d1
	moveq	#1,d2
	and.b	OBJAUX6(a6),d2
	beq.s	.this_way
	neg.w	d0

.this_way:
	add.w	OBJX(a6),d0
	add.w	OBJY(a6),d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)

.no_object_available:
	move.l	a6,a5

.no_new_balloon:
	jsr	DRAW_COMPLEX_SPRITE
	bra	draw_other_half

.think_about_killing:
	move.w	OBJY(a5),d0
	sub.w	BUBY,d0
	sub.w	#32,d0
	bpl.s	.posi
	neg.w	d0

.posi:
	cmp.w	#TT_KILL_YRANGE,d0
	bgt	.no_kill

	move.l	#TT_YOYO_AI,OBJAI(a5)
	sf	OBJAUX0(a5)
	move.b	#TT_YOY_KILL_FRAMES,OBJAUX1(a5)
	jsr	DRAW_COMPLEX_SPRITE
	bra	draw_other_half

TT_YOYO_AI:
	jsr	OBJRANGE
	bcc.s	.inrange

.end_it_all:
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPY

	TT_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#TT_YO_SPEED-1,OBJAUX0(a5)
	
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.not_end_of_anim
	
	move.b	#TT_WAIT_DULL-1,OBJAUX7(A5)
	move.l	#TDEEDUMAI,OBJAI(a5)
	jsr	DRAW_COMPLEX_SPRITE
	sf	OBJFRAME(A5)
	bra	draw_other_half

.not_end_of_anim:
	moveq	#FIRST_YOYO_FRAME,d0
	add.b	OBJAUX1(a5),d0
	move.b	d0,OBJFRAME(A5)

.same_frame:
	jsr	DRAW_COMPLEX_SPRITE

draw_other_half:
	move.b	OBJFRAME(A5),-(sp)
	eor.b	#8,OBJOAM0(a5)
	sf	OBJFRAME(A5)
	jsr	DRAW_COMPLEX_SPRITE
	eor.b	#8,OBJOAM0(a5)
	move.b	(sp)+,OBJFRAME(A5)
	rts

ttdeedum_dma:
	dc.l	.frame0		;0
	dc.l	.frame1		;1
	dc.l	.frame2		;2
	dc.l	.frame3		;3
	dc.l	.frame4		;4
	dc.l	.frame5		;5
	dc.l	.frame4		;6
	dc.l	.frame3		;7
	dc.l	.frame2		;8
	dc.l	.frame1		;9
	dc.l	.frame0		;10

.frame0:
	dc.w	2,0,0,0
	dc.w	0,-44-26,51
	dc.w	8,-26,53
.frame1:
	dc.w	3,0,0,0
	dc.w	0,-44-26,52
	dc.w	8,-26,53
	dc.w	60,-61,54
.frame2:
	dc.w	5,0,0,0
	dc.w	0,-44-26,52
	dc.w	8,-26,53
	dc.w	50,-51,56
	dc.w	60,-57,55
	dc.w	80,-69,57
.frame3:
	dc.w	5,0,0,0
	dc.w	0,-44-26,52
	dc.w	8,-26,53
	dc.w	65,-51,56
	dc.w	60,-57,55
	dc.w	95,-69,57
.frame4:
	dc.w	5,0,0,0
	dc.w	0,-44-26,52
	dc.w	8,-26,53
	dc.w	70,-51,56
	dc.w	60,-57,55
	dc.w	110,-69,57
.frame5:
	dc.w	6,0,0,0
	dc.w	0,-44-26,52
	dc.w	8,-26,53
	dc.w	73,-51,56
	dc.w	95,-51,56
	dc.w	60,-57,55
	dc.w	125,-69,57

.macro	TMAP0
	Soff	0,0,33,14,48,38,41,54,2,35,11,51,28,71
	.endm
.macro	TMAP1
	Soff	0,0,11,51,60,50,27,71,66,53,70,60,70,39
	.endm
.macro	TMAP2
	Soff	0,0,11,51,60,50,27,71,66,53,88,60,88,39
	.endm
.macro	TMAP3
	Soff	0,0,11,51,60,50,27,71,66,53,100,60,100,39
	.endm
.macro	TMAP4
	Soff	0,0,11,51,60,50,27,71,66,53,112,60,112,39
	.endm
.macro	TMAP5
	Soff	0,0,11,51,60,50,27,71,66,53,131,60,131,39
	.endm

TTDEEDUMMAP:
	TMAP0
	TMAP1
	TMAP3
	TMAP4
	TMAP5
	TMAP4
	TMAP3
	TMAP2
	TMAP1
	TMAP0

	Soff	0,0,-20,10,-10,10,0,10,10,10,20,10,0,20

TBALL_AI:
	jsr	OBJRANGE
	bcc.s	.inrange

.end_it_all:
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPYSMALL

	tst.b	OBJAUX7(a5)
	bne.s	.exploding
	
	TBALL_KILL_BUBSY

	move.w	OBJX(a5),d1
	moveq	#-13,d2
	add.w	OBJY(a5),d2
	jsr	GETATTRIB
	beq.s	.all_ok
	st	OBJAUX7(a5)

.all_ok:
	subq.w	#1,OBJY(a5)
	jmp	DRAW_COMPLEX_SPRITE

.exploding:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#TT_BALL_POP_SPEED,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#3,OBJFRAME(a5)
	beq.s	.end_it_all

.same_frame:
	jmp	DRAW_COMPLEX_SPRITE

tball_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	
.frame0:
	dc.w	1,0,0,0
	dc.w	-13,-14,48
.frame1:
	dc.w	1,0,0,0
	dc.w	-17,-16,49
.frame2:
	dc.w	1,0,0,0
	dc.w	-17,-21,50
	
TBALL_MAP:
	Soff	0,0,-6,12,6,12,13,4,-13,4,-9,-10,9,-10