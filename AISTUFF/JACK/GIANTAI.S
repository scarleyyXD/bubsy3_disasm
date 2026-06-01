******************************* Giant Boss AI *****************************

; A rough description of what the giant does.

; He walks forwards until he hits a wall, then turns.
; At random intervals he stands still and fires a bullet.
; If Bubsy gets too close he kicks.

; When bubsy hits his canopy, he gets damaged until he surrenders

GIANT_WALK_CHECK	equ	70
BIGGEST_WALK_OFFSET	equ	35
GIANT_HIT_POINTS	equ	4
MAXBULLETS		equ	2
BULLETLIFETIME		equ	150		;3 seconds

;oam0 is the wrong way round since the sprite was drawn the wrong way..

;format for object is
;	OAM				.w	oam
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	0				.b	aux0
;	0				.b	aux1
;	0				.b	aux2
;	0				.b	aux3
;	0				.b	flags
;	0				.b	aux4

***************************************************************************

GIANTAI
GIANT_LOAD
	jsr	OBJRANGE
	bcc	.INRANGE
	andi.b	#~BOSSFLAG,GAMEFLAG1
	jmp	CLEAROBJ
	rts
.INRANGE
	jsr	CLIPY

	move.w	BUBX,d0								;make sure we are close
	sub.w	OBJX(a5),d0
	bpl.s	.posi
	neg.w	d0
.posi	cmp.w	#16,d0
	bgt	.out
	
	move.w	WINDY,d0
	cmp.w	WINDYOLD,d0				;ensure land does not change height
	bne	.out
	
	move.b	BUBSYFLAGS,d0				;and make sure bubsy is anchored
	andi.b	#ANCHORFLAG,d0
	beq	.out

	move.l	#GIANT_START,OBJAI(a5)		;wait for loading to be done.

	sf	OBJAUX5(a5)				;graphics not load in yet..

	lea	OBJBASE,a1				;first, let's copy AI to beginning of AI DP
	move.w	#OBJLEN,d0
.COPYLOOP
	move.b	(a5)+,(a1)+
	dbf.w	d0,.COPYLOOP

	lea	OBJBASEEND,a5					;now lets clear out the rest of the objects
.CLEARLOOP
	suba.l	#OBJLEN,a5
	cmpa.l	#OBJBASE,a5
	beq	.CHANGEAI
	jsr	CLEAROBJWVRAM
	bra	.CLEARLOOP
.CHANGEAI
	or.b	#BOSSFLAG,GAMEFLAG1
	move.w	WINDY,WINDYOLD
	bclr	#bTIMEFLAG,GAMEFLAG1				;stop the clock
	lea	LEVEL2_BOSS,a0
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	load_file_no_wait				;load in graphics - no wait

	move.w	#0*16,WINDXMIN
	move.w	#39*16,WINDXMAX
	move.w	WINDY,d0
	move.w	d0,WINDYMAX
	sub.w	#16*3,d0
	move.w	d0,WINDYMIN
.out
	rts

;**************************************************************************

GIANT_START
	bclr	#bTIMEFLAG,GAMEFLAG1					;stop the clock
	jsr	loaded_in_no_wait
	bne.s	.yes_loaded
	rts
.yes_loaded
	tst.b	OBJAUX5(a5)
	bne.s	.already_relocated_sprites
	st	OBJAUX5(a5)
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	relocate_sprites
.already_relocated_sprites

	move.l	#GIANT_FALL,OBJAI(a5)
	move.l	#fall,OBJINITDMA(a5)
	sf.b	OBJFRAME(A5)

	sf.b	OBJAUX0(a5)			;animation delay
	move.b	#255,OBJAUX1(a5)		;hit points
	sf.b	OBJAUX2(a5)			;flash

	move.w	WINDY,OBJY(a5)
	rts

****************************** Giant Falling ******************************

GIANT_FALL
	moveq.l	#0,d0
	move.b	OBJAUX0(a5),d0
	addq.b	#1,d0
	cmp.w	#200,d0
	ble.s	.yspeedok
	move.w	#200,d0
.yspeedok
	move.b	d0,OBJAUX0(a5)

	lsr.w	#2,d0
	add.w	d0,OBJY(a5)

	move.w	OBJX(a5),d1		;see if we have hit the ground
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.stillfalling
	jsr	STICKOBJECTTOPLAYFIELD

	move.l	OBJINITDMA(a5),a0
	move.l	-(a0),OBJINITDMA(a5)
	move.l	-(a0),OBJAI(a5)

	move.b	#25,OBJAUX0(a5)

	move.w	WINDY,WINDYMIN		;should stop it scrolling upwards

	move.w	#$4,WINDXMIN
	move.w	#$103,WINDXMAX
.stillfalling
	jmp	GIANT_DISPLAY

************************ Giant Crouching After His Fall *******************

GIANT_CROUCH
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.crouching

	move.l	OBJINITDMA(a5),a0
	move.l	-(a0),OBJINITDMA(a5)
	move.l	-(a0),OBJAI(a5)
	move.l	-(a0),COLLISION_DATA
	sf.b	OBJAUX0(a5)
	sf.b	OBJAUX2(a5)
	move.b	#GIANT_HIT_POINTS,OBJAUX1(a5)

	sf.b	ACTIVEBULLETS
.crouching
	jmp	GIANT_DISPLAY

******************************* Giant Walking *****************************

GIANT_WALK
	bsr	GIANT_COLLIDE		;do collision detection

	tst.b	OBJAUX1(a5)		;should the giant explode?
	bne.s	.noexplode

	move.l	OBJINITDMA(a5),a0
	move.l	-(a0),OBJINITDMA(a5)
	move.l	-(a0),OBJAI(a5)
	sf.b	OBJAUX0(a5)
	sf.b	OBJFRAME(a5)

	bra	.noanim
.noexplode
	cmp.b	#2,OBJFRAME(a5)			;should the giant stand still?
	bne.s	.nostand

	jsr	RANDOM
	and.w	#3,d0
	bne.s	.nostand

	move.l	#GIANT_STAND,OBJAI(a5)
	move.b	#2,OBJFRAME(a5)

	move.b	#30,OBJAUX0(a5)

	bra	.noanim
.nostand

	move.w	BUBX,d0			;should the giant kick?
	move.w	BUBY,d1
	sub.w	OBJX(a5),d0
	sub.w	OBJY(a5),d1
	bgt.s	.nokick
	cmp.w	#-64,d1
	ble.s	.nokick

	tst.b	OBJOAM0(a5)
	bne.s	.left1
	neg.w	d0
.left1
	cmp.w	#40,d0
	ble.s	.nokick
	cmp.w	#80,d0
	bge.s	.nokick

	move.l	#GIANT_KICK,OBJAI(a5)
	move.b	#8,OBJFRAME(a5)

	move.b	#10,OBJAUX0(a5)

	bra	.noanim
.nokick

	subq.b	#1,OBJAUX0(a5)		;animate the walk
	bpl.s	.noanim
	move.b	#10,OBJAUX0(a5)

	move.w	OBJX(a5),d1		;turn around if we walk into a wall
	move.w	OBJY(a5),d2
	move.w	#GIANT_WALK_CHECK+BIGGEST_WALK_OFFSET,d0
	tst.b	OBJOAM0(a5)
	bne.s	.left
	neg.w	d0
.left
	add.w	d0,d1
	jsr	GETATTRIB
	and.w	#WALL_CTRL,d0
	beq.s	.can_walk

	eor.b	#$8,OBJOAM0(a5)
	bra.s	.noanim

.can_walk
	moveq.l	#0,d0			;get current frame
	move.b	OBJFRAME(a5),d0
	move.w	d0,d1

	add.w	d1,d1			;add appropriate step
	lea	steps,a0		;for that frame
	move.w	0(a0,d1.w),d1
	tst.b	OBJOAM0(a5)
	beq.s	.left2
	neg.w	d1
.left2
	add.w	d1,OBJX(a5)

	addq.b	#1,d0			;increment frame number
	cmp.b	#7,d0
	blt.s	.nowrap
	moveq.l	#0,d0
.nowrap
	move.b	d0,OBJFRAME(a5)
.noanim
	jmp	GIANT_DISPLAY

***************************** Giant Standing ******************************

GIANT_STAND
	bsr	GIANT_COLLIDE

	move.l	a5,a6

	cmp.b	#15,OBJAUX0(a5)
	bne	.nofire

	cmp.b	#SMACKSTATE,BUBSTATE		;don't fire if bubsy
	beq	.nofire				;is out cold
	cmp.b	#UNCONCIOUSSTATE,BUBSTATE
	beq	.nofire

	tst.b	OBJAUX2(a5)			;don't fire if giant just bopped
	bne	.nofire


	cmp.b	#MAXBULLETS,ACTIVEBULLETS
	bge	.nofire
	addq.b	#1,ACTIVEBULLETS

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ

	move.w	#$7f00,OBJKEY(A5)
	move.l	#BULLET,OBJAI(a5)
	move.l	#bullet,OBJINITDMA(a5)
	move.l	#bulletmap,OBJMAP(A5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	sub.w	#100,OBJY(a5)

	sf.b	OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#BULLETLIFETIME,OBJAUX1(a5)

	move.w	BUBX,d0			;get the vector from
	move.w	BUBY,d1			;the giant to bubsy
	sub.w	OBJX(a6),d0
	sub.w	OBJY(a6),d1
	add.w	#100,d1
	moveq.l	#-22,d2
	tst.b	OBJOAM0(a6)
	beq.s	.left1
	neg.w	d2
.left1
	add.w	d2,d0
	add.w	d2,OBJX(a5)

	asr.w	#6,d0			;scale the direction vector
	asr.w	#6,d1			;to get a reasonable speed

	tst.w	d0			;make sure the speed is
	bpl.s	.xspos			;not too slow
.xsneg
	cmp.w	#-2,d0
	ble.s	.xsok
	moveq.l	#-2,d0
	bra.s	.xsok
.xspos
	cmp.w	#2,d0
	bge.s	.xsok
	moveq.l	#2,d0
.xsok
	tst.w	d1
	bpl.s	.yspos
.ysneg
	cmp.w	#-2,d1
	ble.s	.ysok
	moveq.l	#-2,d1
	bra.s	.ysok
.yspos
	cmp.w	#2,d1
	bge.s	.ysok
	moveq.l	#2,d1
.ysok

	cmp.w	#5,d0			;make sure the speed is
	ble.s	.xok1			;not too fast
	moveq.l	#5,d0
	bra.s	.xok2
.xok1
	cmp.w	#-5,d0
	bge.s	.xok2
	moveq.l	#-5,d0
.xok2
	cmp.w	#5,d1
	ble.s	.yok1
	moveq.l	#5,d1
	bra.s	.yok2
.yok1
	cmp.w	#-5,d1
	bge.s	.yok2
	moveq.l	#-5,d1
.yok2
	move.b	d0,OBJAUX2(a5)
	move.b	d1,OBJAUX3(a5)
	ext.w	d0
	ext.w	d1
	sub.w	d0,OBJX(a5)
	sub.w	d1,OBJX(a5)

.nofire
	move.l	a6,a5

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.standing
	move.l	#GIANT_WALK,OBJAI(a5)
.standing
	jmp	GIANT_DISPLAY

****************************** Giant Kicking ******************************

GIANT_KICK
	bsr	GIANT_COLLIDE

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same
	move.b	#10,OBJAUX0(a5)
	cmp.b	#10,OBJFRAME(a5)
	bne.s	.kicking

	move.l	#GIANT_WALK,OBJAI(a5)
	move.b	#2,OBJFRAME(a5)

	bra.s	.same
.kicking
	addq.b	#1,OBJFRAME(a5)
.same
	jmp	GIANT_DISPLAY

***************************** Giant Exploding *****************************

GIANT_EXPLODE
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.ok
	move.b	#10,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#3,OBJFRAME(a5)
	bne.s	.ok

	move.l	OBJINITDMA(a5),a0
	move.l	-(a0),OBJINITDMA(a5)
	move.l	-(a0),OBJAI(a5)
	move.l	-(a0),COLLISION_DATA

	sf.b	OBJFRAME(a5)
	move.b	#GIANT_HIT_POINTS,OBJAUX1(a5)
.ok
	jmp	GIANT_DISPLAY

******************************* Giant Hiding ******************************

GIANT_HIDE
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.ok
	move.b	#10,OBJAUX0(a5)

	cmp.b	#2,OBJFRAME(a5)
	beq.s	.nextstage
	addq.b	#1,OBJFRAME(a5)
	bra.s	.ok
.nextstage
	move.l	OBJINITDMA(a5),a0
	move.l	-(a0),OBJINITDMA(a5)
	move.l	-(a0),OBJAI(a5)

	sf.b	OBJFRAME(a5)
	move.b	#255,OBJAUX1(a5)
.ok
	jmp	DRAW_COMPLEX_SPRITE

****************************** Giant Waving *******************************

GIANT_WAVE
	subq.b	#1,OBJAUX1(a5)
	bne.s	.waving
	move.l	#GIANT_DIE,OBJAI(a5)
	jmp	DRAW_COMPLEX_SPRITE
.waving
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.ok
	move.b	#10,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#4,OBJFRAME(a5)
	blt.s	.ok
	sf.b	OBJFRAME(a5)
.ok
	jmp	DRAW_COMPLEX_SPRITE

******************************** Kill Giant *******************************

GIANT_DIE
	bclr	#bSCROLLFLAG,BUBSYFLAGS1				;stop scrolling
	bset	#bBUBSYOFFSCREEN,GAMEFLAG0
	or.b	#BOSSFLAG,GAMEFLAG1

	move.l	a5,-(a7)								;stop the clock
	bclr	#bTIMEFLAG,GAMEFLAG1

	jsr	INITOBJS								;clear out all object entries

	MOVE.L	#OBJBASE,A5								;start the tally score
	ADD.L	#OBJLEN,A5
	CLR.w	OBJKEY(A5)
	MOVE.w	#%1110000000000000+$680,OBJOAM0(A5)
	MOVE.L 	#TALLYAI,OBJAI(A5)
	MOVE.L	#LVLTXTMAP,OBJMAP(A5)

	MOVE.w	TIME,OBJAUX4(A5)							;copy time
	MOVE.w	YARNS,OBJAUX6(A5)							;and yarn

	MOVE	#ENDTXTLEN,D6								;copy the text
	LEA	ENDTXT,A0
	LEA	STRIPBUF,A1
.CTLOOP
	MOVE.B	(A0)+,(A1)+
	DBRA	D6,.CTLOOP

	MOVE.B	#ENDSTATE,BUBSTATE
	MOVE.L	(SP)+,A5

	RTS

******************************* Giant Bullet ******************************

BULLET
	jsr	OBJRANGE			;kill the bullet
	bcs	.killbullet			;if i|'s offscreen
	jsr	CLIPYSMALL

	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcs.s	.hitbubsy

	subq.b	#1,OBJAUX1(a5)
	beq.s	.killbullet

	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)

	move.b	OBJFRAME(a5),d0
	addq.b	#1,d0
	and.b	#1,d0
	move.b	d0,OBJFRAME(a5)
.sameframe
	move.b	OBJAUX2(a5),d0
	move.b	OBJAUX3(a5),d1
	ext.w	d0
	ext.w	d1
	add.w	d0,OBJX(a5)
	add.w	d1,OBJY(a5)

	move.w	OBJX(a5),d1		;detect the bullet against
	move.w	OBJY(a5),d2		;the map
	jsr	GETATTRIB
	and.w	#WALL_CTRL|ATTR_MASK,d0
	beq.s	.air
	and.w	#WALL_CTRL,d0
	bne.s	.wall
.floor
	neg.b	OBJAUX3(a5)		;hit a floor so negate yspeed
	jmp	DRAW_COMPLEX_SPRITE
.wall
	neg.b	OBJAUX2(a5)		;hit a wall so negate xspeed
.air
	jmp	DRAW_COMPLEX_SPRITE
.hitbubsy
	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY
.killbullet
	subq.b	#1,ACTIVEBULLETS
	jmp	CLEAROBJWVRAM

***************************** Giant Subroutines ***************************

***************************** Display The Giant ***************************

GIANT_DISPLAY
	tst.b	OBJAUX2(a5)		;if the giant has been bopped
	beq.s	.noflash		;make him flash
	subq.b	#1,OBJAUX2(a5)
	btst	#0,OBJAUX2(a5)
	bne.s	.noflash
	rts
.noflash
	jmp	DRAW_COMPLEX_SPRITE	;the GIANT has been loaded into memory and thus I can now show it.

************************ Collision Detection Routines *********************

GIANT_COLLIDE
	move.l	COLLISION_DATA,a0
	move.l	(a0),HEAD_KILL_MAP_POINTER
	move.l	(a0)+,OBJMAP(a5)
	bsr	COLLIDE_BIT
	move.l	(a0)+,OBJMAP(a5)
	bsr	COLLIDE_BIT
	move.l	(a0)+,OBJMAP(a5)
	bsr	COLLIDE_BIT
	rts

COLLIDE_BIT
	move.l	a0,-(sp)

	move.b	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.quit

	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.quit

	btst.b	#bANCHORFLAG,BUBSYFLAGS
	bne.s	.vulnerable

	tst.w	BUBVY
	bpl.s	.invulnerable

.vulnerable
	move.w	INVTIMER,d0
	or.w	SHADOWTIMER,d0
	bne.s	.quit

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY
	bra.s	.quit

.invulnerable
	move.l	HEAD_KILL_MAP_POINTER,d0
	cmp.l	OBJMAP(a5),d0
	bne.s	.quit

	move.b	#JUMPSTATE,BUBSTATE
	jsr	RANDOM
	and.w	#15,d0
	subq.w	#8,d0
	move.w	d0,BUBVX
	move.w	#$fa00,BUBVY

	subq.b	#1,OBJAUX1(a5)			;decrement hitpoints
	move.b	#50,OBJAUX2(a5)			;set flash on
.quit
	move.l	(sp)+,a0
	rts	

**************************** A Few Variables ******************************

HEAD_KILL_MAP_POINTER
	dc.l	0

COLLISION_DATA
	dc.l	0

ACTIVEBULLETS
	dc.b	0

************************ X Steps For Walking Frames ***********************

steps	dc.w	-6
	dc.w	-10
	dc.w	-14
	dc.w	-23
	dc.w	-9
	dc.w	-10
	dc.w	-35

****************************** Loads Of Frames ****************************

giant_dma			;totally pointless label

****************************** Falling Frames *****************************

	dc.l	GIANT_CROUCH
	dc.l	crouch
fall
	dc.l	.f0

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,34
	dc.w	-34,-101-37,9

****************************** Crouching Frames ***************************

	dc.l	damage0c
	dc.l	GIANT_WALK
	dc.l	damage0
crouch
	dc.l	.f0

.f0	dc.w	2,0,0,0
	dc.w	-37,-96,35
	dc.w	-34,-96-37,9

****************************** Damage 0 Frames ****************************

	dc.l	GIANT_EXPLODE
	dc.l	explode0
damage0
	dc.l	.f0		frames 0-6 walking
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7		frame 7 standing

	dc.l	.f10		;play the kick backwards for Slick
	dc.l	.f9
	dc.l	.f8		frames 8-10 kicking

.f0	dc.w	2,0,0,0
	dc.w	-48,-96,0
	dc.w	-34,-96-37,7

.f1	dc.w	2,0,0,0
	dc.w	-42,-100,1
	dc.w	-34,-100-37,8

.f8
.f7
.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-37,9

.f3	dc.w	2,0,0,0
	dc.w	-31,-97,3
	dc.w	-34,-97-37,10

.f4	dc.w	2,0,0,0
	dc.w	-52,-96,4
	dc.w	-34,-96-37,11

.f5	dc.w	2,0,0,0
	dc.w	-42,-100,5
	dc.w	-34,-100-37,12

.f6	dc.w	2,0,0,0
	dc.w	-32,-101,6
	dc.w	-34,-101-37,11

.f9	dc.w	2,0,0,0
	dc.w	-85,-101,36
	dc.w	-34,-101-37,11

.f10	dc.w	2,0,0,0
	dc.w	-97,-112,37
	dc.w	-30,-101-37,11

***************************** Explode 0 Frames ****************************

	dc.l	damage1c
	dc.l	GIANT_WALK
	dc.l	damage1
explode0
	dc.l	.f0
	dc.l	.f1
	dc.l	.f2

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-47,13

.f1	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-53,14

.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-36,-101-54,15

****************************** Damage 1 Frames ****************************

	dc.l	damage1c
	dc.l	GIANT_EXPLODE
	dc.l	explode1
damage1
	dc.l	.f0		frames 0-6 walking
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7		frame 7 standing

	dc.l	.f10		;play the kick backwards for Slick
	dc.l	.f9
	dc.l	.f8		frames 8-10 kicking

.f0	dc.w	2,0,0,0
	dc.w	-48,-96,0
	dc.w	-34,-96-37,16

.f1	dc.w	2,0,0,0
	dc.w	-42,-100,1
	dc.w	-34,-100-37,16

.f8
.f7
.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-37,16

.f3	dc.w	2,0,0,0
	dc.w	-31,-97,3
	dc.w	-34,-97-37,16

.f4	dc.w	2,0,0,0
	dc.w	-52,-96,4
	dc.w	-34,-96-37,16

.f5	dc.w	2,0,0,0
	dc.w	-42,-100,5
	dc.w	-34,-100-37,16

.f6	dc.w	2,0,0,0
	dc.w	-32,-101,6
	dc.w	-34,-101-37,16

.f9	dc.w	2,0,0,0
	dc.w	-85,-101,36
	dc.w	-34,-101-37,16

.f10	dc.w	2,0,0,0
	dc.w	-97,-112,37
	dc.w	-30,-101-37,16

***************************** Explode 1 Frames ****************************

	dc.l	damage2c
	dc.l	GIANT_WALK
	dc.l	damage2
explode1
	dc.l	.f0
	dc.l	.f1
	dc.l	.f2

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-45,17

.f1	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-38,-101-49,18

.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-51,-101-53,19

****************************** Damage 2 Frames ****************************

	dc.l	damage2c
	dc.l	GIANT_EXPLODE
	dc.l	explode2
damage2
	dc.l	.f0		frames 0-6 walking
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7		frame 7 standing

	dc.l	.f10		;play the kick backwards for Slick
	dc.l	.f9
	dc.l	.f8		frames 8-10 kicking

.f0	dc.w	2,0,0,0
	dc.w	-48,-96,0
	dc.w	-34,-96-34,20

.f1	dc.w	2,0,0,0
	dc.w	-42,-100,1
	dc.w	-34,-100-34,20

.f8
.f7
.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-34,20

.f3	dc.w	2,0,0,0
	dc.w	-31,-97,3
	dc.w	-34,-97-34,20

.f4	dc.w	2,0,0,0
	dc.w	-52,-96,4
	dc.w	-34,-96-34,20

.f5	dc.w	2,0,0,0
	dc.w	-42,-100,5
	dc.w	-34,-100-34,20

.f6	dc.w	2,0,0,0
	dc.w	-32,-101,6
	dc.w	-34,-101-34,20

.f9	dc.w	2,0,0,0
	dc.w	-85,-101,36
	dc.w	-34,-98-37,20

.f10	dc.w	2,0,0,0
	dc.w	-97,-112,37
	dc.w	-30,-98-37,20

***************************** Explode 2 Frames ****************************

	dc.l	damage3c
	dc.l	GIANT_WALK
	dc.l	damage3
explode2
	dc.l	.f0
	dc.l	.f1
	dc.l	.f2

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-36,21

.f1	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-39,-101-43,22

.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-45,-101-49,23

****************************** Damage 3 Frames ****************************

	dc.l	damage3c
	dc.l	GIANT_EXPLODE
	dc.l	explode3
damage3
	dc.l	.f0		frames 0-6 walking
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7		frame 7 standing

	dc.l	.f10		;play the kick backwards for Slick
	dc.l	.f9
	dc.l	.f8		frames 8-10 kicking

.f0	dc.w	2,0,0,0
	dc.w	-48,-96,0
	dc.w	-34,-96-30,24

.f1	dc.w	2,0,0,0
	dc.w	-42,-100,1
	dc.w	-34,-100-30,24

.f8
.f7
.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-30,24

.f3	dc.w	2,0,0,0
	dc.w	-31,-97,3
	dc.w	-34,-97-30,24

.f4	dc.w	2,0,0,0
	dc.w	-52,-96,4
	dc.w	-34,-96-30,24

.f5	dc.w	2,0,0,0
	dc.w	-42,-100,5
	dc.w	-34,-100-30,24

.f6	dc.w	2,0,0,0
	dc.w	-32,-101,6
	dc.w	-34,-101-30,24

.f9	dc.w	2,0,0,0
	dc.w	-85,-101,36
	dc.w	-34,-94-37,24

.f10	dc.w	2,0,0,0
	dc.w	-97,-112,37
	dc.w	-30,-94-37,24

***************************** Explode 3 Frames ****************************

	dc.l	GIANT_HIDE
	dc.l	hide
explode3
	dc.l	.f0
	dc.l	.f1
	dc.l	.f2

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-35,-101-30,25

.f1	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-40,-101-30,26

.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-45,-101-30,27

*************************** Giant Hiding Frames ***************************

	dc.l	GIANT_WAVE
	dc.l	wave
hide
	dc.l	.f0
	dc.l	.f1
	dc.l	.f2

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-30,28

.f1	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-30,29

.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-27,30

******************************* Giant Waving ******************************

wave	dc.l	.f0
	dc.l	.f1
	dc.l	.f2
	dc.l	.f1

.f0	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-30,31

.f1	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-31,32

.f2	dc.w	2,0,0,0
	dc.w	-32,-101,2
	dc.w	-34,-101-31,33

****************************** Bullet Frames ******************************

bullet	dc.l	.f0
	dc.l	.f1

.f0	dc.w	1,0,0,0
	dc.w	-4,-4,38

.f1	dc.w	1,0,0,0
	dc.w	-2,-2,39

************************** Collision Detection Data ***********************

GIANT_MAP		;another totally pointless label
	ds.b	32

bulletmap
	Soff	0,0,-2,4,2,4,-4,0,4,0,-2,-4,2,-4
	Soff	0,0,-1,2,1,2,-2,0,2,0,-1,-2,1,-2

************************** Damage 0 Collision Data ************************

damage0c
	dc.l	head0
	dc.l	body
	dc.l	legs

head0	Soff	0,096,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,100,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,101,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,097,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,096,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,100,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,101,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,101,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,101,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,101,-33,11,-25,26,-10,36,10,36,25,26,31,11
	Soff	0,101,-33,11,-25,26,-10,36,10,36,25,26,31,11

************************** Damage 1 Collision Data ************************

damage1c
	dc.l	head1
	dc.l	body
	dc.l	legs

head1	Soff	0,096,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,100,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,101,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,097,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,096,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,100,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,101,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,101,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,101,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,101,-33,11,-25,26,-12,34,3,27,25,26,31,11
	Soff	0,101,-33,11,-25,26,-12,34,3,27,25,26,31,11

************************** Damage 2 Collision Data ************************

damage2c
	dc.l	head2
	dc.l	body
	dc.l	legs

head2	Soff	0,096,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,100,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,101,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,97,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,096,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,100,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,101,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,101,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,101,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,101,-33,11,-28,23,-9,27,14,34,26,24,31,11
	Soff	0,101,-33,11,-28,23,-9,27,14,34,26,24,31,11

************************** Damage 3 Collision Data ************************

damage3c
	dc.l	head3
	dc.l	body
	dc.l	legs

head3	Soff	0,096,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,100,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,101,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,097,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,096,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,100,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,101,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,101,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,101,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,101,-33,11,-30,18,-15,23,9,28,27,23,32,9
	Soff	0,101,-33,11,-30,18,-15,23,9,28,27,23,32,9

body	Soff	0,0,-30,89,-23,79,-13,72,-13,72,23,79,30,89	;0-6 walking
	Soff	0,0,-30,94,-23,84,-13,77,-13,77,23,84,30,94	;frame 6=frame 2
	Soff	0,0,-30,93,-23,83,-13,76,-13,76,23,83,30,93
	Soff	0,0,-30,91,-23,81,-13,74,-13,74,23,81,30,91
	Soff	0,0,-30,90,-23,80,-13,73,-13,73,23,80,30,90
	Soff	0,0,-30,94,-23,84,-13,77,-13,77,23,84,30,94
	Soff	0,0,-30,93,-23,83,-13,76,-13,76,23,83,30,93

	Soff	0,0,-30,93,-23,83,-13,76,-13,76,23,83,30,93	;7=standing=frame2

	Soff	0,0,-30,93,-23,83,-13,76,-13,76,23,83,30,93	;8-10 kicking
	Soff	0,0,-30,95,-23,85,-13,78,013,78,23,85,30,95	;frame8=frame2
	Soff	0,0,-30,95,-23,85,-13,78,013,78,23,85,30,95

legs	Soff	0,0,-048,011,-39,22,-29,41,-25,57,-03,30,-13,8	;0-6 walking
	Soff	0,0,-040,015,-28,25,-22,46,-14,67,007,26,-07,10	;frame6=frame2
	Soff	0,0,-030,015,-18,25,-12,44,-07,62,017,26,005,9
	Soff	0,0,-017,013,-09,29,-03,53,018,42,026,27,019,10
	Soff	0,0,0008,013,003,25,009,50,019,58,033,33,040,14
	Soff	0,0,-011,011,-02,24,-09,51,-02,65,023,37,024,17
	Soff	0,0,-030,015,-18,25,-12,44,-07,62,017,26,005,9

	Soff	0,0,-030,015,-18,25,-12,44,-07,62,017,26,005,9		;7=standing=frame2

	Soff	0,0,-77,79,-91,90,-98,96,-105,103,-101,109,-89,111	;these three are backwards!!
	Soff	0,0,-53,29,-67,33,-80,37,-89,40,-82,49,-75,54		;frame8=frame2
	Soff	0,0,-030,015,-18,25,-12,44,-07,62,017,26,005,9		;8-10 kicking
