********************************* Genie AI ********************************

; A rough description of what the Genie does

; Her vase raises from the ground
; She raises from the vase
; She floats left to right across the screen
; She casts two spells:
; The fireball spell, which bounces around the screen
; The gun spell, which appears in a corner and shoots bullets

; When the genie is bopped, she falls to the ground stunned.
; If she is stunned enough, she crawls into the vase for a bit

; When the vase is bopped, it cracks. If cracked enough it falls
; apart.

VASE_HITS	equ	8
GENIE_HITS	equ	4

BULLET_MAX_XV	equ	16
BULLET_MAX_YV	equ	16

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

*************************** Loading Boss graphics *************************

GENIE_LOAD
	jsr	OBJRANGE
	bcc	.INRANGE
	andi.b	#~BOSSFLAG,GAMEFLAG1
	jmp	CLEAROBJ
.BAIL
	rts
.INRANGE
	bsr	CLIPY
	
	move.w	BUBX,d0								;make sure we are close
	sub.w	OBJX(a5),d0
	sub.w	#200,d0
	bpl.s	.posi
	neg.w	d0
.posi	cmp.w	#16,d0
	bgt.s	.BAIL

	or.b	#BOSSFLAG,GAMEFLAG1
	
	move.w	WINDY,d0
	cmp.w	WINDYOLD,d0							;ensure land does not change height
	bne.s	.BAIL
	
	move.b	BUBSYFLAGS,d0							;and make sure bubsy is anchored
	andi.b	#ANCHORFLAG,d0
	beq	.BAIL
.activate	
	lea	OBJBASE,a1					;first, let's copy AI to beggining of AI DP
	move.w	#OBJLEN,d0
.COPYLOOP
	move.b	(a5)+,(a1)+
	dbf.w	d0,.COPYLOOP

	lea	OBJBASEEND,a5							;now lets clear out the rest of the objects
.CLEARLOOP
	suba.l	#OBJLEN,a5
	cmpa.l	#OBJBASE,a5
	beq	.CHANGEAI
	jsr	CLEAROBJWVRAM
	bra	.CLEARLOOP
.CHANGEAI
	lea	LEVEL1_BOSS,a0
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	bclr	#bTIMEFLAG,GAMEFLAG1					;stop the clock
	jsr	load_file_no_wait

	move.l	#GENIE_START,OBJAI(a5)

	move.w	WINDX,WINDXMIN				;set position of screen for boss
	move.w	WINDY,WINDYMIN
	move.w	WINDXMIN,WINDXMAX
	move.w	WINDYMIN,WINDYMAX
	move.w	WINDX,d0				;set bubsy's limits
	addi.w	#10,d0
	move.w	d0,BUBXMIN
	addi.w	#320-20,d0
	move.w	d0,BUBXMAX
	bset	#bBUBSYOFFSCREEN,GAMEFLAG0
	rts

*************** Wait for load to complete, then set up boss ***************

GENIE_START
	bclr	#bTIMEFLAG,GAMEFLAG1		;stop the clock
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

	move.l	#GENIE_HIDING,OBJAI(a5)		;get the genie ready
	move.l	#genie,OBJINITDMA(a5)		;she has to be before
	move.l	#geniemap,OBJMAP(a5)		;the vase so she can go
	move.b	#64,OBJAUX0(a5)			;behind it when hiding
	move.w	WINDX,OBJX(a5)
	add.w	#160,OBJX(A5)
	move.w	WINDY,OBJY(a5)
	add.w	#100,OBJY(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.l	a5,a6

	move.w	#$3fff,d7			;make the vase
	jsr	FINDFIRSTFREEOBJ
	move.l	a5,vaseobject
	move.w	#$7f00,OBJKEY(a5)
	move.l	#VASE_APPEARING,OBJAI(a5)
	move.l	#vase,OBJINITDMA(a5)
	move.l	#vasemap,OBJMAP(a5)
	move.w	WINDX,d0
	move.w	WINDY,d1
	add.w	#160,d0
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)
	sf.b	OBJOAM0(a5)
	sf.b	OBJFRAME(a5)
	move.b	#64,OBJAUX0(a5)
	sf.b	OBJAUX3(a5)
	move.b	#VASE_HITS,OBJAUX4(a5)

	jsr	STICKOBJECTTOPLAYFIELD

	move.l	a6,a5

	move.w	WINDY,floaty			;set genie's float height
	add.w	#20,floaty

	st.b	vase_active			;vase is active
	sf.b	gun_active			;gun is not active yet

	move.b	#2,fireballs
	
	bset	#bBUBSYOFFSCREEN,GAMEFLAG0
	rts

******************************* Vase Routines *****************************

*********************** Vase Raising Up From The Ground *******************

VASE_APPEARING
	subq.w	#1,OBJY(a5)
	subq.b	#1,OBJAUX0(a5)
	bne.s	.raising

	move.l	#VASE_STANDING,OBJAI(a5)
.raising
	jmp	DISPLAY_OBJECT

******************** Vase Standing Waiting To Be Bopped *******************

VASE_STANDING
	bsr	VASE_COLLIDE
	jmp	DISPLAY_OBJECT

********************* Vase Collapsing After Being Smashed *****************

VASE_SMASH
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#16,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#VASE_SMASHED,OBJAI(a5)
	move.b	#15,OBJFRAME(a5)
.sameframe
	jmp	DRAW_COMPLEX_SPRITE

****************** Vase Smashed, Wait For Genie To Go Too *****************

VASE_SMASHED
	sf.b	vase_active
	jmp	DRAW_COMPLEX_SPRITE

***************************** Genie Routines ******************************

************************ Genie Hiding In The Vase *************************

GENIE_HIDING
	subq.b	#1,OBJAUX0(a5)
	bne.s	.hiding

	move.l	#GENIE_APPEARING,OBJAI(a5)
	sf.b	OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.l	vaseobject,a0
	move.w	OBJX(a0),OBJX(a5)
	move.w	OBJY(a0),OBJY(a5)

	sf.b	OBJAUX3(a5)
	move.b	#GENIE_HITS,OBJAUX4(a5)

	jsr	RANDOM			;randomise direction to
	sf.b	d1			;face after appearing
	and.b	#31,d0
	cmp.b	#16,d0
	bge.s	.right
	move.b	#$8,d1
.right
	move.b	d1,OBJOAM0(a5)
.hiding
	jmp	DRAW_COMPLEX_SPRITE	;should fix the disappearing genie bug!

******************* Genie Appearing From Inside The Vase ******************

GENIE_APPEARING
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	eor.b	#1,OBJFRAME(a5)
.sameframe
	subq.w	#1,OBJY(a5)
	move.w	floaty,d0
	cmp.w	OBJY(a5),d0
	bne.s	.notyet

	move.l	#GENIE_FLOATING,OBJAI(a5)
	move.b	#2,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#13,OBJAUX2(a5)
.notyet
	jmp	DRAW_COMPLEX_SPRITE

*************************** Genie Floating Around *************************

GENIE_FLOATING
	subq.b	#1,OBJAUX0(a5)		;floating animation
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#6,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#2,OBJFRAME(a5)
.sameframe

	move.w	WINDX,d0		;move the genie left or right
	tst.b	OBJOAM0(a5)		;depending on which way
	beq.s	.moveright		;she is facing
.moveleft
	subq.w	#1,OBJX(a5)
	add.w	#60,d0
	cmp.w	OBJX(a5),d0
	ble.s	.noturn
	bra.s	.turn
.moveright
	addq.w	#1,OBJX(a5)
	add.w	#320-60,d0
	cmp.w	OBJX(a5),d0
	bge.s	.noturn
.turn
	eor.b	#8,OBJOAM0(a5)
.noturn

	move.b	OBJAUX2(a5),d0		;bob the genie up and down
	ext.w	d0
	ext.l	d0
	moveq.l	#16-4,d1
	asl.l	d1,d0
	add.l	d0,OBJY(a5)

	move.w	floaty,d0		;oscillates around the ycoord
	cmp.w	OBJY(a5),d0		;in floaty
	beq.s	.yspeedok
	bgt.s	.lower
.higher
	subq.b	#1,OBJAUX2(a5)
	cmp.b	#-13,OBJAUX2(a5)
	bge.s	.yspeedok
	move.b	#-13,OBJAUX2(a5)
	bra.s	.yspeedok
.lower
	addq.b	#1,OBJAUX2(a5)
	cmp.b	#13,OBJAUX2(a5)
	ble.s	.yspeedok
	move.b	#13,OBJAUX2(a5)
.yspeedok

	tst.b	gun_active			;can't cast anything if
	bne.s	.nospell			;the gun is active

	move.w	floaty,d0			;can't cast anything if
	sub.w	OBJY(a5),d0			;genie is too close to
	bpl.s	.pos				;to the ground
	neg.w	d0
.pos
	cmp.w	#20,d0
	bge.s	.nospell

	move.w	#90,d0				;she has two positions
	move.w	#-10,d1				;that she can cast a
	tst.b	OBJOAM0(a5)			;spell from
	bne.s	.faceright
	neg.w	d0
	neg.w	d1
.faceright
	add.w	WINDX,d0
	add.w	#160,d0
	cmp.w	OBJX(a5),d0
	beq.s	.spell
	add.w	WINDX,d1
	add.w	#160,d1
	cmp.w	OBJX(a5),d1
	bne.s	.nospell
.spell
	move.l	#GENIE_CASTING,OBJAI(a5)
	move.b	#6,OBJFRAME(a5)
	move.b	#5,OBJAUX0(a5)
.nospell
	bsr	GENIE_COLLIDE

	jmp	DISPLAY_OBJECT

************************** Genie Casting A Spell **************************

GENIE_CASTING
	subq.b	#1,OBJAUX0(a5)
	bne	.sameframe
	move.b	#5,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)

	cmp.b	#11,OBJFRAME(a5)	;first frame with arms outstretched
	bne.s	.nospell

	tst.b	fireballs		;casts some fireballs, then the gun
	bne.s	.castfireball
	move.b	#2,fireballs
.castgun
	move.w	BUBX,d0			;checks which way the genie is
	sub.w	OBJX(a5),d0		;facing and makes sure Bubsy is
	tst.b	OBJOAM0(a5)		;behind her before she casts
	bne.s	.leftgun		;the gun
.rightgun
	tst.w	d0
	bgt.s	.castfireball
	bsr	MAKE_GUN_RIGHT
	bra.s	.nospell
.leftgun
	tst.w	d0
	blt.s	.castfireball
	bsr	MAKE_GUN_LEFT
	bra.s	.nospell
.castfireball
	subq.b	#1,fireballs
	bsr	MAKE_FIREBALL
.nospell
	cmp.b	#15,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#GENIE_FLOATING,OBJAI(a5)
	move.b	#2,OBJFRAME(a5)
.sameframe
	bsr	GENIE_COLLIDE

	jmp	DISPLAY_OBJECT

************************* Genie Stunned When Bopped ***********************

GENIE_STUNNED
	subq.b	#1,OBJAUX0(a5)			;animate the fall
	bne.s	.sameframe
	move.b	#8,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#18,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#16,OBJFRAME(a5)
.sameframe

	move.b	OBJAUX1(a5),d0			;increase velocity downwards
	subq.b	#1,d0
	cmp.b	#-40,d0
	bge.s	.yspeedok
	moveq.l	#-40,d0
.yspeedok
	move.b	d0,OBJAUX1(a5)
	ext.w	d0
	ext.l	d0
	moveq.l	#16-2,d1
	asl.l	d1,d0
	sub.l	d0,OBJY(a5)

	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	add.w	#64,d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.falling

	jsr	STICKOBJECTTOPLAYFIELD
	sub.w	#53,OBJY(a5)

	move.l	#GENIE_RECOVERING,OBJAI(a5)
	move.b	#25,OBJAUX1(a5)
.falling
	jmp	DISPLAY_OBJECT

*************** Genie On The Ground, Recovering After A Bop ***************

GENIE_RECOVERING
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#8,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#18,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#16,OBJFRAME(a5)
.sameframe
	subq.b	#1,OBJAUX1(a5)
	bne.s	.notyet

	move.l	#GENIE_FLOATING,OBJAI(a5)
	move.b	#2,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	sf.b	OBJAUX2(a5)
.notyet
	jmp	DISPLAY_OBJECT

************************** Genie Has Been Beaten **************************

GENIE_BEATEN
	move.b	OBJAUX1(a5),d0			;increase velocity downwards
	subq.b	#1,d0
	cmp.b	#-40,d0
	bge.s	.yspeedok
	moveq.l	#-40,d0
.yspeedok
	move.b	d0,OBJAUX1(a5)
	ext.w	d0
	ext.l	d0
	moveq.l	#16-2,d1
	asl.l	d1,d0
	sub.l	d0,OBJY(a5)

	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	add.w	#64,d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.falling

	move.l	#GENIE_CRYING,OBJAI(a5)
	move.b	#18,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#50,OBJAUX1(a5)
.falling
	jmp	DISPLAY_OBJECT

************************* Genie Crying After Falling **********************

GENIE_CRYING
	subq.b	#1,OBJAUX0(a5)		;animate genie crying
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#20,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#18,OBJFRAME(a5)
.sameframe
	subq.b	#1,OBJAUX1(a5)
	bne.s	.crying

	tst.b	vase_active			;can the genie escape
	bne.s	.escape				;into the vase?
.cantescape
	move.l	#GENIE_DEAD,OBJAI(a5)		;no she can't so
	move.b	#200,OBJAUX1(a5)		;she's dead
	bra.s	.crying
.escape
	move.l	#GENIE_ESCAPE,OBJAI(a5)		;time to escape
	move.b	#10,OBJAUX0(a5)
	sf.b	OBJAUX3(a5)
	sf.b	OBJAUX4(a5)
.crying
	jmp	DRAW_COMPLEX_SPRITE

****************** Genie Escaping To A Point Above The Vase ***************

GENIE_ESCAPE
	subq.b	#1,OBJAUX0(a5)		;animate genie crying
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#20,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#18,OBJFRAME(a5)
.sameframe
	move.l	vaseobject,a0		;get vector to a point
	move.w	OBJX(a0),d0		;above the vase
	move.w	OBJY(a0),d1
	sub.w	#100,d1

	cmp.w	OBJX(a5),d0
	bne.s	.notyet
	cmp.w	OBJY(a5),d1
	bne.s	.notyet

	move.l	#GENIE_DISAPPEARING,OBJAI(a5)
	sf.b	OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	jmp	DISPLAY_OBJECT

.notyet
	cmp.w	OBJX(a5),d0
	beq.s	.xok
	bge.s	.right
.left
	subq.w	#1,OBJX(a5)
	bra.s	.xok
.right
	addq.w	#1,OBJX(a5)
.xok
	cmp.w	OBJY(a5),d1
	beq.s	.yok
	bge.s	.up
.down
	subq.w	#1,OBJY(a5)
	bra.s	.yok
.up
	addq.w	#1,OBJY(a5)
.yok
	jmp	DRAW_COMPLEX_SPRITE

*********************** Genie Moving Down Into The Vase *******************

GENIE_DISAPPEARING
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	eor.b	#1,OBJFRAME(a5)
.sameframe
	tst.b	vase_active
	bne.s	.stillthere

	move.l	#GENIE_DEAD,OBJAI(a5)
	move.b	#16,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#100,OBJAUX1(a5)
	bra.s	.notyet

.stillthere
	addq.w	#1,OBJY(a5)
	move.l	vaseobject,a0
	move.w	OBJY(a0),d0
	cmp.w	OBJY(a5),d0
	bne.s	.notyet

	move.l	#GENIE_HIDING,OBJAI(a5)
	move.b	#50,OBJAUX0(a5)
	jmp	DRAW_COMPLEX_SPRITE
.notyet
	jmp	DRAW_COMPLEX_SPRITE

******************************* Genie Is Dead *****************************

GENIE_DEAD
	subq.b	#1,OBJAUX0(a5)			;animate genie crying
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#20,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#18,OBJFRAME(a5)
.sameframe
	subq.b	#1,OBJAUX1(a5)
	beq	DELETE_BOSS
	jmp	DRAW_COMPLEX_SPRITE

***************************** Fireball Routines ***************************

******************** Fireball Bouncing Around The Screen ******************

FIREBALL
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcs	.hitbubsy

	subq.b	#1,OBJAUX0(a5)			;fireball animation
	bne.s	.sameframe
	move.b	#7,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#3,OBJFRAME(a5)
	bne.s	.sameframe
	sf.b	OBJFRAME(a5)
.sameframe
	subq.b	#1,OBJAUX1(a5)			;check for lifetime
	beq	.killfireball			;exceeded

	move.b	OBJAUX3(a5),d0			;move the fireball
	move.b	OBJAUX4(a5),d1
	ext.w	d0
	ext.w	d1
	ext.l	d0
	ext.l	d1
	moveq.l	#16-2,d2
	asl.l	d2,d0
	asl.l	d2,d1
	add.l	d0,OBJX(a5)
	add.l	d1,OBJY(a5)

	move.w	OBJX(a5),d0			;bounce the fireball
	move.w	OBJY(a5),d1			;off the screen edges
	moveq.l	#16,d2
	moveq.l	#16,d3
	add.w	WINDX,d2
	add.w	WINDY,d3
	cmp.w	d2,d0
	bge.s	.xnotlow
	move.w	d2,d0
	neg.b	OBJAUX3(a5)
	bra.s	.xnothigh
.xnotlow
	add.w	#320-(16*2),d2
	cmp.w	d2,d0
	ble.s	.xnothigh
	move.w	d2,d0
	neg.b	OBJAUX3(a5)
.xnothigh
	cmp.w	d3,d1
	bge.s	.ynotlow
	move.w	d3,d1
	neg.b	OBJAUX4(a5)
	bra.s	.ynothigh
.ynotlow
	add.w	#200-(16*2),d3
	cmp.w	d3,d1
	ble.s	.ynothigh
	move.w	d3,d1
	neg.b	OBJAUX4(a5)
.ynothigh
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)

	move.w	d1,d2			;detect against the map
	move.w	d0,d1			;use low edge of the fireball
	add.w	#16,d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.nobounce
	neg.b	OBJAUX4(a5)
.nobounce
	jmp	DRAW_COMPLEX_SPRITE
.hitbubsy
	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY
.killfireball
	move.l	#CRATEEXPLODE,OBJAI(a5)
	move.l	#CRATE10002,OBJINITDMA(a5)
	move.l	#CRATEMAP,OBJMAP(a5)
	sf.b	OBJAUX2(a5)
	sf.b	OBJAUX1(a5)
	sf.b	OBJAUX0(a5)
	sf.b	OBJFRAME(a5)
	addq.w	#8,OBJY(a5)
	jmp	ENEMYOAMS

******************************* Gun Routines ******************************

****************************** Gun Appearing ******************************

GUN_APPEAR
	subq.b	#1,OBJAUX0(a5)
	bne.s	.notyet
	move.l	#GUN_RELOAD,OBJAI(a5)
	move.b	#15,OBJAUX0(a5)
.notyet
	rts

*************************** Gun Waiting To Shoot **************************

GUN_RELOAD
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nocollide

	bsr	KILL_GUN

	move.b	BUBSYFLAGS,d0
	and.b	#ANCHORFLAG,d0
	bne	.deadly

	tst.w	BUBVY
	blt	.deadly
	rts
.deadly
	moveq.l	#POPSTATE,d0
	jmp	KILLBUBSY
.nocollide
	bsr	GUN_FLOAT

	subq.b	#1,OBJAUX0(a5)
	bne.s	.noshoot

	move.l	#GUN_SHOOT,OBJAI(a5)
	sf.b	OBJFRAME(a5)
	move.b	#8,OBJAUX0(a5)
.noshoot
	jmp	DRAW_COMPLEX_SPRITE

********************** Gun Shooting A Homing Bullet ***********************

GUN_SHOOT
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nocollide

	bsr	KILL_GUN

	move.b	BUBSYFLAGS,d0
	and.b	#ANCHORFLAG,d0
	bne	.deadly

	tst.w	BUBVY
	blt	.deadly
	rts
.deadly
	moveq.l	#POPSTATE,d0
	jmp	KILLBUBSY
.nocollide
	bsr	GUN_FLOAT

	subq.b	#1,OBJAUX0(a5)
	bne	.sameframe
	move.b	#8,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#8,OBJFRAME(a5)
	bne.s	.noshoot

;	bsr	MAKE_HBULLET
	bsr	MAKE_ZBULLETS
.noshoot
	cmp.b	#10,OBJFRAME(a5)
	bne.s	.sameframe

	subq.b	#1,OBJAUX1(a5)		;shoots a few times then
	beq.s	KILL_GUN		;deletes itself

	move.l	#GUN_RELOAD,OBJAI(a5)
	sf.b	OBJFRAME(a5)
	move.b	#15,OBJAUX0(a5)
.sameframe
	jmp	DRAW_COMPLEX_SPRITE

********************* Remove Gun With A Puff Of Smoke *********************

KILL_GUN
	sf.b	gun_active

	move.w	OBJX(a5),d0
	move.w	OBJY(a5),d1
	lea	gun_smoke,a0
	bsr	MAKE_SMOKE

	jmp	CLEAROBJWVRAM
	rts

***************************** Bullet Routines *****************************

HBULLET	subq.b	#1,OBJAUX0(a5)			;has the bullet been on
	bne.s	.stillon			;long enough?
	jmp	CLEAROBJWVRAM
.stillon
	moveq.l	#0,d0				;add on the movement
	move.b	OBJFRAME(a5),d0			;for the current frame
	add.w	d0,d0
	add.w	d0,d0
	lea	velocities,a0
	movem.w	0(a0,d0.w),d6-d7
	neg.w	d7
	muls	#10,d6
	muls	#10,d7
	add.l	d6,OBJX(a5)
	add.l	d7,OBJY(a5)
	asr.l	#8,d6
	asr.l	#8,d7

	subq.b	#1,OBJAUX1(a5)
	bne.s	.donerot
	move.b	#7,OBJAUX1(a5)

	move.w	d6,d1			;get the left side vector
	move.w	d7,d0
	neg.w	d1
	move.w	d6,d4
	move.w	d7,d5
	sub.w	d0,d4
	sub.w	d1,d5
	asr.w	#1,d4
	asr.w	#1,d5
	add.w	d4,d0
	add.w	d5,d1

	move.w	d6,d3			;get the right side vector
	move.w	d7,d2
	neg.w	d2
	move.w	d6,d4
	move.w	d7,d5
	sub.w	d2,d4
	sub.w	d3,d5
	asr.w	#1,d4
	asr.w	#1,d5
	add.w	d4,d2
	add.w	d5,d3

	move.w	OBJX(a5),d6			;get vector from bullet
	move.w	OBJY(a5),d7			;to bubsy
	sub.w	BUBX,d6
	sub.w	BUBY,d7
	add.w	#35,d7

.checkleft
	move.w	d6,d4			;check if we should rotate left
	move.w	d7,d5
	muls	d0,d4
	muls	d1,d5
	add.l	d5,d4
	bgt.s	.checkright
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.donerot
	addq.b	#8,OBJFRAME(a5)
	bra.s	.donerot
.checkright
	move.w	d6,d4			;check if we should rotate right
	move.w	d7,d5
	muls	d2,d4
	muls	d3,d5
	add.l	d5,d4
	bgt.s	.donerot
	addq.b	#1,OBJFRAME(a5)	
	cmp.b	#8,OBJFRAME(a5)
	blt.s	.donerot
	subq.b	#8,OBJFRAME(a5)
.donerot
	jmp	DRAW_COMPLEX_SPRITE

****************************** Zooming Bullet *****************************

ZBULLET
	subq.b	#1,OBJAUX0(a5)		;decrease lifetime
	bne.s	.notyet
	jmp	CLEAROBJWVRAM
.notyet
	move.b	OBJAUX4(a5),d0		;update velocity
	tst.b	OBJOAM0(a5)
	beq.s	.right
.left
	subq.b	#1,d0
	cmp.b	#4*4,d0
	ble.s	.speedok
	move.b	#4*4,d0
	bra.s	.speedok
.right
	addq.b	#1,d0
	cmp.b	#-4*4,d0
	bge.s	.speedok
	move.b	#-4*4,d0
.speedok
	move.b	d0,OBJAUX4(a5)

	ext.w	d0
	asr.w	#2,d0
	add.w	d0,OBJX(a5)

	ext.l	d0
	moveq.l	#16-3,d1
	asl.l	d1,d0
	tst.b	OBJAUX3(a5)
	beq.s	.noy
	bpl.s	.ypos
	neg.l	d0
.ypos
	add.l	d0,OBJY(a5)
.noy
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nocollide

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY

	jmp	CLEAROBJWVRAM
.nocollide
	jmp	DRAW_COMPLEX_SPRITE

**************************** Handy Subroutines ****************************

***************************** Make A Fireball *****************************

MAKE_FIREBALL
	move.l	a5,a6

	move.w	#$3fff,d7		;generate the fireball
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)
	move.l	#FIREBALL,OBJAI(a5)
	move.l	#fireball,OBJINITDMA(a5)
	move.l	#fireballmap,OBJMAP(a5)
	sf.b	OBJFRAME(a5)
	move.b	#7,OBJAUX0(a5)
	move.b	#200,OBJAUX1(a5)

	move.w	#70,d0			;set the position
	move.w	#50,d1			;and velocity
	moveq.l	#8,d2
	tst.b	OBJOAM0(a6)
	beq.s	.castright
	neg.w	d0
	neg.b	d2
.castright
	add.w	OBJX(a6),d0
	add.w	OBJY(a6),d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)
	move.b	d2,OBJAUX3(a5)
	jsr	RANDOM			;random yspeed
	and.b	#7,d0
	add.b	#6,d0
	move.b	d0,OBJAUX4(a5)

	move.w	OBJX(a5),d0		;make a puff of smoke
	move.w	OBJY(a5),d1
	addq.w	#8,d1
	lea	finger_smoke,a0
	bsr	MAKE_SMOKE

	move.l	a6,a5
	rts

************************** Make The Gun At The Left ***********************

MAKE_GUN_LEFT
	move.l	a5,a6

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)
	move.l	#GUN_APPEAR,OBJAI(a5)
	move.l	#gun,OBJINITDMA(a5)
	move.l	#gunmap,OBJMAP(a5)
	sf.b	OBJFRAME(a5)
	move.b	#$8,OBJOAM0(a5)
	move.b	#40,OBJAUX0(a5)
	move.b	#3,OBJAUX1(a5)
	move.b	#6,OBJAUX3(a5)
	move.b	#14,OBJAUX4(a5)

	move.w	WINDX,d0
	move.w	WINDY,d1
	add.w	#70,d0
	add.w	#100,d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)
	move.w	d0,gunx
	move.w	d1,guny

	move.w	OBJX(a5),d0		;make some smoke to
	move.w	OBJY(a5),d1		;cover the gun
	lea	gun_smoke,a0
	bsr	MAKE_SMOKE

	move.l	a6,a5

	move.w	#70,d0			;make some smoke at
	move.w	#50,d1			;the genie's fingertips
	tst.b	OBJOAM0(a6)
	beq.s	.right
	neg.w	d0
.right
	add.w	OBJX(a5),d0
	add.w	OBJY(a5),d1
	addq.w	#8,d1
	lea	finger_smoke,a0
	bsr	MAKE_SMOKE

	st.b	gun_active
	rts

************************* Make The Gun At The Right ***********************

MAKE_GUN_RIGHT
	move.l	a5,a6

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)
	move.l	#GUN_APPEAR,OBJAI(a5)
	move.l	#gun,OBJINITDMA(a5)
	move.l	#gunmap,OBJMAP(a5)
	sf.b	OBJFRAME(a5)
	sf.b	OBJOAM0(a5)
	move.b	#40,OBJAUX0(a5)
	move.b	#3,OBJAUX1(a5)
	move.b	#6,OBJAUX3(a5)
	move.b	#14,OBJAUX4(a5)

	move.w	WINDX,d0
	move.w	WINDY,d1
	add.w	#320-70,d0
	add.w	#100,d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)
	move.w	d0,gunx
	move.w	d1,guny

	move.w	OBJX(a5),d0		;make some smoke to
	move.w	OBJY(a5),d1		;cover the gun
	lea	gun_smoke,a0
	bsr	MAKE_SMOKE

	move.l	a6,a5

	move.w	#70,d0			;make some smoke at
	move.w	#50,d1			;the genie's fingertips
	tst.b	OBJOAM0(a6)
	beq.s	.right
	neg.w	d0
.right
	add.w	OBJX(a5),d0
	add.w	OBJY(a5),d1
	addq.w	#8,d1
	lea	finger_smoke,a0
	bsr	MAKE_SMOKE

	st.b	gun_active
	rts

*************************** Make A Homing Bullet **************************

MAKE_HBULLET
	move.l	a5,a6

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)
	move.l	#HBULLET,OBJAI(a5)
	move.l	#hbullet,OBJINITDMA(a5)
	move.l	#hbulletmap,OBJMAP(a5)
	sf.b	OBJFRAME(a5)
	sf.b	OBJOAM0(a5)
	move.b	#100,OBJAUX0(a5)
	move.b	#7,OBJAUX1(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)

	move.w	#50,d0
	tst.b	OBJOAM0(a6)
	bne.s	.right
	addq.b	#4,OBJFRAME(a5)
	neg.w	d0
.right
	add.w	d0,OBJX(a5)
	addq.w	#8,OBJY(a5)

	move.l	a6,a5
	rts

************************** Make A Zooming Bullet **************************

MAKE_ZBULLETS
	bsr	MAKE_ZBULLET
	move.b	#1,OBJAUX3(a1)		;y movement type

	bsr	MAKE_ZBULLET
	move.b	#0,OBJAUX3(a1)

	bsr	MAKE_ZBULLET
	move.b	#-1,OBJAUX3(a1)
	rts

MAKE_ZBULLET
	move.w	#$3fff,d7
	jsr	GET_AN_OBJECT
	move.w	#$7f00,OBJKEY(a1)
	move.l	#ZBULLET,OBJAI(a1)
	move.l	#hbullet,OBJINITDMA(a1)
	move.l	#hbulletmap,OBJMAP(a1)
	sf.b	OBJFRAME(a1)
	sf.b	OBJOAM0(a1)
	move.b	#50,OBJAUX0(a1)
	move.b	#7,OBJAUX1(a1)
	move.w	OBJX(a5),OBJX(a1)
	move.w	OBJY(a5),OBJY(a1)

	move.w	#50,d0
	move.b	#1*4,d1
	move.b	OBJOAM0(a5),OBJOAM0(a1)
	bne.s	.right
	neg.w	d0
	neg.b	d1
.right
	add.w	d0,OBJX(a1)
	addq.w	#8,OBJY(a1)
	move.b	d1,OBJAUX4(a1)
	eor.b	#8,OBJOAM0(a1)
	rts

************************** Make A Load Of Smoke ***************************

MAKE_SMOKE
	move.w	(a0)+,d7		;makes d7 smoke objects using
	subq.w	#1,d7			;position offsets at a0
.smoke
	bsr	GET_AN_OBJECT

	move.l	#CRATEEXPLODE,OBJAI(a1)
	move.l	#CRATE10002,OBJINITDMA(a1)
	move.l	#CRATEMAP,OBJMAP(a1)
	sf.b	OBJAUX1(a1)
	sf.b	OBJAUX0(a1)
	sf.b	OBJFRAME(a1)

	movem.w	(a0)+,d2-d3
	add.w	d0,d2
	add.w	d1,d3
	addq.w	#8,d3
	move.w	d2,OBJX(a1)
	move.w	d3,OBJY(a1)
	move.w	#$3fff,OBJKEY(a1)

	dbf	d7,.smoke
	rts

**************************** Make The Gun Float ***************************

GUN_FLOAT
	move.b	OBJAUX3(a5),d0
	move.b	OBJAUX4(a5),d1
	ext.w	d0
	ext.w	d1
	ext.l	d0
	ext.l	d1
	moveq.l	#16-5,d2
	asl.l	d2,d0
	asl.l	d2,d1
	add.l	d0,OBJX(a5)
	add.l	d1,OBJY(a5)

	move.w	OBJX(a5),d0
	move.w	OBJY(a5),d1
	cmp.w	gunx,d0
	beq.s	.samex
	bgt.s	.highx
.lowx
	addq.b	#1,OBJAUX3(a5)
	bra.s	.samex
.highx
	subq.b	#1,OBJAUX3(a5)
.samex
	cmp.w	guny,d1
	beq.s	.samey
	bgt.s	.highy
.lowy
	addq.b	#1,OBJAUX4(a5)
	bra.s	.samey
.highy
	subq.b	#1,OBJAUX4(a5)
.samey
	rts

************************ Display A Flashable Object ***********************

DISPLAY_OBJECT
	tst.b	OBJAUX3(a5)
	beq.s	.display
	subq.b	#1,OBJAUX3(a5)
	btst.b	#0,OBJAUX3(a5)
	beq.s	.display
	rts
.display
	jmp	DRAW_COMPLEX_SPRITE

*********************** Collision Detection Subroutines *******************

*************************** Genie Collision Detection *********************

GENIE_COLLIDE
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.out

	tst.w	BUBVY			;if bubsy is moving up
	bgt.s	.bop			;kill the stupid bugger
	moveq.l	#POPSTATE,d0
	jmp	KILLBUBSY
.bop
	move.b	#JUMPSTATE,BUBSTATE	;bounce bubsy a bit
	jsr	RANDOM
	and.w	#15,d0
	subq.w	#8,d0
	move.w	d0,BUBVX
	move.w	#$fc00,BUBVY

	subq.b	#1,OBJAUX4(a5)
	bne.s	.stunned
.beaten
	move.l	#GENIE_BEATEN,OBJAI(a5)
	move.b	#16,OBJFRAME(a5)
	move.b	#10,OBJAUX1(a5)
	bra.s	.out
.stunned
	move.l	#GENIE_STUNNED,OBJAI(a5)
	move.b	#16,OBJFRAME(a5)
	move.b	#8,OBJAUX0(a5)
	move.b	#10,OBJAUX1(a5)	
.out
	rts

*************************** Vase Collision Detection **********************

VASE_COLLIDE
	tst.b	OBJAUX3(a5)		;no detection whilst flashing
	bne	.out

	move.b	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.out

	btst	#bANCHORFLAG,BUBSYFLAGS
	bne.s	.out

	tst.w	BUBVY
	bmi.s	.out

	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.out

	move.b	#JUMPSTATE,BUBSTATE
	jsr	RANDOM
	and.w	#15,d0
	subq.w	#8,d0
	move.w	d0,BUBVX
	move.w	#$fa00,BUBVY

	move.b	#50,OBJAUX3(a5)		;set flash on
	addq.b	#1,OBJFRAME(a5)		;next damage frame
	subq.b	#1,OBJAUX4(a5)		;decrement hitpoints
	bne.s	.out

	move.l	#VASE_SMASH,OBJAI(a5)
	move.b	#9,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)

	sf.b	vase_active
.out
	rts

********************** Super Safe Empty Object Finder *********************

GET_AN_OBJECT
	movem.l	d0-d7/a0/a2-a6,-(sp)		;returns object pointer
	move.w	#$3fff,d7			;in a1
	jsr	FINDFIRSTFREEOBJ
	move.l	a5,a1
	movem.l	(Sp)+,d0-d7/a0/a2-a6
	rts

******************* That's IT, Finito, Kaput, Adios Amigos ****************

DELETE_BOSS
	bclr	#bSCROLLFLAG,BUBSYFLAGS1		;stop scrolling
	bset	#bBUBSYOFFSCREEN,GAMEFLAG0
	or.b	#BOSSFLAG,GAMEFLAG1

	move.l	a5,-(a7)				;stop the clock
	bclr	#bTIMEFLAG,GAMEFLAG1
	jsr	INITOBJS				;clear out all object entries

	MOVE.L	#OBJBASE,A5				;start the tally score
	ADD.L	#OBJLEN,A5
	CLR.w	OBJKEY(A5)
	MOVE.w	#%1110000000000000+$680,OBJOAM0(A5)
	MOVE.L 	#TALLYAI,OBJAI(A5)
	MOVE.L	#LVLTXTMAP,OBJMAP(A5)

	MOVE.w	TIME,OBJAUX4(A5)			;copy time
	MOVE.w	YARNS,OBJAUX6(A5)			;and yarn

	MOVE	#ENDTXTLEN,D6				;copy the text
	LEA	ENDTXT,A0
	LEA	STRIPBUF,A1
.CTLOOP
	MOVE.B	(A0)+,(A1)+
	DBRA	D6,.CTLOOP

	MOVE.B	#ENDSTATE,BUBSTATE
	MOVE.L	(SP)+,A5
	rts

***************************** A Few Variables *****************************

vaseobject
	dc.l	0

floaty	dc.w	0
gunx	dc.w	0
guny	dc.w	0

vase_active
	dc.b	0
genie_active
	dc.b	0
gun_active
	dc.b	0

fireballs
	dc.b	0

	even

******************************** Vase Frames ******************************

vase
	dc.l	.f0			;frame 0 no damage
	dc.l	.f1			;frame 1-8 increasing damage
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7
	dc.l	.f8
	dc.l	.f9			;frames 9-16 falling apart
	dc.l	.f10
	dc.l	.f11
	dc.l	.f12
	dc.l	.f13
	dc.l	.f14
	dc.l	.f15

.f0	dc.w	1,0,0,0
	dc.w	-31,0,0

.f1	dc.w	1,0,0,0
	dc.w	-31,0,1

.f2	dc.w	1,0,0,0
	dc.w	-31,0,2

.f3	dc.w	1,0,0,0
	dc.w	-31,0,3

.f4	dc.w	1,0,0,0
	dc.w	-31,0,4

.f5	dc.w	1,0,0,0
	dc.w	-31,0,5

.f6	dc.w	1,0,0,0
	dc.w	-31,0,6

.f7	dc.w	1,0,0,0
	dc.w	-31,0,7

.f8	dc.w	1,0,0,0
	dc.w	-31,0,8

.f9	dc.w	1,0,0,0
	dc.w	-45,0,9

.f10	dc.w	1,0,0,0
	dc.w	-50,13,10

.f11	dc.w	1,0,0,0
	dc.w	-61,30,11

.f12	dc.w	1,0,0,0
	dc.w	-75,30,12

.f13	dc.w	1,0,0,0
	dc.w	-90,30,13

.f14	dc.w	1,0,0,0
	dc.w	-90,30,14

.f15	dc.w	1,0,0,0
	dc.w	-90,30,15

******************************* Genie Frames ******************************

genie	dc.l	.f0			;frames 0-1 appearing
	dc.l	.f1
	dc.l	.f2			;frames 2-5 floating
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6			;frames 6-15 casting spell
	dc.l	.f7
	dc.l	.f8
	dc.l	.f9
	dc.l	.f10
	dc.l	.f11
	dc.l	.f12
	dc.l	.f13
	dc.l	.f14
	dc.l	.f15
	dc.l	.f16			;frames 16-17 falling down
	dc.l	.f17
	dc.l	.f18			;frames 18-19 crying
	dc.l	.f19

.f0	dc.w	1,0,0,0
	dc.w	-18,0,16

.f1	dc.w	1,0,0,0
	dc.w	-18,0,17

.f2	dc.w	1,0,0,0
	dc.w	-49,0,20

.f5
.f3	dc.w	1,0,0,0
	dc.w	-52,0,21

.f4	dc.w	1,0,0,0
	dc.w	-62,0,22

.f6	dc.w	1,0,0,0
	dc.w	-50,0,23

.f7	dc.w	1,0,0,0
	dc.w	-50,0,24

.f8	dc.w	1,0,0,0
	dc.w	-50,0,25

.f9	dc.w	1,0,0,0
	dc.w	-50,0,26

.f10	dc.w	1,0,0,0
	dc.w	-50,0,27

.f11	dc.w	1,0,0,0
	dc.w	-50,0,28

.f12	dc.w	1,0,0,0
	dc.w	-50,0,29

.f13	dc.w	1,0,0,0
	dc.w	-50,0,30


.f14	dc.w	1,0,0,0
	dc.w	-50,0,31


.f15	dc.w	1,0,0,0
	dc.w	-50,0,32

.f16	dc.w	1,0,0,0
	dc.w	-50,0,33

.f17	dc.w	1,0,0,0
	dc.w	-50,0,34

.f18	dc.w	1,0,0,0
	dc.w	-25,0,18

.f19	dc.w	1,0,0,0
	dc.w	-25,0,19

****************************** Fireball Frames ****************************

fireball
	dc.l	.f0
	dc.l	.f1
	dc.l	.f2

.f0	dc.w	1,0,0,0			;these sprites are supposed
	dc.w	-18,-17,38		;to be numbered backwards

.f1	dc.w	1,0,0,0			;just in case you're wondering
	dc.w	-17,-18,37

.f2	dc.w	1,0,0,0
	dc.w	-18,-16,36

******************************** Gun Frames *******************************

gun	dc.l	.f0		;frame 0 reloading
	dc.l	.f1		;frames 1-9 shooting
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7
	dc.l	.f8
	dc.l	.f9

.f0	dc.w	1,0,0,0
	dc.w	-30,0,39

.f1	dc.w	1,0,0,0
	dc.w	-30,0,40

.f2	dc.w	1,0,0,0
	dc.w	-30,0,41

.f3	dc.w	1,0,0,0
	dc.w	-30,0,42

.f4	dc.w	1,0,0,0
	dc.w	-30,0,43

.f5	dc.w	1,0,0,0
	dc.w	-18,0,44

.f6	dc.w	1,0,0,0
	dc.w	-17,0,45

.f7	dc.w	1,0,0,0
	dc.w	-77,0,46

.f8	dc.w	1,0,0,0
	dc.w	-47,0,47

.f9	dc.w	1,0,0,0
	dc.w	-38,0,48

******************************* Bullet Frames *****************************

hbullet	dc.l	.f0
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7

.f0	dc.w	1,0,0,0
	dc.w	0,0,49

.f1	dc.w	1,0,0,0
	dc.w	0,0,50

.f2	dc.w	1,0,0,0
	dc.w	0,0,51

.f3	dc.w	1,0,0,0
	dc.w	0,0,52

.f4	dc.w	1,0,0,0
	dc.w	0,0,53

.f5	dc.w	1,0,0,0
	dc.w	0,0,54

.f6	dc.w	1,0,0,0
	dc.w	0,0,55

.f7	dc.w	1,0,0,0
	dc.w	0,0,56

************************** Vase Collision Detection ***********************

vasemap
	rept	9
	Soff	0,0,-20,0,20,0,-30,-19,30,-19,-22,-52,22,-52
	endr

************************* Genie Collision Detection ***********************

geniemap
	Soff	0,0,7,0,14,-28,8,-50,-7,0,-14,-28,-8,-50
	Soff	0,0,7,0,14,-28,8,-50,-7,0,-14,-28,-8,-50

	Soff	50,0,55,0,70,-40,46,-48,27,-48,0,-37,42,-23
	Soff	50,0,55,0,70,-40,46,-48,27,-48,0,-37,42,-23
	Soff	50,0,55,0,70,-40,46,-48,27,-48,0,-37,42,-23
	Soff	50,0,55,0,70,-40,46,-48,27,-48,0,-37,42,-23

	Soff	50,0,60,-5,70,-40,46,-48,27,-48,0,-37,42,-23
	Soff	50,0,5,-5,60,-5,50,-37,35,-60,20,-50,0,-40
	Soff	50,0,5,-5,50,-5,47,-47,35,-70,20,-65,0,-55
	Soff	50,0,5,-5,50,-5,47,-47,42,-63,20,-65,5,-55
	Soff	50,0,7,-7,50,-5,57,-47,52,-63,36,-63,20,-65
	Soff	50,0,0,-10,60,-40,30,-30,80,-10,125,-40,105,-55
	Soff	50,0,0,-10,60,-40,30,-30,80,-10,125,-40,105,-55
	Soff	50,0,0,-10,60,-40,30,-30,80,-10,125,-40,105,-55
	Soff	50,0,0,-10,60,-40,30,-30,80,-10,125,-40,105,-55
	Soff	50,0,0,-10,60,-40,30,-30,80,-10,125,-40,105,-55

************************ Fireball Collision Detection *********************

fireballmap
	rept	3
	Soff	0,0,-16,0,16,0,-10,16,10,16,-10,-16,10,-16
	endr

*************************** Gun Collision Detection ***********************

gunmap
	Soff	30,0,0,0,12,-24,24,0,36,-24,48,0,60,-24
	Soff	30,0,0,0,12,-24,24,0,36,-24,48,0,60,-24
	Soff	30,0,0,0,12,-24,24,0,36,-24,48,0,60,-24
	Soff	30,0,0,0,12,-24,24,0,36,-24,48,0,60,-24
	Soff	30,0,0,0,12,-24,24,0,36,-24,48,0,60,-24
	Soff	18,0,0,0,7,-30,14,0,21,-30,28,0,36,-30
	Soff	17,0,0,0,7,-30,14,0,21,-30,28,0,34,-30
	Soff	77,0,0,0,31,-27,62,0,93,-27,124,0,154,-27
	Soff	47,0,0,0,19,-17,38,0,57,-17,76,0,94,-17
	Soff	38,0,0,0,15,-18,30,0,45,-18,60,0,76,-18

************************* Bullet Collision Detection **********************

hbulletmap
	Soff	0,0,-10,5,0,5,10,5,-10,-5,0,-5,10,-5

******************************** Smoke Tables *****************************

finger_smoke
	dc.w	5			;appears at the genie's
	dc.w	-2,-13			;fingertips
	dc.w	-14,-2
	dc.w	17,-5
	dc.w	8,5
	dc.w	-9,8

gun_smoke
	dc.w	3
	dc.w	-20,20
	dc.w	0,20
	dc.w	20,20

******************* Bullet Velocities For each Bullet Frame ***************

velocities
	dc.w	16384,0
	dc.w	10641,-10641
	dc.w	0,-16384
	dc.w	-10641,-10641
	dc.w	-16384,0
	dc.w	-10641,10641
	dc.w	0,16384
	dc.w	10641,10641
