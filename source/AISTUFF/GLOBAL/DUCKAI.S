EGGAI:
	move.b	OBJAUX6(a5),d0				;check if egg is splatting
	beq.s	.CHECKRANGE
	bra	.EGGSPLATAI

.CHECKRANGE:							;check if in y range
	move.w	OBJY(a5),d0
	bmi.s	.KILLROCK

	jsr	OBJRANGE					;check if object is too far away from bubsy
	bcc.s	.INRANGE

.KILLROCK:
	jmp	CLEAROBJWVRAM

.INRANGE:							;check if we collided with egg
	jsr	CLIPY
	move.w	OBJAUX4(a5),d0
	beq.s	.DOCOLLISION
	subq.w	#1,OBJAUX4(a5)
	bra.s	.ANIMATE

.DOCOLLISION:
	jsr	EZNOBOPCOLLIDE
	bcc.s	.ANIMATE

	moveq	#SHATTERSTATE,d0				;kill bubsy
	jsr	KILLBUBSY

	moveq	#SPLATSOUND,d0
	jsr	STARTSOUND

	move.b	#10,OBJAUX6(a5)				;start splat anim

.ANIMATE:
	jsr	MOVEOBJECT

	move.w	OBJVY(a5),d0				;should we apply gravity
	beq.s	.CHECKDROP
	addi.w	#50,OBJVY(a5)
	bra.s	.DRAWROCK

.CHECKDROP:							;we are not animating, check if bubsy is aready dead
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.DRAWROCK

	move.w	OBJX(a5),d0					;check if we can drop
	subi.w	#48,d0
	cmp.w	BUBX,d0
	bcc.s	.DRAWROCK
	addi.w	#96,d0
	cmp.w	BUBX,d0
	bcs.s	.DRAWROCK

	move.w	#$0200,OBJVY(a5)				;we can drop set delta y

	moveq	#EGGPOP,d0
	jsr	STARTSOUND

.DRAWROCK:
	jmp	ENEMYOAMS

.EGGSPLATAI:							;check if egg dma is done
	moveq	#DONEFRAME,d0
	and.b	OBJFLAGS(a5),d0
	bne.s	.DMADONE
	move.b	#1,OBJFRAME(a5)
	ori.b	#DONEFRAME,OBJFLAGS(a5)

.DMADONE:
	subq.b	#1,OBJAUX6(a5)
	bne.s	.DRAWROCK
	addq.b	#1,OBJFRAME(a5)
	move.b	OBJFRAME(a5),d0
	cmpi.b	#3,d0
	bne.s	.RESETCOUNTER
	bra	.KILLROCK

.RESETCOUNTER:
	move.b	#10,OBJAUX6(a5)
	bra.s	.DRAWROCK

THROWNEGGAI:
	move.b	OBJAUX6(a5),d0				;check if egg splatting
	bne.s	.EGGSPLATAI

.CHECKRANGE:						;check egg is in y range
	move.w	OBJY(a5),d0
	bmi.s	.KILLROCK

	moveq	#20,d0
	add.w	OBJX(a5),d0
	bmi.s	.KILLROCK

	jsr	OBJRANGE				;check if object is too far from bubsy
	bcc.s	.INRANGE

.KILLROCK:
	jmp	CLEAROBJWVRAM

.INRANGE:						;check if we collided with egg
	move.w	OBJAUX4(a5),d0
	beq.s	.DOCOLLISION
	subq.w	#1,OBJAUX4(a5)
	bra.s	.ANIMATE

.DOCOLLISION:
	jsr	EZNOBOPCOLLIDE
	bcc.s	.ANIMATE

	moveq	#SHATTERSTATE,d0
	jsr	KILLBUBSY

	move.b	#10,OBJAUX6(a5)

.ANIMATE:
	jsr	MOVEOBJECT

	moveq	#%0000000100000000>>8,d0
	and.b	OBJKEY(a5),d0			;check if we droping or throwing
	bne.s	.DROPPEDEGG

	move.w	OBJVY(a5),d0			;apply gravity - thrown
	addq.w	#2,d0
	bra.s	.STOREVY

.DROPPEDEGG:						;appply gravity dropped
	move.w	OBJVY(a5),d0
	addi.w	#25,d0

.STOREVY:
	move.w	d0,OBJVY(a5)

.DRAWROCK:
	jmp	ENEMYOAMS

.EGGSPLATAI:
	move.l	#EGG10000,OBJINITDMA(a5)
	moveq	#DONEFRAME,d0
	and.b	OBJFLAGS(a5),d0
	bne.s	.DMADONE
	move.b	#1,OBJFRAME(a5)
	ori.b	#DONEFRAME,OBJFLAGS(a5)
	
.DMADONE:
	subq.b	#1,OBJAUX6(a5)
	bne.s	.DRAWROCK
	addq.b	#1,OBJFRAME(a5)
	move.b	OBJFRAME(a5),d0
	cmpi.b	#3,d0
	beq.s	.KILLROCK

.RESETCOUNTER:
	move.b	#10,OBJAUX6(a5)
	bra.s	.DRAWROCK