
VULTURE_WIDTH	equ	-30

;format for object is
;	OAM				.w	oam 
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	X speed				.b	aux0
;	0				.b	aux1 - used to check if weight dropped (0 or 4)
;	0				.b	aux2 - counter set to 0
;	0				.b	aux3 - frame rate for animation
;	0				.b	flags - not used set to 0
;	0				.b	aux4 - offset into animation


;	OBJECT	%0000000000000000,VULTUREAI,vulture_dma,VULTURE_MAP,$05,$00,$00,$00,$00,$00			;vulture right speed 5
;	OBJECT	%0000100000000000,VULTUREAI,vulture_dma,VULTURE_MAP,$-05,$00,$00,$00,$00,$00			;vulture right speed 5

******************************************************************************************************

V_FREE		equ	10
TON_SPRITE_FREE	equ	164
TON_SPRITE	equ	163
T_OFFSET	equ	(-22-4)
T_FLIP_OFFSET	equ	(0-4)
T_Y_OFFSET	equ	(15)
FIRST_T_Y	equ	12
V_CHANGE_HEIGHT	equ	16*2

******************************************************************************************************

.macro Vulturew
	if \1=-1
	Soff	22,-32,0,0,0,0,0,0,0,0,0,0,0,0
	endif
	if \1=0
	Soff	22,-32,0,0,22,0,-2,34,8,37,21,46,46,30
	endif
	if \1=1
	Soff	22,-32,0,0,22,0,-2,34,7,63,27,56,45,30
	endif
	if \1=2
	Soff	22,-32,0,0,22,0,-1,38,10,60,29,51,40,38
	endif
	if \1=3
	Soff	22,-32,0,0,22,0,-1,39,14,41,26,38,45,34
	endif
	.endm

.macro	Vulturef
	if \1=-1
	Soff	0,0,0,0,0,0,0,0,0,0,0,0,0,0
	endif
	if \1=0
	Soff	23,0,0,0,16,-6,6,12,12,28,28,21,45,3
	endif
	if \1=1
	Soff	23,1,0,0,14,-13,26,-23,46,1,27,5,16,8
	endif
	if \1=2
	Soff	23,4,0,0,18,1,12,-22,28,-17,35,-3,46,-11
	endif
	if \1=3
	Soff	23,3,0,0,21,-8,43,-5,8,14,20,29,30,14
	endif
	.endm

.macro	VULTURE_TURN
	moveq	#VULTURE_WIDTH,d1
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d0
.going_right:
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.carry_on
	eor.b	#8,OBJOAM0(a5)
	neg.b	OBJAUX0(a5)
.carry_on:
	.endm

.macro	VULTURE_KILL_BUBSY
	move.w	#$0701,d6
	moveq	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.not_dead
	moveq	#SMASH,d0
	jsr	STARTSOUND
	moveq	#ROLLFALLSTATE,d0
	jsr	KILLBUBSY
.not_dead:
	.endm

.macro	WEIGHT_KILL_BUBSY
	move.w	#$0701,d6
	moveq	#SMASH,d7
	jsr	EZNOBOPCOLLIDE
	bcc.s	.not_dead
	moveq	#SMASH,d0
	jsr	STARTSOUND
	moveq	#ACCORDIANSTATE,d0
	jsr	KILLBUBSY
.not_dead:
	.endm

******************************************************************************************************

VULTUREAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	VULTURE_KILL_BUBSY
	
	VULTURE_TURN
	
	move.b	OBJAUX0(a5),d0			;get speed moving at
	ext.w	d0
	add.w	d0,OBJX(a5)			;add that to the x position
	
	tst.b	OBJAUX1(a5)
	bne	dropped_weight

	move.w	BUBX,d0				;if in range drop the weight
	subi.w	#16*4,d0
	cmp.w	OBJX(a5),d0
	bcc	dropped_weight
	addi.w	#32*4,d0
	cmp.w	OBJX(a5),d0
	bcs	dropped_weight

	move.l	#VULTUREAIDIVING,OBJAI(a5)	;indicate vulture is in dive mode
	move.b	#16,OBJAUX7(a5)			;how long the vulture will dive for before releasing the weight
	move.b	#10,OBJAUX6(a5)			;how long to wait after dive

VULTUREAIDIVING:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	VULTURE_KILL_BUBSY

	VULTURE_TURN
	
	move.b	OBJAUX0(a5),d0			;get speed moving at
	ext.w	d0
	add.w	d0,OBJX(a5)			;add that to the x position
	
	tst.b	OBJAUX7(a5)
	beq.s	.no_dive
	subq.b	#1,OBJAUX7(a5)
	addq.w	#1,OBJY(a5)
	
	moveq	#VULTURE_WIDTH,d1
	tst.b	OBJOAM0(a5)
	beq.s	.going_right1
	neg.w	d0
.going_right1:
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.carry_on1
	subq.w	#1,OBJY(a5)
.carry_on1:
	bra	dropped_weight			;wait for the countdown
.no_dive:	
	tst.b	OBJAUX6(a5)
	beq.s	.no_wait
	subq.b	#1,OBJAUX6(a5)
	bra	dropped_weight			;wait for the countdown
.no_wait:
	tst.b	OBJAUX1(a5)
	bne	dropped_weight

	move.w	BUBX,d0				;if in range drop the weight
	subi.w	#16,d0
	cmp.w	OBJX(a5),d0
	bcc	dropped_weight
	addi.w	#32,d0
	cmp.w	OBJX(a5),d0
	bcs.s	dropped_weight

	move.l	a5,a6

	move.w	#$3fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.RESTOREDP

	clr.w	OBJOAM0(a5)
	move.w	#$7ffe,OBJKEY(a5)		;one existant key

	lea	WEIGHTAI(pc),a0
	move.l	a0,OBJAI(a5)			;set up AI for weight
	move.l	#TON_MAP,OBJMAP(a5)		;set up collision map for weight

	sf	OBJFRAME(a5)			;ensure 1st frame for collision..
	moveq	#-$14,d4
	tst.b	OBJOAM0(a6)			;see if we are facing left or right
	beq.s	.faceright
	moveq	#0,d4
.faceright:	
	add.w	OBJX(a6),d4			;we need to activate egg, save x and y

	move.w	d4,OBJX(a5)			;set up x and y
	move.w	OBJY(a6),d4
	add.w	#FIRST_T_Y,d4
	move.w	d4,OBJY(a5)

	moveq	#64,d0
	tst.b	OBJOAM0(a6)			;see direction vulture is flying
	beq.s	.swaped
	moveq	#-64,d0
.swaped:	move.w	d0,OBJVX(a5)			;set up vx and vy
	clr.w	OBJVY(a5)
	pea	(a6)
	jsr	(a0)				;ensure we draw the frame for the weight
	move.l	(sp)+,a5
	move.b	#4,OBJAUX1(a5)
	move.b	#V_FREE-1,OBJAUX2(a5)
	move.b	#V_FREE,OBJAUX3(a5)
	move.b	#V_CHANGE_HEIGHT,OBJAUX5(a5)	;set up height change
	bra.s	dropped_weight

.RESTOREDP:
	move.l	a6,a5
	
dropped_weight:
	moveq	#0,d0
	move.b	OBJAUX5(a5),d0
	beq.s	.no_height_change
	subq	#1,d0
	move.b	d0,OBJAUX5(a5)
	lsr.w	#3,d0
	move.w	OBJY(a5),d6
	sub.w	d0,OBJY(a5)				;move bird up 1 pixel
	
	moveq	#VULTURE_WIDTH,d1
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d0
.going_right:
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.carry_on
	move.w	d6,OBJY(a5)
.carry_on:

.no_height_change:
	move.b	OBJAUX2(a5),d0				;see if time for a change
	addq	#1,d0
	cmp.b	OBJAUX3(a5),d0
	bne.s	.draw_frame
	
	move.b	OBJAUX4(a5),d0				;if so then update counter
	addq	#1,d0
	and.b	#3,d0
	move.b	d0,OBJAUX4(a5)
	or.b	OBJAUX1(a5),d0				;add sprite offset
	move.b	d0,OBJFRAME(a5)
	
	moveq	#0,d0
.draw_frame:
	move.b	d0,OBJAUX2(a5)
	bsr	DRAW_COMPLEX_SPRITE
	tst.b	OBJAUX1(a5)				;if 4 then free thus no weight
	beq.s	.ton
	rts
.ton:	moveq	#T_OFFSET,d0
	tst.b	OBJOAM0(a5)
	beq.s	.not_flipped
	moveq	#T_FLIP_OFFSET,d0
.not_flipped:
	add.w	OBJX(a5),d0
	sub.w	WINDX,d0
	moveq	#T_Y_OFFSET,d1
	add.w	OBJY(a5),d1
	sub.w	WINDY,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0	;point to sprite table 
	tst.b	in_jack
	bne.s	.jacks
	move.w	#TON_SPRITE,d4
	jmp	print_a_sprite_normal
.jacks:	move.w	#JTON_SPRITE,d4
	jmp	print_a_sprite_normal
	
vulture_dma:
	dc.l	.vultw0
	dc.l	.vultw1
	dc.l	.vultw2
	dc.l	.vultw3
	dc.l	.vultf0
	dc.l	.vultf1
	dc.l	.vultf2
	dc.l	.vultf3

.vultw0:	dc.w	2,0,0,0
	dc.w	-24,-14,148
	dc.w	6,-4,149

.vultw1:	dc.w	2,0,0,0
	dc.w	-24,-31,150
	dc.w	9,-5,151

.vultw2:	dc.w	2,0,0,0
	dc.w	-23,-33,152
	dc.w	9,-6,153

.vultw3:	dc.w	1,0,0,0
	dc.w	-23,-9,154

.vultf0:	dc.w	2,0,0,0
	dc.w	-23,-28,155
	dc.w	11,-3,156

.vultf1:	dc.w	2,0,0,0
	dc.w	-23,-10,157
	dc.w	7,-3,158

.vultf2:	dc.w	1,0,0,0
	dc.w	-23,-5,159

.vultf3:	dc.w	2,0,0,0
	dc.w	-23,-32,160
	dc.w	9,-3,161

TON_MAP:
	dc.w	0,0,0,0
	dc.w	0,0,12,0,24,0
	dc.w	0,27,12,27,24,27

VULTURE_MAP:
	Vulturew	0
	Vulturew	1
	Vulturew	2
	Vulturew	3

	Vulturef	0
	Vulturef	1
	Vulturef	2
	Vulturef	3

WEIGHTAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPYSMALL				; in range y
	
	WEIGHT_KILL_BUBSY			;not able to kill this object

	move.w	OBJVX(a5),d1			;get vx
	beq.s	.okx				;0 then no change
	bmi.s	.nega
	add.l	#$00014000,OBJX(a5)
	bra.s	.okx
.nega:	sub.l	#$00014000,OBJX(a5)	
.okx:	move.w	OBJVY(a5),d0
	addq.w	#1,d0
	and.w	#$f,d0
	bne.s	.ok
	moveq	#$1f,d0
.ok:	move.w	d0,OBJVY(a5)
	asr.w	#2,d0
	add.w	d0,OBJY(a5)			;increase falling speed 1 in 4 frames
	
	moveq	#29,d0
	add.w	OBJY(a5),d0
	move.w	OBJX(a5),d1
	move.w	d0,d2
	jsr	GETATTRIB
	and.w	#ATTR_MASK,d0
	beq.s	.in_air
	move.b	#16,shake_me
	move.l	#CRATEEXPLODE,a0
	move.l	#CRATE10002,OBJINITDMA(a5)
	move.l	#CRATEMAP,OBJMAP(a5)
	move.l	a0,OBJAI(a5)
	add.w	#32,OBJY(a5)
	sf	OBJAUX1(a5)
	sf	OBJAUX0(a5)
	pea	(a0)				;rts from out of that routine to logic
	jmp	DOINITIALDMA			;check has been set up
.in_air:
	move.w	OBJX(a5),d0
	sub.w	WINDX,d0
	move.w	OBJY(a5),d1
	sub.w	WINDY,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0	;point to sprite table 
	tst.b	in_jack
	bne.s	.in_jack
	tst.b	in_alice
	beq.s	.not_alice
	move.w	#ATON_SPRITE_FREE,d4
	jmp	print_a_sprite_normal
.not_alice:
	move.w	#TON_SPRITE_FREE,d4
	jmp	print_a_sprite_normal
.in_jack:
	move.w	#JTON_SPRITE_FREE,d4
	jmp	print_a_sprite_normal
	
in_jack:	dc.b	0
in_alice:	dc.b	0
	even