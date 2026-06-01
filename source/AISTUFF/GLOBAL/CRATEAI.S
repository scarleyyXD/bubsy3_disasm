YARNCRATEAI:
	jsr	DOINITIALDMA					; check if dma complete
	jsr	OBJRANGE					;check if object is within range
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:							;check if we collided with crate
	jsr	CLIPYSMALL
	jsr	ENEMYCOLLIDE
	bcs.s	.COLLIDED

	jsr	STICKOBJECTTOPLAYFIELD			;stick crate to ground

	tst.b	OBJAUX2(a5)				;we did not collide, check if we are on disintergrate anim
	beq.s	.DRAWFRAME

.COLLIDED:							; use collision routine
	tst.b	OBJAUX3(a5)				;check if we gave bubsy 10 yarns
	bne.s	.AMCOLLIDED

	lea	SCORE+4,a0					;give bubsy 500 points
	lea	D500+4,a1
	and	#~FlagX,ccr
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	
	lea	YARNS+2,a0					;give bubsy 25 yarns
	lea	D25+4,a1
	and	#~FlagX,ccr
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	
	st	OBJAUX3(a5)					;set flag

	moveq	#POPSOUND5,d0
	jsr	STARTSOUND
	
.AMCOLLIDED:
	jmp	CRATEEXPLODE

.DRAWFRAME:
	sf	OBJFRAME(a5)					;get yarn face plate
	jmp	ENEMYOAMS					;get frame for crate ( yes that's right, we draw the crate second to appear first)

BOPAI:
	JSR	DOINITIALDMA					;check if dma complete

	JSR	OBJRANGE					;check if object is too far away
	BCC.s	.INRANGE
	JMP	CLEAROBJWVRAM

.INRANGE:
	JSR	CLIPYSMALL						;check if we are on this explode
	
.STILLABOVE:							;check if we are floating number
	TST.B	OBJAUX2(A5)
	BEQ.s	.CHECKNEXTFRAME
	
.FLOATNUMBER:
	SUBQ.w	#1,OBJY(A5)
	ADDQ.B	#1,OBJAUX2(A5)
	MOVE.B	OBJAUX2(A5),D0
	CMP.B	#80,D0
	BNE.s	.DRAWFRAME

.KILLOBJECT:
	JMP	CLEAROBJWVRAM
	
.CHECKNEXTFRAME:							;check if we can get next frame
	moveq	#%0111,D0
	and.w	STIMER,D0
	BNE.s	.DRAWFRAME

.NEXTFRAME:							;get next frame
	CMP.B	#5,OBJFRAME(A5)
	BEQ.s	.NUMBERSTUFF
	ADDQ.B	#1,OBJFRAME(A5)
	
.DRAWFRAME:							;draw frame for crate
	JMP	ENEMYOAM
	
.NUMBERSTUFF:							;we need to get numbers started
	moveq	#0,d6
	move.b	OBJAUX1(A5),D6
	BEQ.s	.KILLOBJECT
	MOVE.B	d6,OBJFRAME(A5)
	move.b	#1,OBJAUX2(A5)
	move.l	#CRATE10006,OBJINITDMA(A5)
	move.l	#SCOREMAP,OBJMAP(a5)
	jmp	ENEMYOAM

CRATEEXPLODE:
	move.b	OBJAUX1(a5),d0				;disable crate
	bne.s	.BANANAEXPLODE
	move.w	OBJKEY(a5),d0
	jsr	OBJENINDEX
	lea	OBJENFLAGS,a0
	or.b	d0,0(a0,d6.w)

.BANANAEXPLODE:
	sf	OBJFRAME(A5)
	
	ori.b	#1,OBJAUX2(a5)				;see if we can get next frame
	moveq	#%111,d0
	and.w	STIMER,d0
	bne.s	.DRAWFRAME

	move.b	OBJAUX0(a5),d0				;get next frame
	addq.b	#1,d0
	move.b	d0,OBJAUX0(a5)
	move.b	d0,OBJAUX1(a5)

	cmpi.b	#5,d0					;check if done
	bne.s	.REQUESTDMA

	jmp	CLEAROBJWVRAM				;kill crate

.REQUESTDMA:
	moveq	#0,d6
	move.b	OBJAUX0(a5),d6
	asl.w	#2,d6
	move.l	.DATATABLE(pc,d6.w),OBJINITDMA(A5)
	
.DRAWFRAME:							;draw frame for crate
	jmp	ENEMYOAMS

.DATATABLE:	
		dc.l	CRATE10001,CRATE10002
		dc.l	CRATE10003,CRATE10004,CRATE10005

ANVILCRATEAI:
	jsr	DOINITIALDMA

	jsr	OBJRANGE
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL
	jsr	ENEMYCOLLIDE
	bcs.s	.COLLIDED

	jsr	STICKOBJECTTOPLAYFIELD			;stick crate to ground

	move.b	OBJAUX2(a5),d0				;we did not collide, check if we are on disintergrate anim
	beq.s	.DRAWFRAME

.COLLIDED:							;check if sprang bubsy
	move.b	OBJAUX3(a5),d0
	bne.s	.JMPCOLLIDE

	btst	#bANCHORFLAG,BUBSYFLAGS			;check if bubsy on ground
	beq.s	.SPRINGUP

	move.w	BUBX,d0					;we are on the ground,check if we to the left or right
	cmp.w	OBJX(a5),d0
	bcs.s	.SPRINGLEFT

	bset	#bBUBSYHFLIP,BUBSYFLAGS			;we are to the right, force bubsy to fling right
	move.w	#$0800,d0
	bra.s	.STOREVXGROUND

.SPRINGLEFT:							;we are to the left , force bubsy to fling left
	bclr	#bBUBSYHFLIP,BUBSYFLAGS
	move.w	#$f800,d0

.STOREVXGROUND:
	move.w	d0,BUBVX

	move.w	#$f800,d0					;get inital Y velocity for jump
	bra.s	.STOREVY

.SPRINGUP:
	move.w	#$f000,d0					;we are in the air, set bubsy

.STOREVY:
	move.w	d0,BUBVY

	moveq	#BLOWUP1,d0					;explosion sound
	jsr	STARTSOUND

	move.b	#JUMPSTATE,BUBSTATE				; put bubsy in jump state
	andi.b	#%11111000,BUBSYFLAGS
	move.b	#32,BUBSYFRAME

	st	OBJAUX3(a5)				;set flag

.JMPCOLLIDE:
	jmp	CRATEEXPLODE				;use collision routine

.DRAWFRAME:							;get frame for yarn template
	move.b	#10,OBJFRAME(a5)

	jmp	ENEMYOAMS					;get frame for crate ( yes that's right, we draw the scate second to appear first)

PLAINCRATEAI:
PLAINCRATEAI1:
	jsr	DOINITIALDMA
	
	jsr	OBJRANGE
	bcc.s	.INRANGE
	cmp	#$168,d0
	bcs.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:							;call stick routine
	jsr	CLIPYSMALL
	jsr	STICKOBJECTTOPLAYFIELD

	move.b	#6,OBJFRAME(a5)				;frame for computations
	move.w	OBJY(a5),d0
	move.w	d0,OBJAUX0(a5)
	subi.w	#32,d0
	move.w	d0,OBJY(a5)
	jsr	OBJECTISLAND
	move.w	sr,d1
	move.w	OBJAUX0(a5),OBJY(a5)
	move.w	d1,sr
	bcs.s	.JMPDRAWFRAME

	move.b	BUBSYFLAGS,d0				;bubsy is not on crate,check if bubsy is anchored
	andi.b	#ANCHORFLAG,d0
	bne.s	.ALREADYPUSH
	
.JMPDRAWFRAME:
	bra	.DRAWFRAME

.ALREADYPUSH:							;check if bubsy is already pushing the crate
	cmpi.b	#PUSHSTATE,BUBSTATE
	bne.s	.JMPCHECKPUSH
	move.b	OBJFLAGS(a5),d0
	andi.b	#OBJBOPPED,d0
	bne.s	.CHECKPUSHY
	
.JMPCHECKPUSH:
	bra	.CHECKPUSH

.CHECKPUSHY:							;bubsy was pushing the crate,make sure Y range is still valid
	move.w	OBJY(a5),d0					;(in case crate has gone off cliff)
	subi.w	#16,d0
	cmp.w	BUBY,d0
	bcc	.RESETPUSH
	add.w	#32,d0
	cmp.w	BUBY,d0
	bcs	.RESETPUSH

.CHECKRIGHT:							;check if bubsy is pushing right
	move.w	STICK,d0
	andi.w	#JOY_RIGHT,d0
	beq.s	.CHECKLEFT

	move.w	OBJX(a5),d0					;check if we are still in range
	cmp.w	BUBX,d0
	bcs.s	.RESETPUSH
	subi.w	#32,d0
	cmp.w	BUBX,d0
	beq.s	.CHECKWALLR
	bcc.s	.RESETPUSH

.CHECKWALLR:							;check if crate is pushed into wall
	move.w	OBJY(a5),d2
	move.w	OBJX(a5),d1
	addi.w	#16,d1
	move.l	a5,-(a7)
	jsr	GETATTRIB
	move.l	(a7)+,a5
	andi.b	#$40,d0
	beq.s	.SETPUSHRIGHT
	bra.s	.RESETPUSH1

.CHECKLEFT:							;check if pushing left
	move.w	STICK,d0
	andi.w	#JOY_LEFT,d0
	beq.s	.CHECKPUSH

.NOCHECKPUSH:							;check if we are still in range
	move.w	OBJX(a5),d0
	cmp.w	BUBX,d0
	bcc.s	.RESETPUSH
	add.w	#32,d0
	cmp.w	BUBX,d0
	bcs.s	.RESETPUSH
	
	move.w	OBJY(a5),d2					;check if crate is pusheed into wall
	move.w	OBJX(a5),d1
	addi.w	#16,d1
	move.l	a5,-(a7)
	jsr	GETATTRIB
	move.l	(a7)+,a5
	andi.b	#$40,d0
	beq.s	.SETPUSHLEFT
	bra.s	.RESETPUSH1

.RESETPUSH:							;we are not pushing crate, reset flag
	andi.b	#~BUBPUSHINGOBJ,BUBSYFLAGS1
	andi.b	#~OBJBOPPED,OBJFLAGS(a5)

.RESETPUSH1:
	bra	.DRAWFRAME

.SETPUSHRIGHT:							;we are on the left side pushing right,set bubsy
	move.w	OBJX(a5),d0
	addq.w	#1,d0
	move.w	d0,OBJX(a5)
	subi.w	#32,d0
	bra.s	.STOREBUBX

.SETPUSHLEFT:							;we are on the right side pushhing left,set bubsy
	move.w	OBJX(a5),d0
	subq.w	#1,d0
	move.w	d0,OBJX(a5)
	addi.w	#32,d0

.STOREBUBX:
	move.w	d0,BUBX
	bra	.DRAWFRAME

.CHECKPUSH:							;bubsy is not on crate, check if bubsy is within y range
	move.w	OBJY(a5),d0
	subi.w	#16,d0
	cmp.w	BUBY,d0
	bcc.s	.RESETPUSH
	addi.w	#32,d0
	cmp.w	BUBY,d0
	bcs.s	.RESETPUSH

	move.b	BUBSYFLAGS,d0				;check which direction we are running
	andi.b	#%01000000,d0
	bne.s	.RUNNINGLEFT

	move.w	OBJX(a5),d0					;we are running right, see if we have hit the left edge of the box
	cmp.w	BUBX,d0
	bcs.s	.JMPRESETPUSH
	subi.w	#16+16,d0
	cmp.w	BUBX,d0
	bcc.s	.JMPRESETPUSH

	move.w	d0,BUBX					;we have hit the left edge of box,stop bubsy
	clr.w	BUBVX

	move.b	#IDLESTATE,BUBSTATE				;put him in idle state ( is he really pushing, will put in pushstate later)

	move.w	STICK,d0					;check if we need push frames
	andi.w	#JOY_RIGHT,d0
	beq.s	.DRAWFRAME
	bra.s	.MAKEPUSH

.RUNNINGLEFT:							;we are running left,see if we have hit right edge of box
	move.w	OBJX(a5),d0
	cmp.w	BUBX,d0
	bcs.s	.NORESETPUSH

.JMPRESETPUSH:
	bra	.RESETPUSH

.NORESETPUSH:
	addi.w	#32,d0
	cmp.w	BUBX,d0
	beq.s	.JMPRESETPUSH
	bcs.s	.JMPRESETPUSH

	move.w	d0,BUBX						;we have hit right edge,stop bubsy
	clr.w	BUBVX

	move.b	#IDLESTATE,BUBSTATE				;put him in idle state ( is he really pushing, will put in pushstate later)

	move.w	STICK,d0					;check if we need push frames
	andi.w	#JOY_LEFT,d0
	beq.s	.DRAWFRAME

.MAKEPUSH:							;make bubsy push the box
	move.b	BUBSYFLAGS,d0
	andi.b	#DEADFLAG,d0
	bne.s	.DRAWFRAME
	move.b	#PUSHSTATE,BUBSTATE
	ori.b	#BUBPUSHINGOBJ,BUBSYFLAGS1
	ori.b	#OBJBOPPED,OBJFLAGS(a5)

.DRAWFRAME:							;get frame for crate (yes that's right, we draw crate second to appear first)
	move.b	#8,OBJFRAME(a5)					;frame to draw
	jmp	ENEMYOAMS

D25:	dc.l	$00000025
D500:	dc.l	$00000500