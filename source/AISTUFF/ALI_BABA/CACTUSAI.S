
;when activated the catus will move in a direction towrads BUBSY only
;if bubsy is not on the ground or if bubsy is not facing the cactus.

;If bubsy gets in range then he will throw his arm (spiky ) to defate bubsy ego
; The cactus can walk..

; if the cactus reaches a slope of wall then he will change direction..




;different types of objects for wake and asleep
;format for object is
;	0				.w	oam - not bothered about flip - its done
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	last frame in animation		.b	aux0
;	0				.b	aux1
;	0				.b	aux2
;	0				.b	aux3
;	0				.b	flags
;	first sprite in animation	.b	aux4

;	OBJECT	%0000000000000000,CACTUSAI,cactus_dma,CACTUS_MAP,$00,$00,$00,$00,$00,$00			;cactus

*********************************************************************************************************************

CATCUS_RANGE_CREEPY	equ	32
CATCUS_RANGE_CREEPX	equ	200
CATCUS_FACE_SPEED	equ	20
CACTUSSKIRTSPEED	equ	15
CSKIRTFRAME		equ	8

CACTUS_RUN_SPEED	equ	8
CWALKFRAME		equ	12
CACTUS_DX		equ	6

CSKIRTFRAMED		equ	26
CTHROW			equ	19

CACTUS_RANGE_KILLY	equ	20
CACTUS_RANGE_KILLX	equ	100
CACTUS_KILL_FRAMES	equ	5
CACTUS_KILL_SPEED	equ	7
CKILLFRAME		equ	20

.macro	Ccacts
	Soff	1,0,0,0,0,50,-21,30,-24,50,21,30,24,50
	.endm
.macro	Ccactt	o1
	if \o1 == 0
	Soff	7,1,0,0,-9,29,-1,48,14,44,12,0,25,27
	endif
	if \o1 == 1
	Soff	12,8,0,0,5,18,21,33,35,33,31,19,23,1
	endif
	if \o1 == 2
	Soff	12,11,0,0,6,21,27,32,35,19,24,2,22,-10
	endif
	.endm

.macro	Ccactw	o1
	if \o1 == 0
	Soff	9,8,0,0,14,9,0,24,0,39,9,4,14,37
	endif
	if \o1 == 1
	Soff	13,6,0,0,-1,17,-12,38,0,45,12,30,28,21
	endif
	if \o1 == 2
	Soff	20,7,0,0,0,15,-18,30,-4,36,10,24,26,8
	endif
	if \o1 == 3
	Soff	28,11,0,0,16,20,29,33,49,32,28,17,33,5
	endif
	if \o1 == 4
	Soff	6,8,0,0,0,40,0,19,15,12,8,25,14,44
	endif
	if \o1 == 5
	Soff	5,15,0,0,-10,20,-11,36,-2,36,14,23,12,1
	endif
	if \o1 == 6
	Soff	11,15,0,0,6,16,15,30,35,26,18,18,21,2
	endif
	if \o1 == 7
	Soff	10,8,0,0,-6,11,-20,30,-2,31,11,21,22,9
	endif
	.endm

.macro	Ccactf	o1
	if \o1 == 0
	Soff	7,1,0,0,-7,28,-1,46,12,7,31,29,11,49
	endif
	if \o1 == 1
	Soff	10,1,0,0,-22,20,-22,42,-14,48,5,32,12,0
	endif
	if \o1 == 2
	Soff	10,1,0,0,-29,9,-37,40,-16,40,5,20,12,0
	endif
	if \o1 == 3
	Soff	8,1,0,0,-3,30,15,44,36,34,57,28,15,15
	endif
	if \o1 == 4
	Soff	-110,27-1,0,1,-8,2,-15,-2,-60,0,-30,0,-129,6
	endif
	.endm

*********************************************************************************************************************

.macro	CACTUS_KILL_BUBSY
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

.macro	CACTUS_KILL_BUBSY_BIG
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

*********************************************************************************************************************

CACTUSAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	CACTUS_KILL_BUBSY

	jsr	STICKOBJECTTOPLAYFIELD

	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.animate

	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below1
	neg.w	d0
.below1:
	cmp.w	#CACTUS_RANGE_KILLY,d0
	bgt.s	.dontkillbubsy
	
	moveq	#0,d7
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	move.w	d0,d1
	bpl.s	.ok1
	moveq	#%00001000,d7
	neg.w	d0
.ok1:
	cmp.w	#CACTUS_RANGE_KILLX,d0
	blt	CACTUSTRYKILLBUBSYINIT
.dontkillbubsy:
	moveq	#ANCHORFLAG,d0			;cactus only detects if bubsy is on the ground
	and.b	BUBSYFLAGS,d0
	beq.s	.animate
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below:
	cmp.w	#CATCUS_RANGE_CREEPY,d0		;allow bubsy to creep up on cactus
	bgt.s	.animate			;dy too great

	move.w	OBJX(a5),d0			;and within area
	sub.w	BUBX,d0
	bpl.s	.ive
	neg.w	d0
.ive:
	cmp.w	#CATCUS_RANGE_CREEPX,d0
	bgt.s	.animate

	moveq	#BUBSYHFLIP,D3
	and.B	BUBSYFLAGS,D3			;see if bubsy is h flipped - facing left
	bne.s	.bubfacingleft
	
	moveq	#0,d7
	move.w	OBJX(a5),d0			;if behind bubsy then outcome is -ive
	sub.w	BUBX,d0
	bmi.s	creep_cactus
	bra.s	.animate

.bubfacingleft:
	moveq	#%00001000,d7
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0			;if behind bubsy then outcome is -ive
	bmi.s	creep_cactus

.animate:
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#CATCUS_FACE_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw

.increment:
	sf	OBJAUX3(a5)
	
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

creep_cactus:
	move.l	#CACTUSSKIRTUPAI,OBJAI(A5)	; point to ai routine
	move.b	d7,OBJOAM0(a5)			; set up the direction
	move.b	#4,OBJAUX0(a5)			; ensure next frame is 0
	st	OBJAUX1(a5)			; set up for initial frame
	move.b	#CACTUSSKIRTSPEED-1,OBJAUX3(a5)
	move.b	#CSKIRTFRAME,OBJAUX4(a5)	; all set up

CACTUSSKIRTUPAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	CACTUS_KILL_BUBSY

	jsr	STICKOBJECTTOPLAYFIELD
	
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#CACTUSSKIRTSPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra.s	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	OBJAUX0(a5),d0
	beq.s	.start_walk
.no_wrap:
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bra	DRAW_COMPLEX_SPRITE

.start_walk:
CACTUSRESETWALK:
	move.l	#CACTUSWALKAI,OBJAI(A5)		; point to ai routine
	move.b	#8,OBJAUX0(a5)			; ensure next frame is 0
	st	OBJAUX1(a5)			; set up for initial frame
	move.b	#2,OBJAUX2(a5)			; creep for 2 cycles
	move.b	#CACTUS_RUN_SPEED-1,OBJAUX3(a5)
	move.b	#CWALKFRAME,OBJAUX4(a5)	; all set up

CACTUSWALKAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	CACTUS_KILL_BUBSY

	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#CACTUS_RUN_SPEED,d0
	beq.s	.INCREMENT
	move.b	d0,OBJAUX3(a5)
	bra	.NOINCREMENT

.INCREMENT:
	move.w	OBJY(a5),d0						;set up y to check if we will walk over the dege
	addq.w	#5,d0
	move.w	d0,d2
	sub.w	#10,d0
	move.w	d0,TEMP5						;set up for checking for floor

	moveq	#-CACTUS_DX,d1
	moveq	#-CACTUS_DX,d6
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	bne.s	.WALKLEFT
	moveq	#CACTUS_DX,d6
	moveq	#CACTUS_DX,d1
.WALKLEFT:
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB						;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP5,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB						;x+dx,y-5
	or.w	TEMP7,d0
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL
	and	d0,d0							;0 then it must be nothing
	beq.s	.change_direction
	bra.s	.all_ok

.CHECKWALL:								;check if we will hit a wall
	move.w	d7,d0
	and.w	#WALL_CTRL,d0
	beq.s	.all_ok							;hit into wall
	
.change_direction:
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move
.all_ok:
	add.w	d6,OBJX(a5)						;move the cactus by d6
.no_move:
.DONETHIS:
	moveq	#0,d0
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	and.b	#7,d0
	bne.s	.no_wrap
	subq.b	#1,OBJAUX2(a5)
	bmi	.check_for_stop
.no_wrap:
	move.b	d0,OBJAUX1(a5)						;pointer to frame number
	add.b	OBJAUX4(a5),d0						;offset in complex sprite table
	move.b	d0,OBJFRAME(a5)
	sf	OBJAUX3(a5)
	jsr	STICKOBJECTTOPLAYFIELD
.NOINCREMENT:
	bsr	DRAW_COMPLEX_SPRITE
	rts

.check_for_stop:
.stop_me:					; don't change direction cactus is facing
CACTUSSKIRTDOWNINITAI:
	move.l	#CACTUSSKIRTDOWNAI,OBJAI(A5)	; point to ai routine
	move.b	#4,OBJAUX0(a5)			; ensure next frame is 0
	st	OBJAUX1(a5)			; set up for initial frame
	move.b	#CACTUSSKIRTSPEED-1,OBJAUX3(a5) ; ensure we are ready to do 1st frame
	move.b	#CSKIRTFRAMED,OBJAUX4(a5)	; all set up

CACTUSSKIRTDOWNAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	CACTUS_KILL_BUBSY

	jsr	STICKOBJECTTOPLAYFIELD
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#CACTUSSKIRTSPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra.s	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	OBJAUX0(a5),d0
	beq.s	RESET_CACTUS
.no_wrap:
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bra	DRAW_COMPLEX_SPRITE

RESET_CACTUS:
	sf	OBJOAM0(a5)
	move.b	#7,OBJAUX0(a5)
	st	OBJAUX1(a5)
	move.b	#2,OBJAUX2(a5)
	sf	OBJAUX3(a5)
	sf	OBJAUX4(a5)
	sf	OBJFLAGS(a5)
	lea	CACTUSAI(pc),a0
	move.l	a0,OBJAI(a5)
	jmp	(a0)

CACTUSTRYKILLBUBSYINIT:
	move.b	d7,OBJOAM0(a5)			; set direction of the throw
	move.l	#CACTUSKILLAI,OBJAI(A5)		; point to ai routine
	sf	OBJAUX0(a5)
	st	OBJAUX1(a5)
	sf	OBJAUX2(a5)
	move.b	#CACTUS_KILL_SPEED-1,OBJAUX3(a5)
	move.b	#CKILLFRAME,OBJAUX4(a5)	; all set up

CACTUSKILLAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	CACTUS_KILL_BUBSY_BIG

	jsr	STICKOBJECTTOPLAYFIELD
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#CACTUS_KILL_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra.s	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	#CACTUS_KILL_FRAMES,d0
	beq	RESET_CACTUS
.no_wrap:
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bra	DRAW_COMPLEX_SPRITE

*********************************************************************************************************************

cactus_dma:
	dc.l	.cacts0		;00
	dc.l	.cacts1		;01
	dc.l	.cacts2		;02
	dc.l	.cacts3		;03
	dc.l	.cacts4		;04
	dc.l	.cacts5		;05
	dc.l	.cacts6		;06
	dc.l	.cacts7		;07
	
	dc.l	.cactf0		;08
	dc.l	.cactt0		;09
	dc.l	.cactt1		;10
	dc.l	.cactt2		;11
	
	dc.l	.cactw0		;12
	dc.l	.cactw1		;13
	dc.l	.cactw2		;14
	dc.l	.cactw3		;15
	dc.l	.cactw4		;16
	dc.l	.cactw5		;17
	dc.l	.cactw7		;18
	dc.l	.cactw6		;19
	
	dc.l	.cactf0		;20
	dc.l	.cactf1		;21
	dc.l	.cactf2		;22
	dc.l	.cactf3		;23
	dc.l	.cactf4		;24
	dc.l	.cactf0		;25

	dc.l	.cactt2		;26
	dc.l	.cactt1		;27
	dc.l	.cactt0		;28
	dc.l	.cactf0		;29

.cacts0:
	dc.w	2,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	
.cacts1:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,81
	
.cacts2:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,82
	
.cacts3:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,83
	
.cacts4:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,84
	
.cacts5:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,85
	
.cacts6:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,86
	
.cacts7:
	dc.w	3,0,0,-1
	dc.w	-8,-26,80
	dc.w	-29,-53,79
	dc.w	-9,-44,87
	
.cactt0:
	dc.w	2,0-17,0,32
	dc.w	0,-52,88
	dc.w	28,$ffdf,89
.cactt1:
	dc.w	2,1-17,0,30
	dc.w	0,-43,90
	dc.w	34,-43,91
.cactt2:
	dc.w	2,1-17,0,29
	dc.w	0,-43,92
	dc.w	34,-43,93

.cactw0:
	dc.w	1,-15,0,32
	dc.w	0,-54,94
.cactw1:
	dc.w	2,-(16+6+3)+1,0,32
	dc.w	-3,-54,95
	dc.w	0,-37,96
.cactw2:
	dc.w	2,-(16+2+6),0,32
	dc.w	-16,-49,97
	dc.w	0,-28,98
.cactw3:
	dc.w	2,-(16+3+6)-2,0,32
	dc.w	16,-48,99
	dc.w	0,-32,100
.cactw4:
	dc.w	1,-(16+3+3)+4+1+1,0,32
	dc.w	0,-55,101
.cactw5:
	dc.w	2,-(16+1)-4+1,0,32
	dc.w	0,-57,102
	dc.w	28,-39,103
.cactw6:
	dc.w	2,-16-2-3-5+1,0,32
	dc.w	21,-50,104
	dc.w	0,-33,105
.cactw7:
	dc.w	2,-16-1-4-5+1,0,32
	dc.w	-10,-48,106
	dc.w	0,-28,107

.cactf0:
	dc.w	2,-16+1+1,0,26
	dc.w	0,-52,108
	dc.w	26,-36-1,109
.cactf1:
	dc.w	2,-16+1,0,$1f-4-2
	dc.w	-18,-50,110
	dc.w	0,-13,111
.cactf2:
	dc.w	2,-15+1,0,$17-1
	dc.w	-36,-47+2,112
	dc.w	0,-32,113
.cactf3:
	dc.w	2,-18+1,0,$1f-1
	dc.w	2,-50,114
	dc.w	0,-21,115
.cactf4:
	dc.w	3,-8+1,0,$d-2
	dc.w	-16,-35,116
	dc.w	17,-45,117
	dc.w	0,-20,118

*********************************************************************************************************************

CACTUS_MAP:
	Ccacts		;00
	Ccacts		;01
	Ccacts		;02
	Ccacts		;03
	Ccacts		;04
	Ccacts		;05
	Ccacts		;06
	Ccacts		;07
	
	Ccactf	0	;08
	Ccactt	0	;09
	Ccactt	1	;10
	Ccactt	2	;11
	
	Ccactw	0	;12
	Ccactw	1	;13
	Ccactw	2	;14
	Ccactw	3	;15
	Ccactw	4	;16
	Ccactw	5	;17
	Ccactw	7	;18
	Ccactw	6	;19
	
	Ccactf	0	;20
	Ccactf	1	;21
	Ccactf	2	;22
	Ccactf	3	;23
	Ccactf	4	;24
	Ccactf	0	;25

	Ccactt	2	;26
	Ccactt	1	;27
	Ccactt	0	;28
	Ccactf	0	;29
