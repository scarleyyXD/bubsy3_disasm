******************************** Lobster AI *******************************

; A rough description of what the lobster does

; He walks backwards and forwards a bit
; The sticks out his claw to grab Bubsy.
; Wowwee...

LOBSTER_HITS	equ	12

LEFT_STAND_X	equ	120
RIGHT_STAND_X	equ	200

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

LOBSTERAI
LOBSTER_LOAD
	jsr	OBJRANGE
	bcc	.INRANGE
	andi.b	#~BOSSFLAG,GAMEFLAG1
	jmp	CLEAROBJ
	rts
.INRANGE
	jsr	CLIPY

	move.w	BUBX,d0					;make sure we are close
	sub.w	OBJX(a5),d0
	bpl.s	.posi
	neg.w	d0
.posi	cmp.w	#64,d0
	bgt	.out

	move.w	WINDY,d0
	cmp.w	WINDYOLD,d0				;ensure land does not change height
	bne	.out

	move.b	BUBSYFLAGS,d0				;and make sure bubsy is anchored
	andi.b	#ANCHORFLAG,d0
	beq	.out

	move.l	#LOBSTER_START,OBJAI(a5)		;wait for loading to be done.

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

	lea	LEVEL4_BOSS,a0
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
.out
	rts

;**************************************************************************

LOBSTER_START
	bclr	#bTIMEFLAG,GAMEFLAG1					;stop the clock
	jsr	loaded_in_no_wait
	bne.s	.yes_loaded
.out
	rts
.yes_loaded
	tst.b	OBJAUX5(a5)
	bne.s	.already_relocated_sprites
	st	OBJAUX5(a5)
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	relocate_sprites
.already_relocated_sprites

	move.l	a5,lobsterobj			;save pointer to lobster

	move.l	#LOBSTER_WALK,OBJAI(a5)		;use the existing object
	move.l	#lobster,OBJINITDMA(a5)		;for the Lobster
	move.l	#lobstermap,OBJMAP(a5)
	move.w	WINDX,OBJX(a5)
	move.w	WINDY,OBJY(a5)
	add.w	#160,OBJX(a5)
	add.w	#100,OBJY(a5)
	sf.b	OBJFRAME(a5)
	move.b	#6,OBJAUX0(a5)
	sf.b	OBJAUX1(a5)			;direction to move
	move.b	#200,OBJAUX2(a5)		;delay for antenna flick
	move.b	#$8,OBJOAM0(a5)			;face left
	jsr	STICKOBJECTTOPLAYFIELD
	add.w	#160,OBJX(a5)

	move.l	a5,a6				;make the lobster's claw
	move.w	#$3fff,d7
	jsr	FINDFIRSTFREEOBJ
	move.w	#$7f00,OBJKEY(a5)
	move.l	#CLAW_WAITING,OBJAI(a5)
	move.l	#claw,OBJINITDMA(a5)
	move.l	#clawmap,OBJMAP(a5)
	sf.b	OBJFRAME(a5)
	move.b	#8,OBJOAM0(a5)
	move.b	#1,OBJAUX0(a5)
	move.l	a6,a5

	bset	#bBUBSYOFFSCREEN,GAMEFLAG0		;hopefully

	move.b	#LOBSTER_HITS,lobsterdamage
	sf.b	lobsterflash
	sf.b	no_claw_collide
	sf.b	lobster_dead
	rts

****************************** Lobster Walking ****************************

LOBSTER_WALK
	tst.b	OBJAUX2(a5)		;should we flick the antenna?
	beq.s	.tryflick
	subq.b	#1,OBJAUX2(a5)
	bne.s	.noflick
.tryflick
	cmp.b	#1,OBJFRAME(a5)
	bne.s	.noflick

	move.l	#LOBSTER_FLICK,OBJAI(a5)
	move.b	#5,OBJFRAME(a5)
	move.b	#8,OBJAUX0(a5)

	jmp	DISPLAY_LOBSTER
.noflick
	subq.b	#1,OBJAUX0(a5)		;walk the lobster
	bne.s	.donewalk
	move.b	#6,OBJAUX0(a5)

	tst.b	OBJAUX1(a5)		;which direction to walk in?
	bne.s	.right
.left
	subq.w	#5,OBJX(a5)		;one step left
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#5,OBJFRAME(a5)
	bne.s	.leftstep
	sf.b	OBJFRAME(a5)
.leftstep
	move.w	WINDX,d0		;has it reached the
	add.w	#LEFT_STAND_X,d0	;stand position
	cmp.w	OBJX(a5),d0
	blt.s	.donewalk
	bra.s	.stand
.right
	addq.w	#5,OBJX(a5)		;one step right
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.rightstep
	addq.b	#5,OBJFRAME(a5)
.rightstep
	move.w	WINDX,d0		;has it reached the
	add.w	#RIGHT_STAND_X,d0	;stand position
	cmp.w	OBJX(a5),d0
	bgt.s	.donewalk
.stand
	cmp.b	#1,OBJFRAME(a5)		;wait until in standing frame
	bne.s	.donewalk

	move.l	#LOBSTER_STAND,OBJAI(a5)
	jsr	RANDOM
	and.b	#31,d0
	add.b	#10,d0
	move.b	d0,OBJAUX0(a5)
	move.b	#1,OBJFRAME(a5)
.donewalk
	bsr	LOBSTER_COLLIDE

	jmp	DISPLAY_LOBSTER

*************************** Lobster Standing Around ***********************

LOBSTER_STAND
	subq.b	#1,OBJAUX0(a5)
	bne.s	.standing

	move.l	#LOBSTER_WALK,OBJAI(a5)
	move.b	#6,OBJAUX0(a5)
	not.b	OBJAUX1(a5)
.standing
	bsr	LOBSTER_COLLIDE

	jmp	DISPLAY_LOBSTER

*********************** Lobster Flicking It's Antenna *********************

LOBSTER_FLICK
	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#8,OBJAUX0(a5)

	addq.b	#1,OBJFRAME(a5)
	cmp.b	#8,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#LOBSTER_WALK,OBJAI(a5)
	move.b	#1,OBJFRAME(a5)
	move.b	#8,OBJAUX0(a5)
	move.b	#65,OBJAUX2(a5)
.sameframe
	bsr	LOBSTER_COLLIDE

	jmp	DISPLAY_LOBSTER

******************************* Lobster Beaten ****************************

LOBSTER_BEATEN
	subq.b	#1,OBJAUX0(a5)		;wait for a bit
	bne.s	.notyet

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
.notyet
	jmp	DISPLAY_LOBSTER

*************************** Lobster's Claw Waiting ************************

CLAW_WAITING
	move.l	lobsterobj,a0			;make the claw follow
	move.w	OBJX(a0),OBJX(a5)		;the lobster
	move.w	OBJY(a0),OBJY(a5)		;I think it should really...
	sub.w	#30,OBJY(a5)

	subq.b	#1,OBJAUX0(a5)
	bne.s	.wait

	tst.b	lobsterdamage
	beq.s	.wait
	move.l	#CLAW_ATTACK,OBJAI(a5)
	move.b	#3,OBJAUX0(a5)
.wait
	bsr	CLAW_COLLIDE

	jmp	DISPLAY_CLAW

****************************** Claw Attacking *****************************

CLAW_ATTACK
	move.l	lobsterobj,a0			;make the claw follow
	move.w	OBJX(a0),OBJX(a5)		;the lobster
	move.w	OBJY(a0),OBJY(a5)		;I think it should really...
	sub.w	#30,OBJY(a5)

	subq.b	#1,OBJAUX0(a5)
	bne.s	.sameframe
	move.b	#3,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#11,OBJFRAME(a5)
	bne.s	.sameframe

	move.l	#CLAW_WAITING,OBJAI(a5)
	jsr	RANDOM
	and.b	#31,d0
	add.b	#30,d0
	move.b	d0,OBJAUX0(a5)
	sf.b	OBJFRAME(a5)
.sameframe
	bsr	CLAW_COLLIDE

	jmp	DISPLAY_CLAW

********************** Lobster Body Collision Detection *******************

LOBSTER_COLLIDE
	tst.b	lobsterflash		;no detection whilst flashing
	bne	.out
	move.b	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.out
;	move.w	INVTIMER,d0
;	or.w	SHADOWTIMER,d0
;	bne	.out

	move.l	#lobsterfront,OBJMAP(a5)	;detect antenna
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcs.s	.killer

	move.l	#lobsterback,OBJMAP(a5)		;detect back
	moveq.l	#0,d0
	jsr	NOBOPCOLLIDE
	bcc.s	.out

.bopped
	tst.w	BUBVY
	ble.s	.killer

	st.b	OBJAUX1(a5)		;make the lobster back off

	move.b	#JUMPSTATE,BUBSTATE
	jsr	RANDOM
	and.w	#15,d0
	subq.w	#8,d0
	move.w	d0,BUBVX
	move.w	#$f800,BUBVY

	move.b	#50,lobsterflash	;set flash on
	subq.b	#1,lobsterdamage	;decrement hitpoints
	bne.s	.out

	move.l	#LOBSTER_BEATEN,OBJAI(a5)
	move.b	#100,OBJAUX0(A5)
	move.b	#8,OBJFRAME(a5)
	st.b	no_claw_collide
	st.b	lobster_dead
.out
	rts
.killer
	moveq.l	#POPSTATE,d0
	jmp	KILLBUBSY

********************** Lobster Claw Collision Detection *******************

CLAW_COLLIDE
	tst.b	lobsterflash		;no detection whilst flashing
	bne	.out
	tst.b	no_claw_collide		;this means lobster is dead
	bne.s	.out

	move.b	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.out
;	move.w	INVTIMER,d0		;removed for not being able to kill lobster
;	or.w	SHADOWTIMER,d0
;	bne.s	.out

	moveq.l	#0,d0			;detect claw
	jsr	NOBOPCOLLIDE
	bcc.s	.out

	moveq.l	#POPSTATE,d0
	jmp	KILLBUBSY
.out
	rts

********************** Display Flashing Lobster Pieces ********************

DISPLAY_LOBSTER
	tst.b	lobsterflash
	beq.s	.display
	subq.b	#1,lobsterflash
	btst.b	#0,lobsterflash
	beq.s	.display
	rts
.display
	jmp	DRAW_COMPLEX_SPRITE

DISPLAY_CLAW
	tst.b	lobster_dead
	beq.s	.dead
	rts
.dead
	btst.b	#0,lobsterflash
	beq.s	.display
	rts
.display
	jmp	DRAW_COMPLEX_SPRITE

****************************** A Few Variables ****************************

lobsterobj
	dc.l	0

lobsterdamage
	dc.b	0
lobsterflash
	dc.b	0
no_claw_collide
	dc.b	0
lobster_dead
	dc.b	0

******************************* Lobster Frames ****************************

	even

lobster	dc.l	.f0		;frames 0-4 lobster walking
	dc.l	.f1
	dc.l	.f2
	dc.l	.f3
	dc.l	.f4
	dc.l	.f5		;frames 5-7 flicking antenna
	dc.l	.f6
	dc.l	.f7
	dc.l	.f8		;frame 8 collapsed to floor dead

.f0	dc.w	1,0,0,0
	dc.w	-85,-74,0

.f1	dc.w	1,0,0,0
	dc.w	-85,-71,1

.f2	dc.w	1,0,0,0
	dc.w	-85,-70,2

.f3	dc.w	1,0,0,0
	dc.w	-85,-70,3

.f4	dc.w	1,0,0,0
	dc.w	-85,-71,4


.f5	dc.w	2,0,0,0
	dc.w	-85,-61,12
	dc.w	12,-97,13

.f6	dc.w	2,0,0,0
	dc.w	-85,-61,12
	dc.w	22,-51,14

.f7	dc.w	2,0,0,0
	dc.w	-85,-61,12
	dc.w	-24,-74,15

.f8	dc.w	1,0,0,0
	dc.w	-85,-33,16

******************************** Claw Frames ******************************

claw	dc.l	.f0		;frames 0-5 claw moving forwards
;	dc.l	.f1	;rem out later
	dc.l	.f2
;	dc.l	.f3	;rem out later
	dc.l	.f4
	dc.l	.f5
	dc.l	.f6		;frame 6 claw fully outstretched
	dc.l	.f7		;frames 7-12 claw moving backwards
	dc.l	.f8
	dc.l	.f9
	dc.l	.f10
	dc.l	.f11
	dc.l	.f12

.f0	dc.w	3,0,0,0
	dc.w	-3,-1,6
	dc.w	28,0,10
	dc.w	14,6,8

.f1	dc.w	3,0,0,0
	dc.w	0,-1,6
	dc.w	31,-1,10
	dc.w	17,5,8

.f2	dc.w	3,0,0,0
	dc.w	4,-1,6
	dc.w	37,-2,10
	dc.w	23,4,8

.f3	dc.w	3,0,0,0
	dc.w	4,1,7
	dc.w	46,-10,10
	dc.w	32,-4,8

.f4	dc.w	3,0,0,0
	dc.w	8,1,7
	dc.w	55,-20,9
	dc.w	44,-6,8

.f5	dc.w	3,0,0,0
	dc.w	17,1,7
	dc.w	77,-14,10
	dc.w	63,-8,8

.f6	dc.w	3,0,0,0
	dc.w	19,1,7
	dc.w	80,-5,11
	dc.w	65,-8,8

.f7	dc.w	3,0,0,0
	dc.w	17,1,7
	dc.w	78,-5,11
	dc.w	63,-8,8

.f8	dc.w	3,0,0,0
	dc.w	8,1,7
	dc.w	59,-3,11
	dc.w	44,-6,8

.f9	dc.w	3,0,0,0
	dc.w	4,1,7
	dc.w	47,-1,11
	dc.w	32,-4,8

.f10	dc.w	3,0,0,0
	dc.w	4,-1,6
	dc.w	38,7,11
	dc.w	23,4,8

.f11	dc.w	3,0,0,0
	dc.w	0,-1,6
	dc.w	31,-1,10
	dc.w	17,5,8

.f12	dc.w	3,0,0,0
	dc.w	-3,-1,6
	dc.w	28,0,10
	dc.w	14,6,8

************************* Lobster Collision Detection *********************

lobstermap
lobsterfront
	Soff	0,0,46,58,35,69,16,72,00,69,-23,73,029,42
	Soff	0,0,31,44,43,57,30,69,11,69,-10,67,-32,70
	Soff	0,0,32,45,41,58,29,69,10,66,-14,62,-36,67
	Soff	0,0,32,44,41,58,30,68,15,68,-12,62,-36,67
	Soff	0,0,31,44,43,57,30,69,11,69,-10,67,-32,70

	Soff	-10,47,0,0,15,0,30,0,45,10,60,18,75,15
	Soff	-10,47,0,0,15,0,30,0,45,0,60,-5,75,-10
	Soff	0,0,31,44,43,57,30,69,11,69,-10,67,-32,70

lobsterback
	rept	8
	Soff	0,0,-84,24,-74,35,-67,47,-55,53,-43,54,-28,54
	endr

************************** Claw Collision Detection ***********************

karl	macro
	Soff	\1,\2,2,-16,18,-3,23,-23,34,-4,41,-21,51,-6
	endm

clawmap
	karl	-12,-4
	karl	-22,-2
	karl	-22,-2
	karl	-29,6
	karl	-42,8
	karl	-61,10

	karl	-63,10

	karl	-61,10
	karl	-42,8
	karl	-29,6
	karl	-22,-2
	karl	-22,-2
	karl	-12,-4
