BANANACRATEAI:
	jsr	DOINITIALDMA			; check if dma complete
	jsr	OBJRANGE			; check if object is too far from bubsy
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:					;check if we collided with crate
	jsr	CLIPYSMALL

	jsr	ENEMYCOLLIDE
	bcs.s	.STARTPOP

	move.b	OBJAUX5(a5),d0
	bne	.JMPPOPPING
	
.STICK:						;stick crate to ground
	jsr	STICKOBJECTTOPLAYFIELD

	moveq	#DONEFRAME,d0
	and.b	OBJFLAGS(a5),d0		;are we waiting for dma to finish
	bne.s	.NOFRAME

	move.b	#1,OBJFRAME(a5)
.DRAWFRAME:
.JMPDRAWFRAME:					;get frame for banana faceplate
	jmp	ENEMYOAMS			;get frame for crate ( Yes, that's right, we draw crate second to appear first )

.STARTPOP:					;we want to request dma, have we already?
	move.b	OBJAUX5(a5),d0
	bne	.JMPPOPPING

	move.l	#BANANA0000,OBJINITDMA(a5)	;request dma
	clr.w	OBJFRAMECTR(a5)			;store number of frames until it is safe
	bra.s	.FRAME
.NOFRAME:					;see if it is time for frame change
	subq.w	#1,OBJFRAMECTR(a5)
	bne.s	.JMPDRAWFRAME
.FRAME:
	andi.b	#DONEFRAME,OBJFLAGS(a5)


	move.b	#BANANASTATE,BUBSTATE		;force bubsy to slip on banana
	ori.b	#ANCHORFLAG,BUBSYFLAGS
	move.w	#45,BUBAVESLOPE
	clr.w	BUBVY

	move.l	#BANANAMAP,OBJMAP(a5)		;start animation going

	MOVE.w	#SCRKEY,D7			;get ready to find crate's script entry
	MOVE.L	#SCRIPT,A0
.LOOKING:
	ADDQ	#6,D7				;now, loop until we find script entry
	MOVE.w	OBJKEY(A5),D0
	CMP.w	(A0,D7.W),D0
	BNE.s	.LOOKING
	ADD.w	#$0100,(A0,D7.W)		;force banana crate to be ground bananas
	ADD.w	#$0100,OBJKEY(A5)
	
	move.l	a5,a6				;save direct page for crate

	move.w	#$3fff,d6			;find a free object using bogus key
	jsr	FINDFREEOBJ
	bcs.s	.RESTOREDP


	move.w	#$7ffe,OBJKEY(a5)		;use a bogus key so FINDFREEOBJ won't give this one away

	move.l	#CRATEEXPLODE,OBJAI(a5)		;set up explosion AI and intial DMA vector
	move.l	#CRATE10002,OBJINITDMA(a5)
	move.l	#CRATEMAP,OBJMAP(a5)
	sf	OBJFRAME(a5)
	sf	OBJAUX1(a5)
	sf	OBJAUX0(a5)
	sf	OBJAUX2(a5)
	ori.b	#OBJBOPPED,OBJFLAGS(a5)

	move.w	OBJX(a6),OBJX(a5)			;set up the x and y
	move.w	OBJY(a6),OBJY(a5)

.RESTOREDP:					;pop this thing
	move.l	a6,a5
	move.b	#1,OBJAUX5(a5)
.JMPPOPPING:
.POPPING:
	move.w	OBJX(a5),OBJAUX0(a5)	;store the x and y
	move.w	OBJY(a5),OBJAUX2(a5)

	moveq	#%111,d0
	and.w	STIMER,d0			;check if we can get next frame
	bne.s	.DRAWFRAMEPOP

	addq.b	#1,OBJAUX5(a5)			;get next frame for bananas

.DRAWFRAMEPOP:					;get frame for banana1 (and check if done yet)
	moveq	#0,d6
	move.b	OBJAUX5(a5),d6
	lea	BANANA1A(pc),a0
	move.b	(a0,d6.w),d0
	bpl.s	.NOTOVERYET

	move.l	#BANANAGROUNDAI,OBJAI(a5)	;now force ground banana AI
	clr.w	OBJAUX2(a5)
	bra	BANANAGROUNDAI

.NOTOVERYET:
	move.b	d0,OBJFRAME(a5)		;we are not done, store frame for banana1

	andi.b	#%11100111,OBJOAM0(a5)	;get flipstate
	lea	BANANA1FLIP,a0
	move.b	(a0,d6.w),d0
	eor.b	d0,OBJOAM0(a5)

	moveq	#0,d6
	move.b	OBJAUX5(a5),d6
	asl.w	#1,d6
	lea	BANANA1X,a0
	move.w	(a0,d6.w),d0
	add.w	OBJAUX0(a5),d0
	move.w	d0,OBJX(a5)

	lea	BANANA1Y,a0			;get y offset for banana1
	move.w	(a0,d6.w),d0
	add.w	OBJAUX2(a5),d0
	move.w	d0,OBJY(a5)

	jsr	ENEMYOAMS			;draw banana1

	move.b	OBJAUX5(a5),d6		;get frame for banana2
	lea	BANANA2A,a0
	move.b	(a0,d6.w),OBJFRAME(a5)

	andi.b	#%11100111,OBJOAM0(a5)	;get flip state
	lea	BANANA2FLIP,a0
	move.b	(a0,d6.w),d0
	or.b	d0,OBJOAM0(a5)


	move.b	OBJAUX5(a5),d6		;get x offset for banana2
	asl.w	#1,d6
	lea	BANANA2X(pc),a0
	move.w	(a0,d6.w),d0
	add.w	OBJAUX0(a5),d0
	move.w	d0,OBJX(a5)

	lea	BANANA2Y(pc),a0			;get y offset for banana2
	move.w	(a0,d6.w),d0
	add.w	OBJAUX2(a5),d0
	move.w	d0,OBJY(a5)

	jsr	ENEMYOAMS			;draw banana2

	move.b	OBJAUX5(a5),d6		;get frame for banana3
	lea	BANANA3A(pc),a0
	move.b	(a0,d6.w),OBJFRAME(a5)

	andi.b	#%11100111,OBJOAM0(a5)	;get flipstate
	lea	BANANA3FLIP(pc),a0
	move.b	(a0,d6.w),d0
	or.b	d0,OBJOAM0(a5)

	move.b	OBJAUX5(a5),d6		;get x offset for banana3
	asl.w	#1,d6
	lea	BANANA3X(pc),a0
	move.w	(a0,d6.w),d0
	add.w	OBJAUX0(a5),d0
	move.w	d0,OBJX(a5)

	lea	BANANA3Y(pc),a0			;get y offset for banana3
	move.w	(a0,d6.w),d0
	add.w	OBJAUX2(a5),d0
	move.w	d0,OBJY(a5)

	jsr	ENEMYOAMS			;draw banana3

	move.w	OBJAUX0(a5),OBJX(a5)	;restore x and y
	move.w	OBJAUX2(a5),OBJY(a5)
	rts

;FRAMES
BANANA1A:	dc.b	0,1,1,1,0,1,0,0,1,2,$FF		;
BANANA2A:	dc.b	0,0,1,1,1,0,1,1,1,1		;
BANANA3A:	dc.b	0,0,1,1,0,0,1,0,1,2		;

;FLIP STATE
BANANA1FLIP:	dc.b	0,$00,$08,$00,$00,$08,$10,$00,$08,$08		;
BANANA2FLIP:	dc.b 	0,$00,$00,$08,$00,$00,$08,$00,$08,$00		;
BANANA3FLIP:	dc.b 	0,$10,$00,$08,$10,$00,$08,$10,$00,$00		;

	even
;X OFFSETS
BANANA1X:	dc.w	0,0-5,0-11,0-15,0-17,0-24,0-17,0-17,0-21,0-20	;
BANANA2X:	dc.w	0,13,10,6,4,3,0-2,0-3,0-4,0			;
BANANA3X:	dc.w	0,13,18,22,16,18,23,18,20,22			;

;Y OFFSETS
BANANA1Y:	dc.w	0,0-22,0-40,0-54,0-56,0-47,0-34,0-24,0-15,0	;
BANANA2Y:	dc.w	0,0-46,0-60,0-75,0-81,0-81,0-72,0-61,0-43,0-24	;
BANANA3Y:	dc.w	0,0-20,0-25,0-36,0-49,0-42,0-40,0-29,0-19,0	;
B_RANGE:	dc.w	0

BANANAGROUNDAI:
	moveq	#NEWOBJECT,d0
	and.b	OBJFLAGS(a5),d0		;check if dma is complete
	bne.s	.DONEINIT
	moveq	#%111,d0
	and.w	STIMER,d0
	beq.s	.OKCHECKINIT
	rts
	
.OKCHECKINIT:
	jsr	DOINITIALDMA

.DONEINIT:					;check if object is too far from bubsy
	jsr	OBJRANGE
	bcc.s	.INRANGE

.KILLME:
	andi.b	#$fe,BANANAFLAG
	jmp	CLEAROBJWVRAM

.INRANGE:					;save x and stick to ground
	jsr	CLIPYSMALL
	move.w	d0,B_RANGE
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	OBJX(a5),OBJAUX0(a5)

	move.w	OBJAUX2(a5),d0		;check if we are timing
	beq.s	.NOTIMER
	subq.w	#1,OBJAUX2(a5)
	beq.s	.KILLME

	cmpi.w	#30,d0			;check if we are flickering
	bcc.s	.NOTIMER
	andi.b	#%10,d0
	bne.s	.GETOUTOFHERE

.NOTIMER:					;get banana1
	move.b	#2,OBJFRAME(a5)
	ori.b	#$08,OBJOAM0(a5)

	moveq	#-20,d0
	add.w	OBJAUX0(a5),d0		;get banana 1 x
	move.w	d0,OBJX(a5)
	jsr	ENEMYOAMS

	bsr.s	BANANACOLLIDE		;check if we collided with banana 1

	move.b	#3,OBJFRAME(a5)		;get banana 2
	andi.b	#$f7,OBJOAM0(a5)

	move.w	OBJAUX0(a5),OBJX(a5)	;get banana 2 x
	jsr	ENEMYOAMS

	bsr.s	BANANACOLLIDE		;check if we have collided with banana 2

	move.b	#2,OBJFRAME(a5)		;banana 3

	moveq	#22,d0
	add.w	OBJAUX0(a5),d0		;get banana 3 x
	move.w	d0,OBJX(a5)
	jsr	ENEMYOAMS

	bsr.s	BANANACOLLIDE		;check if we collided with banana 3

.GETOUTOFHERE:					;restore x
	move.w	OBJAUX0(a5),OBJX(a5)
	rts

BANANACOLLIDE:					;get collision
	move.w	B_RANGE(pc),d0
	jsr	ENEMYCOLLIDE
	bcc.s	.RETURN

	move.w	BUBVX,d0			;we collided, check if we are going too fast
	bpl.s	.CHECKVELOCITY
	neg.w	d0

.CHECKVELOCITY:
	cmpi.w	#$280,d0
	bcs.s	.RETURN

	cmpi.b	#BANANASTATE,BUBSTATE	;check if we are already in banana state
	beq.s	.RETURN

	move.b	#BANANASTATE,BUBSTATE	;force bubsy to slip on banana
	ori.b	#ANCHORFLAG,BUBSYFLAGS
	move.w	#60,BUBAVESLOPE		;set time to skid
	clr.w	BUBVY

.RETURN:						;exit out of here
	rts
