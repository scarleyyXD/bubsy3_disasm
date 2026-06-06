FIND_WARP_RANGE		equ	10

;;;ASBx: ;************************************************************************
;;;ASBx: ;*									 *
;;;ASBx: ;* BUBSY CONTROL ROUTINES						 *
;;;ASBx: ;*									 *
;;;ASBx: ;************************************************************************

PLAYERACC		equ	$0012
MAXVX			equ	$0800
MAXVY			equ	$0F00
RUBBERMAXVY		equ	$1900
RUBBERMINVY		equ	$0280
SLIDEMAXV		equ	$0500
SMACKVX			equ	$0500
AIRSMACKVX		equ	$0580

HOPVY			equ	0-$0480
BONUSHOPVY		equ	0-$0700

JUMPBOOST		equ	0-$0018
GLIDEGRAVITY	equ	$0010	
GRAVITY_CTRL	equ	$0048

SLIDEJUMPDX		equ	$0002
JUMPDX			equ	$0002
GLIDEDX			equ	$0002

DEATHHEIGHT		equ	600
FALLHEIGHT		equ	20
	
ATTR_WHAT		equ	$03ff
ATTR_MASK		equ	$03ff
SLIDE			equ	$8000
SLIDELEFT		equ	$4000
WATER			equ	$2000
TACKS			equ	$1000
RUBBER			equ	$0800
WALL_CTRL		equ	$0400
	
WALLLOOKAHEAD 	equ	15
TACKLOOKAHEAD 	equ	8

BUBCTRL:
	if	DETECTMODE
	jsr	DRAW_DETECT_BOX
	endif

	if	DEBUG
	move.l	#$11110000,bad_routine
	endif
	
	LEA	SYSDP,A5

	moveq	#YARNLIFEFLAG,d0
	and.b	GAMEFLAG0,d0						;give life yor yarn
	bne.s	.NOYARNLIFE

	cmp.w	#$500,YARNS
	blt.s	.NOYARNLIFE

	or.b	#YARNLIFEFLAG,GAMEFLAG0

	lea	LIVES,a0
	move.b	(a0),d0
	moveq	#1,d1 ;moveq.b	#1,d1
	abcd	d1,d0
	move.b	d0,(a0)

	move.w	#POPSOUND5,d0
	JSR	STARTSOUND

.NOYARNLIFE:
	moveq	#2,d0										;select bubsy palette based on player
	or.b	d0,BUBPALSEL
	move.w	PLAYER,d6
	bne.s	.P0
	not.b	d0
	and.b	d0,BUBPALSEL
	
.P0:
	move.w	INVTIMER,d0									;handle shadow colouring
	bne.s	.NOSHADOW
	
	move.b	BUBPALSEL,d6									;always lighten if not inv or shadow
	move.w	SHADOWTIMER,d0
	beq.s	.DOWNCOL

	subq.w	#1,SHADOWTIMER

	moveq	#%00000011,d0
	and.w	STIMER,d0
	bne.s	.NOSHADOW

	move.b	BUBPALSEL,d6
	move.w	SHADOWTIMER,d0
	cmp.w	#4*8,d0										;fade back up at end
	blt.s	.DOWNCOL

	move.w	FrameRate,d1									;flash 5 secs
	mulu.w	#5,d1
	cmp.w	d1,d0
	bge.s	.UPCOL

	moveq	#%00000100,d0
	and.w	STIMER,d0
	bne.s	.UPCOL

.DOWNCOL:											;lighten
	subq.b	#4,d6
	bpl.s	.DONECOL

.UPCOL:												;darken
	addq.b	#4,d6
	cmp.b	#12*2,d6
	blt.s	.DONECOL

	subq.b	#4,d6

.DONECOL:
	move.b	d6,BUBPALSEL

.NOSHADOW:												;handle invincibility
	move.w	INVTIMER,d0
	beq.s	.I00
	subq.w	#1,INVTIMER

	move.w	FrameRate,d1
	mulu.w	#5,d1
	cmp.w	d1,d0
	bge.s	.F2

.F1:
	moveq	#%00000011,d0
	and.w	STIMER,d0
	bne.s	.I00
	bra.s	.F0

.F2:
	moveq	#%00000010,d0
	and.w	STIMER,d0
	bne.s	.I00

.F0:
	move.b	#12*2,BUBPALSEL
	bra.s	.I01

.I00:
	moveq	#%11111100,d0
	and.b	BUBPALSEL,d0								;this is only a byte location!
	cmp.b	#12*2,d0
	bne.s	.I01
	moveq	#%00000011,d0
	and.b	BUBPALSEL,d0
	move.b	d0,BUBPALSEL
	
.I01:
	move.w	BUBY,BUBYOLD								;save bubsy previous position
	move.w	BUBX,BUBXOLD

	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0								;clear bopcount if he is anchored and not invincible
	beq.s	.CBCNOT
	move.w	INVTIMER,d0
	bne.s	.CBCNOT
	clr.w	BOPCOUNT
	
.CBCNOT:
	moveq	#DEADFLAG,d0									;Handle x lookahead. no x lookahead if deadflag set it!.
	and.b	BUBSYFLAGS,d0									;set desired bubsy position, right before we plan to change:
	bne.s	.LA01

	move.w	#(320/2),d6									;center bubsy on edit stage
	
	if	EDITME
	cmp.b	#EDITSTATE,BUBSTATE
	beq.s	.LA0
	endif

	move.w	BUBVX,d0
	bmi.s	.LA00
	cmp.w	#$300,d0
	blt.s	.ok1
	moveq	#$30,d6
	bra.s	.LA0
	
.LA00:
	neg.w	d0
	cmp.w	#$300,d0
	blt.s	.ok1
	move.w	#320-$30,d6
	bra.s	.LA0
	
.ok1:
	move.w	STICK,d0
	move.w	d0,d1
	and.w	#JOY_L,d1
	beq.s	.LA1
	move.w	#160+120,d6									;$80+$58,d6
	tst.w	BUBVX
	bne.s	.LA0
	or.b	#BUBSYHFLIP,BUBSYFLAGS
	bra.s	.LA0
	
.LA1:
	move.w	d0,d1
	and.w	#JOY_R,d1
	beq.s	.LA0
	moveq	#160-120,d6										;$80-$58,d6
	tst.w	BUBVX
	bne.s	.LA0
	and.b	#~BUBSYHFLIP,BUBSYFLAGS
	
.LA0:
	move.w	d6,BUBDWX
	
.LA01:
	and.b	#~TAKEHOLD,GAMEFLAG1								;hold game if take warrants it
	moveq	#0,d6
	move.b	BUBSYFRAME,D6
	cmp.w	#158,d6
	blt.s	.NOTAKEHOLD
	cmp.w	#162,d6
	bge.s	.NOTAKEHOLD

.TAKEHOLD:
	or.b	#TAKEHOLD,GAMEFLAG1								;skip jumpstuff,AI,movement
	bra	.B40

.NOTAKEHOLD:											;reset bubsy y position if he is anchored
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0									;not in jumpland or spinning
	beq.s	.LA2
	moveq	#SPINFLAG,d0
	and.b	BUBSYFLAGS1,d0
	bne.s	.LA2
	move.w	#$90,d0
	move.w	d0,BUBDWYTOP
	move.w	d0,BUBDWYBOT
	
.LA2:
	if	DEBUG
	move.l	#$11110001,bad_routine
	endif
	bsr	STARTJUMP									;see if starting a jump would be appreciated

.B10:
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0									;check for fall if bubsy is anchored
	beq.s	.B38
	
	move.w	BUBY,TEMP9									;bubsy is anchored to the map,save bubsy and move him
	if	DEBUG
	move.l	#$11110002,bad_routine
	endif
	
	bsr	BUBSYMOVEOBJECT

	move.w	BUBY,d0
	sub.w	TEMP9,d0
	bmi.s	.B41
	cmp.w	#FALLHEIGHT,d0
	blt.s	.B41

	move.w	TEMP9,d0
	addq.w	#1,d0
	move.w	d0,BUBY
	bsr	STARTFALL
	bra.s	.B41

.B38:
	if	DEBUG
	move.l	#$11110003,bad_routine
	endif
	
	bsr	BUBSYMOVEOBJECT								;bubsy was not anchored so move him

.B41:											;do bubsy AI based on state
	moveq	#0,d6
	move.b	BUBSTATE,d6
	asl.w	#2,d6
	lea	STATEVECTABLE,a0
	move.l	0(a0,d6.w),a1
	if	DEBUG
	move.l	a1,bad_routine
	endif
	jsr	(a1)
	
.B40:
	if	DEBUG
	move.l	#$11110004,bad_routine
	endif
	
	bsr	CLAMPBUBSY							;attach window to bubsy position

	bsr	ANIMATEBUBSY							;do animation

	if	DEBUG
	move.l	#$11110005,bad_routine
	endif

.NOFRAMECHANGE:
	moveq	#DEADFLAG,d0							;the core routine is called from elsewhere
	and.b	BUBSYFLAGS,d0							;see if bubsy hit a wall don't even bother
	bne.s	.NOSMACK
	
	if	EDITME
	cmp.b	#EDITSTATE,BUBSTATE
	beq.s	.NOSMACK
	endif
	
	cmp.b	#WARP2STATE,BUBSTATE
	beq.s	.NOSMACK
	
	cmp.b	#WARP1STATE,BUBSTATE
	beq.s	.NOSMACK
	
	cmp.b	#WARP3STATE,BUBSTATE
	beq.s	.NOSMACK
	
	bsr	SMACKCHECK
	
.NOSMACK:
	if	DEBUG
	move.l	#$11110006,bad_routine
	endif

	bsr	TACKCHECK								;see if bubsy should pop

	if	DEBUG
	move.l	#$11110007,bad_routine
	endif
	
	moveq	#BOSSFLAG,d0
	and.b	GAMEFLAG1,d0								;if there is a boss fix screen
	beq.s	.NOBOSS
	move.w	#$c0,d0
	move.w	d0,BUBDWYTOP
	move.w	d0,BUBDWYBOT
	
.NOBOSS:
	moveq	#0,d6
	move.b	BUBSYFRAME,d6							;get index for points
	asl.w	#3,d6

	if	DEBUG
	move.l	#$11110009,bad_routine
	endif

	lea	BUBSYBOX1,a0							;set up points box
	lea	BUBBOX1,a1							;only need to set a1 up here only as the data is contiguous
	bsr	.SETPOINTS

	lea	BUBSYBOX2,a0
	addq	#8,a1
;	lea	BUBBOX2,a1
	bsr	.SETPOINTS

	lea	BUBSYBOX3,a0
	addq	#8,a1
;	lea	BUBBOX3,a1

	if	CONSULT
	bsr	.SETPOINTS

;	clr.l	SCORE
;	moveq	#0,d0
;	move.b	BUBSYFRAME,d0
;	lsl.w	#4,d0
;	move.w	d0,SCORE+2
	
	move.w	BUBX,SCORE
	move.w	BUBY,SCORE+2
	lea	SCORE,a0
	bsr.s	.tobcd
	lea	SCORE+2,a0
	bsr.s	.tobcd
	move.l	SCORE,DSCORE

	if	DEBUG
	move.l	#$11110010,bad_routine
	endif

	rts
	
.tobcd:
	moveq	#0,d0
	move.w	(a0),d0
	lsr.w	#4,d0
	
	divu	#10,d0
	swap	d0
	move.b	d0,1(a0)
	clr.w	d0
	swap	d0
	
	divu	#10,d0
	swap	d0
	lsl.b	#4,d0
	or.b	d0,1(a0)
	clr.w	d0
	swap	d0
	
	divu	#10,d0
	swap	d0
	move.b	d0,(a0)
	clr.w	d0
	swap	d0
	
	divu	#10,d0
	swap	d0
	lsl.b	#4,d0
	or.b	d0,(a0)
	clr.w	d0
	rts
	
	endif

.SETPOINTS:										;get index and check if we are h-flipped
	add.w	d6,a0
	move.w	BUBX,d4
	move.w	BUBY,d5

	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.BUBHFLIPPED

	movem.w	(a0),d0-d3
	add.w	d4,d0
	add.w	d5,d1
	add.w	d4,d2
	add.w	d5,d3
	movem.w	d0-d3,(a1)
	rts
	
.BUBHFLIPPED:
	addq	#8,d4
	move.w	d4,d0
	move.w	d4,d2
	sub.w	(a0)+,d2
	move.w	(a0)+,d1
	sub.w	(a0)+,d0
	move.w	(a0)+,d3
	add.w	d5,d3
	add.w	d5,d1
	movem.w	d0-d3,(a1)
	rts

BUBVX_m	equ	3
BUBVX_d	equ	4

BUBVY_m	equ	9
BUBVY_d	equ	10

BUBSYMOVEOBJECT:
	move.w	OBJX(A5),TEMP8									;this routine moves and object by VX (fractional)
												;and sticks it on the ground
												;save x for wall collision
	moveq	#ANCHORFLAG,d0
	and.b	OBJFLAGS(A5),d0									;if object is on the ground
	beq.s	.B10

	move.w	OBJVX(A5),d0									;object is on the ground
	beq.s	.B30
	bmi.s	.B20

	cmp.W	#$0800,d0									; VX is +ive
	bCS.s	.B11
	move.W	#$0800,d0
	bra.s	.B11
	
.B20:												;vx is -ive
	cmp.W	#$f800,d0
	bCC.s	.B11
	move.W	#$f800,d0
	
.B11:
	tst.b	in_water
	beq.s	.no_water
	muls	#BUBVX_m,d0
	divs	#BUBVX_d,d0
	
.no_water:
	ext.l	d0
	asl.L	#8,d0
	
	add.l	d0,OBJX(A5)
	
.B30:
	cmp.b	#WARP2STATE,BUBSTATE
	bne	STICKOBJECTTOPLAYFIELD
	rts
	
.B10:												;the object is in the air
	move.W	OBJVX(A5),d0
	tst.b	in_water
	beq.s	.no_water1
	muls	#BUBVX_m,d0
	divs	#BUBVX_d,d0
	
.no_water1:
	ext.l	d0
	asl.L	#8,d0
	add.l	d0,OBJX(A5)

	move.W	OBJVY(A5),d0
	tst.b	in_water
	beq.s	.no_water2
	muls	#BUBVY_m,d0
	divs	#BUBVY_d,d0
	
.no_water2:
	ext.l	d0
	asl.L	#8,d0
	add.l	d0,OBJY(A5)
	rts

;;;ASBx: ;************************************************************************
;;;ASBx: ;*					 				*
;;;ASBx: ;*	GLOBAL SUBROUTINES			 			*
;;;ASBx: ;*					 				*
;;;ASBx: ;************************************************************************

MOVEOBJECT:
	move.w	OBJX(A5),TEMP8									;this routine moves and object by VX (fractional)
												;and sticks it on the ground
												;save x for wall collision
	moveq	#ANCHORFLAG,d0
	and.b	OBJFLAGS(A5),d0									;if object is on the ground
	beq.s	.B10

	move.w	OBJVX(A5),d0									;object is on the ground
	beq.s	.B30
	bmi.s	.B20

	cmp.W	#$0800,d0									; VX is +ive
	bCS.s	.B11
	move.W	#$0800,d0
	bra.s	.B11
	
.B20:												;vx is -ive
	cmp.W	#$f800,d0
	bCC.s	.B11
	move.W	#$f800,d0
	
.B11:
	ext.l	d0
	asl.L	#8,d0
	add.l	d0,OBJX(A5)
	
.B30:
	bRA	STICKOBJECTTOPLAYFIELD
	
.B10:												;the object is in the air
	move.W	OBJVX(A5),d0
	ext.l	d0
	asl.L	#8,d0
	add.l	d0,OBJX(A5)

	move.W	OBJVY(A5),d0
	ext.l	d0
	asl.L	#8,d0
	add.l	d0,OBJY(A5)
	rts

ACCELOBJX:
	ext.l	d0											;do the velocity
	asl.L	#8,d0
	add.l	d0,OBJX(A5)
	rts

ACCELOBJY:
	ext.l	d0											;do the velocity
	asl.L	#8,d0
	add.l	d0,OBJY(A5)
	rts

;;;ASBx: ;************************************************************************

CHECKOBJBOX:
	move.w	OBJX(A5),d0
	cmp.w	(a0),d0
	blt.s	.OUT

	cmp.w	4(a0),d0
	bge.s	.OUT

	cmp.w	2(a0),d0
	move.w	OBJY(A5),d0
	blt.s	.OUT

	cmp.w	6(a0),d0
	bge.s	.OUT

.IN:
	and.b	#~FlagC,ccr
	rts

.OUT:
	or.b	#FlagC,ccr
	rts

;;;ASBx: ;************************************************************************
;;;ASBx: ;*					 				*
;;;ASBx: ;*	LOCAL SUBROUTINES			 			*
;;;ASBx: ;*					 				*
;;;ASBx: ;************************************************************************

NEWANIMATION:
	cmp.L	ANIMSCRPTR,d0
	bne.s	STARTANIMATION
	rts

STARTANIMATIONFAR:
STARTANIMATION:
	cmp.L	ANIMSCRPTR,d0
	bne.s	.ok
	or.b	#ANIMFLAG,BUBSYFLAGS
	rts
	
.ok:
	move.L	d0,ANIMSCRPTR
	moveq	#1,d1
	move.b	d1,ANIMTIMER
	move.b	d1,ANIMSPEED
	sf	ANIMSTEP
	or.b	#ANIMFLAG,BUBSYFLAGS

;;;ASBx: ;************************************************************************

ANIMATEBUBFAR:
ANIMATEBUBSY:
	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0									;see if the object is animating
	beq.s	.BFF

	move.b	ANIMTIMER,d0									;do the animation timing
	sub.b	ANIMSPEED,d0
	move.b	d0,ANIMTIMER
	beq.s	.B10
	bpl.s	.BFE
	
.B10:
	moveq	#0,d7
	move.b	ANIMSTEP,d7										;time for a new frame
	MOVE.L	ANIMSCRPTR,a0
	move.b	0(a0,d7.w),d0
	bpl.s	.B20
	cmp.b	#ALOADSOUND,d0
	BLO.s	.B20

	bne.s	.NOTLOADSOUND									;a command

	move.b	1(a0,d7.w),d0
	addq.b	#2,d7
	move.b	d7,ANIMSTEP
	JSR	LOADNPLAYSFX
	bra.s	.B10

.NOTLOADSOUND:
	cmp.b	#ASOUND,d0
	bne.s	.NOTSOUND

	move.b	1(a0,d7.w),d0
	JSR	STARTSOUND
	addq.b	#2,d7
	move.b	d7,ANIMSTEP
	bra.s	.B10

.NOTSOUND:
	cmp.b	#ALABEL,d0
	bne.s	.B11

	addq.b	#1,ANIMSTEP										;a label continue
	bra.s	.B10
	
.B11:
	cmp.b	#AEND,d0
	bne.s	.B12

	and.b	#~ANIMFLAG,BUBSYFLAGS									;AEND - turn animation off
	
.BFE:
.BFF:
	rts
	
.B12:
	moveq	#0,d7											;ALOOP - search for the 1st ALABEL and process
	
.B13:	
	move.b	(a0,d7.w),d0
	addq.b	#1,d7
	cmp.b	#ALABEL,d0
	bne.s	.B13

	move.b	d7,ANIMSTEP
	bra.s	.B10
	
.B20:
	move.b	d0,ANIMTIMER									;a count and frame
	move.b	1(a0,d7.w),BUBSYFRAME
	addq.b	#2,d7
	move.b	d7,ANIMSTEP
	rts

;;;ASBx: ;************************************************************************
CLAMPBUBSY:
	move.w	BUBX,d2
	
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0									;this makes sure buby doesn't go off the map
	bne.s	.NOXCHECK

	move.w	BUBXMIN,d0
	cmp.w	d2,d0
	ble.s	.B60

.B10:
	move.w	d0,d2
	clr.w	BUBVX
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.B60

 	MOVE.b	#IDLESTATE,BUBSTATE
	
.B60:
	move.w	BUBXMAX,d0
	cmp.w	d2,d0
	blt.s	.B10
	
.NOXCHECK:
	move.w	d2,BUBX
	rts

;;;ASBx: ;************************************************************************
MOVEPLAYER:											;this moves bubsy(x) according to the joystick
												;and handles run & skid state
	moveq	#ANCHORFLAG,d0									;on char at bubx,buby
	and.b	BUBSYFLAGS,d0									;if bubsy is anchored do VX processing based
	beq.s	.B40

	bsr	GETGRAVITY
	move.w	d0,TEMP9
	add.w	d0,BUBVX
	
.B40:
	move.w	STICK,d0
	and.w	#CTRL_LEFT,d0
	beq	.B10

	move.w	BUBVX,d0									;stick left - accelerate bubsy left
	sub.w	#PLAYERACC,d0
	move.w	d0,BUBVX
	bmi.s	.B01

	lsr.w	#3,d0										; IV VX is +ive make him proportionately
	neg.w	d0										; more responsive
	add.w	BUBVX,d0
	bra.s	.B02
	
.B01:												;check for maxVX
	cmp.w	#-MAXVX,d0
	bge.s	.B02
	move.w	#-MAXVX,d0
	
.B02:
	move.w	d0,BUBVX

	btst.l	#15,d0										;determine skid or run
	beq.s	.B03
	moveq	#RUNSTATE,d6
	bra.s	.B04
	
.B03:
	move.w	BUBVX,d0									;skid, make sound at right time if fast enough
	bpl.s	.SKIDPOS1
	neg.w	d0
	
.SKIDPOS1:
	cmp.w	#$0002,d0
	blt.s	.NOSOUND1

	cmp.b	#1,ANIMTIMER
	bne.s	.NOSOUND1

	move.b	BUBSYFRAME,d6
	cmp.b	#22,d6
	bne.s	.NOSOUND1
	
.SOUND1:
	move.w	#BACKPED,d0
	JSR	STARTSOUND
	
.NOSOUND1:
	moveq	#SKIDSTATE,d6
	
.B04:
	move.b	d6,BUBSTATE
	bra	.B50
	
.B10:												;check for right
	move.w	STICK,d0
	and.w	#CTRL_RIGHT,d0
	beq.s	.B20

	MOVE.w	BUBVX,d0									;stick right - accelerate bubsy right
	addi.w	#PLAYERACC,d0
	move.w	d0,BUBVX

	bpl.s	.B11										;IV VX is -ive make him proportionately more responsive
	neg.w	d0
	lsr.w	#3,d0
	add.w	BUBVX,d0
	bra.s	.B12
	
.B11:												;check for maxVX
	cmp.w	#MAXVX,d0
	blt.s	.B12
	move.w	#MAXVX,d0
	
.B12:
	move.w	d0,BUBVX

	btst.l	#15,d0										;determine skid or run state
	bne.s	.B13
	moveq	#RUNSTATE,d6
	bra.s	.B14
	
.B13:
	move.w	BUBVX,d0									;skid, make sound at right time if fast enough
	bpl.s	.SKIDPOS
	neg.w	d0
	
.SKIDPOS:
	cmp.w	#$0002,d0
	blt.s	.NOSOUND

	cmp.b	#1,ANIMTIMER
	bne.s	.NOSOUND

	move.b	BUBSYFRAME,d6
	cmp.b	#22,d6
	bne.s	.NOSOUND
	
.SOUND:
	move.w	#BACKPED,d0
	JSR	STARTSOUND
	
.NOSOUND:
	moveq	#SKIDSTATE,d6
	
.B14:
	bra.s	.B50
	
.B20:												;no joy input, skid to stop if on flat ground
	move.w	TEMP9,d0
	beq.s	.B23

	moveq	#RUNSTATE,d6									;there is a slope, run without impedance
	move.b	d6,BUBSTATE									;to a flat where he can stop
	move.w	BUBVX,d5									;if VX and G have different signs double G
	eor.w	d5,d0
	bmi.s	.B24
	bpl.s	.B50
	
.B23:													;no slope ... skid
	moveq	#SKIDSTATE,d6
	
.B24:													;decelerate
	move.w	#$0040,d0
	btst.b	#7,BUBVX
	bne.s	.VXNEG
	neg.w	d0
	
.VXNEG:
	add.w	BUBVX,d0
	move.w	d0,BUBVX
	bpl.s	.B21

	neg.w	d0											;go idle if slow enough and on a flat

.B21:
	cmp.w	#$0034,d0
	bge.s	.B22

	move.w	TEMP9,d0
	bpl.s	.B25
	neg.w	d0
	
.B25:
	cmp.w	#$10,d0
	bge.s	.B22

	clr.w	BUBVX
	moveq	#IDLESTATE,d6
	
.B22:
.B50:
	move.w	BUBVX,d0										;handle hflip
	beq.s	.B51
	bmi.s	.B52

	and.b	#~BUBSYHFLIP,BUBSYFLAGS									;VX is +ive
	bra.s	.B51
	
.B52:													;VX is -ve
	or.b	#BUBSYHFLIP,BUBSYFLAGS
	
.B51:
	move.b	d6,BUBSTATE
	rts

BUBAPPLYGRAVITY:
	moveq	#TAKEHOLD,d0
	and.b	GAMEFLAG1,d0									;no gravity if take is holding bubsy
	bne.s	.BAIL

	move.w	BUBVY,d0										;bound bubsy
	add.w	WORLD_GRAVITY,d0
	bmi.s	.VYOK
	cmp.w	WORLD_MAXVY,d0
	blt.s	.VYOK
	move.w	WORLD_MAXVY,d0
	
.VYOK:
	move.w	d0,BUBVY
	
.BAIL:
	rts

;;;ASBx: ;************************************************************************
;;;ASBx: ;MOVEPLAYER8
;;;ASBx: ;	RTS

KILLBUBSY:
	tst.w	INVTIMER										;check for invincibility
	beq.s	.NOTINV
	
.INV:
	or.b	#FlagC,ccr
	rts
	
.NOTINV:													;check if we are in shadow state
	tst.w	SHADOWTIMER
	bne.s	.INV

	move.b	BUBSYFLAGS,d1
	moveq	#DEADFLAG,d5
	or.b	d5,BUBSYFLAGS
	and.b	d1,d5											;make bubsy dead, and if he already is bail
	bne.s	.INV

	move.b	d0,BUBSYDEMISE										;set final resting state

	or.b	#BUBSYOFFSCREEN,GAMEFLAG0								;allow him to go off screen

	cmp.b	#POPSTATE,d0
	beq.s	.DONE

	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.AIR

	movem.w d1-d2,-(a7)										;bubsy is anchored, see if he is on a hill

	move.w	BUBX,d1
	move.w	BUBY,d2

	jsr	GETGRAVITY
	cmp.w	#$10,d0
	blt.s	.GROUND1

	movem.w (a7)+,d1-d2

	moveq	#ROLLFALLSTATE,d0
	bra.s	.DONE
	
.GROUND1:
	movem.w (a7)+,d1-d2

	move.b	BUBSYDEMISE,d0
	bra.s	.DONE
	
.AIR:													;tumble in air and do demise
	moveq	#HITFALLSTATE,d0
	
.DONE:
	move.b	d0,BUBSTATE

	and.b	#~FlagC,ccr
	rts

CHECKFORLANDINGGOINGUP:
	tst.b	jump_through_allowed									;if set then can jump through blocks going up
	bne.s	.allowed_to_pass
	
	move.w	BUBX,d1
	move.w	BUBY,d2
	JSR	GETATTRIB
	and.w	#ATTR_MASK,d0
	bne.s	.something
	
.allowed_to_pass:
	rts
	
.something:
	cmp.w	#512,d0
	bgt.s	.allowed_to_pass
	move.w	BUBY,TEMP9
	add.w	#16,BUBY
	bsr	STICKOBJECTTOPLAYFIELD
	move.w	TEMP9,d0
	move.w	BUBY,d1
	cmp.w	d1,d0
	bgt.s	.MYCHECKFORLANDING
	move.w	d0,BUBY
	rts
	
.MYCHECKFORLANDING:
	move.w	BUBOBJGRAV,d1										;other objects can be ground
													;init to object gravity attribute
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.B00
	
.B00NOT:													;get the attribute
	move.w	BUBX,d1
	move.w	BUBY,d2
	JSR	GETATTRIB
	move.w	d0,d1

	and.w	#WATER,d0										;check for water
	beq.s	.NOWATER

	or.w	#$00015,BUBY
	
.FINDSURFACE:
	move.w	BUBX,d1
	move.w	BUBY,d2
	sub.w	#16,d2
	move.w	d2,BUBY

	JSR	GETATTRIB

	and.w	#WATER,d0
	bne.s	.FINDSURFACE

	MOVE.B	#SPLASHSTATE,BUBSTATE
	clr.w	BUBVY
	addq.w	#2,BUBY
	rts
	
.NOWATER:
	move.w	#RUBBER,d0
	and.w	d1,d0
	beq.s	.NOTRUBBER

	move.w	BUBVY,d0
	bmi.s	.NOTRUBBER
	
.SPRING:													;no spring if bubsy is dead
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.NOTRUBBER

	MOVE.B	#JUMPSTATE,BUBSTATE									;from tree limb

; DSW WWW THIS IS AN OBVIOUS AND DANGEROUS ERROR (SEE ABOVE)
	and.b	#~BUBONRAFT,BUBSYFLAGS1
	and.b	#~BUBONRAFT,BUBSYFLAGS
	MOVE.B	#32,BUBSYFRAME

	move.w	#$f300,BUBVY									;get inital velocity for jump

	move.w	#BOING3,d0
	JMP	STARTSOUND
	
.NOTRUBBER:												;see if we hit map ground
	move.w	#ATTR_MASK,d0
	and.w	d1,d0
	bne.s	.B01
	rts
	
.B01:													;we hit real ground
	subi.w	#16,BUBY
	
.B00:													;entry point for landng on an object
.B31:
	move.w	BUBVX,d0											;if landng push back, VX =0
	bpl.s	.MOVINGRIGHT

	move.w	STICK,d0
	and.w	#CTRL_RIGHT,d0
	beq.s	.LVXDONE
	bra.s	.LVX0

.MOVINGRIGHT:
	move.w	STICK,d0
	and.w	#CTRL_LEFT,d0
	beq.s	.LVXDONE
	
.LVX0:
	clr.w	BUBVX
	
.LVXDONE:													;see if we landed on a slide
	move.w	#SLIDE,d0
	and.w	d1,d0
	beq.s	.B31A

	move.w	#$20,d6											;he landed on a slide!
	move	#SLIDELEFT,d0
	and.w	d1,d0											;determine acceleration direction
	beq.s	.B31B

	move.w	#-$20,d6
	
.B31B:
	move.w	d6,BUBOBJGRAV

	or.b	#SPINFLAG,BUBSYFLAGS1									;flag bubsy as spinning

	move.w	BUBOBJGRAV,d0										;start him moving out
	asl.w	#2,d0
	move.w	d0,BUBVX

	MOVE.B	#1,ANIMTIMER											;do short landng
	
.B31A:														;entry point for normal landng
	bsr	STICKOBJECTTOPLAYFIELD

	or.b	#ANCHORFLAG,BUBSYFLAGS

	move.w	BUBY,d0											;set top of window to buby-window
	sub.w	WINDY,d0
	bmi.s	.B31E

	and.w	#$fffc,d0
	cmp.w	BUBWYBOT,d0
	blt.s	.B31C
	move.w	BUBWYBOT,d0
	
.B31C:
	cmp.w	#$0010,d0
	bge.s	.B31D
	
.B31E:
	move.w	#$0010,d0
	
.B31D:
	move.w	d0,BUBWYTOP
	move.w	d0,BUBDWYTOP
	rts											;as going up cannot fall to death
	
;;;ASBx: ;************************************************************************
CHECKFORLANDNG:
	move.w	BUBOBJGRAV,d1										;other objects can be ground
													;init to object gravity attribute
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.B00
	
.B00NOT:													;get the attribute
	move.w	BUBX,d1
	move.w	BUBY,d2
	JSR	GETATTRIB
	move.w	d0,d1

	and.w	#WATER,d0										;check for water
	beq.s	.NOWATER

	or.w	#$00015,BUBY
	
.FINDSURFACE:
	move.w	BUBX,d1
	move.w	BUBY,d2
	sub.w	#16,d2
	move.w	d2,BUBY

	JSR	GETATTRIB

	and.w	#WATER,d0
	bne.s	.FINDSURFACE

	MOVE.B	#SPLASHSTATE,BUBSTATE
	clr.w	BUBVY
	addq.w	#2,BUBY
	rts
	
.NOWATER:
	move.w	#RUBBER,d0
	and.w	d1,d0
	beq.s	.NOTRUBBER

	move.w	BUBVY,d0
	bmi.s	.NOTRUBBER
	
.SPRING:													;no spring if bubsy is dead
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.NOTRUBBER

	MOVE.B	#JUMPSTATE,BUBSTATE									;from tree limb

; DSW WWW THIS IS AN OBVIOUS AND DANGEROUS ERROR (SEE ABOVE)
	and.b	#~BUBONRAFT,BUBSYFLAGS1
	and.b	#~BUBONRAFT,BUBSYFLAGS
	MOVE.B	#32,BUBSYFRAME

	move.w	#$f300,BUBVY									;get inital velocity for jump

	move.w	#BOING3,d0
	JMP	STARTSOUND
	
.NOTRUBBER:												;see if we hit map ground
	move.w	#ATTR_MASK,d0
	and.w	d1,d0
	bne.s	.B01
	rts
	
.B01:													;we hit real ground
	subi.w	#16,BUBY
	
.B00:													;entry point for landng on an object
	MOVE.B	#JUMPLANDSTATE,BUBSTATE
	
	move.L	#JUMPLANDANIMATION,d0
	bsr	STARTANIMATION

	MOVE.B	#31,BUBSYFRAME
	move.w	BUBVX,d0
	bne.s	.B31

	MOVE.B	#6,ANIMTIMER
	
.B31:
	move.w	BUBVX,d0											;if landng push back, VX =0
	bpl.s	.MOVINGRIGHT

	move.w	STICK,d0
	and.w	#CTRL_RIGHT,d0
	beq.s	.LVXDONE
	bra.s	.LVX0

.MOVINGRIGHT:
	move.w	STICK,d0
	and.w	#CTRL_LEFT,d0
	beq.s	.LVXDONE
	
.LVX0:
	clr.w	BUBVX
	
.LVXDONE:													;see if we landed on a slide
	move.w	#SLIDE,d0
	and.w	d1,d0
	beq.s	.B31A

	move.w	#$20,d6											;he landed on a slide!
	move	#SLIDELEFT,d0
	and.w	d1,d0											;determine acceleration direction
	beq.s	.B31B

	move.w	#-$20,d6
	
.B31B:
	move.w	d6,BUBOBJGRAV

	or.b	#SPINFLAG,BUBSYFLAGS1									;flag bubsy as spinning

	move.w	BUBOBJGRAV,d0										;start him moving out
	asl.w	#2,d0
	move.w	d0,BUBVX

	MOVE.B	#1,ANIMTIMER											;do short landng
	
.B31A:														;entry point for normal landng
	bsr	STICKOBJECTTOPLAYFIELD

	or.b	#ANCHORFLAG,BUBSYFLAGS

	move.w	BUBY,d0											;set top of window to buby-window
	sub.w	WINDY,d0
	bmi.s	.B31E

	and.w	#$fffc,d0
	cmp.w	BUBWYBOT,d0
	blt.s	.B31C
	move.w	BUBWYBOT,d0
	
.B31C:
	cmp.w	#$0010,d0
	bge.s	.B31D
	
.B31E:
	move.w	#$0010,d0
	
.B31D:
	move.w	d0,BUBWYTOP
	move.w	d0,BUBDWYTOP

	moveq	#BONUSFLAG,d0
	and.b	GAMEFLAG1,d0										;no squish in bonus round
	bne.s	.B40

	tst.b	in_water
	bne.s	.B40
	
	move.w	BUBY,d0											;see if we should squish player
	sub.w	BUBAPEX,d0
	bmi.s	.B40
	cmp.w	#DEATHHEIGHT,d0
	blt.s	.B40

;;;ASBx: ; IF PLAYER IS ON A SLOPE (30+) AND THERE IS AN EXIT PATH, SKIP THE SQUISH AND JUST DO THE ACCORDIAN WALK
;;;ASBx: ; IF HE LANDS ON A FLAT AND THERE ISN'T A GOOD PATH FOR THE ACCORDIAN WALK JUST SQUISH
;;;ASBx: ; IF HE LANDS ON A SLOPE AND THERE IS NO GOOD PATH FOR THE ACCORDIAN, TUMBLE TO THE GROUND UNCONCIOUS				

	move.w	#SMASH,d0
	JSR	STARTSOUND

	or.b	#DEADFLAG,BUBSYFLAGS
	and.b	#~BUBSYHFLIP,BUBSYFLAGS

	bsr	GETGRAVITY
	move.w	d0,TEMP9											;save gravity

	bpl.s	.GPOS
	neg.w	d0
	
.GPOS:
	cmp.w	#$a,d0												;30 deg VX
	bge.s	.SLOPE

	bsr.s	CHECKACCORDIANPATH										;he landed on a flat, check exit path
	move.w	d0,BUBVX

	and.w	#~BUBSYHFLIP,d0
	or.b	d0,BUBSYFLAGS
	MOVE.B	#SQUISHSTATE,BUBSTATE
	
.B40:
	rts
	
.SLOPE:														;he landed on a slope, check exit path
	bsr.s	CHECKACCORDIANPATH
	move.w	d0,BUBVX
	and.w	#BUBSYHFLIP,d0
	or.b	d0,BUBSYFLAGS
	tst.w	d0
	beq.s	.TUMBLE
	
.ACCORDIAN:
	MOVE.B	#ACCORDIANSTATE,BUBSTATE
	move.L	#ACCORDIANANIMATION2,d0
	bra	STARTANIMATION
	
.TUMBLE:
	MOVE.B	#ROLLFALLSTATE,BUBSTATE
	rts

;;;ASBx: ;************************************************************************

CHECKACCORDIANPATH:
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0										;if bubsy is on an object, no way
	beq.s	.B00

	clr.w	d0
	rts

.B00:
	move.w	BUBX,TEMP7											;save bubsy position
	move.w	BUBY,TEMP8

	move.w	#1,TEMP5											;direction counter

	move.w	#$fff8,TEMP4										;initial direction

	move.w	TEMP9,d0											;check slopes
	ble.s	.STARTLEFT

.STARTRIGHT:
	move.w	#8,TEMP4

.STARTLEFT:
.LOOP0:
	move.w	TEMP7,BUBX											;initial coordinates
	move.w	TEMP8,BUBY

	moveq	#24-1,d6											;loop iterations in either direction
	
.LOOP1:
	move.w	d6,-(a7)

	MOVE	BUBY,TEMP6
	bsr	STICKOBJECTTOPLAYFIELD
	move.w	(a7)+,d6

	move.w	BUBY,d0
	sub.w	TEMP6,d0
	bpl.s	.LP

	cmp.w	#$fff8,d0
	beq.s	.BADPATH
	bra.s	.LN

.LP:
	cmp.w	#FALLHEIGHT,d0
	bge.s	.BADPATH

.LN:														;now lets test the character he is on
	move.w	BUBX,d1
	move.w	BUBY,d2
	subq.w	#1,d2
	JSR	GETATTRIB
	and.w	#SLIDE|WALL_CTRL,d0											;slide + wall
	bne.s	.BADPATH

	MOVE.W	TEMP4,D0											;that one was ok lets try the next
	ADD.W	D0,BUBX

	dbf	d6,.LOOP1

.GOODPATH:													;sucess !!!!!! retrieve x and y
	move.w	TEMP7,BUBX
	move.w	TEMP8,BUBY

	move.w	TEMP4,d0											;make +/- 8 +/- 1
	asl.w	TEMP4
	roxr.w	#1,d0
	asl.w	TEMP4
	roxr.w	#1,d0
	asl.w	TEMP4
	roxr.w	#1,d0
	rts

.BADPATH:													;change direction
	neg.w	TEMP4

	subq.w	#1,TEMP5											;see if we have done both
	bpl	.LOOP0

	move.w	TEMP7,BUBX											;failure
	move.w	TEMP8,BUBY

	clr.w	d0
	rts

;;;ASBx: ;************************************************************************
STARTFALL:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.B10

.ROLLFALL:													;if he is rolling down a hill don't
	move.w	BUBY,BUBAPEX										;change state of anim
	and.b	#~ANCHORFLAG,BUBSYFLAGS
	rts

.B10:														;nope, fell off something normal
	clr.w	BUBVY
	move.w	BUBVX,d0
	asl.w	#1,d0
	roxr.w	BUBVX

.B20:
	move.w	BUBY,BUBAPEX
	move.L	#JUMPSTARTANIM,d0
	bsr	STARTANIMATION

	and.b	#~ANCHORFLAG,BUBSYFLAGS
	move.B	#JUMPSTATE,BUBSTATE

	rts

;;;ASBx: ;************************************************************************
STARTJUMP:
	moveq	#SPINFLAG,d0	;moveq.b	#SPINFLAG,d0							;check for a jump not if editing or sliding, or unconcious
	and.b	BUBSYFLAGS1,d0								;if bubsy is anchored and not in a jump_land state or dying
	bne.s	.NOJUMP

	move.b	BUBSYFLAGS,d6
	
	moveq	#DEADFLAG,d0
	and.b	d6,d0
	bne.s	.NOJUMP

	moveq	#ANCHORFLAG,d0
	and.b	d6,d0
	beq.s	.NOJUMP

	move.b	BUBSTATE,D6
	cmp.b	#UNCONCIOUSSTATE,d6
	beq.s	.NOJUMP

	cmp.b	#SMACKSTATE,d6
	beq.s	.NOJUMP

	cmp.b	#BANANASTATE,d6
	beq.s	.NOJUMP

	cmp.b	#ENDSTATE,d6
	beq.s	.NOJUMP

	if	EDITME
	cmp.b	#EDITSTATE,d6
	beq.s	.NOJUMP
	endif

	cmp.w	#WARP1STATE,d6
	beq.s	.NOJUMP
	
	cmp.w	#WARP2STATE,d6
	beq.s	.NOJUMP

	cmp.w	#WARP3STATE,d6
	beq.s	.NOJUMP

	cmp.b	#LIMBOSTATE,d6
	bne.s	.JUMP

.NOJUMP:
	rts

.JUMP:
	move.w	EDGESTICK,d0
	and.w	JUMPBUTTON,d0
	bne.s	.B10

	move.w	EDGESTICK,d0
	and.w	GLIDEBUTTON,d0
	beq.s	.NOJUMP
	
	or.b	#GLIDEFLAG,BUBSYFLAGS1

.B10:
	or.b	#TIMEFLAG,GAMEFLAG1									;if he can jump the clock should be running

	move.w	#$30,BUBDWYTOP										;open window for jump
	move.w	#$30,BUBWYTOP

	move	#BOING,d0
	JSR	STARTSOUND

	move.b	#JUMPSTATE,BUBSTATE									;start a jump
	and.b	#~(ANCHORFLAG+BUBONOBJFLAG),BUBSYFLAGS
	and.b	#~BUBONRAFT,BUBSYFLAGS1

	move.w	BUBY,BUBAPEX										;set apex

	move.L	#JUMPSTARTANIM,d0									;start appropriate animation
	tst.b	BUBVX
	beq.s	.B30
	move.L	#RUNNINGJUMPSTARTANIM,d0
	
.B30:
	bsr	STARTANIMATION

	move.w	BUBVX,d0										;handle VY based on VX
	bpl.s	.B30A
	neg.w	d0
	
.B30A:
	lsr.w	#7,d0
	and.w	#$001e,d0
	move.w	JUMPTAB(pc,d0.w),BUBVY

	move.w	BUBVX,d0										;halve VX
	asl.w	#1,d0
	roxr.w	BUBVX

	bsr	GETGRAVITY										;account for incline

	asl.w	#3,d0
	ADD.W	D0,BUBVX	; DSW OPTIMIZATION

	rts

JUMPTAB:
		dc.w	0-$0680,0-$06C0,0-$0700,0-$0740,0-$0780
		dc.w	0-$0800,0-$0840,0-$0880,0-$08C0
		dc.w	0-$08C0,0-$08C0,0-$08C0,0-$08C0,0-$08C0,0-$08C0,0-$08C0

;;;ASBx: ;************************************************************************
TACKCHECK:
	move.b	BUBSTATE,d6										;be sure bubsy is alive so we can kill him
	
	if	EDITME
	cmp.b	#EDITSTATE,d6
	beq	.NOTACK
	endif
	
	cmp.b	#POPSTATE,d6
	beq	.NOTACK

	cmp.b	#WARP2STATE,d6
	beq	.NOTACK

	cmp.b	#WARP1STATE,d6
	beq.s	.NOTACK

	cmp.b	#WARP3STATE,d6
	beq.s	.NOTACK

	cmp.b	#LIMBOSTATE,d6
	beq.s	.NOTACK

	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.NOTACK

	moveq	#TACKLOOKAHEAD,d6
	move.w	BUBX,d0
	sub.w	BUBXOLD,d0
	bne.s	.WL10
	moveq	#0,d6
	
.WL10:
	bpl.s	.WL20
	moveq	#-TACKLOOKAHEAD,d6
	
.WL20:
	move.w	d6,d0
	add.w	BUBX,d0
	move.w	d0,d1

	move.w	BUBY,d2										;this is to account for tack being on the floor
	subq.w	#1,d2
	move.w	d6,-(sp)
	JSR	GETATTRIB
	move.w	(sp)+,d6

	and.w	#TACKS,d0
	bne.s	.found_tacks
	
	move.w	d6,d1
	add.w	BUBX,d1

	moveq	#-40,d2
	add.w	BUBY,d2										;this is to account for tack being head height
	JSR	GETATTRIB

	and.w	#TACKS,d0
	beq.s	.NOTACK
	
.found_tacks:
	clr.w	BUBVX
	clr.w	BUBVY
	move.b	#POPSTATE,BUBSTATE
	
.NOTACK:
	rts

;;;ASBx: ;************************************************************************
SMACKCHECK:
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0								;by the ceiling only check if he is airborne
	bne.s	.NOCEILING

	tst.w	BUBVY
	bpl.s	.NOCEILING

	move.w	BUBX,d1									;check above bubys head
	move.w	BUBY,d2
	subi.w	#20,d2
	JSR	GETATTRIB

	and.w	#WALL_CTRL,d0
	beq.s	.NOCEILING

.CEILING:
	clr.w	BUBVY
	move.w	BUBY,d0
	addq.w	#8,d0
	and.w	#$fff8,d0
	move.w	d0,BUBY
	rts
	
.NOCEILING:
	moveq	#WALLLOOKAHEAD,d6									;check for wall
	move.w	BUBX,d0
	sub.w	BUBXOLD,d0
	bne.s	.WL10
	move.w	BUBVX,d0
	
.WL10:
	bpl.s	.WL20
	moveq	#-WALLLOOKAHEAD,d6
	
.WL20:
	move.w	d6,d0
	add.w	BUBX,d0
	move.w	d0,d1
	move.w	BUBY,d2
	subq.w	#1,d2										;this is to account for the wall being on the floor
	JSR	GETATTRIB

	move	#WALL_CTRL,d5
	and.w	d0,d5
	beq	.NOWALL

	and.w	#ATTR_MASK,d0									;we hit a wall .. see if it is also floor
	beq.s	.ALIGNX

	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0									;if bubsy came from above do not reposition X
	bne.s	.ALIGNX

	moveq	#$f0,d0
	
	move.w	BUBY,d1
	and.w	d0,d1

	and.w	BUBYOLD,d0
	
	cmp.w	d1,d0
	bCS.s	.NOREALIGNX

.ALIGNX:								;reposition X
	move.w	BUBX,d0
	sub.w	BUBXOLD,d0
	bne.s	.B10
	move.w	BUBVX,d0
.B10:
	move.w	d0,d1
	moveq	#$f0,d0
	and.w	BUBX,d0
	subq.w	#1,d0
	move.w	d1,d6
	sf	d6						;and.w	#$ff00,d6
	bpl.s	.B30
	addi.w	#9,d0
	
.B30:
	move.w	d0,BUBX

.NOREALIGNX:												;see if it was an airborne or ground hit
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.GROUNDSMACK

.AIRSMACK:												;did he hit hard enought for a smack
	move.w	BUBVX,d0
	bpl.s	.B32
	neg.w	d0
	
.B32:
	cmp.w	#AIRSMACKVX,d0
	bCS.s	.NOAIRSMACK

	move.L	#SMACKANIMATION,d0									;we hit hard enough
	bsr	STARTANIMATION

	and.b	#~SPINFLAG,BUBSYFLAGS1
	clr.w	BUBVY
	
	move.b	BUBSYFLAGS,d0
	and.b	#~BUBSYHFLIP,d0
	tst.w	BUBVX
	bpl.s	.B32A
	or.b	#BUBSYHFLIP,d0
	
.B32A:
	move.b	d0,BUBSYFLAGS
	moveq	#AIRSMACKSTATE,d6
	bra.s	.B50

.NOAIRSMACK:											;no smack, just a stop. he can con|inue in the state he is
	clr.w	BUBVX										;in but we will halt his horzontal movement
	rts

.GROUNDSMACK:											;he is on the ground. did he hit hard enough for a smack
	move.w	BUBVX,d0
	bpl.s	.B31
	neg.w	d0
	
.B31:
	cmp.w	#SMACKVX,d0
	bCS.s	.NOSMACK

.DOSMACK:
	and.b	#~SPINFLAG,BUBSYFLAGS1
	move.L	#SMACKANIMATION,d0
	bsr	STARTANIMATION
	
	moveq	#HITWALLSOUND,d0
	JSR	STARTSOUND

	moveq	#SMACKSTATE,d6
	bra.s	.B50

.NOSMACK:
	moveq	#PUSHSTATE,d6

.B50:
	move.b	d6,BUBSTATE
	clr.w	BUBVX
;	rts
.NOWALL:												;there was no wall collision near his feet, now let's bound him
	rts

;;;ASBx: ;************************************************************************


;;;ASBx: ;************************************************************************
;;;ASBx: ;*					 				*
;;;ASBx: ;*	BUBSY STATES			 				*
;;;ASBx: ;*					 				*
;;;ASBx: ;************************************************************************
;;;ASBx: 
;;;ASBx: ;************************************************************************
	
;;;ASBx: ;************************************************************************
;;;ASBx: ;*	IDLE STATES			 				*
;;;ASBx: ;************************************************************************
;;;ASBx: ;************************************************************************


;;;ASBx: ;************************************************************************
BUBIDLE:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.ALIVE

	moveq	#FALLBACKSTATE,d0
	bra	KILLBUBSY

.ALIVE:													;if object and objgrav > $f 45
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.NOTONOBJ1

	moveq	#$1f,d0
	and.w	BUBOBJGRAV,d0
	cmp.w	#$B,d0
	bcs.s	.NOTONOBJ1

	move.b	#RUNSTATE,BUBSTATE
	bra	BUBRUN

.NOTONOBJ1:												;see if he should be sliding
	move.w	BUBX,d1
	move.w	BUBY,d2											;check for water attribute
	JSR	GETATTRIB

	move.w	#WATER,d1
	and.w	d1,d0
	beq.s	.NO_WATER

	or.w	#$00015,BUBY
	
.FINDSURFACE:
	move.w	BUBX,d1
	move.w	BUBY,d2
	sub.w	#16,d2
	move.w	d2,BUBY

	JSR	GETATTRIB

	and.w	#WATER,d0
	bne.s	.FINDSURFACE

	MOVE.B	#SPLASHSTATE,BUBSTATE
	clr.w	BUBVY
	addq.w	#2,BUBY
	rts
	
.NO_WATER:
	and.b	#~SPINFLAG,BUBSYFLAGS1								;must not be sliding

	move.w	BUBX,TEMP4									;determine if he should balance or idle
	move.w	BUBY,TEMP5

	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0									;if on obj no knocking
	beq.s	.NOTONOBJ

	move.L	#IDLEOBJANIMATION,d0
	bsr	STARTANIMATION
	bra	.B00

.NOTONOBJ:
.CHECKRIGHT:
	move.w	BUBX,d0
	addi.w	#12,d0
	move.w	d0,BUBX
	bsr	STICKOBJECTTOPLAYFIELD

	move.w	BUBY,d0
	sub.w	TEMP5,d0
	bmi.s	.CHECKLEFT
	cmp.w	#FALLHEIGHT,d0
	bge.s	.BALANCERIGHT

.CHECKLEFT:
	move.w	TEMP4,d0
	subi.w	#12,d0
	move.w	d0,BUBX
	move.w	TEMP5,BUBY
	bsr	STICKOBJECTTOPLAYFIELD

	move.w	BUBY,d0
	sub.w	TEMP5,d0
	bmi.s	.IDLE
	
	tst.b	in_water
	bne.s	.IDLE
	cmp.w	#FALLHEIGHT,d0
	blt.s	.IDLE

.BALANCELEFT:
	or.b	#BUBSYHFLIP,BUBSYFLAGS
	bra.s	.BALANCE

.BALANCERIGHT:
	and.b	#~BUBSYHFLIP,BUBSYFLAGS

.BALANCE:
	move.L	ANIMSCRPTR,d0
	cmp.L	#BALANCEANIMATION,d0
	beq.s	.B00
	cmp.L	#BALANCE1ANIMATION,d0
	beq.s	.B00

	moveq	#2,d0
	and.w	STIMER,d0
	move.w	d0,d6
	lea	BALANCETAB,a0
	ASL	#1,D6			
	move.L	0(a0,d6.w),d0
	bsr	STARTANIMATION
	bra.s	.B00

.IDLE:
	move.L	#IDLEANIMATION,d0
	bsr	STARTANIMATION

.B00:													;retrieve orginal bubxy
	move.w	TEMP4,BUBX
	move.w	TEMP5,BUBY

	or.b	#ANCHORFLAG,BUBSYFLAGS									;anchor him none the less
	move.w	STICK,d0										;move, but don't if edge of matt
	and.w	#CTRL_RIGHT,d0
	beq.s	.B10
	move.w	BUBX,d0
	cmp.w	BUBXMAX,d0
	bge.s	.B10

	move.b	#RUNSTATE,BUBSTATE
	rts

.B10:
	move.w	STICK,d0
	and.w	#CTRL_LEFT,d0
	beq.s	.B11
	move.w	BUBXMIN,d0
	cmp.w	BUBX,d0
	bge.s	.B11

	move.b	#RUNSTATE,BUBSTATE
	rts

.B11:
	move.w	STICK,d0
	and.w	#CTRL_UP,d0
	beq.s	.B12

	MOVE.L	WARPLIST,a0
	
.CHECKWARPLIST:
	move.w	0(a0),d0
	bmi.s	.NOWARP

	sub.w	BUBX,d0
	bpl.s	.B120
	neg.w	d0
	
.B120:
	cmp.w	#FIND_WARP_RANGE,d0
	bgt	NEXTWARP	
	
.in_xrange:
	move.w	2(a0),d0
	cmp.w	BUBY,d0
	beq	DOWARP

NEXTWARP	equ	*
	addq.w	#8,a0
	bra.s	.CHECKWARPLIST

.NOWARP:													;fallthru is lookupstate
	move.b	#LOOKUPSTATE,BUBSTATE
	rts

.B12:
	move.w	EDGESTICK,d0
	and.w	#CTRL_DOWN,d0
	beq.s	.B13
	move.b	#LOOKDOWNSTATE,BUBSTATE

.B13:
	rts

DOWARP:
	move.w	(a0),BUBX
	move.b	#61,no_track_window
	move.w	4(a0),d0
	beq	NEXTWARP
	move.w	d0,WARPDEST
	sub.w	BUBX,d0
	move.w	d0,BUBVX

	move.w	6(a0),d0
	move.w	d0,WARPDEST+2
	sub.w	BUBY,d0
	move.w	d0,BUBVY
	move.w	#$200,TEMP4

.FINDV:
	lsr.w	TEMP4
	asl.w	BUBVY
	asl.w	BUBVX
	move.w	BUBVY,d0
	bpl.s	.FV0
	neg.w	d0
	
.FV0:
	cmp.w	#$0a00,d0
	bge.s	.FOUNDV
	move.w	BUBVX,d0
	bpl.s	.FV1
	neg.w	d0
	
.FV1:
	cmp.w	#$0a00,d0
	blt.s	.FINDV

.FOUNDV:													;either VX or VY is great enough to warp by and
	move.w	TEMP4,d0										;temp4 has the number of iteraions to get there
	addq.w	#1,d0											;because a 1 wouldn't move bubsy at all
	move.w	d0,BUBOBJGRAV
	move.b	#WARP1STATE,BUBSTATE

	and.b	#~ANCHORFLAG,BUBSYFLAGS
	or.b	#DEADFLAG,BUBSYFLAGS								;to kill collisions

	clr.w	BUBVX
	clr.w	BUBVY
	move.L	#ENTERANIMATION,d0
	
.NOTW6:
	bra	STARTANIMATION
	
BALANCETAB:
	dc.l	BALANCEANIMATION,BALANCE1ANIMATION

;;;ASBx: ;************************************************************************
BUBEND:
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0									;first wait until bubsy is anchored
	bne.s	.ANCHORED

	move.w	BUBX,d1										;see if he hits the floor
	move.w	BUBY,d2
	JSR	GETATTRIB
	and.w	#ATTR_MASK,d0
	beq.s	.NOFLOOR

	or.b	#ANCHORFLAG,BUBSYFLAGS								;he hit, anchor him and stick him
	bra	STICKOBJECTTOPLAYFIELD	;STICKBUBSYTOPLAYFIELD

.NOFLOOR:
	clr.w	BUBVX
	bra	BUBAPPLYGRAVITY

.ANCHORED:
	and.w	#%0011000000001111,STICK								;filter all non system input

	move.w	BUBX,d0											; if not between 32 and 96 the set stick to
	sub.w	WINDX,d0										;that dir and call bubrun
	cmp.w	#32,d0
	blt.s	.LEFT

	cmp.w	#96,d0
	bge.s	.RIGHT

	move.w	BUBVX,d0
	beq.s	.HOORAY
	bra.s	.INTHERE

.RIGHT:
	or.w	#CTRL_LEFT,STICK
	bra.s	.INTHERE

.LEFT:
	or.w	#CTRL_RIGHT,STICK

.INTHERE:
	bsr	BUBRUN										;do the necessary running

	move.b	#ENDSTATE,BUBSTATE								;restore the true state
	rts

.HOORAY:												;when stopped in range start HOORAY!
	move.L	#HOORAYANIMATION,d0
	bra	STARTANIMATION

;;;ASBx: ;************************************************************************
BUBWARP1:
	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.B10

	move.b	#WARP2STATE,BUBSTATE							;time to warp

	move.w	WARPDEST,BUBX
	move.w	WARPDEST+2,BUBY

.B10:
	rts

;;;ASBx: ;************************************************************************
BUBWARP2:
	move.L	#WARPANIMATION,d0
	bsr	STARTANIMATION

	move.w	WINDX,d0
	sub.w	WINDXOLD,d0
	bne.s	.B10
	
	move.w	WINDY,d0
	sub.w	WINDYOLD,d0
	bne.s	.B10
	
	move.w	WINDX,d0
	sub.w	BUBX,d0
	bpl.s	.xpl
	neg.w	d0
	
.xpl:
	cmp.w	#320,d0
	bgt.s	.B10
	
	move.w	WINDY,d0
	sub.w	BUBY,d0
	bpl.s	.ypl
	neg.w	d0
	
.ypl:
	cmp.w	#280,d0
	bgt.s	.B10
	
	move.w	WINDY,d0
	sub.w	WINDYOLD,d0
	bne.s	.B10
	
	or.b	#ANCHORFLAG,BUBSYFLAGS

	move.b	#WARP3STATE,BUBSTATE
	move.L	#EXITANIMATION,d0
	
.NOTW6:
	bsr	STARTANIMATION
	
.B10:
	rts

;;;ASBx: ;************************************************************************
BUBWARP3:
	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0								;animate
	bne.s	.B10
	
	move.b	#IDLESTATE,BUBSTATE
	and.b	#~DEADFLAG,BUBSYFLAGS

.B10:
	rts

;;;ASBx: ;************************************************************************
BUBREADY:
	jsr	STICKOBJECTTOPLAYFIELD

	move.l	#IDLEANIMATION,d0
	bsr	STARTANIMATION
	move.w	STICK,d0
	and.w	#JOY_ANY+JOY_X+JOY_A+JOY_Y+JOY_B,d0
	beq.s	.B10

	or.b	#TIMEFLAG,GAMEFLAG1
	move.b	#IDLESTATE,BUBSTATE

.B10:
	rts

;;;ASBx: ;************************************************************************
BUBLOOKUP:
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0								;if object and objgrav > $f 45
	beq.s	.NOTONOBJ

	moveq	#$1f,d0
	and.w	BUBOBJGRAV,d0
	cmp.w	#$B,d0
	blt.s	.NOTONOBJ

	move.b	#RUNSTATE,BUBSTATE
	bra	BUBRUN

.NOTONOBJ:											;keep on looking up
	move.w	STICK,d0
	and.w	#CTRL_UP,d0
	bne.s	.B10

	move.b	#IDLESTATE,BUBSTATE
	rts

.B10:
	move.L	#LOOKUPANIMATION,d0
	bsr	STARTANIMATION

OVER2A:	move.w	#$c0,BUBDWYTOP
OVER2B:	move.w	#$c0,BUBDWYBOT
	rts

;;;ASBx: ;************************************************************************
BUBLOOKDOWN:
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0								;if on object and objgrav >$f 45
	beq.s	.NOTONOBJ

	moveq	#$1f,d0
	and.w	BUBOBJGRAV,d0
	cmp.w	#$b,d0
	blt.s	.NOTONOBJ

	move.b	#RUNSTATE,BUBSTATE
	bra	BUBRUN

.NOTONOBJ:
	move.w	STICK,d0
	and.w	#CTRL_DOWN,d0
	bne.s	.B10

	move.b	#47,BUBSYFRAME
	move.b	#IDLESTATE,BUBSTATE
	rts

.B10:
	move.L	#DUCKANIMATION,d0
	bsr	STARTANIMATION

	cmp.b	#46,BUBSYFRAME
	bne.s	.B20

	move.w	#$38,BUBDWYTOP
	move.w	#$38,BUBDWYBOT

.B20:
	rts

;;;ASBx: ;************************************************************************
BUBCATFIGHT:
	move.L	#CATFIGHTANIMATION,d0
	bsr	STARTANIMATION

	cmp.b	#$ef,ANIMTIMER								;wait for animation to stop
	bne.s	.B10

.GETOUT:
	move.b	#JUMPSTATE,BUBSTATE
	and.b	#~ANIMFLAG,BUBSYFLAGS
	clr.L	ANIMSCRPTR

.B10:
	bra	BUBJUMP

;;;ASBx: ;************************************************************************
BUBAIRSMACK:
	bsr	BUBAPPLYGRAVITY								;apply gravity
	bsr	CLAMPBUBSY

	bsr	CHECKFORLANDNG								;see if we hit the ground.. Note .. If he is hit too
											;high he will splat. If he doesn't fall too far he
	cmp.b	#JUMPLANDSTATE,BUBSTATE							;will do the requested demise
	bne.s	.NOGROUND

	moveq	#SPINFLAG,d0
	and.b	BUBSYFLAGS1,d0
	beq.s	.NOSPIN
	RTS

.NOSPIN:
	move.b	#UNCONCIOUSSTATE,BUBSTATE
	move.L	#UNCONCIOUSANIMATION,d0
	bsr	STARTANIMATION
	
.NOGROUND:
	rts

;;;ASBx: ;************************************************************************
BUBSHAKE:
	move.b	#IDLESTATE,BUBSTATE
	bra	BUBIDLE

;;;ASBx: ;************************************************************************
BUBUNCONCIOUS:
	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.B10
	move.b	#READYSTATE,BUBSTATE
	
.B10:
	cmp.b	#85,BUBSYFRAME
	bne.s	.NOSTART
	cmp.b	#40,ANIMTIMER
	bne.s	.NOSTART

	move.l	A5,-(a7)
	move.w	#$7fff,d6
	JSR	FINDFREEOBJ
	bcs.s	.NOCANDO

	move.w	#$7ffe,OBJKEY(A5)

	move.l	#BIRDSAI,OBJAI(A5)								;set up birds AI
	move.L	#BIRDS1,OBJINITDMA(A5)
	move.l	#BIRDSMAP,OBJMAP(a5)

	moveq	#24,d6									;set up x,y and OAM0
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.FLIPPED
	moveq	#-24,d6

.FLIPPED:
	move.w	d6,d0
	add.w	BUBX,d0
	move.w	d0,OBJX(A5)
	move.w	BUBY,d0
	sub.w	#40,d0
	move.w	d0,OBJY(A5)

.GOTVRAM:
	or.w	#$E000,D0
	MOVE	D0,OBJOAM0(A5)
	sf	OBJFRAME(A5)

.NOCANDO:
	move.l	(a7)+,A5
	
.NOSTART:
	rts

;;;ASBx: ;************************************************************************
;;;ASBx: ;*	DEMISE STATES			 				*
;;;ASBx: ;************************************************************************

BUBROLLFALL:
	move.L	#HHITANIMATION,d0							;do the animation
	bsr	STARTANIMATION

	or.b	#DEADFLAG,BUBSYFLAGS						;flag his demise

	and.b	#~BUBSYHFLIP,BUBSYFLAGS						;face bubsy forward for backward landng
	tst.w	BUBVX
	bmi.s	.NOFLIP
	or.b	#BUBSYHFLIP,BUBSYFLAGS

.NOFLIP:											;see if he is falling or rolling
	moveq	#ANCHORFLAG,d0
	move.b	BUBSYFLAGS,d0
	beq.s	.FALLING

.ROLLING:										;move bubsy dwon hill
	bsr	GETGRAVITY
	bpl.s	.GPOS

.GNEG:
	neg.w	d0
	move.w	#-$300,BUBVX
	bra.s	.GDONE

.GPOS:
	move.w	#$300,BUBVX

.GDONE:
	cmp.w	#8,d0
	bge.s	.not_on_flat_surface
;	and.w	#ATTR_MASK,d1
;	cmp.w	#ATTR_WHAT,d1								;first 30 degrees
;	bge.s	.NOTBOTTOM
;
	move.L	#UNCDEMISEANIMATION,d0
	bsr	STARTANIMATION
	move.b	#UNCDEMISESTATE,BUBSTATE
	
.not_on_flat_surface:
.NOTBOTTOM:
	rts

.FALLING:										;apply gravity
	bsr	BUBAPPLYGRAVITY
	bsr	CLAMPBUBSY

	bsr	CHECKFORLANDNG								;see if we hit the ground. note if he falls too far
	cmp.b	#JUMPLANDSTATE,BUBSTATE
	bne.s	.NOGROUND
	move.b	#ROLLFALLSTATE,BUBSTATE
	
.NOGROUND:
	rts

;;;ASBx: ;************************************************************************

BUBUNCDEMISE:
	or.b	#BUBSYPRIORITY,BUBSYFLAGS							;give him priORITY
	or.b	#%00001010,BUBSYFLAGS								;anchor him down and flag him dead
	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;no scroll

	cmp.b	#85,BUBSYFRAME									;start birds at frame 85 animtimer 40
	bne	.NOSTART
	cmp.b	#40,ANIMTIMER
	bne.s	.NOSTART

	move.l	A5,-(a7)									;start birds and fade
	BRA.s	.NOCANDO			; WWW NO OBJECT STRUCTURES YET
	move.w	#$7fff,d6
	JSR	FINDFREEOBJ
	bcs.s	.NOCANDO

	move.w	#$7ffe,OBJKEY(A5)

	move.l	#BIRDSAI,OBJAI(A5)								;set up birds AI
	move.L	#BIRDS1,OBJINITDMA(A5)

	moveq	#24,d6									;set up x,y and OAM0
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.FLIPPED
	moveq	#-24,d6

.FLIPPED:
	move.w	d6,d0
	add.w	BUBX,d0
	move.w	d0,OBJX(A5)
	move.w	BUBY,OBJY(A5)

.GOTVRAM:
	or.w	#$e000,d0									;flips,palette and priORITY
	move.w	d0,OBJOAM0(A5)
	sf	OBJFRAME(A5)

.NOCANDO:
	move.l	(a7)+,A5

	move.b	#$F8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL

.NOSTART:
	bra	BUBDEAD

;;;ASBx: ;************************************************************************

BUBHITFALL:
	move.L	#HHITANIMATION,d0								;do the animation
	bsr	STARTANIMATION

	or.b	#DEADFLAG,BUBSYFLAGS								;flag his demise

	bsr	BUBAPPLYGRAVITY									;apply gravity
	bsr	CLAMPBUBSY
	move.w	BUBVY,d0
	bpl.s	.NOAPEX
	move.w	BUBY,BUBAPEX

.NOAPEX:												;check for walls
	bsr	SMACKCHECK
	cmp.b	#HITFALLSTATE,BUBSTATE
	bne.s	.NOSMACK

	move.L	#HHITANIMATION,d0								;replay the animation
	bsr	STARTANIMATION
	move.b	#HITFALLSTATE,BUBSTATE

.NOSMACK:											;face bubsy for backwards landng
	and.b	#~BUBSYHFLIP,BUBSYFLAGS
	tst.w	BUBVX
	bmi.s	.NOFLIP
	or.b	#BUBSYHFLIP,BUBSYFLAGS

.NOFLIP:
	bsr	CHECKFORLANDNG								;see if we hit the ground. note. if he is hit
											;too high he wil splat if he doesn't fall too
	cmp.b	#JUMPLANDSTATE,BUBSTATE							;far he will do the requested demise
	bne.s	.NOGROUND

	move.w	BUBX,d1									;bubsy has landed, see if he is on a hill
	move.w	BUBY,d2
	jsr	GETGRAVITY
	tst.w	d0
	bpl.s	.ok1
	neg.w	d0
	
.ok1:
	cmp.w	#8,d0
	bge.s	.GROUND1
	
	moveq	#ROLLFALLSTATE,d6
	bra.s	.DONE

.GROUND1:
	move.b	BUBSYDEMISE,d6								;do demise

.DONE:
	move.b	d6,BUBSTATE

.NOGROUND:
	rts

;;;ASBx: ;************************************************************************


;;;ASBx: ;************************************************************************
BUBSQUISH:
	move.L	#SQUISHANIMATION,d0
	bsr	NEWANIMATION

	or.b	#BUBSYPRIORITY,BUBSYFLAGS							;give him priORITY
	clr.w	BUBVY									;hold him still
	or.b	#%00001010,BUBSYFLAGS							;anchor him down and flag him dead
	and.b	#~SPINFLAG,BUBSYFLAGS1							;no spin
	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;no scroll

	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0								;see if it is time to walk
	bne.s	.NOTYET

	move.w	BUBVX,d0									;time to start walking if we should
	beq.s	.NOWALK

.STARTWALK:
	move.b	#ACCORDIANSTATE,BUBSTATE
	move.L	#ACCORDIANANIMATION,d0
	bra	STARTANIMATION

.NOWALK:												;no walk, fade and go be dead
	move.b	#$f8,FADEDIR
	move.b	#DEADSTATE,BUBSTATE
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL

.NOTYET:
	rts

	move.w	BUBVX,d0									;move him if he is walking
	add.w	BUBX,d0
	move.w	d0,BUBX
	bsr	STICKOBJECTTOPLAYFIELD

.B11:												;see if we should fade
	cmp.b	#73,BUBSYFRAME
	bne.s	.B10
	move.b	#$F8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL

.B10:												;go wait for total death
	bra	BUBDEAD

;;;ASBx: ;************************************************************************
BUBACCORDIAN:
	clr.w	BUBVY									;hold him still
	or.b	#%00001010,BUBSYFLAGS							;anchor him down and flag him dead
	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;no scroll
	or.b	#BUBSYOFFSCREEN,GAMEFLAG0							;flag bubsy off edge of screen

	cmp.b	#68,BUBSYFRAME
	blt.s	.SKIPMOVE

	move.w	BUBVX,d0
	add.w	BUBX,d0
	move.w	d0,BUBX

.SKIPMOVE:
	bsr	STICKOBJECTTOPLAYFIELD
	cmp.b	#73,BUBSYFRAME
	bne.s	.B10
	move.b	#$f8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL

.B10:												;go wait for total death
	bra	BUBDEAD1

;;;ASBx: ;************************************************************************


;;;ASBx: ;************************************************************************
BUBSPLASH:
	move.L	#SPLASHANIMATION,d0								;make sure animation is started
	bsr	NEWANIMATION

	clr.w	BUBVX
	clr.w	BUBVY

	or.b	#DEADFLAG,BUBSYFLAGS							;flag him dead

	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;no scroll, no anchor
	and.b	#~ANCHORFLAG,BUBSYFLAGS

	cmp.b	#$ef,ANIMTIMER
	bne.s	.B10

	moveq	#4,D6
	and.w	STIMER,D6									;choose which drowning now

	lea	.DROWNSTATETAB,a0
	move.L	0(a0,d6.w),d0
	bsr	STARTANIMATION
	move.b	#DROWNSTATE,BUBSTATE

;	move.l	A5,-(a7)									;start bubbles here
;	move.w	#$7fff,d6
;	JSR	FINDFREEOBJ
;	bcs.s	.NOCANDO
;
;	or.w	#$E000,d0	; SEGA								;flips, palette & priORITY
;	move.w	d0,OBJOAM0(A5)
;
;	move.w	#$7ffe,OBJKEY(A5)
;
;	move.l	#BUBBLESAI,OBJAI(A5)							;set bubbles AI vector
;
;	move.L	#BUBBLES0000,OBJINITDMA(A5)
;
;	move.w	BUBX,OBJX(A5)								;set up	x,y and OAM0
;	move.w	BUBY,OBJY(A5)
;	sf	OBJFRAME(A5)
;
;.NOCANDO:
;	move.l	(a7)+,A5

.B10:
	rts

.DROWNSTATETAB:
	dc.l DROWNHATANIMATION,DROWNCOUNTANIMATION

;;;ASBx: ;************************************************************************
BUBDROWN:
	clr.w	BUBVX									;hold him still
	clr.w	BUBVY

	moveq	#%00000011,d0
	and.w	STIMER,d0									;make him drown
	bne.s	.B00
	addq.w	#1,BUBY

.B00:
	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;no scroll, no anchor
	and.b	#~ANCHORFLAG,BUBSYFLAGS

	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0								;wait for animation to stop
	bne.s	.B10

	move.L	#DROWNFEETANIMATION,d0							;start feet and fade
	bsr	STARTANIMATION
	move.b	#DROWNFEETSTATE,BUBSTATE
	move.b	#-8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL

.B10:
	rts

;;;ASBx: ;************************************************************************
BUBDROWNFEET:
	cmp.b	#32,ANIMTIMER								;make him sink 32 frames
	bge.s	.B00
	moveq	#1,d0
	and.w	STIMER,d0
	bne.s	.B10
	addq.w	#1,BUBY
	bra.s	.B10

.B00:
	subq.w	#1,BUBY

.B10:
	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;no scrolling and no anchor
	and.b	#~ANCHORFLAG,BUBSYFLAGS
	bra	BUBDEAD
	
;;;ASBx: ;************************************************************************

BUBDRAIN:
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************
BUBFALLBACK:
	move.L	#FALLBACKANIMATION,d0							;start animation
	bsr	STARTANIMATION
	or.b	#BUBSYPRIORITY,BUBSYFLAGS
	clr.w	BUBVX
	clr.w	BUBVY

;	cmp.b	#1,ANIMTIMER								;wait for animation to start boom
;	bne.s	.B10
;	cmp.b	#134,BUBSYFRAME
;	bne.s	.B10
;	nop			*andy
;.B10:
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************
BUBMELT:
	move.L	#MELTANIMATION,d0								;start of animation
	bsr	STARTANIMATION
	or.b	#BUBSYPRIORITY,BUBSYFLAGS
	clr.w	BUBVX
	clr.w	BUBVY
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************
BUBSPLIT:
	move.L	#SPLITANIMATION,d0								;start of animation
	bsr	STARTANIMATION
	or.b	#BUBSYPRIORITY,BUBSYFLAGS
	or.b	#BUBSYOFFSCREEN,GAMEFLAG0							;flag bubsy off edge of screen

	clr.w	BUBVX
	clr.w	BUBVY
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************

BUBBEHEADED:
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************
BUBSHATTER:
	move.L	#SHATTERANIMATION,d0							;start animation
	bsr	STARTANIMATION

	clr.w	BUBVX
	clr.w	BUBVY

;	cmp.b	#36,BUBSYFRAME
;	bne.s	.B10
;	cmp.b	#40,ANIMTIMER
;	bne.s	.B10
;	nop		*andy
;.B10:
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************

BUBNOTIME:
	move.L	#NOTIMEANIMATION,d0
	bsr	STARTANIMATION
	clr.w	BUBVX
	clr.w	BUBVY
	bra	WAITFORDEATH

;;;ASBx: ;************************************************************************

BUBPOP:
	or.b	#BUBSYPRIORITY,BUBSYFLAGS						;give him priORITY
	or.b	#DEADFLAG,BUBSYFLAGS							;dead
	and.b	#%10111101,BUBSYFLAGS							;no anchor
	and.b	#~SCROLLFLAG,BUBSYFLAGS1						;stop scrolling
	or.b	#BUBSYOFFSCREEN,GAMEFLAG0						;flag bubsy off edge of screen

	move.L	#POPANIMATION,d0
	cmp.L	ANIMSCRPTR,d0
	beq.s	.POP0
	bsr	STARTANIMATION
	move.w	#$E8,BUBOBJGRAV

.POP0:
	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.POP
	rts

.POP:											;if off the right edge start fade
	move.w	BUBX,d0
	sub.w	WINDX,d0
	bmi.s	.LEFTEDGE
	cmp.w	#320,d0
	blt.s	.NOTYET
	
.YET:
	move.b	#$f8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL
	
.NOTYET:
	move.w	BUBY,d0
	sub.w	WINDY,d0
	bmi.s	.yet
	cmp.w	#280,d0
	blt.s	.LEFTEDGE
	
.yet:	
	move.b	#$f8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL

.LEFTEDGE:
	addq.w	#8,BUBOBJGRAV
	move.w	BUBOBJGRAV,d0							;use as angle
	JSR	GETSIN
	asl.w	#3,d0
	addi.w	#$00c0,d0
	move.w	d0,BUBVX
	
	move.w	BUBOBJGRAV,d0
	JSR	GETCOS
	not.w	d0
	asl.w	#3,d0
	subi.w	#$00c0,d0
	move.w	d0,BUBVY

	moveq	#$10,d0
	add.w	BUBOBJGRAV,d0
	asl.w	#3,d0
	and.w	#$700,d0
	asr.w	#8,d0
	move.w	d0,d7
	lea	.POPFRAMES,a0
	move.b	0(a0,d7.w),BUBSYFRAME
	bra	BUBDEAD1

.POPFRAMES:
	dc.b	200,201,202,203,204,205,206,207

;;;ASBx: ;************************************************************************

BUBCONV:
	bra.s	BUBDEAD1										;wait for finished fade out

;;;ASBx: ;************************************************************************

WAITFORDEATH:
	clr.w	BUBVX										;still hold him
	clr.w	BUBVY

	or.b	#%00001010,BUBSYFLAGS								;anchor him down & flag him dead
	and.b	#~SCROLLFLAG,BUBSYFLAGS1							;stop scrolling

	cmp.b	#$ef,ANIMTIMER
	bne.s	.B10

	move.b	#DEADSTATE,BUBSTATE								;make him dead and fade out
	move.b	#$F8,FADEDIR
	moveq	#FADEOUTSOUND,d0
	JSR	STARTSOUNDALL
.B10:
	rts

;;;ASBx: ;************************************************************************

BUBDEAD:
	clr.w	BUBVX									;hold him still
	clr.w	BUBVY

BUBDEAD1:
	and.b	#~SPINFLAG,BUBSYFLAGS1							;lose that spinflag

;	move.b	FADEVAL,d0								;see if it is totally faded
;	and.b	#$f0,d0
;	beq.s	.B10
;	rts

.B10:
	jsr	NEW_OL
	jsr	NEW_OL

	and.b	#$7f,OBJFLAGS(A5)								;wierd but clears vflip
	
	move.b	LIVES,d0
	move.b	#2,d1
	asr.b	#1,d1
	
SETNOLIVES	equ	*
	bcs.s	.bypass	 ;effective noop
	sbcd	d1,d0
	move.b	d0,LIVES
	cmp.b	#$99,d0
	beq.s	.NOLIVES
	
.bypass:
	jmp	PLAYERTURNOVER

.NOLIVES:											;no more lives continue
	subq.b	#1,CONTINUES
	bpl.s	.CONTINUE
	bra	.NOCONTINUE

.CONTINUE:
	bsr	KILLGAME									;do continue screen

	JSR	WVBL

	lea	OBJBASE,A5
	move.w	#$7ffe,OBJKEY(A5)

	st	GAME_OVER_FLAG
	move.l	#CONTINUEAI,OBJAI(A5)							;set up AI vector

	move.w	#$E680,OBJOAM0(A5)							;set up OAM0

	sf	OBJFRAME(A5)								;clear flag

	LEA	CONTINUETEXT,A0
	LEA	STRIPBUF,A1
	MOVE	#CONTINUETEXTLEN,D6
	
.COPYING:
	MOVE.B	(A0)+,(A1)+
	DBRA	D6,.COPYING

	move.l	#STRIPBUF,OBJAUX0(A5)
	
	move.B	#59,OBJAUX6(A5)								;init clock
	move.B	#10,OBJAUX7(A5)

	MOVE.L	#SYSDP,A5

	move.w	WINDX,d0								;position bubsy
	addi.w	#$20,d0
	move.w	d0,BUBX
	move.w	WINDY,d0
	add.w	#$80,d0
	move.w	d0,BUBY

	clr.w	BUBVX									;hold him still
	clr.w	BUBVY
	and.b	#%10111101,BUBSYFLAGS							;clear anchorflag & hflip
	clr.w	BUBXMIN

	move.L	#CONTINUEANIMATION,d0							;make bubsy animate in limbo
	bsr	STARTANIMATION
	move.b	#LIMBOSTATE,BUBSTATE

	clr.w	INVTIMER									;turn off invincibility & shadow
	clr.w	SHADOWTIMER

	move.b	#8,FADEDIR									;fade in
	st	FADEVAL								;andyseed
	sf	FADEDIR								;andyseed

	rts

.NOCONTINUE:											;no more bubsys do game over
	move.l	A5,-(a7)									;see if game over object is alive
	lea	OBJBASE,A5
	moveq	#NUMOBJS,d7

.IO00:
	cmp.l	#GAMEOVERAI,OBJAI(A5)
	bne.s	.IO01

	move.w	#$ffff,CONTINUES								; CONTINUES AND LIVES!
	JMP	PLAYERTURNOVER

.IO01:
	adda.w	#OBJLEN,A5
	subq.w	#1,d7
	bne.s	.IO00
	move.l	(a7)+,A5

	move.b	#LIMBOSTATE,BUBSTATE								;put bubsy in limbo

	move.w	WINDX,d0									;put bubsy off screen
	addi.w	#$200,d0
	move.w	d0,BUBX

	or.b	#BUBSYOFFSCREEN,GAMEFLAG0							;flag bubsy off edge of screen

	bsr	KILLGAME

	JSR	WVBL

	lea	OBJBASE,A5

	move.w	#$7ffe,OBJKEY(A5)

	st	GAME_OVER_FLAG
	move.l	#GAMEOVERAI,OBJAI(A5)								;set up AI vector

	move.w	WINDX,d0									;set up x and y
	addi.w	#256+128,d0
	move.w	d0,OBJX(A5)
	move.w	WINDY,d0
	addi.w	#96,d0
	move.w	d0,OBJY(A5)

	move.w	#$E680,OBJOAM0(A5)								;set up OAM0

	move.b	#$e0,FADEVAL
	move.b	#$0f,FADEDIR
	move.b	#$0f,d0
	jmp	SegaFader

;;;ASBx: ;************************************************************************

BUBLIMBO:
	rts

;;;ASBx: ;************************************************************************
BUBRUN:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.ALIVE
	moveq	#FALLBACKSTATE,d0
	bra	KILLBUBSY

.ALIVE:
	and.b	#~SPINFLAG,BUBSYFLAGS1							;clear spinflag so he can jump

	lea	RUNANIMATION,a0
	move.L	ANIMSCRPTR,d0								;start animation if necessary
	cmp.L	a0,d0
	beq.s	.B00
	cmp.L	#RUNUPANIMATION,d0
	beq.s	.B00
	cmp.L	#RUNDNANIMATION,d0
	beq.s	.B00
	move.L	a0,d0
	bsr	STARTANIMATION

.B00:
	move.w	BUBVX,d0									;set animation speed based on VX
	bpl.s	.B10
	neg.w	d0

.B10:
	moveq	#1,d6
	cmp.w	#$0300,d0
	blt.s	.B40
	addq.w	#1,d6
	cmp.w	#$0800,d0
	blt.s	.B40
	addq.w	#1,d6
	cmp.w	#$0c00,d0
	blt.s	.B40
	addq.w	#1,d6

.B40:
	move.b	d6,ANIMSPEED
	bsr	MOVEPLAYER

	bsr	GETGRAVITY									;set the appropriate base

	addi.w	#$100,d0									;center at $8000
	add.w	BUBAVESLOPE,d0
	move.w	d0,BUBAVESLOPE
	asl.w	#1,d0
	roxr.w	BUBAVESLOPE
	move.w	BUBAVESLOPE,D0

	beq.s	.B60										; if no ground don't mess with frame
	moveq	#4,d6
	cmp.w	#$100+$9,d0									;0=0 1=15 A=30 10=45 34=60
	bge.s	.B62										;if not inclined enough set to normal
	cmp.w	#$100-9,d0
	bge.s	.B61

.B62:												;determine uphill or down hill
	subq.w	#2,d6
	cmp.w	#$100,d0
	blt.s	.INCLINE

.DECLINE:
	subq.w	#2,d6

.INCLINE:											;if running left swap up for down
	move.w	BUBVX,d0
	bpl.s	.B61
	eor.w	#2,d6

.B61:
	lea	RUNANIMATIONTAB,A2
	ASL	#1,D6
	move.L	0(A2,d6.w),ANIMSCRPTR

.B60:												;check for water attribute from getgravity
	move.w	#WATER,d0
	and.w	d1,d0
	beq.s	.NO_WATER

	or.w	#$00015,BUBY
	
.FINDSURFACE:
	move.w	BUBX,d1
	move.w	BUBY,d2
	sub.w	#16,d2
	move.w	d2,BUBY

	JSR	GETATTRIB

	and.w	#WATER,d0
	bne.s	.FINDSURFACE

	MOVE.B	#SPLASHSTATE,BUBSTATE
	clr.w	BUBVY
	addq.w	#2,BUBY
	rts

.NO_WATER:
	rts

RUNANIMATIONTAB:
	dc.l	RUNDNANIMATION,RUNUPANIMATION,RUNANIMATION
;;;ASBx: ;************************************************************************

BUBSKID:
	move.w	BUBX,d1
	move.w	BUBY,d2											;check for water attribute
	JSR	GETATTRIB

	move.w	#WATER,d1
	and.w	d1,d0
	beq.s	.NO_WATER

	or.w	#$00015,BUBY
.FINDSURFACE:
	move.w	BUBX,d1
	move.w	BUBY,d2
	sub.w	#16,d2
	move.w	d2,BUBY

	JSR	GETATTRIB

	and.w	#WATER,d0
	bne.s	.FINDSURFACE

	MOVE.B	#SPLASHSTATE,BUBSTATE
	clr.w	BUBVY
	addq.w	#2,BUBY
	rts

.NO_WATER:
	move.b	#1,ANIMSPEED
	move.L	#SKIDANIMATION,d0
	bsr	STARTANIMATION
	bra	MOVEPLAYER

;;;ASBx: ;************************************************************************

BUBBANANA:
	subq.w	#1,BUBAVESLOPE
	bne.s	.B10
	move.b	#SKIDSTATE,BUBSTATE

.B10:
	move.b	#1,ANIMSPEED
	move.L	#BANANAANIMATION,d0
	bsr	STARTANIMATION

	move.w	BUBVX,d0
	beq.s	.B51
	bmi.s	.B52

	and.b	#~BUBSYHFLIP,BUBSYFLAGS						;VX is positive
	bra.s	.B51

.B52:											;VX is negative
	or.b	#BUBSYHFLIP,BUBSYFLAGS

.B51:
	rts

;;;ASBx: ;************************************************************************

BUBPUSH:
	move.L	#PUSHANIMATION,d0
	bsr	STARTANIMATION

	and.b	#~SPINFLAG,BUBSYFLAGS1						;must not be sliding

	move.w	STICK,d0
	and.w	#JOY_HOR,d0
	bne.s	.B10

.DONEPUSHING:
	move.b	#IDLESTATE,BUBSTATE
	rts

.B10:
	and.w	#CTRL_LEFT,d0
	bne.s	.LEFT

.RIGHT:
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.DONEPUSHING
	bra.s	.PUSHING1

.LEFT:
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.DONEPUSHING

.PUSHING1:
	moveq	#BUBPUSHINGOBJ,d0
	and.b	BUBSYFLAGS1,d0							;see if bubsy pushing object
	bne.s	.ISOBJ

	moveq	#WALLLOOKAHEAD+4,d6							;make sure wall is still there
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.WALLRIGHT
	moveq	#-WALLLOOKAHEAD-4,d6

.WALLRIGHT:
	move.w	d6,d1
	add.w	BUBX,d1
	move.w	BUBY,d2
	subq.w	#1,d2
	JSR	GETATTRIB
	and.w	#WALL_CTRL,d0
	beq.s	.DONEPUSHING

.ISOBJ:											;check for water attribute
	rts

;;;ASBx: ;************************************************************************

BUBJUMP:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0							;zombie fix
	beq.s	.ALIVE
	moveq	#FALLBACKSTATE,d0
	bra	KILLBUBSY

.ALIVE:
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	move.B	d0,TEMP9							;save hflip for later

	move.w	STICK,d0								;move LR in air
	and.w	#CTRL_LEFT,d0
	beq.s	.B10
	subq.w	#JUMPDX,BUBX
	or.b	#BUBSYHFLIP,BUBSYFLAGS
	bra.s	.B11

.B10:
	move.w	STICK,d0
	and.w	#CTRL_RIGHT,d0
	beq.s	.B11
	ADDq.W	#JUMPDX,BUBX
	and.b	#~BUBSYHFLIP,BUBSYFLAGS

.B11:
	move.w	STICK,d0								;this is used to activate glide whenever
	and.W	GLIDEBUTTON,d0
	beq.s	.B12
	or.b	#GLIDEFLAG,BUBSYFLAGS1

.B12:
	bsr	CLAMPBUBSY								;clamp bubsy

	move.w	BUBVY,d0								;going up or down
	bpl.s	.B20

	move.w	STICK,d0								;going up - check for boost on upswing or jump
	and.w	JUMPBUTTON,d0
	beq.s	.B18
	ADD.W	#JUMPBOOST,BUBVY

.B18:											;apply gravity
	bsr	BUBAPPLYGRAVITY
	bsr	CLAMPBUBSY

	move.w	BUBY,BUBAPEX							;set apex of the jump

	move.w	STICK,d0								;this is used to activate glide approaching the apex
	and.w	GLIDEBUTTON,d0
	beq.s	.B12A
	or.b	#GLIDEFLAG,BUBSYFLAGS1

.B12A:
	bsr	CHECKFORLANDINGGOINGUP
	rts

.B20:
	move.b	BUBSYFLAGS1,D1								;jump at apex or in descent - check for glide
	and.b	#~GLIDEFLAG,BUBSYFLAGS1
	moveq	#GLIDEFLAG,D0
	and.B	d1,D0								;jump at apex or in descent - check for glide
	bne.s	.B25
	move.w	EDGESTICK,d0
	and.w	GLIDEBUTTON,d0
	beq.s	.B30

.B25:
	move.b	#GLIDESTATE,BUBSTATE
	bra	BUBGLIDE

.B30:
	cmp.L	#CATFIGHTANIMATION,d0
	beq.s	.AT0
	move.B	#30,BUBSYFRAME
	and.b	#~ANIMFLAG,BUBSYFLAGS

.AT0:
	bsr	CHECKFORLANDNG							;we're supposed to do this if he has landed
	bra	BUBAPPLYGRAVITY							;haven't hit the ground yet !! do gra~ity and exit

;;;ASBx: ;************************************************************************
BUBJUMPLAND:										;this is the jump and land state
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	beq.s	.ALIVE
	moveq	#FALLBACKSTATE,d0
	bra	KILLBUBSY

.ALIVE:
	or.b	#ANCHORFLAG,BUBSYFLAGS						;anchor him
	clr.w	BUBVY								;vertical stop
	move.w	#$100,BUBAVESLOPE						;clear the slope ave reg

	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0							;wait for time to expire
	bne.s	.B10

	bsr	GETGRAVITY								;done squatting, if slope and bubvx are 0 the go idle
	or.w	BUBVX,d0								;otherwise run
	beq.s	.B20
	moveq	#RUNSTATE,d6
	bra.s	.B21

.B20:
	moveq	#IDLESTATE,d6

.B21:											;check for waterslide attrib
.B30:											;he is'nt on a slide now, see if he was on a waterslide
	and.b	#~SPINFLAG,BUBSYFLAGS1
	moveq	#SPINFLAG,D0
	and.B	BUBSYFLAGS1,D0
	beq.s	.B40
	clr.w	BUBVX
	moveq	#SHAKESTATE,d6

.B40:
	move.b	d6,BUBSTATE

.B10:
	rts

BUBGLIDE:										;this is the logic for glide state (duh)
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0								;zombie fix
	beq.s	.ALIVE
	moveq	#FALLBACKSTATE,d5
	bra	KILLBUBSY

.ALIVE:											;disable glide flag for next jump
	and.b	#~GLIDEFLAG,BUBSYFLAGS1
	
	bsr	CLAMPBUBSY

	move.w	STICK,d0								;if they let go of the button, let him fall
	and.w	GLIDEBUTTON,d0
	bne.s	.B00
	move.b	#JUMPSTATE,BUBSTATE
	bra	BUBJUMP

.B00:
	moveq	#BUBSYHFLIP,d0
	and.b	BUBSYFLAGS,d0
	move.b	d0,TEMP9

	move.w	STICK,d0								;handle left and right movement
	and.w	#CTRL_LEFT,d0
	beq.s	.B20
	move.w	BUBX,d0
	subq.w	#GLIDEDX,d0
	move.w	d0,BUBX
	move.w	BUBVX,d0
	bmi.s	.B11
	neg.w	d0
	move.w	d0,BUBVX

.B11:
	or.b	#BUBSYHFLIP,BUBSYFLAGS
	bra.s	.B30

.B20:
	move.w	STICK,d0
	and.w	#CTRL_RIGHT,d0
	beq.s	.B30A
	move.w	BUBX,d0
	addq.w	#GLIDEDX,d0
	move.w	d0,BUBX
	move.w	BUBVX,d0
	bpl.s	.B21
	neg.w	d0
	move.w	d0,BUBVX

.B21:
	and.b	#~BUBSYHFLIP,BUBSYFLAGS
	bra.s	.B30

.B30A:
	tst.w	BUBVX
	beq.s	.B30
	and.b	#~BUBSYHFLIP,BUBSYFLAGS						;face if no button pressed
	tst.w	BUBVX
	bpl.s	.B30
	or.b	#BUBSYHFLIP,BUBSYFLAGS

.B30:											;start animation if not in a take
.AT1:
	move.L	#GLIDEANIMATION,d0
	bsr	STARTANIMATION

.AT0:											;apply gravity
	move.w	WORLD_GLIDEGRAVITY,d0
	add.w	d0,BUBVY

	move.w	BUBY,BUBAPEX							;set apex of jump
	bsr	CLAMPBUBSY
	bra	CHECKFORLANDNG							;see if we should land

WORLD_MAXVY:		dc.w	MAXVY
WORLD_GRAVITY:		dc.w	GRAVITY_CTRL
WORLD_GLIDEGRAVITY:	dc.w	GLIDEGRAVITY

;;;ASBx: ;************************************************************************
;;;ASBx: KILLGAME
;;;ASBx: ; USED TO GET RID OA ALL AI AND KILL COLOR CYCLIING TO ENABLE
;;;ASBx: ; PALETTE DMA
;;;ASBx: ;******************************** INIT OBJCECT VRAM SLOTS

KILLGAME:
	OR.B	#OVERLOFF,VBLANKFLAG	; TURN OFF OVERLAYS
	JMP	INITOBJS										;clear object

BUBSMACK:
	move.L	#SMACKANIMATION,d0
	bsr	NEWANIMATION

	moveq	#ANIMFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.B10

	move.b	#UNCONCIOUSSTATE,BUBSTATE
	move.L	#UNCONCIOUSANIMATION,d0
	bsr	STARTANIMATION

.B10:
	rts

BUBGOLEM:
BUBAROOGA:
BUBFREEZE:
BUBWARP4:
	nop
check:
	illegal
	rts

;************************************************************************
;*	TABLE OF STATE VECTORS	 					*
;************************************************************************
STATEVECTABLE:
	dc.l	BUBSHATTER,BUBCATFIGHT,BUBSMACK,check,BUBREADY
	dc.l	BUBIDLE,BUBRUN,BUBSKID,BUBJUMP,BUBJUMPLAND
	dc.l	BUBGLIDE,BUBDEAD,BUBLOOKUP,BUBLOOKDOWN,BUBSQUISH
	dc.l	BUBPUSH,BUBHITFALL,BUBACCORDIAN,BUBAIRSMACK,BUBUNCONCIOUS
	dc.l	BUBDRAIN,BUBFALLBACK,BUBMELT,BUBSPLIT,BUBBEHEADED
	dc.l	BUBSPLASH,BUBDROWN,BUBDROWNFEET,check,check
	dc.l	check,BUBSHAKE,BUBROLLFALL,BUBUNCDEMISE,BUBWARP1
	dc.l	BUBWARP2,BUBWARP3,check,BUBBANANA,BUBNOTIME
	dc.l	BUBPOP,BUBLIMBO,BUBEND,check,BUBCONV
	dc.l	BUBWARP4,check,check,check,BUBFREEZE
	dc.l	check,check,check,BUBGOLEM,BUBAROOGA

;************************************************************************
;*	ANIMATION SEQUENCES						*
;************************************************************************
JUMPLANDANIMATION:
	dc.b	6,31,AEND
	
JUMPSTARTANIM:
	dc.b	4,25,4,32,AEND
	
RUNNINGJUMPSTARTANIM:
	dc.b	4,25,4,26,8,27,8,28,8,29,1,30,AEND
	
GLIDEANIMATION:
	dc.b	6,26,ALABEL,12,33,12,34,12,35,12,34,ALOOP
	
SKIDANIMATION:
	dc.b	ALABEL,4,20,4,21,4,22,4,23,4,24,ALOOP
	
RUNANIMATION:
	dc.b	ALABEL,8,0,8,1,8,2,8,3,8,4,8,5,8,221,8,222,ALOOP
	
RUNDNANIMATION:
	dc.b	ALABEL,8,96,8,97,8,98,8,99,8,100,8,101,8,223,8,224,ALOOP
	
VHITANIMATION:
	dc.b	8,115,8,116,8,117,8,118
	dc.b	ALABEL,8,136,8,137,8,138,8,139,ALOOP
	
HHITANIMATION:
	dc.b	8,111,8,112,8,113,8,114
	dc.b 	ALABEL,8,139,8,138,8,137,8,136,ALOOP
	
BANANAANIMATION:
	dc.b	ASOUND,BANANASOUND
	dc.b	ALABEL,8,184,8,185,ALOOP
	
CONTINUEANIMATION:
	dc.b	104,8					; 74
	dc.b	15,9,15,8,15,9,15,8,15,9,15,8,15,9,15,8	; 120 15*8
	dc.b	15,11,15,10,15,11,15,10,15,11,15,10	; 90 15*6
	dc.b	10,186,10,187,10,186,10,187
	dc.b	10,188,10,189
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	16,192,10,193,10,194,10,195
	dc.b	10,196,32,197,$F0,197,AEND

NOTIMEANIMATION:
	dc.b	10,186,10,187,10,186,10,187
	dc.b	10,188,10,189
	dc.b	4,190,ALOADSOUND,AROOGHALOAD,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	4,190,4,191
	dc.b	16,192,10,193,10,194,10,195
	dc.b	10,196,32,197,$F0,197,AEND
	
POPANIMATION:
	dc.b	ASOUND,POPSOUND,10,198,10,199,24,200,AEND					; 68 was 8 before
	
RUNUPANIMATION:
	dc.b	ALABEL,8,102,8,103,8,104,8,105,8,106,8,107,8,225,8,226,ALOOP
	
IDLEANIMATION:
	dc.b	100,8,100,8,100,8
	dc.b	ALABEL
	dc.b	15,6,15,7,15,6,15,7,15,6,15,7,15,6,15,7
	dc.b	30,8
	dc.b	15,9,15,8,15,9,15,8,15,9,15,8,15,9,15,8
	dc.b	30,8
	dc.b	15,6,15,7,15,6,15,7,15,6,15,7,15,6,15,7
	dc.b	30,8
	dc.b	15,9,15,8,15,9,15,8,15,9,15,8,15,9,15,8
	dc.b	30,8
	dc.b	8,10,120,12
	dc.b	ALOADSOUND,HELLOLOAD
	dc.b	8,13,ASOUND,SCREENHIT,8,14
	dc.b	8,13,ASOUND,SCREENHIT,8,14
	dc.b	8,13,ASOUND,SCREENHIT,8,14
	dc.b	120,12,8,10
	dc.b	ALOOP
	
IDLEOBJANIMATION:
	dc.b	100,8,100,8,100,8
	dc.b	ALABEL
	dc.b	15,6,15,7,15,6,15,7,15,6,15,7,15,6,15,7
	dc.b	30,8

	dc.b	15,9,15,8,15,9,15,8,15,9,15,8,15,9,15,8

	dc.b	15,11,15,10,15,11,15,10,15,11,15,10
	dc.b	30,8
	dc.b	15,6,15,7,15,6,15,7,15,6,15,7,15,6,15,7
	dc.b	30,8

	dc.b	15,9,15,8,15,9,15,8,15,9,15,8,15,9,15,8

	dc.b	15,11,15,10,15,11,15,10,15,11,15,10
	dc.b	30,8
	dc.b	8,10,120,12,8,10
	dc.b	ALOOP
	
CATFIGHTANIMATION:
	dc.b	8,15,8,17,8,18,8,16,8,19
;	dc.b	8,15,8,17
	dc.b	$F0,15,AEND
	
SHATTERANIMATION:
	dc.b	50,61
	dc.b	ALOADSOUND,YIKESLOAD
	dc.b	50,36
	dc.b	ALOADSOUND,GLASSLOAD
	dc.b	8,37,8,38,8,39,32,40,$F0,40,AEND
	
SMACKANIMATION:
	dc.b	ASOUND,SMASH,8,81,8,82,8,83,8,84,AEND
	
UNCONCIOUSANIMATION:
	dc.b	1,30,9,30
	dc.b	ALOADSOUND,BIRDSLOAD
	dc.b	50,85
	dc.b	8,86,8,87,8,86,8,87,8,86,8,87
	dc.b	8,86,8,87,8,86,8,87,8,86,8,87
	dc.b	8,86,8,87,24,86,24,87
	dc.b	16,88,30,89,10,88,10,89
	dc.b	8,29,8,30,AEND
	
UNCDEMISEANIMATION:
	dc.b	10,30
	dc.b	ALOADSOUND,COOCOOLOAD
	dc.b	50,85
	dc.b	8,86,8,87,8,86,8,87,8,86,8,87
	dc.b	8,86,8,87,8,86,8,87,8,86,8,87
	dc.b	8,86,8,87,24,86,24,87
	dc.b	16,88,30,89,10,88,10,89,10,87,AEND
	
SQUISHANIMATION:
	dc.b	ALOADSOUND,SQUISHLOAD,6,64,60,65,8,66,32,67,AEND
	
ACCORDIANANIMATION2:
	dc.b	8,64,40,67	; FALL INTO ACCORDIAN ANIMATION
	
ACCORDIANANIMATION:
	dc.b	ALABEL
	dc.b	ASOUND,ACCORDIANSOUND
	dc.b	8,68,8,69,8,70
	dc.b	8,71,8,72,8,73
	dc.b	ALOOP
	
PUSHANIMATION:
	dc.b	ALABEL,ASOUND,SCRAPESOUND,8,90,8,91,8,92,8,93,8,94,8,95,ALOOP
	
LOOKUPANIMATION:
	dc.b	1,45,AEND
	
DUCKANIMATION:
	dc.b	8,47,40,48
	
LOOKDOWNANIMATION:
	dc.b	1,46,AEND
	
SPLASHANIMATION:
	dc.b	ALOADSOUND,SPLASHLOAD,8,126,8,127,8,119,$F0,119,AEND
	
DROWNHATANIMATION:
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121
	dc.b	4,120,4,121,4,120,4,121,AEND
	
DROWNCOUNTANIMATION:
	dc.b	32,122,32,123,64,124,AEND
	
DROWNFEETANIMATION:
	dc.b	64,125,AEND
	
PALMSANIMATION:
 	dc.b	40,12,AEND
	
FALLBACKANIMATION:
	dc.b	ALOADSOUND,COOCOOLOAD
	dc.b	50,61,10,133,10,134,ASOUND,SMASH,32,135,$F0,135,AEND
	
VHITNSANIMATION:
	dc.b	ALABEL,8,136,8,137,8,138,8,139,ALOOP
	
LAUGHANIMATION:
	dc.b	ALABEL,12,140,12,141,ALOOP
	
MELTANIMATION:
	dc.b	10,142,10,143,10,142,10,143
	dc.b	10,142,10,143,10,142,10,143
	dc.b	32,144,8,145,8,146,8,147,8,148,32,149,$F0,149,AEND
	
SPLITANIMATION:
	dc.b	16,61,8,150,8,151,8,152,ASOUND,SMASH,32,153,$F0,153,AEND
	
BALANCEANIMATION:
	dc.b	8,162,8,163,8,164,8,163
	dc.b	ALOADSOUND,YEOWLOAD
	dc.b	ALABEL,8,162,8,163,8,164,8,163,ALOOP
	
BALANCE1ANIMATION:
	dc.b	8,165,8,166,8,216,8,166
	dc.b	ALOADSOUND,YIKESLOAD
	dc.b	ALABEL,8,165,8,166,8,216,8,166,ALOOP
	
ENTERANIMATION:
	dc.b	10,172,10,173,10,174,10,175,10,176,10,177,AEND
	
EXITANIMATION:
	dc.b	10,178,10,179,10,180,10,181,10,182,10,183,AEND
	
WARPANIMATION:
	dc.b	10,49,AEND
	
WINANIMATION:
	dc.b	120,8					; 2 SEC					
	dc.b	8,211,8,212,8,211,8,213,8,214,32,215	; 72
	dc.b	8,211,8,212,8,211,8,213,8,214,32,215	; 72
	dc.b 	AEND
	
HOORAYANIMATION:
	dc.b	8,211,8,212,8,211,8,213,8,214,32,215
	dc.b	8,211,8,212,8,211,8,213,8,214,32,215,AEND
	
READYANIMATION:
	dc.b	100,108,ALABEL,8,109,8,110,ALOOP

W1L1LOADANIM:
;	dc.b	$1E,$08,$FD,$0F,$09,$0F,$08,$0F
;	dc.b	$09,$0F,$08,$0F,$0B,$0F,$0A,$0F

	dc.b	$1E,$08,$FD,$0F,$08,$0F
	dc.b	$0B,$0F,$0A,$0F

	dc.b	$0B,$0F,$0A,$0F,$0B,$0F,$0A,$1E
	dc.b	$08,$0F,$06,$0F,$07,$0F,$06,$0F
	dc.b	$07,$0F,$06,$0F,$07,$0F,$06,$0F
	dc.b	$07,$1E,$08,$FE
	
W1L2LOADANIM:
	dc.b	$26,$50,$06,$40
	dc.b	$3C,$41,$FF
	
W1L3LOADANIM:
	dc.b	$4B,$2D,$FD,$0F,$06,$0F,$07,$0F,$06,$0F,$07,$0F,$08
	dc.b	$0F,$09,$0F,$08,$0F,$09,$0F,$0B,$0F,$0A,$0F,$0B,$0F,$0A,$0F,$0B
	dc.b	$0F,$0A,$0F,$06,$0F,$07,$0F,$06,$0F,$07,$0F,$06,$0F,$07,$0F,$06
	dc.b	$0F,$07,$1E,$08,$0F,$09,$0F,$08,$0F,$09,$0F,$08,$0F,$09,$0F,$08
	dc.b	$0F,$09,$0F,$08,$0F,$0B,$0F,$0A,$0F,$0B,$0F,$0A,$0F,$0B,$0F,$0A
	dc.b	$FE
	
W2L1LOADANIM:
	dc.b	$FD,$08,$0F,$08,$11,$08,$12,$08,$10,$08,$13,$FE
	
W2L2LOADANIM:
	dc.b	$30,$3D,$20
	dc.b	$3E,$08,$3F,$0C,$3E,$08,$3F,$78,$3E,$08,$3F,$0C,$3E,$08,$3F,$78
	dc.b	$3E,$08,$3F,$0C,$3E,$08,$3F,$78,$3E,$FF
	
W2L3LOADANIM:
	dc.b	$0F,$2F,$08,$30,$23,$2E
	dc.b	$08,$30,$FF
	
W3L1LOADANIM:
W3L2LOADANIM:
W3L3LOADANIM:
W4L1LOADANIM:
	dc.b	40,45
	dc.b	10,61,10,133,10,134,ASOUND,SMASH,32,135,$F0,135,AEND
	
W4L2LOADANIM:
	dc.b	40,46,ALABEL
	dc.b	4,160,4,161,ALOOP
	
W4L3LOADANIM:
	dc.b	10,142,10,143,10,142,10,143
	dc.b	15,144,8,145,8,146,8,147,8,148,32,149,$F0,149,AEND
	
W5L1LOADANIM:
	dc.b	30,45
	dc.b	ALABEL,8,0,8,1,8,2,8,3,8,4,8,5,ALOOP
	
W5L2LOADANIM:
	dc.b	ALABEL
	dc.b	8,68,8,69,8,70
	dc.b	8,71,8,72,8,73
	dc.b	ALOOP
	
W5L3LOADANIM:
	dc.b	ALABEL,8,15,8,17,8,18,8,16,8,19,ALOOP
	
GAME_OVER_FLAG:
	dc.b	0
	even