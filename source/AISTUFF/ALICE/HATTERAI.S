******************************* Mad Hatter AI *****************************

; A rough description of what the Mad Hatter does.

; He trundles backwards and forwards in his teapot tank.
; At random the teapot blows steam out of it's spout at Bubsy.
; Occasionally the Hatter stops. His top hat flips open. Cups fly
; out and float across the screen, then crash to the floor.

HATTER_HITS	equ	8

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

HATTER:
HATTER_LOAD:
	jsr	OBJRANGE
	bcc	.INRANGE
	andi.b	#~BOSSFLAG,GAMEFLAG1
	jmp	CLEAROBJ

.BAIL:
	rts

.INRANGE:
	jsr	CLIPY
	
	move.w	BUBX,d0								;make sure we are close
	sub.w	OBJX(a5),d0
	bpl.s	.posi
	neg.w	d0

.posi:
	cmp.w	#16,d0
	bgt.s	.BAIL
	
	or.b	#BOSSFLAG,GAMEFLAG1
	
	move.w	WINDY,d0
	cmp.w	WINDYOLD,d0							;ensure land does not change height
	bne.s	.BAIL
	
	move.b	BUBSYFLAGS,d0							;and make sure bubsy is anchored
	andi.b	#ANCHORFLAG,d0
	beq	.BAIL
	
	lea	OBJBASE,a1					;first, let's copy AI to beggining of AI DP
	move.w	#OBJLEN,d0

.COPYLOOP:
	move.b	(a5)+,(a1)+
	dbf.w	d0,.COPYLOOP

	lea	OBJBASEEND,a5							;now lets clear out the rest of the objects

.CLEARLOOP:
	suba.l	#OBJLEN,a5
	cmpa.l	#OBJBASE,a5
	beq	.CHANGEAI
	jsr	CLEAROBJWVRAM
	bra	.CLEARLOOP

.CHANGEAI:
	lea	LEVEL5_BOSS,a0
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	bclr	#bTIMEFLAG,GAMEFLAG1					;stop the clock
	jsr	load_file_no_wait

	move.l	#HATTER_START,OBJAI(a5)

	move.w	WINDX,WINDXMIN
	move.w	WINDY,WINDYMIN
	move.w	WINDXMIN,WINDXMAX
	move.w	WINDYMIN,WINDYMAX
	move.w	WINDX,d0
	addi.w	#10,d0
	move.w	d0,BUBXMIN
	addi.w	#320-20,d0
	move.w	d0,BUBXMAX
	rts

*************** Wait for load to complete, then set up boss ***************

HATTER_START:
	bclr	#bTIMEFLAG,GAMEFLAG1		;stop the clock
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
	move.l	#HATTER_APPEAR,OBJAI(a5)
	move.l	#hatter,OBJINITDMA(a5)
	move.l	#hatterbloke,OBJMAP(a5)
	move.w	WINDX,OBJX(a5)
	move.w	WINDY,OBJY(a5)
	add.w	#100,OBJY(a5)

	sf.b	OBJOAM0(a5)
	sf.b	OBJFRAME(a5)
	move.b	#-1,OBJAUX4(a5)			;x velocity

	jsr	STICKOBJECTTOPLAYFIELD
	
	add.w	#350,OBJX(a5)

	move.b	#HATTER_HITS,hathitpoints
	sf.b	hatterflash
	sf.b	nextattack

	bset	#bBUBSYOFFSCREEN,GAMEFLAG0
	rts

********************** Hatter Appearing From Stage Right ******************

HATTER_APPEAR:
	addq.b	#1,OBJFRAME(a5)			;animate the trundle
	cmp.b	#6,OBJFRAME(a5)
	bne.s	.sameframe
	sf.b	OBJFRAME(a5)

.sameframe:
	subq.w	#1,OBJX(a5)			;move the tank
	move.w	WINDX,d0
	add.w	#160,d0
	cmp.w	OBJX(a5),d0
	bne.s	.notyet
	move.l	#HATTER_TRUNDLE,OBJAI(a5)
	sf.b	OBJAUX0(a5)

.notyet:
	jmp	DRAW_COMPLEX_SPRITE

*************************** Hatter Trundling Along ************************

HATTER_TRUNDLE:
	tst.b	OBJAUX0(a5)		;first decide if we
	beq.s	.attack			;should attack bubsy
	subq.b	#1,OBJAUX0(a5)
	bne	.noattack

.attack:
	tst.b	OBJFRAME(a5)
	bne	.noattack

	move.w	BUBX,d0			;if bubsy is behind the tank
	cmp.w	OBJX(a5),d0		;only do the cup attack
	bpl.s	.cupattack

	moveq.l	#0,d0
	move.b	nextattack,d0
	addq.b	#1,d0
	and.b	#15,d0
	move.b	d0,nextattack
	add.w	d0,d0
	add.w	d0,d0
	lea	.attacktab,a0
	move.l	0(a0,d0.w),a0
	jmp	(a0)

.cupattack:
	move.l	#HATTER_OPEN_HAT,OBJAI(a5)	;start teacup attack
	move.b	#10,OBJAUX0(a5)			;with cup bombs
	move.b	#6,OBJFRAME(a5)
	move.b	#0,cuptype
	bra	.out

.cupattack2:
	move.l	#HATTER_OPEN_HAT,OBJAI(a5)	;start teacup attack
	move.b	#10,OBJAUX0(a5)			;with cup grenades
	move.b	#6,OBJFRAME(a5)
	move.b	#1,cuptype
	bra	.out

.hsteamattack:
	move.l	#HATTER_HSTEAM,OBJAI(a5)	;start horizontal steam attack
	move.b	#10,OBJAUX0(a5)
	move.b	#12,OBJFRAME(a5)
	bra.s	.out

.dsteamattack:
	move.l	#HATTER_DSTEAM,OBJAI(a5)	;start diagonal steam attack
	move.b	#10,OBJAUX0(a5)
	move.b	#9,OBJFRAME(a5)
	bra.s	.out

.noattack:
	move.b	OBJAUX4(a5),d0			;now move the tank
	ext.w	d0
	add.w	d0,OBJX(a5)
	tst.w	d0
	bpl.s	.down

.up:
	move.w	WINDX,d0			;have we reached the
	add.w	#60,d0				;wait position?
	cmp.w	OBJX(a5),d0
	beq.s	.wait
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#6,OBJFRAME(a5)
	blt.s	.out
	sf.b	OBJFRAME(a5)
	bra.s	.out

.down:
	move.w	WINDX,d0			;have we reached the
	add.w	#200,d0				;wait position?
	cmp.w	OBJX(a5),d0
	beq.s	.wait
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.out
	move.b	#5,OBJFRAME(a5)
	bra.s	.out

.wait:
	move.l	#HATTER_WAIT,OBJAI(a5)

	jsr	RANDOM
	and.b	#15,d0
	add.b	#10,d0
	move.b	d0,OBJAUX1(a5)

.out:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

.attacktab:
	dc.l	.hsteamattack
	dc.l	.dsteamattack
	dc.l	.cupattack
	dc.l	.hsteamattack
	dc.l	.dsteamattack
	dc.l	.cupattack
	dc.l	.dsteamattack
	dc.l	.cupattack2
	dc.l	.hsteamattack
	dc.l	.hsteamattack
	dc.l	.cupattack
	dc.l	.dsteamattack
	dc.l	.dsteamattack
	dc.l	.hsteamattack
	dc.l	.cupattack2
	dc.l	.dsteamattack

**************************** Hatter Waiting To Move ***********************

HATTER_WAIT:
	subq.b	#1,OBJAUX1(a5)
	bne.s	.notyet

	move.l	#HATTER_TRUNDLE,OBJAI(a5)
	neg.b	OBJAUX4(a5)

.notyet:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

*************************** Hatter Opening His Hat ************************

HATTER_OPEN_HAT:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#9,OBJFRAME(a5)
	bne.s	.sameframe
	move.b	#8,OBJFRAME(a5)

	move.l	#HATTER_SHOOT_CUPS,OBJAI(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#7,OBJAUX1(a5)

.sameframe:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

********************* Hatter Shooting Teacups From His hat ****************

HATTER_SHOOT_CUPS:
	subq.b	#1,OBJAUX0(a5)		;wait for reload
	bne	.noshoot
	move.b	#10,OBJAUX0(a5)

	subq.b	#1,OBJAUX1(a5)		;shoot a cup if we can
	beq	.trundle

	moveq.l	#0,d0			;at least two types of cup
	move.b	cuptype,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	cuptab,a0
	move.l	0(a0,d0.w),a0
	jsr	(a0)

.noshoot:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

.trundle:
	move.l	#HATTER_CLOSE_HAT,OBJAI(a5)
	move.b	#10,OBJAUX0(a5)

	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

*************************** Hatter Closing His Hat ************************

HATTER_CLOSE_HAT:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(a5)
	cmp.b	#5,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#HATTER_TRUNDLE,OBJAI(a5)
	jsr	RANDOM
	and.b	#63,d0
	add.b	#50,d0
	move.b	d0,OBJAUX0(a5)

.sameframe:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

************************ Hatter Firing Steam Diagonally *******************

HATTER_DSTEAM:
	subq.b	#1,OBJAUX0(a5)
	bne	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#11,OBJFRAME(a5)
	bne.s	.noshoot

	move.l	a5,a6

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)

	move.l	#STEAM,OBJAI(a5)
	move.l	#dsteam,OBJINITDMA(a5)
	move.l	#dsteammap,OBJMAP(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	sub.w	#100,OBJX(a5)
	sub.w	#100,OBJY(a5)

	sf.b	OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#100,OBJAUX1(a5)
	move.b	#-8,OBJAUX3(a5)
	move.b	#-5,OBJAUX4(a5)

	move.l	a6,a5

.noshoot:
	cmp.b	#12,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#HATTER_TRUNDLE,OBJAI(a5)
	move.b	#0,OBJFRAME(a5)
	jsr	RANDOM
	and.b	#63,d0
	add.b	#50,d0
	move.b	d0,OBJAUX0(a5)

.sameframe:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

*********************** Hatter Firing Steam Horizontally ******************

HATTER_HSTEAM:
	subq.b	#1,OBJAUX0(a5)
	bne	.sameframe
	move.b	#10,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#14,OBJFRAME(a5)
	bne.s	.noshoot

	move.l	a5,a6

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)

	move.l	#STEAM,OBJAI(a5)
	move.l	#hsteam,OBJINITDMA(a5)
	move.l	#hsteammap,OBJMAP(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	sub.w	#90,OBJX(a5)
	sub.w	#60,OBJY(a5)

	sf.b	OBJFRAME(a5)
	move.b	#10,OBJAUX0(a5)
	move.b	#100,OBJAUX1(a5)
	move.b	#-8,OBJAUX3(a5)
	move.b	#0,OBJAUX4(a5)

	move.l	a6,a5

.noshoot:
	cmp.b	#15,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#HATTER_TRUNDLE,OBJAI(a5)
	move.b	#0,OBJFRAME(a5)
	jsr	RANDOM
	and.b	#63,d0
	add.b	#50,d0
	move.b	d0,OBJAUX0(a5)

.sameframe:
	bsr	TANK_COLLIDE
	jmp	DISPLAY_HATTER

***************************** Hatter Stunned ******************************

HATTER_STUNNED:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.notyet
	move.l	ai,OBJAI(a5)
	move.b	frame,OBJFRAME(a5)
	move.b	#1,OBJAUX0(a5)

.notyet:
	jmp	DISPLAY_HATTER

***************** Hatter Trundles Offscreen And Is Beaten *****************

HATTER_BEATEN:
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.sameframe
	move.b	#5,OBJFRAME(a5)

.sameframe:
	addq.w	#1,OBJX(a5)

	move.w	WINDX,d0
	add.w	#350,d0
	cmp.w	OBJX(a5),d0
	beq.s	.finished

	jmp	DRAW_COMPLEX_SPRITE

.finished:
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

.CTLOOP:
	MOVE.B	(A0)+,(A1)+
	DBRA	D6,.CTLOOP

	MOVE.B	#ENDSTATE,BUBSTATE
	MOVE.L	(SP)+,A5
	rts

************************* Steam Cloud Floating Along **********************

STEAM:
	subq.b	#1,OBJAUX1(a5)			;kill the steam if it's
	bne.s	.stillon			;been on long enough
	jmp	CLEAROBJWVRAM

.stillon:
	subq.b	#1,OBJAUX0(a5)			;animate the steam
	bne.s	.sameframe
	move.b	#10,OBJAUX0(a5)
	eor.b	#1,OBJFRAME(a5)

.sameframe:
	move.b	OBJAUX3(a5),d0			;move the steam
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

	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nohit

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY

.nohit:
	jmp	DRAW_COMPLEX_SPRITE

********************************* Teacup Bomb *****************************

TEACUP_BOMB:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.stillon
	jmp	CLEAROBJWVRAM

.stillon:
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#8,OBJFRAME(a5)
	blt.s	.frameok
	sf.b	OBJFRAME(a5)

.frameok:
	move.b	OBJAUX3(a5),d0
	move.b	OBJAUX4(a5),d1
	tst.b	d0
	bne.s	.nofall

	move.l	#TEACUP_BOMB_FALL,OBJAI(a5)
	move.b	#20,OBJAUX0(a5)
	bra.s	.doneyv

.nofall:
	bpl.s	.xvpos

.xvneg:
	addq.b	#1,d0
	bra.s	.donexv

.xvpos:
	subq.b	#1,d0

.donexv:
	subq.b	#1,d1
	bpl.s	.doneyv
	moveq.l	#0,d1

.doneyv:
	move.b	d0,OBJAUX3(a5)
	move.b	d1,OBJAUX4(a5)
	ext.w	d0
	ext.w	d1
	ext.l	d0
	ext.l	d1
	moveq.l	#16-2,d2
	asl.l	d2,d0
	asl.l	d2,d1
	add.l	d0,OBJX(a5)
	sub.l	d1,OBJY(a5)

	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nohit

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY

.nohit:
	jmp	DRAW_COMPLEX_SPRITE

**************************** Falling Teacup Bomb **************************

TEACUP_BOMB_FALL:
	tst.b	OBJAUX0(a5)
	beq.s	.fall
	subq.b	#1,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#8,OBJFRAME(a5)
	blt.s	.frameok
	sf.b	OBJFRAME(a5)

.frameok:
	bra.s	.nohit

.fall:
	sf.b	OBJFRAME(a5)

	move.b	OBJAUX4(a5),d0
	subq.b	#1,d0
	cmp.b	#-32,d0
	bge.s	.yspeedok
	move.b	#-32,d0

.yspeedok:
	move.b	d0,OBJAUX4(a5)
	ext.w	d0
	ext.l	d0
	moveq.l	#16-2,d1
	asl.l	d1,d0
	sub.l	d0,OBJY(a5)

	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	add.w	#16,d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.notfloor

	move.l	#TEACUP_EXPLODE,OBJAI(a5)
	move.b	#5,OBJAUX0(a5)
	move.b	#8,OBJFRAME(a5)

.notfloor:
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nohit

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY

.nohit:
	jmp	DRAW_COMPLEX_SPRITE

******************************* Teacup Grenade ****************************

TEACUP_GRENADE:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.stillon
	jmp	CLEAROBJWVRAM

.stillon:
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#8,OBJFRAME(a5)
	blt.s	.frameok
	sf.b	OBJFRAME(a5)

.frameok:
	move.b	OBJAUX3(a5),d0
	move.b	OBJAUX4(a5),d1
	subq.b	#1,d1
	cmp.b	#-32,d1
	bge.s	.yspeedok
	move.b	#-32,d1

.yspeedok:
	move.b	d0,OBJAUX3(a5)
	move.b	d1,OBJAUX4(a5)
	ext.w	d0
	ext.w	d1
	ext.l	d0
	ext.l	d1
	moveq.l	#16-2,d2
	asl.l	d2,d0
	asl.l	d2,d1
	add.l	d0,OBJX(a5)
	sub.l	d1,OBJY(a5)

	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	add.w	#16,d2
	jsr	GETATTRIB
	tst.w	d0
	beq.s	.notfloor

	move.l	#TEACUP_EXPLODE,OBJAI(a5)
	move.b	#5,OBJAUX0(a5)
	move.b	#8,OBJFRAME(a5)

.notfloor:
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.nohit

	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY

.nohit:
	jmp	DRAW_COMPLEX_SPRITE

****************************** Teacup Explosion ***************************

TEACUP_EXPLODE:
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#5,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#12,OBJFRAME(a5)
	bne.s	.sameframe
	jmp	CLEAROBJWVRAM

.sameframe:
	jmp	DRAW_COMPLEX_SPRITE

**************************** Handy Subroutines ****************************

**************************** Make A Teacup Bomb ***************************

MAKE_TEACUP_BOMB:
	move.l	a5,a6			;make a cup bomb

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)

	move.l	#TEACUP_BOMB,OBJAI(a5)
	move.l	#teacup,OBJINITDMA(a5)
	move.l	#teacupmap,OBJMAP(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	add.w	#45,OBJX(a5)
	sub.w	#120,OBJY(a5)
	sf.b	OBJFRAME(a5)

	jsr	RANDOM
	and.b	#31,d0
	add.b	#15,d0
	move.w	BUBX,d1
	sub.w	OBJX(a5),d1
	bpl.s	.xok1
	neg.b	d0

.xok1:
	move.b	d0,OBJAUX3(a5)
	move.b	#10,OBJAUX4(a5)

	move.l	a6,a5
	rts

*************************** Make A Teacup Grenade *************************

MAKE_TEACUP_GRENADE:
	move.l	a5,a6

	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)

	move.l	#TEACUP_GRENADE,OBJAI(a5)
	move.l	#teacup,OBJINITDMA(a5)
	move.l	#teacupmap,OBJMAP(a5)
	move.w	OBJX(a6),OBJX(a5)
	move.w	OBJY(a6),OBJY(a5)
	add.w	#45,OBJX(a5)
	sub.w	#120,OBJY(a5)

	sf.b	OBJFRAME(a5)
	move.b	#100,OBJAUX0(a5)
	jsr	RANDOM
	and.b	#3,d0
	add.b	#6,d0
	move.w	BUBX,d1
	sub.w	OBJX(a5),d1
	bpl.s	.xok
	neg.b	d0

.xok:
	move.b	d0,OBJAUX3(a5)
	move.b	#16,OBJAUX4(a5)

	move.l	a6,a5
	rts

********************** Teapot Tank Collision Detection ********************

TANK_COLLIDE:
	tst.b	hatterflash
	bne	.out

	move.b	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.out

	move.l	#hatterbloke,OBJMAP(a5)		;bop the hatter
	moveq.l	#0,d0				;to beat the boss
	jsr	NOBOPCOLLIDE
	bcs.s	.bophatter

	move.l	#hatterhandle,OBJMAP(a5)
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcs.s	.bophatter

	move.l	#hatterspout,OBJMAP(a5)
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.out

.bophatter:
	tst.w	BUBVY
	ble.s	.killhim

	move.b	#JUMPSTATE,BUBSTATE		;count that as a bop
	jsr	RANDOM
	and.w	#7,d0
	subq.w	#4,d0
	move.w	d0,BUBVX
	move.w	#$fa00,BUBVY

	move.b	#50,hatterflash
	subq.b	#1,hathitpoints
	bne.s	.reaction

	move.l	#HATTER_BEATEN,OBJAI(a5)
	bra.s	.out

.reaction:
	move.l	OBJAI(a5),ai
	move.b	OBJFRAME(a5),d0
	move.b	d0,frame
	cmp.b	#6,d0
	blt.s	.ok
	moveq.l	#0,d0

.ok:
	add.w	#15,d0
	move.l	#HATTER_STUNNED,OBJAI(a5)
	move.b	d0,OBJFRAME(a5)
	move.b	#50,OBJAUX0(a5)

.out:
	rts

.killhim:
	moveq.l	#POPSTATE,d0
	jsr	KILLBUBSY
	rts

******************************* Display Hatter ****************************

DISPLAY_HATTER:
	tst.b	hatterflash
	beq.s	.noflash
	subq.b	#1,hatterflash
	btst.b	#0,hatterflash
	bne.s	.noflash
	rts

.noflash:
	jmp	DRAW_COMPLEX_SPRITE

******************************* A Few Variables ***************************

ai:	dc.l	0
hathitpoints:	dc.b	0
hatterflash:	dc.b	0
cuptype:	dc.b	0
nextattack:	dc.b	0
frame:	dc.b	0
	even

cuptab:
	dc.l	MAKE_TEACUP_BOMB
	dc.l	MAKE_TEACUP_GRENADE

******************************** Hatter Frames ****************************

hatter:
	dc.l	.f0		;frames 0-5 Hatter trundling along
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6		;frames 6-8 hat flipping open
	dc.l	.f7
	dc.l	.f8
	dc.l	.f9		;frames 9-11 shooting diagonal steam
	dc.l	.f10
	dc.l	.f11
	dc.l	.f12		;frames 12-14 shooting horizontal steam
	dc.l	.f13
	dc.l	.f14

	dc.l	.f15		;frames 15-20 getting hit
	dc.l	.f16
	dc.l	.f17
	dc.l	.f18
	dc.l	.f19
	dc.l	.f20

.f0:
	dc.w	2,0,0,0
	dc.w	-31,-119,0
	dc.w	0,-27,21
.f1:
	dc.w	2,0,0,0
	dc.w	-31,-119,0
	dc.w	0,-27,22
.f2:
	dc.w	2,0,0,0
	dc.w	-31,-119,0
	dc.w	0,-27,23
.f3:
	dc.w	2,0,0,0
	dc.w	-31,-119,0
	dc.w	0,-27,24
.f4:
	dc.w	2,0,0,0
	dc.w	-31,-119,0
	dc.w	0,-27,25
.f5:
	dc.w	2,0,0,0
	dc.w	-31,-119,0
	dc.w	0,-27,26
.f6:
	dc.w	2,0,0,0
	dc.w	-31,-125,1
	dc.w	0,-27,21
.f7:
	dc.w	2,0,0,0
	dc.w	-31,-132,2
	dc.w	0,-27,21
.f8:
	dc.w	2,0,0,0
	dc.w	-28,-129,3
	dc.w	0,-27,21
.f9:
	dc.w	2,0,0,0
	dc.w	-24,-119,5
	dc.w	0,-27,21
.f10:
	dc.w	2,0,0,0
	dc.w	-62,-119,4
	dc.w	0,-27,21
.f11:
	dc.w	2,0,0,0
	dc.w	-24,-119,5
	dc.w	0,-27,21
.f12:
	dc.w	2,0,0,0
	dc.w	-24,-119,7
	dc.w	0,-27,21
.f13:
	dc.w	2,0,0,0
	dc.w	-83,-119,6
	dc.w	0,-27,21
.f14:
	dc.w	2,0,0,0
	dc.w	-24,-119,7
	dc.w	0,-27,21
.f15:
	dc.w	2,0,0,0
	dc.w	-31,-115,9
	dc.w	0,-27,21
.f16:
	dc.w	2,0,0,0
	dc.w	-31,-115,9
	dc.w	0,-27,22
.f17:
	dc.w	2,0,0,0
	dc.w	-31,-115,9
	dc.w	0,-27,23
.f18:
	dc.w	2,0,0,0
	dc.w	-31,-115,9
	dc.w	0,-27,24
.f19:
	dc.w	2,0,0,0
	dc.w	-31,-115,9
	dc.w	0,-27,25
.f20:
	dc.w	2,0,0,0
	dc.w	-31,-115,9
	dc.w	0,-27,26

*************************** Diagonal Steam Frames *************************

dsteam:
	dc.l	.f0
	dc.l	.f1
.f0:
	dc.w	1,0,0,0
	dc.w	0,0,15
.f1:
	dc.w	1,0,0,0
	dc.w	0,0,16

*************************** Horizontal Steam Frames ***********************

hsteam:
	dc.l	.f0
	dc.l	.f1
.f0:
	dc.w	1,0,0,0
	dc.w	0,0,13
.f1:
	dc.w	1,0,0,0
	dc.w	0,0,14

******************************* Teacup Frames *****************************

teacup:
	dc.l	.f0		;frames 0-7 with flame flashing
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6
	dc.l	.f7
	dc.l	.f8		;frames 8-11 exploding
	dc.l	.f9
	dc.l	.f10
	dc.l	.f11

.f0:
	dc.w	1,0,0,0
	dc.w	-7,-11,12
.f1:
	dc.w	1,0,0,0
	dc.w	-7,-11,11
.f2:
	dc.w	1,0,0,0
	dc.w	-7,-11,11
.f3:
	dc.w	1,0,0,0
	dc.w	-7,-11,11
.f4:
	dc.w	1,0,0,0
	dc.w	-7,-11,12
.f5:
	dc.w	1,0,0,0
	dc.w	-7,-11,12
.f6:
	dc.w	1,0,0,0
	dc.w	-7,-11,11
.f7:
	dc.w	1,0,0,0
	dc.w	-7,-11,12
.f8:
	dc.w	1,0,0,0
	dc.w	-10,-10,17
.f9:
	dc.w	1,0,0,0
	dc.w	-10,-10,18
.f10:
	dc.w	1,0,0,0
	dc.w	-10,-10,19
.f11:
	dc.w	1,0,0,0
	dc.w	-10,-10,20

************************* Hatter Collision Detection **********************

******************** Collision Data For The Teapot Spout ******************

hatterspout:
	rept	6
	Soff	0,0,2,10,-5,35,5,63,-15,50,-15,70,-30,78	;trundling along
	endr

	Soff	0,0,2,10,-5,35,5,63,-15,50,-15,70,-30,78	;hat opening
	Soff	0,0,2,10,-5,35,5,63,-15,50,-15,70,-30,78
	Soff	0,0,2,10,-5,35,5,63,-15,40,-15,50,-25,60

	Soff	0,0,2,10,-5,35,5,63,-15,40,-15,50,-25,60	;diagonal steam
	Soff	0,0,2,10,-5,35,5,63,-20,45,-40,60,-30,65
	Soff	0,0,2,10,-5,35,5,63,-15,40,-15,50,-25,60

	Soff	0,0,2,10,-5,35,5,63,-15,40,-15,50,-25,60	;horizontal steam
	Soff	0,0,2,10,-5,35,5,63,-15,45,-40,40,-40,50
	Soff	0,0,2,10,-5,35,5,63,-15,40,-15,50,-25,60

******************** Collision Data For The Teapot Handle *****************

hatterhandle:
	rept	17
	Soff	-75,75,0,-10,15,0,30,-10,30,-30,22,-45,15,-60
	endr

****************** Collision Data For The Hatter's Personage **************

hatterbloke:
	rept	17
	Soff	-45,90,-12,27,18,22,-22,10,20,0,-25,-20,20,-20
	endr

********************** Diagonal Steam Collision Detection *****************

dsteammap:
	rept	2
	Soff	0,0,0,-10,15,-20,20,0,30,-20,52,-25,80,-35
	endr

******************** Horizontal Steam Collision Detection *****************

hsteammap:
	rept	2
	Soff	0,0,0,-10,15,-15,30,-15,50,-12,5,0,25,0
	endr

************************* Teacup Collision Detection **********************

teacupmap:
	rept	8
	Soff	0,0,-3,9,0,9,3,9,-7,0,0,0,7,0
	endr
