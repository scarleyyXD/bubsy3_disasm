BOP_X_RANGE		equ	48
BOP_X_RANGE_BIG		equ	130
BOP_Y_RANGE		equ	160

ENEMYBOP_BIG
	move.w	d7,-(a7)							;save organic state of this enemy a this point
	move.w	d6,-(a7)

	bsr	ENEMYCOLLIDE_BIG							;check for collision
	bcc.s	.NOCOLLIDE

	move.w	INVTIMER,d0							;check if we are invincible
	beq.s	.NOTINVINCABLE

	move.w	(a7)+,d0							;we are invincible,make sure cat fight state is off
	sf	d0
	move.w	d0,-(a7)
	bra	FORCEDBOPCONT

.NOTINVINCABLE									;we collided, check if we are on the ground
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.DIED

	move.w	BUBVY,d0							;chek we are going down
	bpl.s	.BOUNCEUP

.DIED										;we sould die now, we may be a panther
	move.w	SHADOWTIMER,d0
	beq.s	.NOPANTHER
	andi.b	#~FlagC,ccr
.NOCOLLIDE
	move.w (a7)+,d6
	move.w (a7)+,d7
	rts

.NOPANTHER
	addq	#4,sp
	ori.b	#FlagC,ccr
	rts

.BOUNCEUP
	ori.b	#BUBSYBOUNCE,BUBSYFLAGS1					;reverse bubsy's VY
	bra.s	FORCEDBOPCONT


ENEMYBOP
	move.w	d7,-(a7)							;save organic state of this enemy a this point
	move.w	d6,-(a7)

	bsr	ENEMYCOLLIDE							;check for collision
	bcc.s	.NOCOLLIDE

	move.w	INVTIMER,d0							;check if we are invincible
	beq.s	.NOTINVINCABLE

	move.w	(a7)+,d0							;we are invincible,make sure cat fight state is off
	sf	d0
	move.w	d0,-(a7)
	bra.s	FORCEDBOPCONT

.NOTINVINCABLE									;we collided, check if we are on the ground
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.DIED

	move.w	BUBVY,d0							;chek we are going down
	bpl.s	.BOUNCEUP

.DIED										;we sould die now, we may be a panther
	move.w	SHADOWTIMER,d0
	beq.s	.NOPANTHER
	andi.b	#~FlagC,ccr
.NOCOLLIDE
	move.w (a7)+,d6
	move.w (a7)+,d7
	rts

.NOPANTHER
	addq	#4,sp
	ori.b	#FlagC,ccr
	rts

.BOUNCEUP
	ori.b	#BUBSYBOUNCE,BUBSYFLAGS1					;reverse bubsy's VY
	bra.s	FORCEDBOPCONT

FORCEDBOP									;save organic state of this enemy and point value
	MOVE.w	D7,-(SP)
	MOVE.w	D6,-(SP)

FORCEDBOPCONT
	MOVE.w	(SP)+,D0							;check if we need to put bubsy in alternative
	MOVE.w	(SP)+,D7							;state ( like catfight)
	ROR.w	#8,D0
	sf	TEMP5
	MOVE.B	D0,TEMP5+1
	ROR.w	#8,D0
	CMP.B	#0,D0
	BEQ.s	.DONTRETURN
	MOVE.B	D0,BUBSTATE

.DONTRETURN									;explode & get out of here ( don't return to object )
	ADDQ.L	#4,SP
	BRA.s	EXPLODEOBJCONT

EXPLODEOBJ
	CLR.w	TEMP5

EXPLODEOBJCONT
	CMP.B	#0,D7
	BEQ.s	.NOSOUND
	MOVEq	#SMASH,D0
	JSR	STARTSOUND

.NOSOUND
	MOVE	OBJX(A5),D4							;we need to activate explode anim, save x and y
	MOVE	OBJY(A5),D5

	MOVE	OBJOAM0(A5),D0							;save priority of this object
	AND.w	#%1000000000000000,D0	; PRI
	OR.w	#%0110000000000000,D0	; PAL
	MOVE	D0,TEMP6

	move.b	#SECONDSLOT,D0
	and.B	OBJFLAGS,D0							;we bopped an object , kill it
	BEQ.s	.ONESLOT
	MOVE	OBJAUX0(A5),D0
.ONESLOT
	MOVE	OBJKEY(A5),D0
	JSR	OBJENINDEX
	LEA	OBJENFLAGS,A0
	OR.B	D0,(A0,D6.W)
	JSR	CLEAROBJWVRAM

	MOVE.L	A5,-(SP)							;find a free object using a bogus key
	MOVE	#$3FFF,D6							;(object guaranteed since we just cleared one )
	JSR	FINDFREEOBJ

	move.w	TEMP6,OBJOAM0(A5)

	MOVE	#$7FFE,OBJKEY(A5)

	MOVE.L	#BOPAI,OBJAI(A5)						;set up explode AI and initial DMA vector
	MOVE.L	#CRATE10001,OBJINITDMA(A5)
	move.l	#CRATEMAP,OBJMAP(a5)
	MOVE	D4,OBJX(A5)							;set up x , y	and frame
	MOVE	D5,OBJY(A5)
	MOVE.B	#1,OBJFRAME(A5)	

	moveq	#0,d0								;we need to get numbers started
	MOVE.B	TEMP5+1,D0
	BEQ.s	.NOSCORE
	SUBQ	#1,D0
	ADD.w	BOPCOUNT,D0
	
	ASL.w	#1,D0								;derive SCORE
	CMP.w	#36,D0
	BCS.s	.NOSCORECLAMP
	MOVEq	#36,D0
.NOSCORECLAMP
	MOVE	D0,D6
	lea	SCORE+3,a0
	MOVE.w	.SCORETABLE(PC,D6.W),D0

	AND.B	#~%10000,CCR						;add SCORE
	MOVE.B	(a0),D1
	ABCD	D0,D1
	MOVE.B	D1,(a0)
	LSR	#8,D0
	MOVE.B	-(a0),D1
	ABCD	D0,D1
	MOVE.B	D1,(a0)
	sf	D0
	MOVE.B	-(a0),D1
	ABCD	D0,D1
	MOVE.B	D1,(a0)
	MOVE.B	-(a0),D1
	ABCD	D0,D1
	MOVE.B	D1,(a0)

	moveq	#0,d0							;pass along SCORE
	MOVE.B	TEMP5+1,D0
	BEQ.s	.NOSCORE
	ADD.w	BOPCOUNT,D0
	ADDQ	#1,BOPCOUNT
.NOSCORE
	CMP.w	#19,D0
	BCS.s	.STORESCORE
	MOVEq	#19,D0
.STORESCORE
	MOVE.B	D0,OBJAUX1(A5)
	MOVE.L	(SP)+,A5
	RTS

.SCORETABLE
	dc.w	$0100,$0200,$0300,$0400,$0500,$0600
	dc.w	$0700,$0800,$0900,$1000,$1100,$1200
	dc.w	$1300,$1400,$1500
	dc.w	$2000,$3000,$4000,$5000

EZNOBOPCOLLIDE

	cmpi.w	#BOP_X_RANGE,d0							;check if we within x range
	bcs.s	.CHECKSHADOW
	andi	#~FlagC,ccr
	rts

.CHECKSHADOW								;check if we are in shadow state
	move.w	SHADOWTIMER,d0
	beq.s	.CHECKEASY
	andi	#~FlagC,ccr
	rts

.CHECKEASY								;check if we are in easy state
	moveq	#ANCHORFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	CONTCOLLIDE
	move.w	BUBVY,d0
	bmi.s	CONTCOLLIDE
	bra	EZCOLLIDE

NOBOPCOLLIDE

	cmpi.w	#BOP_X_RANGE,d0							;check if we within x range
	bcs.s	.CHECKSHADOW
	rts

.CHECKSHADOW								;check if we are in shadow state
	move.w	SHADOWTIMER,d0
	beq.s	CONTCOLLIDE
	andi.b	#~FlagC,ccr
	rts

NOBOPCOLLIDEBIG

	cmpi.w	#BOP_X_RANGE_BIG,d0							;check if we within x range
	bcs.s	.CHECKSHADOW
	rts

.CHECKSHADOW								;check if we are in shadow state
	move.w	SHADOWTIMER,d0
	beq.s	CONTCOLLIDE
	andi.b	#~FlagC,ccr
	rts


ENEMYCOLLIDE_BIG
	CMP.w	#BOP_X_RANGE_BIG,D0							;check if we are within x range
	BCS.s	CONTCOLLIDE
.fail	AND	#~1,CCR
	RTS


ENEMYCOLLIDE
	CMP.w	#BOP_X_RANGE,D0							;check if we are within x range
	BCS.s	.CHECKEDIT
.BAIL	AND	#~1,CCR
	RTS

CONTCOLLIDE equ *

.CHECKEDIT
	IFNE	EDITME
	moveq	#SCRIPTEDIT,D0						;check if we are in edit state, if so bypass
	and.B	EDITFLAGS,D0
	BNE.s	.BAIL
	ENDC
.CHECKDEAD								;check if we already dead
	moveq	#DEADFLAG,D0
	and.B	BUBSYFLAGS,D0
	BNE.s	.BAIL

	MOVE.w	BUBY,D0							;check if we are within y range
	SUB.w	OBJY(A5),D0
	BPL.s	.CHECKYPOS
	NEG.w	D0
.CHECKYPOS
	CMP.w	#BOP_Y_RANGE,D0
	BCC.s	.BAIL							;out of range ??
	
	MOVE.L	OBJMAP(A5),A0						;get proper bank

	moveq	#0,d7							;get index for collision points of this frame
	MOVE.B	OBJFRAME(A5),D7
	lsl.w	#5,d7
	lea	8(a0,d7.w),a0
	move.l	a1,usp
	bSR.s	.CHECKCOLLIDE						;get first collision
	BCC.s	.CHECKPOINT2
.qrts	RTS

.CHECKPOINT2								;get second collision
	bSR.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT3								;get third collision
	bSR.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT4								;get forth collision
	bSR.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT5								;get fifth collision
	bSR.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT6								;get sixth collision

.CHECKCOLLIDE
	MOVE.w	OBJX(A5),D3						;find absolute x position ( no h-flip )
	moveq	#$08,D0
	and.b	OBJOAM0(A5),D0						;begin collision check by finding out if we are h_flipped
	BNE.s	.FINDXFLIP

	ADD.w	(a0)+,D3
	BRA.s	.STOREX

.FINDXFLIP								;find x position ( h-flip)
	SUB.w	(a0)+,D3

.STOREX


	MOVE.w	OBJY(A5),D4						;find y position ( no v-flip)
;	btst	#4,OBJOAM0(a5)						;check if we are v-flipped
;	bne.s	.FINDYVFLIP
;never y flipped
	ADD.w	(a0)+,D4
;	bra.s	.STOREY
;	
;.FINDYVFLIP								;find y position (v-flipped)
;	sub.w	(a0)+,d4
;
.STOREY

.CHECK1BOX
	lea	BUBBOX1,a1
	CMP.w	(a1)+,D3						;check inside of box 1			
	BCS.s	.CHECK2BOX
	CMP.w	(a1)+,D4
	BCS.s	.CHECK2BOX
	CMP.w	(a1)+,D3
	BCC.s	.CHECK2BOX
	CMP.w	(a1)+,D4
	BCC.s	.CHECK2BOX
	OR	#1,CCR							;we are inside box 1, set collision flag (carry bit)
	RTS

.CHECK2BOX
	lea	BUBBOX2,a1
	CMP.w	(a1)+,D3						;check box 2
	BCS.s	.CHECK3BOX
	CMP.w	(a1)+,D4
	BCS.s	.CHECK3BOX
	CMP.w	(a1)+,D3
	BCC.s	.CHECK3BOX
	CMP.w	(a1)+,D4
	BCC.s	.CHECK3BOX
	move.l	usp,a1
	OR	#1,CCR
	RTS

.CHECK3BOX								;check box 3
	lea	BUBBOX3,a1
	CMP.w	(a1)+,D3
	BCS.s	.NOBOXCOLLIDE
	CMP.w	(a1)+,D4
	BCS.s	.NOBOXCOLLIDE
	CMP.w	(a1)+,D3
	BCC.s	.NOBOXCOLLIDE
	CMP.w	(a1)+,D4
	BCC.s	.NOBOXCOLLIDE
	move.l	usp,a1
	OR	#1,CCR
	RTS

.NOBOXCOLLIDE									;we are outside box 3, clear collision flag
	move.l	usp,a1
	AND	#~1,CCR
	RTS

EZCOLLIDE

.CHECKEDIT									;check if we are in edit state, if so bypass
	IFNE	EDITME
	moveq	#SCRIPTEDIT,d0
	and.b	EDITFLAGS,d0
	beq.s	.CHECKDEAD
.BAIL
	andi.b	#~FlagC,ccr
	rts
	ENDC
.CHECKDEAD									;check if we are already dead
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.BAIL

	move.w	BUBY,d0							;check if we are within y range
	sub.w	OBJY(a5),d0
	bpl.s	.CHECKYPOS
	neg.w	d0

.CHECKYPOS
	cmpi.w	#64,d0
	bcC	.BAIL

	moveq	#BUBSYBOUNCE,d0
	and.b	BUBSYFLAGS1,d0						;check if we are rebounding
	bne	.BAIL

	moveq	#0,d7
	move.b	OBJFRAME(a5),d7
	asl.w	#5,d7
	addq.w	#8,d7
	move.l	OBJMAP(a5),a0
	lea	8(a0,d7.w),a0
	move.l	a1,usp
	bsr.s	.CHECKCOLLIDE							;get first collision
	bcs.s	.qrts
.CHECKPOINT2									;get second collison
	bsr.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT3									;get third collision
	bsr.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT4									;get forth
	bsr.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT5									;get fifth
	bsr.s	.CHECKCOLLIDE
	bcs.s	.qrts
.CHECKPOINT6									;and sixth
.CHECKCOLLIDE									;begin collsion by checking if we are H-flipped
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	btst	#3,OBJOAM0(a5)
	bne.s	.FINDXHFLIP

	move.w	OBJX(a5),d0
	add.w	d1,d0
	bra.s	.STOREX

.FINDXHFLIP
	move.w	OBJX(a5),d0
	sub.w	d1,d0
.STOREX
	move.w	d0,d3

	moveq	#$10,d0
	and.b	OBJOAM0(a5),d0						;check if v-flipped
	bne.s	.FINDYVFLIP

	move.w	OBJY(a5),d0
	add.w	d2,d0
	bra.s	.STOREY

.FINDYVFLIP
	move.w	OBJY(a5),d0
	sub.w	d2,d0
.STOREY
	move.w	d0,d4

.CHECK1BOX									;check inside box 1
	lea	BUBBOX1,a1
	cmp.w	(a1)+,d3
	bcs.s	.CHECK2BOX
	cmp.w	(a1)+,d4
	bcs.s	.CHECK2BOX
	cmp.w	(a1)+,d0
	bcc.s	.CHECK2BOX
	cmp.w	(a1)+,d0
	bcc.s	.CHECK2BOX
	move	usp,a1
	ori.b	#FlagC,ccr							;yes
	rts
	IFEQ	EDITME
.BAIL
	ENDC
.CHECK2BOX									;check inside box 2
	move	usp,a1
	andi.b	#~FlagC,ccr
.qrts	rts

OBJECTISLAND

	IFNE	EDITME
	moveq	#SCRIPTEDIT,d0
	and.b	EDITFLAGS,d0						;check if we are in edit state, if so bypass
	bne.s	.TOTALBYPASS
	ENDC
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.TOTALBYPASS

	moveq	#GETOFFME,d0
	and.b	OBJFLAGS(a5),d0						;check if bubsy is already on this object
	bne.s	.JUMPED
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.BUBNOTONHERE

	move.w	BUBVY,d0						;is he still here, or did he jump
	bmi.s	.JUMPED
	move.w	BUBY,d0
	addq.w	#7,d0
	move.w	d0,BUBY
	bsr	.BUBCOL
	bcs.s	.GETACCEL

.JUMPED									;bubsy jumped, pull ground out and tell object bubsy not on it
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.NOCOL
	andi.b	#~BUBONOBJFLAG,BUBSYFLAGS
	andi.b	#~BUBONMEFLAG,OBJFLAGS(a5)

.NOCOL									;we are off object
	andi.b	#~GETOFFME,OBJFLAGS(a5)

.TOTALBYPASS
	andi.b	#~FlagC,ccr
	rts

.BUBNOTONHERE								;bubsy is not on the object, check if bubsy falling
	move.w	BUBVY,d0
	bmi.s	.NOCOL

	bsr.s	.BUBCOL							;bubsy is falling, did he hit
	bcc.s	.NOCOL

	ori.b	#%00000110,BUBSYFLAGS					;bubsy hit, put hit on object

	clr.w	BUBVY							;stop bubsy's descent

	ori.b	#BUBONMEFLAG,OBJFLAGS(a5)				;flag bubsy as being on this object

.GETACCEL								;we are on object, check if we are dead
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.YESCOL

	clr.w	BUBVY							;get the slope of object
	move.l	OBJMAP(a5),a0
	move.w	0(a0,d7.w),d6
	asl.w	#1,d6
	move.w	.ACCELTABLE(pc,d6.w),d6
	move.w	d6,BUBOBJGRAV
	beq.s	.YESCOL
	
	cmpi.b	#IDLESTATE,BUBSTATE					;put bubsy in run state
	bne.s	.ALREADYRUN
	move.b	#RUNSTATE,BUBSTATE
.ALREADYRUN

.YESCOL									;we are on object
	ori.b	#FlagC,ccr
	rts

;TABLE FOR VALUES OF BUBOBJGRAV
.ACCELTABLE	dc.w	$11,$0F,$0B,$03,$00,$04,$0C,$10,$12


.BUBCOL										;get object attributes
	move.l	OBJMAP(a5),a0
	moveq	#0,d6
	move.b	OBJFRAME(a5),d6
	asl.w	#1,d6
	move.w	d6,d7
	asl.w	#4,d7
	addq.w	#8,d7

	moveq	#%00001000,d0
	and.b	OBJOAM0(a5),d0							;check if object is flipped
	bne.s	.OBJFLIPPED

	move.w	OBJX(a5),d0							; if not flipped, check we are within left range
	sub.w	0(a0,d7.w),d0
	cmp.w	BUBX,d0
	bcc.s	.NOTONOBJECT

	addq.w	#2,d7								;check if we are within right range
	add.w	0(a0,d7.w),d0
	cmp.w	BUBX,d0
	bcs.s	.NOTONOBJECT

	addq.w	#2,d7								;find distance from center point
	bra.s	.FINDALTITUDE

.OBJFLIPPED									;we are flipped, check if we are within right range
	move.w	OBJX(a5),d0
	add.w	0(a0,d7.w),d0
	cmp.w	BUBX,d0
	bcs.s	.NOTONOBJECT

	addq.w	#2,d7								;check if we are within left range
	sub.w	0(a0,d7.w),d0
	cmp.w	BUBX,d0
	bcc.s	.NOTONOBJECT

	addq.w	#4,d7								;find distance from center point

.FINDALTITUDE									;find out which slope we are using
	move.w	0(a0,d7.w),d1
	asl.w	#4,d1

	move.w	BUBX,d0								;find distance from centre point
	sub.w	OBJX(a5),d0
	bpl.s	.POSDISTANCE

	neg.w	d0								;make positive
	move.w	d0,d2

	addi.w	#144,d1								;adjust slope
	move.w	d2,d0
	bra.s	.FINDINDEX

.NOTONOBJECT									;return with signal for off object
	andi.b	#~FlagC,ccr
	rts

.POSDISTANCE									;divide distance by 8 to find gross adjustment
	move.w	d0,d2							;then double for 2byte answer

.FINDINDEX
	lsr.w	#3,d0
	asl.w	#1,d0

	add.w	d1,d0							;find index for tables
	move.w	d0,d6

	move.w	.BIGSLOPES(pc,d6.w),d0						;add gross adjustment to object y
	add.w	OBJY(a5),d0
	move.w	d0,d3

	moveq	#7,d0
	and.w	d2,d0							;get lower 8 to find fine adjustment
	asl.w	#1,d0
	add.w	d1,d0
	move.w	d0,d6

	lea	.LITTLESLOPES(pc),a1					;add fine adjustment to object y
	move.w	0(a1,d6.w),d0
	add.w	d0,d3

	move.w	BUBY,d0							;check if bubsy is an object
	cmp.w	d3,d0
	bcs.s	.NOTONOBJECT
	sub.w	#16,d0
	cmp.w	d3,d0
	bcc.s	.NOTONOBJECT

	move.w	d3,BUBY							;put bubsy on surface of object

	ori.b	#FlagC,ccr							;return with signal for an object
	rts

;TABLE FOR GROSS ADJUSTMENTS TO Y
.BIGSLOPES
	dc.w	0,0-16,0-32,0-48,0-64,0-80,0-96,0-112
	dc.w	0,0-8,0-16,0-24,0-32,0-40,0-48,0-56
	dc.w	0,0-4,0-8,0-12,0-16,0-20,0-24,0-28
	dc.w	0,0-2,0-4,0-6,0-8,0-10,0-12,0-14
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,2,4,6,8,10,12,14
	dc.w	0,4,8,12,16,20,24,28
	dc.w	0,8,16,24,32,40,48,56
	dc.w	0,16,32,48,64,80,96,112

;TABLE FOR GROSS ADJUSTMENTS TO Y (NEGATIVE)
	dc.w	0,16,32,48,64,80,96,112
	dc.w	0,8,16,24,32,40,48,56
	dc.w	0,4,8,12,16,20,24,28
	dc.w	0,2,4,6,8,10,12,14
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0-2,0-4,0-6,0-8,0-10,0-12,0-14
	dc.w	0,0-4,0-8,0-12,0-16,0-20,0-24,0-28
	dc.w	0,0-8,0-16,0-24,0-32,0-40,0-48,0-56
	dc.w	0,0-16,0-32,0-48,0-64,0-80,0-96,0-112

;TABLE FOR FINE ADJUSTMENTS TO Y
.LITTLESLOPES
	dc.w	0,0-2,0-4,0-6,0-8,0-10,0-12,0-14
	dc.w	0,0-1,0-2,0-3,0-4,0-5,0-6,0-7
	dc.w	0,0,0-1,0-1,0-2,0-2,0-3,0-3
	dc.w	0,0,0,0,0-1,0-1,0-1,0-1
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,1,1,1,1
	dc.w	0,0,1,1,2,2,3,3
	dc.w	0,1,2,3,4,5,6,7
	dc.w	0,2,4,6,8,10,12,14

;TABLE FOR FINE ADJUSTMENTS TO Y
	dc.w	0,2,4,6,8,10,12,14
	dc.w	0,1,2,3,4,5,6,7
	dc.w	0,0,1,1,2,2,3,3
	dc.w	0,0,0,0,1,1,1,1
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0-1,0-1,0-1,0-1
	dc.w	0,0,0-1,0-1,0-2,0-2,0-3,0-3
	dc.w	0,0-1,0-2,0-3,0-4,0-5,0-6,0-7
	dc.w	0,0-2,0-4,0-6,0-8,0-10,0-12,0-14


CREATELAND
	IFNE	EDITME
	moveq	#SCRIPTEDIT,d0
	and.b	EDITFLAGS,d0						;check if we are in edit state, if so bypass
	bne.s	.TOTALBYPASS
	ENDC
	moveq	#GETOFFME,d0
	and.b	OBJFLAGS(a5),d0						;check if bubsy is already on this object
	bne.s	.JUMPED
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.BUBNOTONHERE

	move.w	BUBVY,d0							;is he still on or did he jump
	bmi.s	.JUMPED
	bsr	.BUBCOL
	bcs.s	.YESCOL

.JUMPED										;bubsy jumped, pull ground out and tell object bubsy not on it
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.NOCOL
	andi.b	#~BUBONOBJFLAG,BUBSYFLAGS
	andi.b	#~BUBONMEFLAG,OBJFLAGS(a5)


.NOCOL										;we are off object
	andi.b	#~GETOFFME,OBJFLAGS(a5)

.TOTALBYPASS
	andi.w	#~FlagC,sr
	rts

.BUBNOTONHERE									;bubsy is not on object, check if bubsy is falling
	move.w	BUBVY,d0
	bmi.s	.NOCOL

	BSR.s	.BUBCOL							;bubsy is falling ,did he hit
	bcc.s	.NOCOL

.YESCOL										;bubsy hit, put him on object
	move.w	sr,-(a7)
	ori.b	#%00000110,BUBSYFLAGS

	clr.w	BUBVY								;stop bubsys descent

	ori.b	#BUBONMEFLAG,OBJFLAGS(a5)					;flag bubsy as being on this object
	clr.w	BUBOBJGRAV
	move.w	(a7)+,sr
	rts

.BUBCOL										;check we are within left range
	move.w	OBJX(a5),d0
	cmp.w	BUBX,d0
	bcc.s	.NOTONOBJECT

	move.w	TEMP6,d0							;check we are within right range
	cmp.w	BUBX,d0
	bcs.s	.NOTONOBJECT

	move.w	OBJY(a5),d0							;check we are within top range
	subq.w	#1,d0
	cmp.w	BUBY,d0
	bcc.s	.NOTONOBJECT

	addi.w	#16,d0							;check we are within bottom range
	cmp.w	BUBY,d0
	bcs.s	.NOTONOBJECT

	move.l	a0,d0
	add.l	d0,BUBX

	move.w	OBJY(a5),BUBY						; put bubsy on object and set flag
	ori.w	#FlagC,sr
	rts

.NOTONOBJECT									;return with signal for off object
	andi.w	#~FlagC,sr
	rts
