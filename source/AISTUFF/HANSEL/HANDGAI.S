***************************** Hansel And Gretel AI ************************

; A rough description of what Hansel and Gretel do.

; They jump up and down and lob cherries at Bubsy.
; Wowwee...

HG_HITPOINTS	equ	8
WITCH_DEPTH	equ	150

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

HANDGAI:
HG_LOAD:
	jsr	OBJRANGE
	bcc	.INRANGE
	andi.b	#~BOSSFLAG,GAMEFLAG1
	jmp	CLEAROBJ
	rts
.INRANGE:
	jsr	CLIPY

	move.w	BUBX,d0					;make sure we are close
	sub.w	OBJX(a5),d0
	bpl.s	.posi
	neg.w	d0
.posi:	cmp.w	#16,d0
	bgt	.out

	move.w	WINDY,d0
	cmp.w	WINDYOLD,d0				;ensure land does not change height
	bne	.out
	
	move.b	BUBSYFLAGS,d0				;and make sure bubsy is anchored
	andi.b	#ANCHORFLAG,d0
	beq	.out

	move.l	#HG_START,OBJAI(a5)		;wait for loading to be done.

	sf	OBJAUX5(a5)				;graphics not load in yet..

	lea	OBJBASE,a1				;first, let's copy AI to beginning of AI DP
	move.w	#OBJLEN,d0
.COPYLOOP:
	move.b	(a5)+,(a1)+
	dbf.w	d0,.COPYLOOP

	lea	OBJBASEEND,a5					;now lets clear out the rest of the objects
.CLEARLOOP:
	suba.l	#OBJLEN,a5
	cmpa.l	#OBJBASE,a5
	beq	.CHANGEAI
	jsr	CLEAROBJWVRAM
	bra	.CLEARLOOP
.CHANGEAI:
	or.b	#BOSSFLAG,GAMEFLAG1
	move.w	WINDY,WINDYOLD
	bclr	#bTIMEFLAG,GAMEFLAG1				;stop the clock

	lea	LEVEL3_BOSS,a0
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	load_file_no_wait				;load in graphics - no wait

	move.w	WINDX,WINDXMIN
	move.w	WINDY,WINDYMIN
	move.w	WINDXMIN,WINDXMAX
	move.w	WINDYMIN,WINDYMAX
	move.w	WINDX,d0
	addi.w	#10,d0
	move.w	d0,BUBXMIN
	addi.w	#320-20,d0
	move.w	d0,BUBXMAX
.out:
	rts

;**************************************************************************

HG_START:
	bclr	#bTIMEFLAG,GAMEFLAG1					;stop the clock
	jsr	loaded_in_no_wait
	bne.s	.yes_loaded
	rts
.yes_loaded:
	tst.b	OBJAUX5(a5)
	bne.s	.already_relocated_sprites
	st	OBJAUX5(a5)
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	relocate_sprites
.already_relocated_sprites:
	move.l	#WITCH_DESCENDING,OBJAI(a5)	;use the existing object
	move.l	#witch,OBJINITDMA(a5)		;for the witch
	move.w	WINDX,OBJX(a5)
	move.w	WINDY,OBJY(a5)
	add.w	#160,OBJX(a5)
	sub.w	#70,OBJY(a5)
	sf.b	OBJFRAME(a5)
	move.b	#WITCH_DEPTH,OBJAUX0(a5)
	move.b	#20,OBJAUX4(a5)			;x velocity

	move.l	a5,a6

	move.w	#$3fff,d7			;get another object
	jsr	FINDFIRSTFREEOBJ		;for Gretel
	move.w	#$7f00,OBJKEY(A5)
	move.l	#HG_APPEARING,OBJAI(a5)
	move.l	#gretel,OBJINITDMA(a5)
	move.l	#gretelmap,OBJMAP(A5)
	move.w	WINDX,OBJX(a5)
	move.w	WINDY,OBJY(a5)
	add.w	#160-80,OBJX(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.b	#31,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)			;animation delay
	move.b	#1,OBJAUX1(a5)			;jump delay
	sf.b	OBJAUX3(a5)
	move.b	#HG_HITPOINTS,OBJAUX4(a5)

	move.w	#$3fff,d7			;get another object
	jsr	FINDFIRSTFREEOBJ		;for Hansel
	move.w	#$7f00,OBJKEY(A5)
	move.l	#HG_APPEARING,OBJAI(a5)
	move.l	#hansel,OBJINITDMA(a5)
	move.l	#hanselmap,OBJMAP(a5)
	move.w	WINDX,OBJX(a5)
	move.w	WINDY,OBJY(a5)
	add.w	#160+80,OBJX(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	move.b	#31,OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)			;animation delay
	move.b	#50,OBJAUX1(a5)			;jump delay
	sf.b	OBJAUX3(a5)
	move.b	#HG_HITPOINTS,OBJAUX4(a5)

	move.l	a6,a5

	bset	#bBUBSYOFFSCREEN,GAMEFLAG0		;hopefully

	move.b	#2,handg			;Hansel AND Gretel
	rts

************************* Hansel And Gretel Appearing *********************

HG_APPEARING:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)

	subq.b	#1,OBJFRAME(a5)
	cmp.b	#22,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#HG_STANDING,OBJAI(a5)
	sf.b	OBJFRAME(a5)

	move.b	#10,OBJAUX0(a5)

.sameframe:
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE

********************** Hansel and Gretel doing nothing ********************

HG_STANDING:
	bsr	HG_COLLIDE

	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#5,OBJFRAME(a5)
	blt.s	.sameframe
	sf.b	OBJFRAME(a5)
.sameframe:
	subq.b	#1,OBJAUX1(a5)
	bne.s	.nojump

	move.l	#HG_CROUCHING,OBJAI(a5)
	move.b	#5,OBJFRAME(a5)
	move.b	#5,OBJAUX0(a5)
.nojump:
	jmp	DISPLAY_HG

************************ Hansel And Gretel Crouching **********************

HG_CROUCHING:
	bsr	HG_COLLIDE

	cmp.b	#8,OBJFRAME(a5)
	bne.s	.crouching

	move.l	#HG_LAUNCHING,OBJAI(a5)
	move.b	#20,OBJAUX0(a5)

	bra.s	.sameframe
.crouching:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe

	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
.sameframe:
	jmp	DISPLAY_HG

************************ Hansel And Gretel Launching **********************

HG_LAUNCHING:
	bsr	HG_COLLIDE

	subq.b	#1,OBJAUX0(a5)
	bne.s	.notyet

	move.l	#HG_JUMPING,OBJAI(a5)
	move.b	#3,OBJAUX0(a5)
	move.b	#30,OBJAUX2(a5)		;vertical speed
.notyet:
	jmp	DISPLAY_HG

************************* Hansel And Gretel Jumping ***********************

HG_JUMPING:
	bsr	HG_COLLIDE

	cmp.b	#11,OBJFRAME(a5)
	beq.s	.sameframe
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#3,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
.sameframe:
	move.b	OBJAUX2(a5),d0
	move.b	d0,d1
	ext.w	d1
	asr.w	#2,d1
	sub.w	d1,OBJY(a5)

	subq.b	#1,d0
	bpl.s	.jumping
	move.l	#HG_FALLING,OBJAI(a5)

	move.b	#12,OBJFRAME(a5)
	move.b	#3,OBJAUX0(a5)

	jsr	MAKE_CHERRIES
.jumping:
	move.b	d0,OBJAUX2(a5)

	jmp	DISPLAY_HG

************************* Hansel And Gretel Falling ***********************

HG_FALLING:
	bsr	HG_COLLIDE

	cmp.b	#18,OBJFRAME(a5)
	beq.s	.sameframe

	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe

	move.b	#3,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
.sameframe:
	move.b	OBJAUX2(a5),d0
	move.b	d0,d1
	ext.w	d1
	asr.w	#2,d1
	sub.w	d1,OBJY(a5)

	subq.b	#1,d0
	cmp.b	#-30,d0
	bge.s	.speedok
	move.b	#-30,d0
.speedok:
	move.b	d0,OBJAUX2(a5)

	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.stillfalling

	jsr	STICKOBJECTTOPLAYFIELD

	move.l	#HG_LANDING,OBJAI(a5)
	move.b	#8,OBJFRAME(a5)
	move.b	#20,OBJAUX0(a5)
.stillfalling:
	jmp	DISPLAY_HG

************************* Hansel And Gretel Landing ***********************

HG_LANDING:
	bsr	HG_COLLIDE

	subq.b	#1,OBJAUX0(a5)
	bne.s	.landing

	move.l	#HG_STANDING,OBJAI(a5)
	sf.b	OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)

	jsr	RANDOM
	and.b	#31,d0
	add.b	#50,d0
	move.b	d0,OBJAUX1(a5)
.landing:
	jmp	DISPLAY_HG

********************* Hansel And Gretel Disappearing **********************

HG_DISAPPEAR:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#32,OBJFRAME(a5)
	bne.s	.sameframe
	subq.b	#1,handg		;one down
	jmp	CLEAROBJWVRAM
.sameframe:
	jmp	DRAW_COMPLEX_SPRITE

***************************** A Deadly Cherry *****************************

CHERRY_MOVE:
	subq.b	#1,OBJAUX0(a5)			;has the cherry outlived
	beq	.killcherry			;it's usefulness?

	move.b	OBJAUX1(a5),d0			;update the position
	move.b	OBJAUX2(a5),d1
	ext.w	d0
	ext.w	d1
	asr.w	#2,d0
	asr.w	#2,d1
	add.w	d0,OBJX(a5)
	sub.w	d1,OBJY(a5)

	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcs.s	.hitbubsy

	move.w	WINDX,d2			;check the position
	add.w	#9,d2				;against the x limits
	cmp.w	OBJX(a5),d2			;negate xspeed if required
	ble.s	.xnotlow
	move.w	d2,OBJX(a5)
	neg.b	OBJAUX1(a5)
	bra.s	.xnothigh
.xnotlow:
	add.w	#320-18,d2
	cmp.w	OBJX(a5),d2
	bge.s	.xnothigh
	move.w	d2,OBJX(a5)
	neg.b	OBJAUX1(a5)
.xnothigh:
	subq.b	#1,OBJAUX2(a5)			;update the yspeed
	cmp.b	#-50,OBJAUX2(a5)
	bge.s	.yspeedok
	move.b	#-50,OBJAUX2(a5)
.yspeedok:
	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.nobounce
	move.b	OBJAUX2(a5),d0
	neg.b	d0
	subq.b	#8,d0
	move.b	d0,OBJAUX2(a5)
	jsr	STICKOBJECTTOPLAYFIELD
.nobounce:
	jmp	DRAW_COMPLEX_SPRITE
.hitbubsy:
	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY
.killcherry:
	move.l	#CHERRY_DIE,OBJAI(a5)
	move.b	#1,OBJFRAME(a5)
	move.b	#7,OBJAUX0(a5)
	jmp	DRAW_COMPLEX_SPRITE

***************************** A Dying Cherry ******************************

CHERRY_DIE:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#7,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#4,OBJFRAME(a5)
	blt.s	.sameframe
	jmp	CLEAROBJWVRAM
.sameframe:
	jmp	DRAW_COMPLEX_SPRITE	

***************************** Witch Descending ****************************

WITCH_DESCENDING:
	bsr	SWING_WITCH
	add.w	#1,OBJY(a5)
	subq.b	#1,OBJAUX0(a5)
	bne.s	.notyet
	move.l	#WITCH_SWINGING,OBJAI(a5)
.notyet:
	jmp	DISPLAY_WITCH

WITCH_SWINGING:
	bsr	SWING_WITCH
	tst.b	handg
	bne.s	.notdoneyet
	move.l	#WITCH_RELEASING,OBJAI(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#1,OBJFRAME(a5)
.notdoneyet:
	jmp	DISPLAY_WITCH

WITCH_RELEASING:
	bsr	SWING_WITCH
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#5,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#WITCH_WAVING,OBJAI(a5)
	move.b	#WITCH_DEPTH,OBJAUX1(a5)
.sameframe:
	jmp	DISPLAY_WITCH

WITCH_WAVING:
	bsr	SWING_WITCH
	subq.w	#1,OBJY(a5)
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#7,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#5,OBJFRAME(a5)
.sameframe:
	subq.b	#1,OBJAUX1(a5)
	beq.s	.finished
	jmp	DISPLAY_WITCH
.finished:
	bset	#bBUBSYOFFSCREEN,GAMEFLAG0		;finished
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
.CTLOOP:
	MOVE.B	(A0)+,(A1)+
	DBRA	D6,.CTLOOP

	MOVE.B	#ENDSTATE,BUBSTATE
	MOVE.L	(SP)+,A5
	rts

********************** The Witch Swing From Side To Side ******************

SWING_WITCH:
	move.b	OBJAUX4(a5),d0			;x velocity
	move.b	d0,d1
	ext.w	d1
	ext.l	d1
	moveq.l	#16-4,d2
	asl.l	d2,d1
	add.l	d1,OBJX(a5)

	move.w	WINDX,d1			;compare with centre x
	add.w	#160,d1				;if object left of centre
	cmp.w	OBJX(a5),d1			;accelerate right
	beq.s	.xspeedok			;and vice-versa
	blt.s	.swingright
.swingleft:
	addq.b	#1,d0
	bra.s	.xspeedok
.swingright:
	subq.b	#1,d0
.xspeedok:
	move.b	d0,OBJAUX4(a5)
	rts

************************* Draw The Cage And The Chain *********************

DISPLAY_WITCH:
	move.w	OBJY(a5),-(sp)

	move.w	WINDX,d0		;makes the cage move up
	add.w	#160,d0			;and down a bit
	sub.w	OBJX(a5),d0
	bpl.s	.pos
	neg.w	d0
.pos:
	cmp.w	#10,d0
	ble.s	.nope
	subq.w	#1,OBJY(a5)
.nope:
	move.w	OBJX(a5),d0
	move.w	OBJY(a5),d1
	sub.w	WINDX,d0
	sub.w	WINDY,d1
	sub.w	#8,d0
	sub.w	#8,d1
	ext.l	d0
	ext.l	d1
	asl.l	#8,d0
	asl.l	#8,d1

	move.w	WINDX,d2
	add.w	#160,d2
	sub.w	OBJX(a5),d2
;	ext.l	d2
;	move.l	#256,d3

;	asl.l	#8,d2
	muls	#12,d2
;	divs	d3,d2
;	ext.l	d2
	move.l	#-12*256,d3

	moveq.l	#6,d7
.drawchain:
	movem.l	d0-d3/d7,-(sp)

	asr.l	#8,d0
	asr.l	#8,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0
	moveq.l	#77,d4
	jsr	print_a_sprite_normal

	movem.l	(sp)+,d0-d3/d7
	add.l	d2,d0
	add.l	d3,d1
	dbf	d7,.drawchain

	jsr	DRAW_COMPLEX_SPRITE

	move.w	(sp)+,OBJY(a5)
	rts

*********************** Hansel And Gretel Subroutines *********************

************************* Display Hansel And Gretel ***********************

DISPLAY_HG:
	tst.b	OBJAUX3(a5)
	beq.s	.noflash
	subq.b	#1,OBJAUX3(a5)
	btst.b	#0,OBJAUX3(a5)
	bne.s	.noflash
	rts
.noflash:
	jmp	DRAW_COMPLEX_SPRITE

******************* Hansel And Gretel Collision Detection *****************

HG_COLLIDE:
	move.b	OBJFRAME(a5),-(sp)

	tst.b	OBJAUX3(a5)		;no detection whilst flashing
	bne	.out

	move.b	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.out

	sf.b	OBJFRAME(a5)
	moveq.l	#0,d0
	
	jsr	NOBOPCOLLIDE
	bcc.s	.out

	btst	#bANCHORFLAG,BUBSYFLAGS
	bne.s	.vulnerable

	tst.w	BUBVY
	bpl.s	.invulnerable

.vulnerable:
	move.w	INVTIMER,d0
	or.w	SHADOWTIMER,d0
	bne.s	.out

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY
	bra.s	.out

.invulnerable:
	move.b	#JUMPSTATE,BUBSTATE
	jsr	RANDOM
	and.w	#15,d0
	subq.w	#8,d0
	move.w	d0,BUBVX
	move.w	#$fa00,BUBVY

	move.b	#50,OBJAUX3(a5)		;set flash on
	subq.b	#1,OBJAUX4(a5)		;decrement hitpoints
	bne.s	.out

	move.l	#HG_DISAPPEAR,OBJAI(a5)
	move.b	#23,(sp)		;frame number is on the stack!!!
	move.b	#10,OBJAUX0(a5)
.out:
	move.b	(sp)+,OBJFRAME(a5)
	rts

**************************** Make Two Cherries ****************************

MAKE_CHERRIES:
	move.l	a5,a6				;no smutty comments please

	move.w	#$3fff,d7			;make the left cherry
	jsr	FINDFIRSTFREEOBJ

	move.w	#$7f00,OBJKEY(a5)
	move.l	#CHERRY_MOVE,OBJAI(a5)
	move.l	#cherry,OBJINITDMA(a5)
	move.l	#cherrymap,OBJMAP(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	sub.w	#25,OBJX(a5)
	sub.w	#37,OBJY(a5)
	jsr	RANDOM
	and.b	#31,d0
	add.b	#100,d0
	move.b	d0,OBJAUX0(a5)		;cherry lifetime
	jsr	RANDOM
	and.b	#7,d0
	move.b	#-4,OBJAUX1(a5)			;x velocity
	move.b	d0,OBJAUX2(a5)			;y velocity

	move.w	#$3fff,d7			;make the right cherry
	jsr	FINDFIRSTFREEOBJ

	move.w	#$7f00,OBJKEY(a5)
	move.l	#CHERRY_MOVE,OBJAI(a5)
	move.l	#cherry,OBJINITDMA(a5)
	move.l	#cherrymap,OBJMAP(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	add.w	#25,OBJX(a5)
	sub.w	#37,OBJY(a5)
	jsr	RANDOM
	and.b	#31,d0
	add.b	#100,d0
	move.b	d0,OBJAUX0(a5)		;cherry lifetime
	jsr	RANDOM
	and.b	#7,d0
	move.b	#4,OBJAUX1(a5)			;x velocity
	move.b	d0,OBJAUX2(a5)			;y velocity

	move.l	a6,a5
	rts

****************************** A Few Variables ****************************

	even

handgx:	dc.w	0
handgy:	dc.w	0

handg:	dc.b	0

****************************** Loads Of Frames ****************************

	even

******************************* Hansel Frames *****************************

hg_dma:
hansel:
	dc.l	.f0			;frames 0-4 standing
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5			;frames 5-11 jumping
	dc.l	.f6
	dc.l	.f7
	dc.l	.f8
	dc.l	.f9
	dc.l	.f10
	dc.l	.f11
	dc.l	.f12			;frame 12 firing cherry
	dc.l	.f13			;frames 13-19 falling
	dc.l	.f14
	dc.l	.f15
	dc.l	.f16
	dc.l	.f17
	dc.l	.f18
	dc.l	.f19
	dc.l	.f20			;frames 20-22 standing again
	dc.l	.f21
	dc.l	.f22
	dc.l	.f23			;frames 23-31 appearing/disappearing
	dc.l	.f24
	dc.l	.f25
	dc.l	.f26
	dc.l	.f27
	dc.l	.f28
	dc.l	.f29
	dc.l	.f30
	dc.l	.f31
	dc.l	.f32			;frame 32 landing on bubsy

.f0:	dc.w	1,0,0,0
	dc.w	-17,-50,33
.f1:	dc.w	1,0,0,0
	dc.w	-17,-50,34
.f2:	dc.w	1,0,0,0
	dc.w	-17,-50,35
.f3:	dc.w	1,0,0,0
	dc.w	-17,-50,36
.f4:	dc.w	1,0,0,0
	dc.w	-17,-50,37
.f5:	dc.w	1,0,0,0
	dc.w	-24,-50,38
.f6:	dc.w	1,0,0,0
	dc.w	-18,-50,39
.f7:	dc.w	1,0,0,0
	dc.w	-18,-50,40
.f8:	dc.w	1,0,0,0
	dc.w	-18,-39,41
.f9:	dc.w	1,0,0,0
	dc.w	-18,-52,42

.f10:	dc.w	1,0,0,0
	dc.w	-18,-52,43

.f11:	dc.w	1,0,0,0
	dc.w	-24,-52,44

.f12:	dc.w	1,0,0,0
	dc.w	-26,-52,45

.f13:	dc.w	1,0,0,0
	dc.w	-23,-52,46

.f14:	dc.w	1,0,0,0
	dc.w	-23,-52,47

.f15:	dc.w	1,0,0,0
	dc.w	-23,-52,48

.f16:	dc.w	1,0,0,0
	dc.w	-23,-52,49

.f17:	dc.w	1,0,0,0
	dc.w	-23,-52,50

.f18:	dc.w	1,0,0,0
	dc.w	-23,-52,51

.f19:	dc.w	1,0,0,0
	dc.w	-19,-39,52

.f20:	dc.w	1,0,0,0
	dc.w	-17,-50,53

.f21:	dc.w	1,0,0,0
	dc.w	-17,-50,54

.f22:	dc.w	1,0,0,0
	dc.w	-17,-50,55

.f23:	dc.w	1,0,0,0
	dc.w	-17,-50,56

.f24:	dc.w	1,0,0,0
	dc.w	-16,-48,57

.f25:	dc.w	1,0,0,0
	dc.w	-15,-45,58

.f26:	dc.w	1,0,0,0
	dc.w	-14,-41,59

.f27:	dc.w	1,0,0,0
	dc.w	-14,-40,60

.f28:	dc.w	1,0,0,0
	dc.w	-13,-38,61

.f29:	dc.w	1,0,0,0
	dc.w	-12,-34,62

.f30:	dc.w	1,0,0,0
	dc.w	-11,-31,63

.f31:	dc.w	1,0,0,0
	dc.w	-9,-27,64

.f32:	dc.w	1,0,0,0
	dc.w	-18,-39,65

******************************* Gretel Frames *****************************

gretel:
	dc.l	.f0			;frames 0-4 standing
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5			;frames 5-11 jumping
	dc.l	.f6
	dc.l	.f7
	dc.l	.f8
	dc.l	.f9
	dc.l	.f10
	dc.l	.f11
	dc.l	.f12			;frame 12 firing cherry
	dc.l	.f13			;frames 13-19 falling
	dc.l	.f14
	dc.l	.f15
	dc.l	.f16
	dc.l	.f17
	dc.l	.f18
	dc.l	.f19
	dc.l	.f20			;frames 20-22 standing again
	dc.l	.f21
	dc.l	.f22
	dc.l	.f23			;frames 23-31 appearing/disappearing
	dc.l	.f24
	dc.l	.f25
	dc.l	.f26
	dc.l	.f27
	dc.l	.f28
	dc.l	.f29
	dc.l	.f30
	dc.l	.f31
	dc.l	.f32			;frame 32 landing on bubsy

.f0:	dc.w	1,0,0,0
	dc.w	-17,-48,0

.f1:	dc.w	1,0,0,0
	dc.w	-17,-48,1

.f2:	dc.w	1,0,0,0
	dc.w	-17,-48,2

.f3:	dc.w	1,0,0,0
	dc.w	-17,-48,3

.f4:	dc.w	1,0,0,0
	dc.w	-17,-48,4

.f5:	dc.w	1,0,0,0
	dc.w	-23,-48,5

.f6:	dc.w	1,0,0,0
	dc.w	-18,-48,6

.f7:	dc.w	1,0,0,0
	dc.w	-18,-48,7

.f8:	dc.w	1,0,0,0
	dc.w	-17,-36,8

.f9:	dc.w	1,0,0,0
	dc.w	-18,-50,9

.f10:	dc.w	1,0,0,0
	dc.w	-21,-50,10

.f11:	dc.w	1,0,0,0
	dc.w	-23,-50,11

.f12:	dc.w	1,0,0,0
	dc.w	-24,-50,12

.f13:	dc.w	1,0,0,0
	dc.w	-21,-50,13

.f14:	dc.w	1,0,0,0
	dc.w	-21,-50,14

.f15:	dc.w	1,0,0,0
	dc.w	-21,-50,15

.f16:	dc.w	1,0,0,0
	dc.w	-21,-50,16

.f17:	dc.w	1,0,0,0
	dc.w	-21,-50,17

.f18:	dc.w	1,0,0,0
	dc.w	-21,-50,18

.f19:	dc.w	1,0,0,0
	dc.w	-17,-36,19

.f20:	dc.w	1,0,0,0
	dc.w	-17,-48,20

.f21:	dc.w	1,0,0,0
	dc.w	-17,-48,21

.f22:	dc.w	1,0,0,0
	dc.w	-17,-48,22

.f23:	dc.w	1,0,0,0
	dc.w	-17,-48,23

.f24:	dc.w	1,0,0,0
	dc.w	-16,-46,24

.f25:	dc.w	1,0,0,0
	dc.w	-15,-44,25

.f26:	dc.w	1,0,0,0
	dc.w	-14,-40,26

.f27:	dc.w	1,0,0,0
	dc.w	-14,-39,27

.f28:	dc.w	1,0,0,0
	dc.w	-13,-38,28

.f29:	dc.w	1,0,0,0
	dc.w	-13,-33,29

.f30:	dc.w	1,0,0,0
	dc.w	-11,-32,30

.f31:	dc.w	1,0,0,0
	dc.w	-11,-29,31

.f32:	dc.w	1,0,0,0
	dc.w	-17,-36,32

******************************* Cherry Frames *****************************

cherry:
	dc.l	.f0			;frame 0 normal cherry
	dc.l	.f1			;frames 1-3 exploding cherry
	dc.l	.f2
	dc.l	.f3

.f0:	dc.w	1,0,0,0
	dc.w	-9,-20,66

.f1:	dc.w	1,0,0,0
	dc.w	-12,-18,67

.f2:	dc.w	1,0,0,0
	dc.w	-13,-22,68

.f3:	dc.w	1,0,0,0
	dc.w	-14,-24,69

****************************** Witch Frames *******************************

witch:
	dc.l	.f0			;frame 0 closed cage
	dc.l	.f1			;frames 1-4 opening cage
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5			;frames 5-6 witch waving
	dc.l	.f6

.f0:	dc.w	1,0,0,0
	dc.w	-32,0,70

.f1:	dc.w	1,0,0,0
	dc.w	-32,-5,71

.f2:	dc.w	1,0,0,0
	dc.w	-34,-5,72

.f3:	dc.w	1,0,0,0
	dc.w	-64,-6,73

.f4:	dc.w	1,0,0,0
	dc.w	-89,0,74

.f5:	dc.w	1,0,0,0
	dc.w	-89,0,75

.f6:	dc.w	1,0,0,0
	dc.w	-89,0,76

***************** Hansel And Gretel Collision Detection Data **************

hanselmap:
gretelmap:
	Soff	0,0,-12,0,12,0,-12,22,12,22,-12,44,12,44

*********************** Cherry Collision Detection Data *******************

cherrymap:
	Soff	1,9,-3,8,3,8,-8,0,8,0,-3,-8,3,-8
