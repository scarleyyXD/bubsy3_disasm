

AVULTURE_ICON	equ	58

ATON_SPRITE		equ	164-148+AVULTURE_ICON
ATON_SPRITE_FREE	equ	163-148+AVULTURE_ICON

******************************************************************************************************

AVULTUREAI
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
	bne	adropped_weight



	move.w	BUBX,d0				;if in range drop the weight
	subi.w	#16*4,d0
	cmp.w	OBJX(a5),d0
	bcc	adropped_weight
	addi.w	#32*4,d0
	cmp.w	OBJX(a5),d0
	bcs	adropped_weight

	move.l	#AVULTUREAIDIVING,OBJAI(a5)	;indicate vulture is in dive mode
	move.b	#16,OBJAUX7(a5)			;how long the vulture will dive for before releasing the weight
	move.b	#10,OBJAUX6(a5)			;how long to wait after dive


AVULTUREAIDIVING
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
	bra	adropped_weight			;wait for the countdown
.no_dive	
	tst.b	OBJAUX6(a5)
	beq.s	.no_wait
	subq.b	#1,OBJAUX6(a5)
	bra	adropped_weight			;wait for the countdown
.no_wait

	tst.b	OBJAUX1(a5)
	bne	adropped_weight



	move.w	BUBX,d0				;if in range drop the weight
	subi.w	#16,d0
	cmp.w	OBJX(a5),d0
	bcc	adropped_weight
	addi.w	#32,d0
	cmp.w	OBJX(a5),d0
	bcs.s	adropped_weight


	move.l	a5,a6

	move.w	#$3fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.RESTOREDP

	clr.w	OBJOAM0(a5)
	move.w	#$7ffe,OBJKEY(a5)		;one existant key

	lea	WEIGHTAI,a0
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
	bra.s	adropped_weight

.RESTOREDP
	move.l	a6,a5
	
	
adropped_weight
	moveq	#0,d0
	move.b	OBJAUX5(a5),d0
	beq.s	.no_height_change
	subq	#1,d0
	move.b	d0,OBJAUX5(a5)
	lsr.w	#3,d0
	sub.w	d0,OBJY(a5)				;move bird up 1 pixel
	
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
	jsr	DRAW_COMPLEX_SPRITE
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
	move.w	#ATON_SPRITE,d4
	jmp	print_a_sprite_normal
	
	
avulture_dma
	dc.l	.vultw0
	dc.l	.vultw1
	dc.l	.vultw2
	dc.l	.vultw3
	dc.l	.vultf0
	dc.l	.vultf1
	dc.l	.vultf2
	dc.l	.vultf3


.vultw0	dc.w	2,0,0,0
	dc.w	-24,-14,148-148+AVULTURE_ICON
	dc.w	6,-4,149-148+AVULTURE_ICON

.vultw1	dc.w	2,0,0,0
	dc.w	-24,-31,150-148+AVULTURE_ICON
	dc.w	9,-5,151-148+AVULTURE_ICON

.vultw2	dc.w	2,0,0,0
	dc.w	-23,-33,152-148+AVULTURE_ICON
	dc.w	9,-6,153-148+AVULTURE_ICON

.vultw3	dc.w	1,0,0,0
	dc.w	-23,-9,154-148+AVULTURE_ICON


.vultf0	dc.w	2,0,0,0
	dc.w	-23,-28,155-148+AVULTURE_ICON
	dc.w	11,-3,156-148+AVULTURE_ICON

.vultf1	dc.w	2,0,0,0
	dc.w	-23,-10,157-148+AVULTURE_ICON
	dc.w	7,-3,158-148+AVULTURE_ICON

.vultf2	dc.w	1,0,0,0
	dc.w	-23,-5,159-148+AVULTURE_ICON

.vultf3	dc.w	2,0,0,0
	dc.w	-23,-32,160-148+AVULTURE_ICON
	dc.w	9,-3,161-148+AVULTURE_ICON


