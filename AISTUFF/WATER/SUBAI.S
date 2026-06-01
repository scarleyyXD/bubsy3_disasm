SUB_LAND_DETECT_X	equ	30
SUB_LAND_DETECT_Y	equ	0
SUB_MOVE_X		equ	-1
SUB_RADIUS		equ	160
SUB_RATE		equ	1
SUB_TURN_RATE		equ	9

MISSLE_OFFSET_X		equ	0
MISSLE_OFFSET_Y		equ	4

MISSILE_START_SPEED	equ	3
MISSILE_START_ANGLE	equ	0

MISSILE_SPEED		equ	2
MISSILE_TURN_ANGLE	equ	8

SUB_EYE_X_OFFSET	equ	-5
SUB_EYE_Y_OFFSET	equ	-39
SUB_EYE_FRAME		equ	68

SUB_WAIT_MISSILE	equ	120


SUB_KILL_BUBSY	macro
	move.w	#$0801,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm

MISSILE_KILL_BUBSY	macro
	moveq	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm



SUBRATE		equ	1

SUBAI	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE
	JSR	CLIPY

	SUB_KILL_BUBSY

	subq.b	#1,OBJAUX0(A5)
	bpl	.draw_this_frame
.next_frame
	sf	OBJFRAME(A5)
	move.b	#SUB_RATE-1,OBJAUX0(a5)

	subq.b	#1,OBJAUX4(a5)
	bpl	.dont_seek_bubsy
	move.b	#SUB_WAIT_MISSILE,OBJAUX4(a5)
	
	move.w	BUBX,d0						;xý
	sub.w	OBJX(a5),d0
	muls	d0,d0
	
	move.w	OBJY(a5),d1					;yý
	sub.w	BUBY,d1
	muls	d1,d1
	
	add.l	d0,d1
	
	cmp.w	#SUB_RADIUS*SUB_RADIUS,d1			;rý=yý+xý
	bgt.s	.dont_seek_bubsy
	
	move.l	a5,a6
	move.w	OBJKEY(A5),d6
	add.w	#$0100,d6
	jsr	FINDFREEOBJ
	bcs.s	.no_object_available

	move.l	#SUB_HOME_MISSILEAI,OBJAI(a5)			;set up object data
	move.l	#SUB_HOME_MISSILEMAP,OBJMAP(A5)
	move.l	#sub_home_missile_dma,OBJINITDMA(A5)
	move.w	d6,OBJKEY(A5)
	sf	OBJFRAME(A5)
	move.w	#MISSLE_OFFSET_X,d0				;set inital co-ordinates
	move.w	#MISSLE_OFFSET_Y,d1
	moveq	#MISSILE_START_ANGLE,d7
	tst.b	OBJOAM0(a5)
	beq.s	.left
	neg.w	d0
	add.b	#$80,d7
.left	add.w	OBJX(A6),d0
	add.w	OBJY(A6),d1						
	move.w	d0,OBJX(A5)
	move.w	d1,OBJY(A5)
	moveq	#0,d1						;set direction
	move.w	OBJX(A5),d0
	cmp.w	BUBX,d0
	blt.s	.no_flip
	moveq	#8,d1
.no_flip
	move.b	d1,OBJOAM0(A5)
	move.l	a6,a5
	bra.s	.done
.no_object_available
	move.l	a6,a5
	sf	OBJAUX4(a5)					;if failed then wait till we can fire
.done
.dont_seek_bubsy	
	moveq	#-SUB_LAND_DETECT_X,d1
	moveq	#SUB_LAND_DETECT_Y,d2
	moveq	#SUB_MOVE_X,d3
	
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d3
	neg.w	d1
.going_right
	add.w	d3,OBJX(A5)				;move the sub
	add.w	OBJX(A5),d1
	add.w	OBJY(A5),d2
	jsr	GETATTRIB

	and.w	#~ATTR_MASK,d0
	beq.s	.nothing_in_front
.hit_wall
	eor.b	#8,OBJOAM0(A5)
	bset	#0,OBJFRAME(A5)				;frame == 1
	move.b	#SUB_TURN_RATE-1,OBJAUX0(a5)
.nothing_in_front

.draw_this_frame					;now draw the sub and over that if necessary the blinking eyes
	jsr	DRAW_COMPLEX_SPRITE
	
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0				;get current state of the eyes 0=open 1=closed
	and.w	#1,d0
	subq.b	#1,OBJAUX2(a5)
	bne.s	.no_change
	bchg	#0,d0					;change eye state and store
	move.b	.eye_tab(pc,d0.w),OBJAUX2(a5)
	move.b	d0,OBJAUX3(a5)
.no_change
	btst	#0,d0
	beq.s	.no_draw_eyes

	tst.b	OBJFRAME(a5)				; if sub turning then have the eyes open
	bne.s	.no_draw_eyes
	
	move.l	LOAD_LEVEL_SPRITES_HERE,a0		;get addr of sprites
	moveq	#SUB_EYE_X_OFFSET,d0			;get x , y position
	moveq	#SUB_EYE_Y_OFFSET,d1
	add.w	OBJX(A5),D0
	add.w	OBJY(A5),D1
	SUB.w	WINDX,D0
	SUB.w	WINDY,D1
	moveq	#SUB_EYE_FRAME,d4
	jmp	print_a_sprite_normal
.no_draw_eyes
	rts

.eye_tab	dc.b	90,6


SUBMAP
	Soff	28,8,0,0,2,18,14,32,37,32,53,18,45,0
	Soff	16,8,0,0,-21,16,4,34,23,36,47,15,28,0

sub_dma
	dc.l	.frame0
	dc.l	.frame1
	
.frame0	dc.w	2,0,0,0
	dc.w	-35,-32,66
	dc.w	-15,-18-32+2,67
		
.frame1	dc.w	2,0,0,0
	dc.w	-34,-34,65
	dc.w	-16,-34-18+2,67

;********************************************************************************************************

MISSLE_Y_CHANGE	equ	1

SUB_HOME_MISSILEAI
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE
	JSR	CLIPYSMALL

	MISSILE_KILL_BUBSY

	moveq	#-MISSILE_SPEED,d0
	tst.b	OBJOAM0(a5)
	bne.s	.left
	neg.w	d0
.left
	add.w	d0,OBJX(A5)
	
	moveq	#MISSLE_Y_CHANGE,d1
	move.w	OBJY(A5),d0
	add.w	#20,d0
	cmp.w	BUBY,d0
	beq.s	.no_add
	ble.s	.dy
	neg.w	d1
.dy	add.w	d1,OBJY(a5)
.no_add	
	moveq	#8,d1
	tst.b	OBJOAM0(a5)
	beq.s	.posi
	neg.w	d1
.posi	
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	bne.s	.explode
	jmp	DRAW_COMPLEX_SPRITE
.explode
	move.l	#CRATEEXPLODE,OBJAI(a5)
	move.l	#CRATE10002,OBJINITDMA(a5)
	move.l	#CRATEMAP,OBJMAP(a5)
	sf.b	OBJAUX2(a5)
	sf.b	OBJAUX1(a5)
	sf.b	OBJAUX0(a5)
	sf.b	OBJFRAME(a5)
	addq.w	#8,OBJY(a5)
	jmp	ENEMYOAMS


SUB_HOME_MISSILEMAP
	Soff	0,0,-11,-3,0,-3,11,-3,-11,3,0,3,11,3
	
sub_home_missile_dma
	dc.l	.frame2
.frame2	dc.w	1,0,0,0
	dc.w	-11,-3,71
