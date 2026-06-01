TACKCRATEAI:
	jsr	DOINITIALDMA

	jsr	OBJRANGE
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL
	jsr	ENEMYCOLLIDE
	bcs.s	.STARTPOP

	move.b	OBJAUX0(a5),d0				;are we already popping
	bne	.POPPING

.NOPOP:								;are we waiting for pop to start
	move.b	OBJFLAGS(a5),d0
	andi.b	#DONEFRAME,d0
	bne.s	.NOFRAME

	jsr	STICKOBJECTTOPLAYFIELD			;make sure we are on the ground

.DRAWCRATE:							;get frame for tack template
	move.b	#3,OBJFRAME(a5)
	jmp	ENEMYOAMS

.STARTPOP:							;we want to start pop, are we already popping.
	move.b	OBJAUX0(a5),d0
	bne	.POPPING

	move.l	#TACKS10000,OBJINITDMA(a5)
	clr.w	OBJFRAMECTR(a5)
	bra.s	.FRAME

.NOFRAME:
	subq.w	#1,OBJFRAMECTR(a5)
	bne.s	.DRAWCRATE
	
.FRAME:
	andi.b	#~DONEFRAME,OBJFLAGS(a5)
	move.l	#TACKMAP,OBJMAP(a5)				;start animation going

	MOVE.w	#SCRKEY,D7					;ready to find crate's script
	MOVE.L	#SCRIPT,A0
	
.LOOKING:							;now loop until we find script entry
	ADDQ	#6,D7	; SCRLEN
	MOVE	OBJKEY(A5),D0
	CMP	(A0,D7.W),D0
	BNE.s	.LOOKING
	ADD	#$0100,(A0,D7.W)

	move.w	OBJX(a5),d4					;we need to acivate explosion, save x and y
	move.w	OBJY(a5),d5

	move.l	a5,-(a7)

	move.w	#$3fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.RESTOREDP

	move.w	#$7ffe,OBJKEY(a5)

	move.l	#BOPAI,OBJAI(a5)				;set up explosion AI and initial dma vector
	move.l	#CRATE10006,OBJINITDMA(a5)
	sf	OBJAUX2(a5)
	sf	OBJFRAME(a5)
	ori.b	#OBJBOPPED,OBJFLAGS(a5)

	move.w	d4,OBJX(a5)					;set up x and y
	move.w	d5,OBJY(a5)

.RESTOREDP:
	move.l	(a7)+,a5
	move.b	#1,OBJAUX0(a5)
	move.l	#TACKS10000,OBJINITDMA(a5)

.POPPING:
	moveq	#%111,d0
	and.w	STIMER,d0
	bne.s	.DRAWFRAME

	addq.b	#1,OBJAUX0(a5)
	move.b	OBJAUX0(a5),d0
	cmpi.b	#6,d0
	bne.s	.NOFRAME2
	move.l	#TACKGROUNDAI,OBJAI(a5)			;force groundtack AI
	bra.s	TACKGROUNDAI
	
.NOFRAME2:
	move.b	OBJAUX0(a5),d0
	subq.b	#1,d0
	move.b	d0,OBJFRAME(a5)

.DRAWFRAME:
	jmp	ENEMYOAM

TACKGROUNDAI:
	jsr	DOINITIALDMA

	jsr	OBJRANGE
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL
	jsr	EZNOBOPCOLLIDE
	bcc.s	.NOCOLLIDE

	move.w	INVTIMER,d0
	bne.s	.NOCOLLIDE

	move.w	d0,BUBVY
	move.w	d0,BUBVX
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY

.NOCOLLIDE:								;stick object to the ground
	jsr	STICKOBJECTTOPLAYFIELD
	move.b	#4,OBJFRAME(a5)
	jmp	ENEMYOAMS