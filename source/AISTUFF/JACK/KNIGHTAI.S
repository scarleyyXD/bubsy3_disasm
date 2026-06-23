;the knight stands there and waits for Bubsy to come with range, he then moves towards Bubsy
;and when within range attacks the Feline wonder.

.macro KNIGHT_KILL_BUBSY_EH_SQUISH
	move.w	#$0901,d6				;see if BUBSY has bopped the KNIGHT
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#SPLITSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

********************************************************************

KNIGHT_WALK_RANGE		equ	160
KNIGHT_KILL_ME			equ	110

KNIGHT_YKILL_RANGE		equ	20

KNIGHT_BORED_SPEED		equ	8
KNIGHT_BORED_FRAMES		equ	8

KNIGHT_LOOK_AHEAD		equ	20
KNIGHT_KILL_AHEAD		equ	36+70

KNIGHTAI:
	jsr	OBJRANGE						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY
	KNIGHT_KILL_BUBSY_EH_SQUISH

	jsr	STICKOBJECTTOPLAYFIELD
	
	moveq	#DEADFLAG,d7
	and.b	BUBSYFLAGS,d7
	bne	.just_animate

	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.yplus
	neg.w	d0

.yplus:
	cmp.w	#KNIGHT_YKILL_RANGE,d0
	bgt	.just_animate
	moveq	#0,d1
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bpl.s	.bub_to_right
	eor.b	#$08,d1							;d1 = face direction 0 == right 8 ==left
	neg.w	d0							;d0 = abs value of x difference

.bub_to_right:
	cmp.b	OBJOAM0(a5),d1
	beq	.facing_wrong_way

	move.w	OBJX(a5),TEMP1
	move.w	OBJY(a5),TEMP2
	cmp.w	#KNIGHT_WALK_RANGE,d0
	bgt.s	.just_animate
	cmp.w	#KNIGHT_KILL_ME,d0
	blt	.kill_bubsy

	;check if the knight can walk in that direction
	moveq	#KNIGHT_LOOK_AHEAD,d1
	tst.b	OBJOAM0(a5)
	bne.s	.left
	neg.w	d1

.left:
	add.w	d1,OBJX(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	TEMP2,d0
	cmp.w	OBJY(a5),d0
	beq.s	.ok1

.fail:
	move.w	TEMP2,OBJY(a5)
	bra.s	.cant_walk

.ok1:
	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	and.w	#~ATTR_MASK,d0
	bne.s	.fail
	move.l	#KNIGHT_WALKAI,OBJAI(a5)
	sf	OBJAUX0(a5)
	move.b	#KNIGHT_WALK_FRAMES,OBJAUX6(a5)

.cant_walk:
	move.w	TEMP1,OBJX(a5)

.just_animate:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#KNIGHT_BORED_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	move.b	#KNIGHT_BORED_FRAMES,OBJFRAME(A5)			; play the frames backwards ???
	move.b	#KNIGHT_BORED_SPEED*10-1,OBJAUX0(a5)

.no_wrap:
.same_frame:
	JMP	DRAW_COMPLEX_SPRITE

.kill_bubsy:
	moveq	#KNIGHT_KILL_AHEAD,d1
	tst.b	OBJOAM0(a5)
	bne.s	.aleft
	neg.w	d1

.aleft:
	add.w	d1,OBJX(a5)
	sub.w	#16,OBJY(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	TEMP2,d0
	cmp.w	OBJY(a5),d0
	beq.s	.aok1

.afail:
	move.w	TEMP2,OBJY(a5)
	bra.s	.cant_walk

.aok1:
	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	addq	#2,d2
	jsr	GETATTRIB
	and.w	#~ATTR_MASK,d0
	bne.s	.afail
	move.w	TEMP2,OBJY(a5)
	move.w	TEMP1,OBJX(a5)
	lea	KNIGHT_KILLAI(pc),a0
	move.l	a0,OBJAI(a5)
	move.b	#KNIGHT_KILL_FRAMES,OBJAUX6(a5)
	sf	OBJAUX0(a5)
	eor.b	#$08,OBJOAM0(a5)
	jmp	(a0)

.facing_wrong_way:
	lea	KNIGHT_TURNAI(pc),a0
	move.l	a0,OBJAI(a5)
	sf	OBJAUX0(a5)
	move.b	#KNIGHT_TURN_FRAMES,OBJAUX6(a5)
	jmp	(a0)

********************************************************************

KNIGHT_TURN_SPEED	equ	8
KNIGHT_TURN_FIRST_FRAME	equ	12
KNIGHT_TURN_FRAMES	equ	6

KNIGHT_TURNAI:
	jsr	OBJRANGE						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY
	KNIGHT_KILL_BUBSY_EH_SQUISH

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	
	move.b	#KNIGHT_TURN_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX6(a5)
	bpl.s	.no_wrap
	eor.b	#$08,OBJOAM0(a5)
	move.l	#KNIGHTAI,OBJAI(a5)					;turn the guard around and
	move.b	#KNIGHT_BORED_FRAMES,OBJFRAME(A5)			;set to normal Knight AI
	move.b	#KNIGHT_BORED_SPEED*10-1,OBJAUX0(a5)
	bra.s	.same_frame

.no_wrap:
	moveq	#KNIGHT_TURN_FIRST_FRAME,d0
	add.b	OBJAUX6(a5),d0
	move.b	d0,OBJFRAME(A5)

.same_frame:
	JMP	DRAW_COMPLEX_SPRITE
	
********************************************************************

KNIGHT_WALK_SPEED	equ	8
KNIGHT_WALK_FIRST_FRAME	equ	9
KNIGHT_WALK_FRAMES	equ	3

KNIGHT_WALKAI:
	jsr	OBJRANGE						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY
	KNIGHT_KILL_BUBSY_EH_SQUISH

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	
	move.b	#KNIGHT_WALK_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX6(a5)
	bpl.s	.no_wrap
	move.l	#KNIGHTAI,OBJAI(a5)					;turn the guard around and
	move.b	#KNIGHT_BORED_FRAMES,OBJFRAME(A5)			;set to normal Knight AI
	move.b	#KNIGHT_BORED_SPEED*10-1,OBJAUX0(a5)
	move.w	#-6,d0
	tst.b	OBJOAM0(a5)
	beq.s	.negi
	neg.w	d0

.negi:
	add.w	d0,OBJX(a5)
	bra.s	.same_frame

.no_wrap:
	moveq	#KNIGHT_WALK_FIRST_FRAME,d0
	add.b	OBJAUX6(a5),d0
	move.b	d0,OBJFRAME(A5)
	
	move.b	OBJAUX6(a5),d0
	add.b	d0,d0
	move.w	.knight_move_x(pc,d0.w),d0
	tst.b	OBJOAM0(a5)
	bne.s	.no_turn
	neg.w	d0

.no_turn:
	add.w	d0,OBJX(a5)

.same_frame:
	JMP	DRAW_COMPLEX_SPRITE

.knight_move_x:
	dc.w	8,7,10

********************************************************************

KNIGHT_KILL_FIRST_FRAME	equ	18
KNIGHT_KILL_FRAMES	equ	6

KNIGHT_KILLAI:
	jsr	OBJRANGE						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY
	KNIGHT_KILL_BUBSY_EH_SQUISH
	
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	
	move.b	#KNIGHT_WALK_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJAUX6(a5)
	bpl.s	.no_wrap
	move.l	#KNIGHTAI,OBJAI(a5)					;turn the guard around and
	move.b	#KNIGHT_BORED_FRAMES,OBJFRAME(A5)			;set to normal Knight AI
	move.b	#KNIGHT_BORED_SPEED*10-1,OBJAUX0(a5)
	eor.b	#$08,OBJOAM0(a5)
	bra.s	.same_frame

.no_wrap:
	moveq	#KNIGHT_KILL_FIRST_FRAME,d0
	add.b	OBJAUX6(a5),d0
	move.b	d0,OBJFRAME(A5)
	
	move.b	OBJAUX6(a5),d0
	add.b	d0,d0
	move.w	.knight_move_x(pc,d0.w),d0
	tst.b	OBJOAM0(a5)
	beq.s	.no_turn
	neg.w	d0

.no_turn:
	add.w	d0,OBJX(a5)

.same_frame:
	JMP	DRAW_COMPLEX_SPRITE

.knight_move_x:
	dc.w	8,28,0,0,0,0,0

********************************************************************

.macro	KNI_MAP
	if \1=0
	Soff	10,0,0,0,1,18,0,38,20,0,28,36,33,62
	endif
	if \1=1
	KNI_MAP	0
	endif
	if \1=2
	KNI_MAP	0
	endif
	if \1=3
	KNI_MAP	0
	endif
	if \1=4
	KNI_MAP	0
	endif
	if \1=5
	KNI_MAP	0
	endif
	if \1=6
	KNI_MAP	0
	endif
	if \1=7
	KNI_MAP	0
	endif
	
	if \1=8
	Soff	10,1,0,0,0,38,10,53,55,24,45,13,20,0
	endif
	if \1=9
	Soff	10,1,0,0,0,38,9,53,46,25,53,16,20,0
	endif
	if \1=10
	Soff	10,1,0,0,0,26,2,48,16,68,19,32,20,0
	endif
	if \1=11
	Soff	10,1,0,0,1,27,1,70,16,50,20,37,20,0
	endif
	if \1=12
	Soff	10,1,0,0,-7,29,-14,62,11,53,19,22,20,0
	endif
	if \1=13
	Soff	10,1,0,0,-21,38,-20,55,9,53,19,38,20,0
	endif
	
	if \1=14
	Soff	16,1,0,0,6,34,13,50,32,0,33,26,41,59
	endif
	if \1=15
	Soff	20,1,0,0,12,30,20,45,46,54,41,26,45,0
	endif
	
	if \1=16
	Soff	10,1,0,0,11,35,24,52,43,69,51,60,33,13
	endif
	if \1=17
	Soff	10,1,0,0,27,24,56,0,72,44,101,30,115,11
	endif
	if \1=18
	Soff	10,1,0,0,27,24,62,24,82,10,98,8,113,5
	endif
	if \1=19
	Soff	10,1,0,0,27,24,62,24,85,12,103,13,114,13
	endif
	if \1=20
	Soff	10,7,0,0,11,25,23,43,50,56,35,27,30,-7
	endif
	.endm

********************************************************************

knight_dma:
	dc.l	.bored1		;00	;normal bored anim
	dc.l	.bored7		;01
	dc.l	.bored6		;02
	dc.l	.bored5		;03
	dc.l	.bored4		;04
	dc.l	.bored3		;05
	dc.l	.bored2		;06
	dc.l	.bored1		;07
	dc.l	.bored0		;08
	
	dc.l	.bored14	;09	;move sideways
	dc.l	.bored15	;10
	dc.l	.bored14	;11

	dc.l	.bored13	;12	;turn frames
	dc.l	.bored12	;13
	dc.l	.bored11	;14
	dc.l	.bored10	;15
	dc.l	.bored9		;16
	dc.l	.bored8		;17

	dc.l	.bored0		;18
	dc.l	.bored20	;19	;kill frames
	dc.l	.bored19	;02
	dc.l	.bored18	;21
	dc.l	.bored17	;22
	dc.l	.bored16	;23
	
.bored20:
	dc.w	1,-11,0,22
	dc.w	0,-67,69
.bored19:
	dc.w	2,-11,0,22
	dc.w	0,-26,65
	dc.w	63-1,-4-24+12-2-1,68
.bored18:
	dc.w	2,-11,0,22
	dc.w	0,-26,65
	dc.w	63-1,-4-24+12,67
.bored17:
	dc.w	2,-11,0,22
	dc.w	0,-26,65
	dc.w	63-22-1,-36-2-1-24+12,66
.bored16:
	dc.w	1,-11,0,22
	dc.w	0,-70,64
.bored15:
	dc.w	1,-10,-22,20
	dc.w	0-3-8-1,-57+16+5,63
.bored14:
	dc.w	1,-10,-22,20
	dc.w	0-8+2,-62+16+5,62
.bored13:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-20-6,-22-12,61
.bored12:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-12-5,-22-21,60
.bored11:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-6,-22-27,59
.bored10:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-6,-22-25,58
.bored9:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0,-32,57
.bored8:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0,-32,56
.bored7:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-1,-42,55
.bored6:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-10,-42,54
.bored5:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-3,-42,53
.bored4:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-9,-42,52
.bored3:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-10,-42,51
.bored2:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0-6,-42,50
.bored1:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0,-42,49
.bored0:
	dc.w	2,-10,-22,20
	dc.w	0,-22,47
	dc.w	0,-42,48

********************************************************************

KNIGHTMAP:
	KNI_MAP	1
	KNI_MAP	7
	KNI_MAP	6
	KNI_MAP	5
	KNI_MAP	4
	KNI_MAP	3
	KNI_MAP	2
	KNI_MAP	1
	KNI_MAP	0
	
	KNI_MAP	14
	KNI_MAP	15
	KNI_MAP	14
	
	KNI_MAP	13
	KNI_MAP	12
	KNI_MAP	11
	KNI_MAP	10
	KNI_MAP	9
	KNI_MAP	8
	
	KNI_MAP	0
	KNI_MAP	20
	KNI_MAP	19
	KNI_MAP	18
	KNI_MAP	17
	KNI_MAP	16