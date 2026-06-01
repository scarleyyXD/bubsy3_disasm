;add the playing with egg


;Sid the snake just sits there. Bobing his head about.

;If he sees Bubsy then he will throw an egg at him - this is a random event ( within area )
;when not throwing eggs at Bubsy he just sits swaying his head and juggling an egg in his tail

;the snake sits there and cannot move. He can only fire in the direction he is facing..

;format for object is
;	0				.w	oam set for direction as well as flags
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	last frame in animation		.b	aux0
;	0				.b	aux1
;	0				.b	aux2
;	0				.b	aux3
;	0				.b	flags
;	first sprite in animation	.b	aux4

;	OBJECT	%0000100000000000,SIDAI,sid_dma,SID_MAP,$18,$00,$00,$00,$00,$00			;sid left
;	OBJECT	%0000000000000000,SIDAI,sid_dma,SID_MAP,$18,$00,$00,$00,$00,$00			;sid right


*******************************************************************
;macros	for sprite collation
;head
.macro	shead o1
	if \o1 == 0
	dc.w	0,-25,49		;h0
	endif
	if \o1 == 1
	dc.w	0,-24,50		;h1
	endif
	if \o1 == 2
	dc.w	0,-25,51		;h2
	endif
	if \o1 == 3
	dc.w	0,-26,52		;h3
	endif
	if \o1 == 4
	dc.w	0,-26,52		;h3
	endif
	.endm

;wag tail
.macro	swag o1
	if \o1 == 0
	dc.w	-20,-38,53		;w0
	endif
	if \o1 == 1
	dc.w	-24,-37,54		;w1
	endif
	if \o1 == 2
	dc.w	-31,-33,55		;w2
	endif

	if \o1 == 3
	dc.w	-28,-26,56		;t0
	endif
	if \o1 == 4
	dc.w	-27,-27,57		;t1
	endif
	if \o1 == 5
	dc.w	-28,-36,58		;t2
	endif
	if \o1 == 6
	dc.w	-27,-32,59		;t3
	endif
	if \o1 == 7
	dc.w	-31,-29,60		;t4
	endif
	.endm

.macro	stoss o1
	if \o1 == 0
	dc.w	-24,-48,45		;sw0
	endif
	if \o1 == 1
	dc.w	-22,-67,46		;sw1
	endif
	if \o1 == 2
	dc.w	-24,-71,47		;sw2
	endif

	if \o1 == 3
	dc.w	-22,-76,48		;st3
	endif
	if \o1 == 4
	dc.w	-24,-71,45		;st4
	endif
	if \o1 == 5
	dc.w	-22,-67,46		;st5
	endif
	if \o1 == 6
	dc.w	-24,-48,47		;st6
	endif
	.endm

;stick tongue out
.macro	hiss
	dc.w	16,-16,\1+62
	.endm

;blink close eyes
.macro	sblink
	dc.w	24-16-4,-23,61
	.endm

***	macros for collision detection

.macro	Sshead o1
	dc.l	0,0
	dc.w	0,0,20,-6
	
	if \o1 == 0
	dc.w	14,-24		;h0
	endif
	if \o1 == 1
	dc.w	14,-22		;h1
	endif
	if \o1 == 2
	dc.w	11,-23		;h2
	endif
	if \o1 == 3
	dc.w	14,-24		;h3
	endif
	if \o1 == 4
	dc.w	14,-24		;h3
	endif
	.endm

;wag tail
.macro	Sswag o1
	DC.W	-2,-22,-17,-1
	if \o1 == 0
	dc.w	-17,-37			;w0
	endif
	if \o1 == 1
	dc.w	-22,-34			;w1
	endif
	if \o1 == 2
	dc.w	-29,-30			;w2
	endif

	if \o1 == 3
	dc.w	-23,-24			;t0
	endif
	if \o1 == 4
	dc.w	-23,-25			;t1
	endif
	if \o1 == 5
	dc.w	-23,-28			;t2
	endif
	if \o1 == 6
	dc.w	-18,-28			;t3
	endif
	if \o1 == 7
	dc.w	-25,-21			;t4
	endif
	.endm

.macro	Soff o1,o2,o3,o4,o5,o6,o7,o8,o9,oa,ob,oc,od,oe
	dc.l	0,0			;2 dummy words x,y + map long - blank
	dc.w	\o3-\o1,-(\o2+\o4)		;6 points
	dc.w	\o5-\o1,-(\o2+\o6)
	dc.w	\o7-\o1,-(\o2+\o8)

	dc.w	\o9-\o1,-(\o2+\oa)
	dc.w	\ob-\o1,-(\o2+\oc)
	dc.w	\od-\o1,-(\o2+\oe)
	.endm

.macro	Sswing o1
	if \o1 == 0
	Soff	16,00,00,03,16,00,30,50,20,27,53,40,67,19
	endif
	if \o1 == 1
	Soff	16,00,00,03,16,00,01,13,22,25,48,12,62,02
	endif
	if \o1 == 2
	Soff	16,00,00,03,16,00,02,18,19,25,35,20,51,06
	endif
	if \o1 == 3
	Soff	16,00,00,03,16,00,37,02,03,20,18,33,44,17
	endif
	if \o1 == 4
	Soff	17,00,00,03,16,00,38,04,15,22,33,21,21,36
	endif
	endm

.macro	SID_KILL_BUBSY
	move.w	#$0601,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#FALLBACKSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

*******************************************************************

SID_ANIM_SPEED		equ	8
SID_RANGE_KILLY		equ	40
SID_RANGE		equ	130
SID_THROW_SPEED		equ	5
SID_THROW_FRAME		equ	$19
SID_THROW_FRAMES	equ	4
SID_WAIT_FRAME		equ	0
SID_WAIT_FRAMES		equ	18
SID_THROW_NOW		equ	6

*******************************************************************

SIDAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPYSMALL				; in range y

	SID_KILL_BUBSY

	jsr	STICKOBJECTTOPLAYFIELD
	
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#SID_ANIM_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.no_spitting
	
	cmp.b	#SID_THROW_NOW,OBJAUX1(a5)
	bne	.no_spitting
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below:
	cmp.w	#SID_RANGE_KILLY,d0		;allow bubsy to creep up on guard
	bgt	.no_spitting			;dy too great
	
	tst.w	OBJOAM0(a5)
	beq.s	.facing_right
	
	move.w	OBJX(a5),d0			;and within area
	sub.w	BUBX,d0
	bmi	.no_spitting			; bubsy must be facing sid
	bra.s	.cont
.facing_right:
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0			; and within area
	bmi	.no_spitting			; bubsy must be facing sid
.cont:
	cmp.w	#SID_RANGE,d0
	bgt.w	.no_spitting	;bgt.s->bgt.w

	move.l	a5,a6
	
	move.w	#$3fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.RESTOREDP				;if no key then fail
	
	move.w	OBJOAM0(a6),OBJOAM0(a5)
	move.w	#$7eff,OBJKEY(a5)			;e==not dropped but thrown
	
	move.l	#SIDS_EGG,OBJINITDMA(a5)		;view as an egg
	tst.b	NOT_ALI
	beq.s	.its_ali
	move.l	#SIDS_EGG1,OBJINITDMA(a5)		;view as an egg
.its_ali:
	move.l	#THROWNEGGAI,OBJAI(a5)			;set up the egg vector
	sf	OBJFRAME(a5)
	move.l	#EGGMAP,OBJMAP(a5)			;set up eggs frames
	move.w	OBJX(a6),d1
	move.w	OBJY(a6),d0
	sub.w	#20,d0	
	move.w	d0,OBJY(a5)
	clr.w	OBJVY(a5)				;set up Vy
	move.w	#$0800,d0
	tst.b	OBJOAM0(a5)
	beq.s	.ok
	move.w	#-$0800,d0
	sub.w	#80,d1
.ok:	add.w	#40,d1
	move.w	d1,OBJX(a5)				;set up x,y
	move.w	#1,OBJAUX4(a5)				;set proximity fuse
	move.w	d0,OBJVX(a5)				;set up Vx

.RESTOREDP:
	move.l	a6,a5
	bra.s	.SIDINITTHROW
	
.no_spitting:
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	OBJAUX0(a5),d0
	ble.s	.no_wrap
	moveq	#0,d0
.no_wrap:
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bra	DRAW_COMPLEX_SPRITE

.SIDINITTHROW:
	move.l	#SIDTHROWAI,OBJAI(a5)
	move.b	#SID_THROW_FRAME,OBJAUX4(a5)				;base for the animation
	move.b	#SID_THROW_FRAMES,OBJAUX0(a5)
	move.b	#SID_THROW_SPEED-1,OBJAUX3(a5)				;draw 1st frame..
	st	OBJAUX1(a5)

*****************************************************************************************

SIDTHROWAI:
	jsr	OBJRANGE							;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	SID_KILL_BUBSY

	jsr	STICKOBJECTTOPLAYFIELD
	
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#SID_THROW_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	move.b	d0,OBJAUX1(a5)
	cmp.b	OBJAUX0(a5),d0
	bgt	.reset_sid						;at the end reset sid to waiting
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bsr	DRAW_COMPLEX_SPRITE
	rts

.reset_sid:
	move.l	#SIDAI,OBJAI(a5)
	move.b	#SID_WAIT_FRAME,OBJAUX4(a5)				;base for the animation
	move.b	#SID_WAIT_FRAMES,OBJAUX0(a5)
	st	OBJAUX1(a5)						;reset anim pointer
	move.b	#SID_ANIM_SPEED-1,OBJAUX3(a5)
	bra	SIDAI

sid_dma:
.sid_bored:
	dc.l	.sidb00			;00
	dc.l	.sidb01			;01
	dc.l	.sidb02			;02
	dc.l	.sidb01			;03
	dc.l	.sidb02			;04
	dc.l	.sidb03			;05
	dc.l	.sidb04			;06
	dc.l	.sidb05			;07
	dc.l	.sidb04			;08
	dc.l	.sidb06			;09
	dc.l	.sidb07			;10

	dc.l	.sidt01			;11
	dc.l	.sidt02			;12
	dc.l	.sidt03			;13
	dc.l	.sidt04			;14
	dc.l	.sidt05			;15
	dc.l	.sidt06			;16
	dc.l	.sidt07
	
	dc.l	.sidb08			;17
	dc.l	.sidb09			;18
	dc.l	.sidb10			;19
	dc.l	.sidb11			;20
	dc.l	.sidb09			;21
	dc.l	.sidb12			;22
	dc.l	.sidb13			;23
	dc.l	.sidb14			;24

.sid_chuck:
	dc.l	.sidc1			;25
	dc.l	.sidc2			;26
	dc.l	.sidc3			;27
	dc.l	.sidc4			;28
	dc.l	.sidc0			;29

.sidb00:
	dc.w	2,0,0,0
	shead	0
	swag	0
.sidb01:
	dc.w	3,0,0,0
	shead	0
	swag	0
	hiss	0
.sidb02:
	dc.w	3,0,0,0
	shead	0
	swag	0
	hiss	1
.sidb03:
	dc.w	4,0,0,0
	shead	0
	swag	0
	hiss	2
	sblink
.sidb04:
	dc.w	2,0,0,0
	shead	1
	swag	0
.sidb05:
	dc.w	2,0,0,0
	shead	2
	swag	0
.sidb06:
	dc.w	2,0,0,0
	shead	0
	swag	5
.sidb07:
	dc.w	2,0,0,0
	shead	0
	swag	7
.sidb08:
	dc.w	2,0,0,0
	shead	0
	swag	4
.sidb09:
	dc.w	2,0,0,0
	shead	0
	swag	3
.sidb10:
	dc.w	3,0,0,0
	shead	0
	swag	1
	hiss	1
.sidb11:
	dc.w	2,0,0,0
	shead	0
	swag	6
.sidb12:
	dc.w	2,0,0,0
	shead	0
	swag	2
.sidb13:
	dc.w	2,0,0,0
	shead	3
	swag	1
.sidb14:
	dc.w	2,0,0,0
	shead	4
	swag	2

.sidc0:
	dc.w	2,-18,0,$24
	dc.w	0,-24,65
	dc.w	13,-37,66
.sidc1:
	dc.w	3,-16,0,$20
	dc.w	10,-53,67
	dc.w	0,-28,68
	dc.w	34,-28,69
.sidc2:
	dc.w	2,-16,0,$20
	dc.w	0,-26,70
	dc.w	36,-21,71
.sidc3:
	dc.w	2,-16,0,$20
	dc.w	0,-26,72
	dc.w	38,-19,73
.sidc4:
	dc.w	1,-17,0,$22
	dc.w	0,-34,74

.sidt01:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	0

.sidt02:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	1

.sidt03:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	2

.sidt04:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	3

.sidt05:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	4

.sidt06:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	5

.sidt07:	dc.w	3,0,0,0
	shead	2
	swag	6
	stoss	6

SID_MAP:
	Sshead	0			;00
	Sswag	0

	Sshead	0			;01
	Sswag	0

	Sshead	0			;02
	Sswag	0

	Sshead	0			;01
	Sswag	0

	Sshead	0			;02
	Sswag	0

	Sshead	0			;03
	Sswag	0

	Sshead	1			;04
	Sswag	0

	Sshead	2			;05
	Sswag	0

	Sshead	1			;04
	Sswag	0

	Sshead	0			;06
	Sswag	5

	Sshead	0			;07
	Sswag	7

	rept	7			;toss
	Sshead	2
	Sswag	5
	endr

	Sshead	0			;08
	Sswag	4

	Sshead	0			;09
	Sswag	3

	Sshead	0			;10
	Sswag	1

	Sshead	0			;11
	Sswag	6

	Sshead	0			;09	
	Sswag	3

	Sshead	0			;12
	Sswag	2

	Sshead	3			;13
	Sswag	1

	Sshead	4			;14
	Sswag	2

	Sswing	0			;chuck ok
	Sswing	1
	Sswing	2
	Sswing	3
	Sswing	4

NOT_ALI:	dc.b	0
	even
