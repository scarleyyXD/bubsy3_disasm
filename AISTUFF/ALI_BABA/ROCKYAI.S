;format for object is
;	0				.w	oam set for direction as well as flags
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	0				.b	aux0
;	0				.b	aux1
;	0				.b	aux2
;	0				.b	aux3
;	0				.b	flags
;	0				.b	aux4

;	OBJECT	%0000100000000000,ROCKYAI,rock_dma,ROCKY_MAP,$00,$00,$00,$00,$00,$00			;rock left
;	OBJECT	%0000000000000000,ROCKYAI,rock_dma,ROCKY_MAP,$00,$00,$00,$00,$00,$00			;rock right


;the rock sits there and occassionaly sticks his tongue out at BUBSY, when licked
;he will fall back and die.

ROCK_LICK_TIMER		equ	20
ROCK_RANGE_KILLY	equ	10
ROCK_RANGE_KILLX	equ	16

ROCKYAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL				; in range y

	tst.b	OBJAUX4(a5)
	bne	.fired_once
	
	tst.b	OBJAUX5(a5)
	beq.s	.no_colliding
	
	move.w	#$0601,d6			;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#FALLBACKSTATE,d0
	jsr	KILLBUBSY
.no_collide
	bra	.firing
.no_colliding
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.just_draw_frame
	
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below
	cmp.w	#ROCK_RANGE_KILLY,d0
	bgt	.just_draw_frame
	
	
	tst.w	OBJOAM0(a5)
	beq.s	.facing_right
	
	moveq	#24,d0
	add.w	BUBX,d0
	sub.w	OBJX(a5),d0			;and within area
	bmi	.just_draw_frame		;bubsy must be facing rock
	bra.s	.cont
.facing_right
	moveq	#-24,d0				;alignment for the rock
	add.w	BUBX,d0
	sub.w	OBJX(a5),d0			; and within area
	bmi.s	.just_draw_frame		; bubsy must be facing rock
.cont	cmp.w	#ROCK_RANGE_KILLX,d0
	bgt.s	.just_draw_frame
	
	move.b	#ROCK_LICK_TIMER,OBJAUX2(a5)	;set waiting timer
	st	OBJAUX5(a5)			;1st frame
	move.b	#2,OBJFRAME(a5)			;show tongue
	sf	OBJAUX3(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE

.fired_once
.just_draw_frame
	moveq	#%10000,d1
	and.w	STIMER,d1
	lsr.w	#4,d1
	move.b	d1,OBJFRAME(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE

.firing
	move.b	OBJAUX2(a5),d0			;count the tongue down
	subq.b	#1,d0
	bne.s	.go_on
	st	OBJAUX4(a5)			;indicate rock is harmless
	sf	OBJFRAME(a5)
.go_on	move.b	d0,OBJAUX2(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE


	
rock_dma
	dc.l	.frame_1
	dc.l	.frame_2
	dc.l	.frame_3
	
.frame_1
	dc.w	1,0,-24,0
	dc.w	-16,0,119

.frame_2
	dc.w	1,0,-24,0
	dc.w	-16,0,120

.frame_3
	dc.w	1,0,-24,0
	dc.w	-16,0,177

ROCKY_MAP
	rept	2
	dc.w	0,0
	dc.l	0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	endr
	
	dc.w	0,0
	dc.l	0
	dc.w	16,0-9
	dc.w	24,-6-9
	dc.w	5,-9-9
	dc.w	13,-1-9
	dc.w	30,-12-9
	dc.w	40,-4-9
	
		