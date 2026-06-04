; the mirage bottle is half buried on the sand and
; when bubsy is a certain distance from the bottle
; it jumps out of the ground ( a sumersault ) and
; runs at Bubsy. At a specific distance for bubsy
; the bottle will leap at him in a curve and will
; either collide with bubsy else when it comes
; into contact with the ground explodes.

*****************************************************************************************

;format for object is
;	0				.w	oam - not bothered about flip - its done
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	last frame in animation		.b	aux0
;	0				.b	aux1
;	0				.b	aux2 - not used set to 0 
;	0				.b	aux3 - set to 0 for 1st frame counter
;	0				.b	flags - not used set to 0
;	0				.b	aux4

;	OBJECT	%0000000000000000,MIRAGEAI,mirage_dma,MIRAGE_MAP,$00,$00,$00,$00,$00,$00			;mirage bottle

*****************************************************************************************

MIRAGE_RANGE_WAKEY		equ	30
MIRAGE_AWAKE_DISTANCE		equ	180
MIRAGE_KILL_DISTANCE		equ	80
MIRAGE_RUN_SPEED		equ	7
MIRAGE_AWAKE_SPEED		equ	6
ABOUT_TO_RUN			equ	7
MIRAGE_DX			equ	8
MIRAGE_POUNCE_WAIT		equ	8
MIRAGE_SPECIAL			equ	8

MF0	equ	13
MF1	equ	MF0+1
MF2	equ	MF1+1
MF3	equ	MF2+1

.macro	Mirages
	Soff	-9,-5,0,0,12,0,3,5,7,5,-9,12,-6,15
	.endm
macro	Mirager	o1
	if \o1=0
	Soff	0,2,0,0,37,3,19,17,31,16,28,23,36,25
	endif
	if \o1=1
	Soff	0,3,0,0,11,7,0,13,16,21,10,24,19,30
	endif
	if \o1=2
	Soff	0,5,0,0,22,5,6,15,22,18,16,25,26,30
	endif
	if \o1=3
	Soff	0,2,0,0,37,3,14,11,30,17,24,22,34,27
	endif
	if \o1=4
	Soff	-2,4,0,0,-2,12,8,-3,11,14,9,23,18,28
	endif
	if \o1=5
	Soff	-6,0,0,0,22,5,17,13,3,15,13,26,24,29
	endif
	.endm
.macro	Miragew	o1
	if \o1=0
	Soff	-30,-1,0,0,15,18,-3,19,-19,19,-19,12,-29,17
	endif
	if \o1=1
	Soff	2,10,0,0,14,5,11,15,24,21,31,10,35,19
	endif
	if \o1=2
	Soff	-3,10,0,0,-2,18,-3,29,6,9,4,36,15,22
	endif
	if \o1=3
	Soff	9,4,0,0,-3,11,-2,18,-11,23,13,18,24,16
	endif
	if \o1=4
	Soff	0,-1,0,0,1,18,3,31,10,2,9,12,7,13
	endif
	if \o1=5
;	Mirager	4
	Soff	-7,4,0,0,-2,12,8,-3,11,14,9,23,18,28
	endif
	.endm
.macro	Miraget	o1
	if \o1=0
	Soff	-20,-27,0,0,-8,4,2,11,-14,15,-8,22,-17,27
	endif
	if \o1=1
	Soff	-19,-26,0,0,-8,5,3,10,-13,14,-7,20,-17,25
	endif
	if \o1=2
	Soff	0,-21,0,0,1,4,8,-4,17,9,11,15,21,19
	endif
	if \o1=3
	Soff	0,-27,0,0,0,5,19,5,19,17,29,16,32,25
	endif
	.endm

*****************************************************************************************

.macro	MIRAGE_KILL_BUBSY
	move.w	#$0901,d6				;see if BUBSY has bopped the guard
	moveq	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#SHATTERSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

.macro	MIRAGE_POUNCE_KILL_BUBSY
	move.w	#$0901,d6				;see if BUBSY has bopped the guard
	moveq	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#SHATTERSTATE,d0
	jsr	KILLBUBSY
	bra	MIRAGEEXPLODEAIINIT			;explode that bottle
.no_collide:
	.endm

*****************************************************************************************

MIRAGEAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	MIRAGE_KILL_BUBSY
	
	jsr	STICKOBJECTTOPLAYFIELD
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below:
	cmp.w	#MIRAGE_RANGE_WAKEY,d0
	bgt.s	.not_woken

	moveq	#0,d7
	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.not_neg
	moveq	#%1000,d7
	neg.w	d0
.not_neg:
	cmp.w	#MIRAGE_AWAKE_DISTANCE,d0
	blt.s	.woken
.not_woken:
	jmp	DRAW_COMPLEX_SPRITE
.woken:	move.b	d7,OBJOAM0(a5)			;set direction of wakening
	move.l	#MIRAGEWOKENAI,OBJAI(a5)
	move.b	#1,OBJFRAME(A5)			;set 1st frame
	sf	OBJAUX0(a5)			;reset timer
	bra.s	miss_this_stuff
	
MIRAGEWOKENAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	MIRAGE_KILL_BUBSY
	
	jsr	STICKOBJECTTOPLAYFIELD
miss_this_stuff:
	move.b	OBJAUX0(a5),d0
	addq.b	#1,d0
	cmp.b	#MIRAGE_AWAKE_SPEED,d0
	bne.s	.just_draw
	moveq	#0,d0
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#ABOUT_TO_RUN,OBJFRAME(a5)
	beq.s	MIRAGERUNINITAI
.just_draw:
	move.b	d0,OBJAUX0(a5)	
	bra	DRAW_COMPLEX_SPRITE

MIRAGERUNINITAI:
	move.l	#MIRAGERUNAI,OBJAI(a5)				;initalise run ai
	st	OBJAUX1(a5)
	move.b	#MIRAGE_RUN_SPEED-1,OBJAUX3(a5)
	move.b	#7,OBJAUX4(a5)

MIRAGERUNAI:
	jsr	OBJRANGE					;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY						; in range y
	
	MIRAGE_KILL_BUBSY
	
	jsr	STICKOBJECTTOPLAYFIELD
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	addq.b	#1,d0
	cmp.b	#MIRAGE_RUN_SPEED,d0
	beq.s	.INCREMENT
	move.b	d0,OBJAUX3(a5)
	bra	.NOINCREMENT

.INCREMENT:
	move.w	OBJY(a5),d0					;set up y to check if we will walk over the dege
	addq.w	#5,d0
	move.w	d0,d2
	sub.w	#10,d0
	move.w	d0,TEMP5					;set up for checking for floor

	moveq	#0,d6
	move.b	OBJAUX1(a5),d6
	ext.w	d6
	move.b	.walk_offsets(pc,d6.w),d6
	ext.w	d6
	
	moveq	#MIRAGE_DX,d1
	btst.b	#3,OBJOAM0(a5)					;check if we should walk left ??
	beq.s	.WALKLEFT
	neg.w	d1
	neg.w	d6
.WALKLEFT:
	add.w	OBJX(a5),d1					;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB					;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP5,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB					;x+dx,y-5
	or.w	TEMP7,d0
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL
	and	d0,d0						;0 then it must be nothing
	beq.s	.change_direction
	bra.s	.all_ok

.CHECKWALL:							;check if we will hit a wall
	move.w	d7,d0
	and.w	#WALL_CTRL,d0
	bne	MIRAGEEXPLODEAIINIT				;hit into wall the explode
	bra.s	.all_ok
	
.change_direction:
	bchg.b	#3,OBJOAM0(a5)					;change direction
	bra	.INCREMENT					;and calc new position

.walk_offsets	equ	*+3
	dc.b	37,3,3
	dc.b	38,6,8
	dc.b	37,3,3
	
	even

.all_ok:
	add.w	d6,OBJX(a5)					;move the bottle by d6
.no_move:
.DONETHIS:
	moveq	#0,d0
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	#6,d0
	bne.s	.no_wrap
	moveq	#0,d0
.no_wrap:
	move.b	d0,OBJAUX1(a5)					;pointer to frame number
	add.b	OBJAUX4(a5),d0					;offset in complex sprite table
	move.b	d0,OBJFRAME(a5)
	sf	OBJAUX3(a5)

	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.not_neg
	neg.w	d0
.not_neg:
	cmp.w	#MIRAGE_KILL_DISTANCE,d0
	blt.s	MIRAGEPOUNCEINITAI

.NOINCREMENT:
	moveq	#0,d1
	move.b	OBJAUX1(a5),d1
	move.b	.walky(pc,d1.w),d1
	sub.w	d1,OBJY(a5)
	
	bra	DRAW_COMPLEX_SPRITE

.walky:	dc.b	14,0,0,10,0,0

MIRAGEPOUNCEINITAI:
	move.l	#MIRAGEPOUNCEAI,OBJAI(a5)			;set initial AI and frame
	move.b	#MF0,OBJFRAME(a5)
	sf	OBJAUX2(a5)					;counter between frames
	sf	OBJAUX3(a5)					;pointer into look up table

MIRAGEPOUNCEAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	MIRAGE_POUNCE_KILL_BUBSY

	move.b	OBJAUX2(a5),d0
	addq	#1,d0
	cmp.b	#MIRAGE_POUNCE_WAIT,d0
	beq.s	.update_bottle
	move.b	d0,OBJAUX2(a5)
	jmp	DRAW_COMPLEX_SPRITE
.update_bottle:
	sf	OBJAUX5(a5)
.get_again:
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	lea	.pounce_bottle(pc,d0.w),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	tst.b	d2
	bmi.s	.do_last_move
	move.b	d2,OBJFRAME(a5)
	addq.b	#3,OBJAUX3(a5)
.skip_update:
	btst	#3,OBJOAM0(a5)
	beq.s	.right
	neg.b	d0
.right:
	ext.w	d0	
	ext.w	d1
	add.w	d0,OBJX(A5)
	add.w	d1,OBJY(A5)
	
	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	
	and.w	#ATTR_MASK,d0
	bne	MIRAGEEXPLODEAIINIT
	bra	DRAW_COMPLEX_SPRITE
.do_last_move:
	subq.b	#6,OBJAUX3(a5)
	bra.s	.get_again
	
.pounce_bottle:
	dc.b	8,-10,MF0
	dc.b	7,-08,MF1
	dc.b	6,-06,MF2
	dc.b	5,-04,MF3
	dc.b	4,-02,MF3
	dc.b	4,-02,MF3
	dc.b	3,-01,MF3
	dc.b	3,-01,MF3
	dc.b	3,-01,MF3
	dc.b	3,+00,MF3
	dc.b	3,+00,MF3
	dc.b	3,+00,MF3
	dc.b	3,+00,MF3
	dc.b	3,+00,MF3
	dc.b	3,+00,MF3
	dc.b	3,+01,MF3
	dc.b	3,+01,MF3
	dc.b	3,+01,MF3
	dc.b	2,+02,MF3
	dc.b	2,+02,MF3
	dc.b	2,+04,MF3
	dc.b	2,+06,MF3
	dc.b	1,+08,MF3
	dc.b	1,+10,MF3
	dc.b	-1,-1,-1

	even

GENERAL_EXPLOSION:
MIRAGEEXPLODEAIINIT:
	move.l	#CRATEEXPLODE,a0
	move.l	#CRATE10002,OBJINITDMA(a5)
	move.l	#CRATEMAP,OBJMAP(a5)
	move.l	a0,OBJAI(a5)
	add.w	#19,OBJX(a5)
	add.w	#12,OBJY(a5)
	sf	OBJAUX1(a5)
	sf	OBJAUX0(a5)
	jmp	(a0)
	
*****************************************************************************************

mirage_dma:
	dc.l	.mirages0	;00
	dc.l	.miragew0	;01
	dc.l	.miragew1	;02
	dc.l	.miragew2	;03
	dc.l	.miragew3	;04
	dc.l	.miragew4	;05
	dc.l	.miragew5	;06

	dc.l	.mirager0	;07
	dc.l	.mirager1	;08
	dc.l	.mirager2	;09
	dc.l	.mirager3	;10
	dc.l	.mirager4	;11
	dc.l	.mirager5	;12
	dc.l	.miraget0	;13
	dc.l	.miraget1	;14
	dc.l	.miraget2	;15
	dc.l	.miraget3	;16
	
;137 onwards for puffs of sand

.mirages0:
	dc.w	1,0,0,-1
	dc.w	0,-10,121

.miragew0:
	dc.w	2,0,0,0
	dc.w	1,-18,132
	dc.w	20,-30,137

.miragew1:
	dc.w	2,0,0,0
	dc.w	-2,-32,134
	dc.w	0,-24,138

.miragew2:
	dc.w	2,0,0,0
	dc.w	-1,-46,135
	dc.w	0,-19,139

.miragew3:
	dc.w	2,0,0,0
	dc.w	-22,-30,136
	dc.w	0,-15,140

.miragew4:
	dc.w	2,0,0,0
	dc.w	0,-30,133
	dc.w	0,-8,141

.miragew5:
	dc.w	2,0,0,0
	dc.w	5,-33,126
	dc.w	0,-3,142

.mirager0:
	dc.w	1,0,0,0
	dc.w	0,-30,122

.mirager1:
	dc.w	1,0,0,0
	dc.w	0,-33,123

.mirager2:
	dc.w	1,0,0,0
	dc.w	0,-36,124

.mirager3:
	dc.w	1,0,0,0
	dc.w	0,-30,125

.mirager4:
	dc.w	1,0,0,0
	dc.w	0,-33,126

.mirager5:
	dc.w	1,0,0,0
	dc.w	0,-37,127

.miraget0:
	dc.w	1,0,0,0
	dc.w	0,-28,128

.miraget1:
	dc.w	1,0,0,0
	dc.w	0,-27,129

.miraget2:
	dc.w	1,0,0,0
	dc.w	0,-26,130

.miraget3:
	dc.w	1,0,0,0
	dc.w	0,-28,131

MIRAGE_MAP:
	Mirages
	
	Miragew	0
	Miragew	1
	Miragew	2
	Miragew	3
	Miragew	4
	Miragew	5
	
	Mirager	0
	Mirager	1
	Mirager	2
	Mirager	3
	Mirager	4
	Mirager	5

	Miraget	0
	Miraget	1
	Miraget	2
	Miraget	3
