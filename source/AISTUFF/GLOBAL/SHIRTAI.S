SHIRTAI:
	jsr	DOINITIALDMA
	jsr	OBJRANGE
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
	
.INRANGE:
	jsr	CLIPYSMALL
	jsr	ENEMYCOLLIDE
	bcc.s	.NOCOLLIDE

	move.b	OBJAUX0(a5),d0			;issue lives for shirts 1 & 2
	cmpi.b	#2+1,d0
	bge.s	.NOLIFE

	move.b	LIVES,d1
	andi.b	#~FlagX,ccr
	abcd	d1,d0
	move.b	d0,LIVES
	bra.s	.COLDONE
	
.NOLIFE:						;invincibility thing
	move.w	#20*60,d6
	andi.w	#$000f,d0
	cmpi.b	#4,d0
	bne.s	.INV

.SHADOW:
	move.w	d6,SHADOWTIMER
	clr.w	INVTIMER
	bra.s	.COLDONE

.INV:
	move.w	d6,INVTIMER
	clr.w	SHADOWTIMER

.COLDONE:
	moveq	#0,d6
	move.b	OBJAUX0(a5),d6
	move.b	SHIRTSOUNDS(PC,d6.w),d0
	jsr	STARTSOUND
	clr.w	d6
	clr.w	d7
	jsr	FORCEDBOP

.NOCOLLIDE:						;draw number
	move.b	OBJAUX0(a5),d0
	subq.b	#1,d0

	cmp.l	#SHIRT10000,OBJINITDMA(A5)
	beq.s	.not_special_shirt
	subq.b	#2,d0					;was 2 now == 0
	beq.s	.NOTINV
	moveq	#2,d1
	and.w	STIMER,d1
	beq.s	.NOTINV
	subq.b	#1,d0						;dont draw the sprite - flicker..
	
.NOTINV:
.not_special_shirt:
	move.b	d0,OBJFRAME(A5)
	jmp	ENEMYOAMS

SHIRTSOUNDS:
	dc.b	 0,SHIRT1SOUND,SHIRT2SOUND,INVSHIRTSOUND
	dc.b	 0,SHADOWSHIRTSOUND