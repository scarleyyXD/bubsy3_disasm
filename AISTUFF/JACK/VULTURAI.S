JTON_SPRITE		equ	15
JTON_SPRITE_FREE	equ	16

JVULTUREAI
	jsr	DOINITIALDMA			;check has been set up
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPY				; in range y
	
	VULTURE_KILL_BUBSY
	
	VULTURE_TURN
	
	move.b	OBJAUX0(a5),d0			;get speed moving at
	ext.w	d0
	add.w	d0,OBJX(a5)			;add that to the x position
	
	tst.b	OBJAUX1(a5)
	bne	jdropped_weight



	move.w	BUBX,d0				;if in range drop the weight
	subi.w	#16*4,d0
	cmp.w	OBJX(a5),d0
	bcc	jdropped_weight
	addi.w	#32*4,d0
	cmp.w	OBJX(a5),d0
	bcs	jdropped_weight

	move.l	#JVULTUREAIDIVING,OBJAI(a5)	;indicate vulture is in dive mode
	move.b	#16,OBJAUX7(a5)			;how long the vulture will dive for before releasing the weight
	move.b	#10,OBJAUX6(a5)			;how long to wait after dive

JVULTUREAIDIVING
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
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
.going_right1
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.carry_on1
	subq.w	#1,OBJY(a5)
.carry_on1
	bra	dropped_weight			;wait for the countdown
.no_dive	
	tst.b	OBJAUX6(a5)
	beq.s	.no_wait
	subq.b	#1,OBJAUX6(a5)
	bra	dropped_weight			;wait for the countdown
.no_wait

	tst.b	OBJAUX1(a5)
	bne	jdropped_weight



	move.w	BUBX,d0				;if in range drop the weight
	subi.w	#16,d0
	cmp.w	OBJX(a5),d0
	bcc	jdropped_weight
	addi.w	#32,d0
	cmp.w	OBJX(a5),d0
	bcs.s	jdropped_weight


	move.l	a5,a6

	move.w	#$3fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.RESTOREDP

	clr.w	OBJOAM0(a5)
	move.w	#$7ffe,OBJKEY(a5)		;one existant key

	lea	JWEIGHTAI(pc),a0
	move.l	a0,OBJAI(a5)			;set up AI for weight
	move.l	#TON_MAP,OBJMAP(a5)		;set up collision map for weight

	sf	OBJFRAME(a5)			;ensure 1st frame for collision..
	moveq	#-$14,d4
	tst.b	OBJOAM0(a6)			;see if we are facing left or right
	beq.s	.faceright
	moveq	#0,d4
.faceright	
	add.w	OBJX(a6),d4			;we need to activate egg, save x and y

	move.w	d4,OBJX(a5)			;set up x and y
	move.w	OBJY(a6),d4
	add.w	#FIRST_T_Y,d4
	move.w	d4,OBJY(a5)

	moveq	#64,d0
	tst.b	OBJOAM0(a6)			;see direction vulture is flying
	beq.s	.swaped
	moveq	#-64,d0
.swaped	move.w	d0,OBJVX(a5)			;set up vx and vy
	clr.w	OBJVY(a5)
	pea	(a6)
	jsr	(a0)				;ensure we draw the frame for the weight
	move.l	(sp)+,a5
	move.b	#4,OBJAUX1(a5)
	move.b	#V_FREE-1,OBJAUX2(a5)
	move.b	#V_FREE,OBJAUX3(a5)
	move.b	#V_CHANGE_HEIGHT,OBJAUX5(a5)	;set up height change
	bra.s	jdropped_weight
.RESTOREDP
	move.l	a6,a5
	
	
jdropped_weight

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
.going_right
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.carry_on
	move.w	d6,OBJY(a5)
.carry_on

.no_height_change	
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
.draw_frame
	move.b	d0,OBJAUX2(a5)
	bsr	DRAW_COMPLEX_SPRITE
	tst.b	OBJAUX1(a5)				;if 4 then free thus no weight
	beq.s	.ton
	rts
.ton	moveq	#T_OFFSET,d0
	tst.b	OBJOAM0(a5)
	beq.s	.not_flipped
	moveq	#T_FLIP_OFFSET,d0
.not_flipped
	
	add.w	OBJX(a5),d0
	sub.w	WINDX,d0
	moveq	#T_Y_OFFSET,d1
	add.w	OBJY(a5),d1
	sub.w	WINDY,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0	;point to sprite table 
	move.w	#JTON_SPRITE,d4
	jmp	print_a_sprite_normal
	
	
jvulture_dma
	dc.l	.vultw0
	dc.l	.vultw1
	dc.l	.vultw2
	dc.l	.vultw3
	dc.l	.vultf0
	dc.l	.vultf1
	dc.l	.vultf2
	dc.l	.vultf3


.vultw0	dc.w	2,0,0,0
	dc.w	-24,-14,148-148
	dc.w	6,-4,149-148

.vultw1	dc.w	2,0,0,0
	dc.w	-24,-31,150-148
	dc.w	9,-5,151-148

.vultw2	dc.w	2,0,0,0
	dc.w	-23,-33,152-148
	dc.w	9,-6,153-148

.vultw3	dc.w	1,0,0,0
	dc.w	-23,-9,154-148


.vultf0	dc.w	2,0,0,0
	dc.w	-23,-28,155-148
	dc.w	11,-3,156-148

.vultf1	dc.w	2,0,0,0
	dc.w	-23,-10,157-148
	dc.w	7,-3,158-148

.vultf2	dc.w	1,0,0,0
	dc.w	-23,-5,159-148

.vultf3	dc.w	2,0,0,0
	dc.w	-23,-32,160-148
	dc.w	9,-3,161-148


JWEIGHTAI
	jsr	DOINITIALDMA			;check has been set up
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL			; in range y
	
	WEIGHT_KILL_BUBSY			;not able to kill this object
	
	
	
	
	move.w	OBJVX(a5),d1			;get vx
	beq.s	.okx				;0 then no change
	bmi.s	.nega
	add.l	#$00014000,OBJX(a5)
	bra.s	.okx
.nega	sub.l	#$00014000,OBJX(a5)	
.okx	move.w	OBJVY(a5),d0
	addq.w	#1,d0
	and.w	#$f,d0
	bne.s	.ok
	moveq	#$1f,d0
.ok	move.w	d0,OBJVY(a5)
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
.in_air	
	move.w	OBJX(a5),d0
	sub.w	WINDX,d0
	move.w	OBJY(a5),d1
	sub.w	WINDY,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0	;point to sprite table 
	move.w	#JTON_SPRITE_FREE,d4
	jmp	print_a_sprite_normal
	
