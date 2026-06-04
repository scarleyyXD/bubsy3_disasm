.macro	STARFISH_KILL_BUBSY
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collision
	
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collision:
	.endm

.macro	OCTOPUS_KILL_BUBSY
	move.w	#$0301,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

.macro	parse
	dc.w	\1+O_OFF_X
	dc.w	-(\2)-O_OFF_Y
	dc.w	\3
	.endm

.macro	OCTNORML	o1	; head ->
	if \o1=0
	parse	0,22,19
	endif
	if \o1=1
	parse	0,19,20
	endif
	if \o1=2
	parse	0,15,21
	endif
	.endm

.macro	OCTNORMR	o1	; head <-
	if \o1=0
	parse	-44,26,16
	endif
	if \o1=1
	parse	-44,25,17
	endif
	if \o1=2
	parse	-36,25,18
	endif
	.endm

.macro	OCTATAR	o1		; head ->
	if \o1=0
	parse	-44,16,22
	endif
	if \o1=1
	parse	-34,27,23
	endif
	if \o1=2
	parse	-29,26,24
	endif
	if \o1=3
	parse	-67,25,25
	endif
	if \o1=4
	parse	-57,15,26
	endif
	if \o1=5
	parse	-53,15,30
	endif
	.endm

.macro	OCTATAL	o1		; head <-
	if \o1=0
	parse	0,22,31
	endif
	if \o1=1
	parse	0,26,32
	endif
	if \o1=2
	parse	-4,28,33
	endif
	if \o1=3
	parse	-4,15,34
	endif
	if \o1=4
	parse	0,15,35
	endif
	if \o1=5
	parse	0,15,36
	endif
	.endm

************** equates for the bored stuff ***********

OCTOPUS_BORED_SPEED		equ	16
OCTPUS_BORED_FRAMES		equ	4
OCTOPUS_SEE_RANGE		equ	120

*******	equates for eyes blinking **************

OCTO_EYES_RATE			equ	7
OCTOPUS_MAX_EYE			equ	8
OCTOPUS_FIRST_EYE_FRAME		equ	38
OCTO_EYE_X_OFFSET		equ	-5
OCTO_EYE_Y_OFFSET		equ	-24

*******	equates for basket blinking **************

OCTOPUS_FIRST_BASKET_FRAME	equ	77
OCTO_BASKET_X_OFFSET1		equ	30
OCTO_BASKET_X_OFFSET2		equ	(-OCTO_BASKET_X_OFFSET1)-20
OCTO_BASKET_Y_OFFSET		equ	-14
OCTO_BASKET_RATE		equ	7
OCTOPUS_MAX_BASKET		equ	3

************************************************************
O_OFF_X	equ	2
O_OFF_Y	equ	17

*******	equates for thowing anim **************

OCTOPUS_THROW_SPEED		equ	7
OCTOPUS_THROW_FRAMES		equ	6

*******	equates for starfish's eyes blinking **************

FISH_BLINK_RATE			equ	7
OCTO_R_MAKE_STAR		equ	2
OCTO_R_OFFX			equ	20
OCTO_R_OFFY			equ	-20
OCTO_R_SPEED			equ	4

OCTO_L_MAKE_STAR		equ	2
OCTO_L_OFFX			equ	-20
OCTO_L_OFFY			equ	-20
OCTO_L_SPEED			equ	-OCTO_R_SPEED

****************************************************************

OCTOPUSAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY

	OCTOPUS_KILL_BUBSY

	tst.b	OBJFLAGS(A5)
	bne.s	.stuck_to_ground
	jsr	STICKOBJECTTOPLAYFIELD
	st	OBJFLAGS(a5)
.stuck_to_ground:
	move.w	OBJKEY(A5),d6		;see if a starfish exist
	add.w	#$0100,d6
	
	move.l	a5,a6
	jsr	FINDFREEOBJ
	
;	move.w	sr,-(sp)
	move.l	a6,a5
;	move.w	(sp)+,sr
	
	bcs.s	.none_free
	
	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.xposi
	neg.w	d0	;neg.s->neg.w
.xposi:	cmp.w	#OCTOPUS_SEE_RANGE,d0
	blt	OCTOPUS_START_TO_THROW
.none_free:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.no_new_frame
	move.b	#OCTOPUS_BORED_SPEED-1,OBJAUX0(A5)
	
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	move.b	#OCTPUS_BORED_FRAMES-1,OBJFRAME(A5)
.no_wrap:
.no_new_frame:
	jsr	DRAW_COMPLEX_SPRITE
	bra	OCTOPUS_EYES				;when drawn add the roving eyes.. >>> yes I said roving and not moving...

***************************************************************************************************

OCTOPUS_START_TO_THROW:					;initalise the throw anim
	move.w	OBJX(A5),d0
	cmp.w	BUBX,d0
	blt.s	.to_right				; set up depending upon the animation
	move.l	#OCTOPUS_KILL_L_AI,OBJAI(A5)
	move.l	#OCTOPUS_KILL_L_MAP,OBJMAP(A5)
	move.l	#octopus_kill_l_dma,OBJINITDMA(A5)
	bra.s	.cont
.to_right:
	move.l	#OCTOPUS_KILL_R_AI,OBJAI(A5)
	move.l	#OCTOPUS_KILL_R_MAP,OBJMAP(A5)
	move.l	#octopus_kill_r_dma,OBJINITDMA(A5)
.cont:	move.b	#OCTOPUS_THROW_FRAMES-1,OBJFRAME(A5)
	move.b	#OCTOPUS_THROW_SPEED-1,OBJAUX0(a5)
	jsr	DRAW_COMPLEX_SPRITE
	bra	OCTOPUS_EYES				;when drawn add the roving eyes.. >>> yes I said roving and not moving...
	
***************************************************************************************************

OCTOPUS_KILL_L_AI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY
	
	OCTOPUS_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#OCTOPUS_THROW_SPEED-1,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.not_end_of_anim

	sf	OBJFRAME(A5)
	move.l	#OCTOPUSAI,OBJAI(A5)
	move.l	#OCTOPUSMAP,OBJMAP(A5)
	move.l	#octopus_dma,OBJINITDMA(A5)
	bra.s	.same_frame
.not_end_of_anim:
	cmp.b	#OCTO_L_MAKE_STAR,OBJFRAME(A5)
	bne.s	.carry_on
	move.w	#OCTO_L_OFFX,d0
	move.w	#OCTO_L_OFFY,d1
	move.w	#OCTO_L_SPEED,d2
	bsr	MAKE_FISH
.carry_on:
.same_frame:
	jsr	DRAW_COMPLEX_SPRITE
	bra	OCTOPUS_EYES

***************************************************************************************************

OCTOPUS_KILL_R_AI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY
	
	OCTOPUS_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#OCTOPUS_THROW_SPEED-1,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.not_end_of_anim

	sf	OBJFRAME(A5)
	move.l	#OCTOPUSAI,OBJAI(A5)
	move.l	#OCTOPUSMAP,OBJMAP(A5)
	move.l	#octopus_dma,OBJINITDMA(A5)
	bra.s	.same_frame
.not_end_of_anim:
	cmp.b	#OCTO_R_MAKE_STAR,OBJFRAME(A5)
	bne.s	.carry_on
	move.w	#OCTO_R_OFFX,d0
	move.w	#OCTO_R_OFFY,d1
	move.w	#OCTO_R_SPEED,d2
	bsr	MAKE_FISH
.carry_on:
.same_frame:
	jsr	DRAW_COMPLEX_SPRITE
	bra	OCTOPUS_EYES

***************************************************************************************************
	
MAKE_FISH:
	movem.w	d0-d2,-(sp)
	move.l	a5,a6
	move.w	OBJKEY(A5),d6
	add.w	#$0100,d6
	
	jsr	FINDFREEOBJ
	bcs.s	.none_free
	
	movem.w	(sp),d0-d2
	
	move.w	d6,OBJKEY(A5)
	move.l	#fish_dma,OBJINITDMA(a5)
	move.l	#FISHAI,OBJAI(A5)
	move.l	#FISH_MAP,OBJMAP(a5)
	add.w	OBJX(a6),d0
	add.w	OBJY(a6),d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)
	move.w	d2,OBJAUX0(a5)		;set speed
	clr.w	OBJAUX2(a5)
.none_free:
	addq.l	#6,sp
	move.l	a6,a5
	rts

OCTOPUSMAP:
OCTOPUS_KILL_R_MAP:
OCTOPUS_KILL_L_MAP:
	rept	8
	Soff	0,0,-8,0,8,0,-8,10,8,10,-8,27,8,27
	endr

octopus_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame1

.frame0:	dc.w	2,0,0,-1
	OCTNORMR	0
	OCTNORML	0
.frame1:	dc.w	2,0,0,-1
	OCTNORMR	1
	OCTNORML	1
.frame2:	dc.w	2,0,0,-1
	OCTNORMR	2
	OCTNORML	2

octopus_kill_l_dma:
	dc.l	.framer5
	dc.l	.framer4
	dc.l	.framer3
	dc.l	.framer2
	dc.l	.framer1
	dc.l	.framer0
	
.framer0:
	dc.w	2,0,0,-1		;0	; right tendril -->>
	OCTNORML	0
	OCTATAR		0
.framer1:
	dc.w	2,0,0,-1		;1
	OCTNORML	1
	OCTATAR		1
.framer2:
	dc.w	2,0,0,-1		;2
	OCTNORML	2
	OCTATAR		2
.framer3:
	dc.w	2,0,0,-1		;3
	OCTNORML	0
	OCTATAR		3
.framer4:
	dc.w	2,0,0,-1		;4
	OCTNORML	1
	OCTATAR		4
.framer5:
	dc.w	2,0,0,-1		;5
	OCTNORML	2
	OCTATAR		5

octopus_kill_r_dma:
	dc.l	.framel5
	dc.l	.framel4
	dc.l	.framel3
	dc.l	.framel2
	dc.l	.framel1
	dc.l	.framel0

.framel0:
	dc.w	2,0,0,-1		;0	; left tendril <<--
	OCTNORMR	0
	OCTATAL		0

.framel1:
	dc.w	2,0,0,-1		;1
	OCTNORMR	1
	OCTATAL		1

.framel2:
	dc.w	2,0,0,-1		;2
	OCTNORMR	2
	OCTATAL		2
	
.framel3:
	dc.w	2,0,0,-1		;3
	OCTNORMR	0
	OCTATAL		3

.framel4:
	dc.w	2,0,0,-1		;4
	OCTNORMR	1
	OCTATAL		4

.framel5:
	dc.w	2,0,0,-1		;5
	OCTNORMR	2
	OCTATAL		5
	
*********************************************************************************
*										*
*	Starfish thrown by octopus						*
*										*
*********************************************************************************

FISHAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY
	
	STARFISH_KILL_BUBSY
	
	subq.b	#1,OBJAUX6(a5)
	bpl.s	.same_frame
	eor.b	#1,OBJFRAME(A5)
	move.b	#FISH_BLINK_RATE,OBJAUX6(a5)
.same_frame:
	move.w	OBJAUX0(a5),d0		; update the starfish
	move.w	OBJAUX2(a5),d1
	add.w	d0,OBJX(A5)
	add.w	d1,OBJY(a5)
	
	move.w	OBJX(A5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	and.w	#ATTR_MASK,d0
	beq.s	.just_draw_starfish
	
	move.w	OBJY(A5),-(sp)
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	(sp)+,d0
	cmp.w	OBJY(a5),d0
	blt.s	.just_draw_starfish
	jmp	CLEAROBJWVRAM
.just_draw_starfish:
	jmp	DRAW_COMPLEX_SPRITE
fish_dma:
	dc.l	.frame0
	dc.l	.frame1

.frame0:	dc.w	1,0,0,-1
	dc.w	-9,-8,14
.frame1:	dc.w	1,0,0,-1
	dc.w	-9,-8,15

FISH_MAP:
	rept	2
	Soff	0,0,0,0,0,7,8,1,-8,1,-6,-8,6,-8
	endr

*********************************************************************************

; places the eyes on the octopus and the basket of fish
; eyes require OBJAUX6 & 7
; basket require OBJAUX4 & 5

OCTOPUS_EYES:
	moveq	#0,d4
	move.b	OBJAUX6(A5),d4				; eye frame
	subq.b	#1,OBJAUX7(a5)				; wait counter
	bpl.s	.same_frame
	move.b	#OCTO_EYES_RATE,OBJAUX7(a5)
	subq.b	#1,d4
	bpl.s	.no_wrap
	moveq	#OCTOPUS_MAX_EYE-1,d4
.no_wrap:
	move.b	d4,OBJAUX6(a5)
.same_frame:
	lea	.eyes,a1	; hang me if this doesn't work
	move.b	(a1,d4.w),d4
	add.b	#OCTOPUS_FIRST_EYE_FRAME,d4		;get frame number
	
	move.l	LOAD_LEVEL_SPRITES_HERE,a0		;get addr of sprites
	
	move.w	#OCTO_EYE_X_OFFSET,d0			;get x , y position
	move.w	#OCTO_EYE_Y_OFFSET,d1
	add.w	OBJX(A5),D0
	add.w	OBJY(A5),D1
	SUB.w	WINDX,D0
	SUB.w	WINDY,D1
	jsr	print_a_sprite_normal
.OCTOPUS_BASKET:
	moveq	#OCTOPUS_FIRST_BASKET_FRAME,d4
	move.l	LOAD_LEVEL_SPRITES_HERE,a0		;get addr of sprites
	move.w	#OCTO_BASKET_X_OFFSET1,d0		;get x , y position
	move.w	#OCTO_BASKET_Y_OFFSET,d1
	add.w	OBJX(A5),D0
	add.w	OBJY(A5),D1
	SUB.w	WINDX,D0
	SUB.w	WINDY,D1
	jsr	print_a_sprite_normal
	
	moveq	#OCTOPUS_FIRST_BASKET_FRAME,d4
	move.l	LOAD_LEVEL_SPRITES_HERE,a0		;get addr of sprites
	move.w	#OCTO_BASKET_X_OFFSET2,d0		;get x , y position
	move.w	#OCTO_BASKET_Y_OFFSET,d1
	add.w	OBJX(A5),D0
	add.w	OBJY(A5),D1
	SUB.w	WINDX,D0
	SUB.w	WINDY,D1
	jmp	print_a_sprite_normal
	
.eyes:	dc.b	0,0,1,2,2,1,0,3,3
	even
