;the card stands there and waits for Bubsy to come with range, he then moves towards Bubsy
;and when within range attacks the Feline wonder.

.macro	CARD_KILL_BUBSY_EH_SQUISH
	move.w	#$0901,d6				;see if BUBSY has bopped the KNIGHT
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	endm

.macro	CARD_KILL_BUBSY_EH_POP
	move.w	#$0901,d6				;see if BUBSY has bopped the KNIGHT
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

CARD_KILL_X_RANGE	equ	56
CARD_KILL_Y_MID		equ	(48/2)
CARD_KILL_Y_RANGE	equ	60
CARD_KILL_FRAMES	equ	3
CARD_KILL_SPEED		equ	6
CARD_KILL_FIRST_FRAME	equ	5

CARD_WALK_SPEED		equ	6
CARD_WALK_FRAMES	equ	5
CARD_WALK_OFFSET	equ	-10
CARD_WALK_DX		equ	-2
CARD_WALK_BDX		equ	-10+CARD_WALK_DX

CARD_TURN_FIRST_FRAME	equ	8
CARD_TURN_FRAMES	equ	7
CARD_TURN_SPEED		equ	7
CARD_TURN_FLIP_FRAME	equ	1

********************************************************************

CARDAI:
	jsr	OBJRANGE						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY
	CARD_KILL_BUBSY_EH_SQUISH

	moveq	#0,d1
	move.w	OBJX(a5),d0
	sub.w	BUBX,d0
	bpl.s	.bub_to_right
	moveq	#8,d1

.bub_to_right:
	move.b	d1,OBJOAM0(a5)
	move.l	#CARD_WALKAI,OBJAI(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE

CARD_WALKAI:
	jsr	OBJRANGEBIG
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPY
	CARD_KILL_BUBSY_EH_SQUISH

	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.no_kill
	
	move.w	OBJX(A5),d0
	sub.w	BUBX,d0
	tst.b	OBJOAM0(a5)
	beq.s	.facing_right
	neg.w	d0

.facing_right:
	tst.w	d0
	bmi.s	.no_kill
	cmp.w	#CARD_KILL_X_RANGE,d0
	bgt.s	.no_kill
	
	move	#CARD_KILL_Y_MID,d0
	add.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bmi.s	.no_kill
	cmp.w	#CARD_KILL_Y_RANGE,d0
	bgt.s	.no_kill
	move.l	#CARD_KILLAI,OBJAI(a5)
	sf	OBJAUX0(a5)
	move.b	#CARD_KILL_FRAMES,OBJAUX1(a5)
	jmp	DRAW_COMPLEX_SPRITE

.no_kill:
	subq.b	#1,OBJAUX0(a5)
	bpl	.no_change
	move.b	#CARD_WALK_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	move.b	#CARD_WALK_FRAMES-1,OBJAUX1(a5)

.no_wrap:
	move.b	OBJAUX1(a5),OBJFRAME(a5)
	
	move.w	OBJY(a5),d0						;set up y to check if we will walk over the dege
	add.w	#12,d0
	move.w	d0,d2
	sub.w	#24,d0
	move.w	d0,TEMP5						;set up for checking for floor

	moveq	#CARD_WALK_BDX,d1
	moveq	#CARD_WALK_DX,d6
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d1
	neg.w	d6

.going_right:
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB						;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP5,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB						;x+dx,y-5
	tst.w	d0
	bne.s	.use_this_one
	or.w	TEMP7,d0

.use_this_one:
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	beq.s	.turn_around

.CHECKWALL:								;check if we will hit a wall
	and.w	#WALL_CTRL,d7
	bne.s	.turn_around

.all_ok:
	add.w	d6,OBJX(a5)						;move the guard by d6
	jsr	STICKOBJECTTOPLAYFIELD

.no_change:
	jmp	DRAW_COMPLEX_SPRITE
	
.turn_around:
	move.l	#CARD_TURNAI,OBJAI(a5)
	sf	OBJAUX0(a5)
	move.b	#CARD_TURN_FRAMES,OBJAUX1(a5)
	jmp	DRAW_COMPLEX_SPRITE

***********************************************************

CARD_KILLAI:
	jsr	OBJRANGE
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPY
	CARD_KILL_BUBSY_EH_POP

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.no_change
	
	move.b	#CARD_KILL_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	
	move.l	#CARD_WALKAI,OBJAI(a5)
	sf	OBJAUX0(a5)
	sf	OBJAUX1(a5)
	jmp	DRAW_COMPLEX_SPRITE

.no_wrap:
.no_change:
	moveq	#CARD_KILL_FIRST_FRAME,d0
	add.b	OBJAUX1(a5),d0
	move.b	d0,OBJFRAME(a5)
	jmp	DRAW_COMPLEX_SPRITE

***********************************************************

CARD_TURNAI:
	jsr	OBJRANGE
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM

.inrange:
	jsr	CLIPY
	CARD_KILL_BUBSY_EH_SQUISH
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.no_change
	move.b	#CARD_TURN_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	move.l	#CARD_WALKAI,OBJAI(a5)
	sf	OBJAUX0(a5)
	sf	OBJAUX1(a5)
	jmp	DRAW_COMPLEX_SPRITE

.no_wrap:
	cmp.b	#CARD_TURN_FLIP_FRAME,OBJAUX1(a5)
	bne.s	.no_flip
	eor.b	#8,OBJOAM0(A5)

.no_flip:
	moveq	#CARD_TURN_FIRST_FRAME,d0
	add.b	OBJAUX1(a5),d0
	move.b	d0,OBJFRAME(a5)

.no_change:
	jmp	DRAW_COMPLEX_SPRITE

CARD_X_OFFSET	equ	41
CARD_X1_OFFSET	equ	-20

card_dma:
	dc.l	.walk4		;0
	dc.l	.walk3		;1
	dc.l	.walk2		;2
	dc.l	.walk1		;3
	dc.l	.walk0		;4

	dc.l	.atta2		;5
	dc.l	.atta1		;6
	dc.l	.atta0		;7

	dc.l	.turn1		;8
	dc.l	.turn2		;9
	dc.l	.turn4
	dc.l	.turn3
	dc.l	.turn2
	dc.l	.turn1
	dc.l	.walk0

.walk0:
	dc.w	3,0+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-14,1
	dc.w	0,-14-35,0
	dc.w	-38+1,-50+5,6
.walk1:
	dc.w	2,0+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-51,2
	dc.w	-38+1,-50+5,6
.walk2:
	dc.w	3,2+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	-38+1,-50+5,6
	dc.w	0,-14-35,0
	dc.w	0,-14,3
.walk3:
	dc.w	2,-3+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	-38+1,-50+5,6
	dc.w	0,-51,4
.walk4:
	dc.w	3,+3+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	-38+1,-50+5,6
	dc.w	0,-14,5
	dc.w	0,-14-35,0

.atta0:
	dc.w	2,0+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-49,19
	dc.w	-28+1,-49,18
.atta1:
	dc.w	2,0+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	-30+5+3,-25-25,16
	dc.w	0,-25,17
.atta2:
	dc.w	2,0+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-50,15
	dc.w	-48,-40+1,14

.turn1:
	dc.w	2,1+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-49,8
	dc.w	-14,-49-21,7
.turn2:
	dc.w	3,-1+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-26,11
	dc.w	0,-26-33,10
	dc.w	0,-26-33-23,9
.turn3:
	dc.w	3,-1+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-26,11
	dc.w	0,-26-33,12
	dc.w	0,-26-33-23,9
.turn4:
	dc.w	3,0+CARD_X1_OFFSET,0,CARD_X_OFFSET
	dc.w	0,-26,11
	dc.w	0,-26-33,13
	dc.w	0,-26-33-23,9

.macro	CARD_A_MAP
	Soff	0,0,0,0,0,10,0,20,0,30,0,40,0,50,0,60
	.endm
.macro	CARD_T0_MAP
	Soff	34,(49+21),0,0,11,-11,46,-19,46,-53,14,-19,14,-53
	.endm

.macro	CARD_T_MAP
	Soff	3,26+33+23-2,0,0,0,-25,-19,-32,-16,-66,16,-32,19,-66
	.endm

CARDMAP:
	Soff	55,40,0,0,31,0,39,-27,71,-27,39,9,71,9
	Soff	58,40,0,0,31,0,39,-27,71,-27,39,9,71,9
	Soff	55,40,0,0,31,0,39,-27,71,-27,39,9,71,9
	Soff	55,40,0,0,31,0,39,-27,71,-27,39,9,71,9
	Soff	55,40,0,0,31,0,39,-27,71,-27,39,9,71,9
	
	Soff	60,30,0,0,17,2,29,5,57,16,62,-9,73,-25
	
	Soff	46,28,0,0,14,4,35,19,50,16,73,23,39,-10
	
	Soff	55,40,0,0,31,0,39,-27,71,-27,39,9,71,9
	
	CARD_T0_MAP
	rept	4
	CARD_T_MAP
	endr
	CARD_T0_MAP
	
	Soff	55,40,0,0,31,0,39,-27,71,-27,39,9,71,9