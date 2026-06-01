JAM_DROP_INTERVAL	equ	-1
JXOFF	equ	8
JYOFF	equ	1

JAMDROPAI:
	jsr	OBJRANGE
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM
.inrange:
	JSR	CLIPYSMALL
	subq.b	#1,OBJAUX0(a5)
	bne.s	.spawn_drop
	rts
.spawn_drop:
	move.b	#JAM_DROP_INTERVAL,OBJAUX0(a5)
	move.l	a5,a6
	
	move.w	OBJKEY(a6),d6
	add.w	#$0100,d6
	jsr	FINDFREEOBJ
	bcs.s	.no_creation
	
	move.w	d6,OBJKEY(a5)
	move.l	#JAMAI,OBJAI(a5)
	move.l	OBJMAP(a6),OBJMAP(a5)
	move.l	OBJINITDMA(a6),OBJINITDMA(A5)
	sf	OBJFRAME(a5)
	moveq	#JXOFF,d0
	moveq	#JYOFF,d1
	add.w	OBJX(a6),d0
	add.w	OBJY(a6),d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)
	sf	OBJAUX1(a5)

.no_creation:
	move.l	a6,a5
	rts

JDROPYINC	equ	4
JDROPANIM	equ	3

JAMAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL
	
	moveq	#DEADFLAG,d0			; if bubsy is already dead than no collision detection
	and.b	BUBSYFLAGS,d0
	bne.s	.no_collide

	move.w	#$0601,d6
	move.w	#SMASH,d7
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY			;if splatter then melt bubsy

.no_collide:
	move.w	OBJY(a5),-(sp)			;save current y
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	(sp)+,d0
	cmp.w	OBJY(a5),d0
	bge.s	.on_ground
	add.w	#JDROPYINC,d0
	move.w	d0,OBJY(a5)
	jmp	DRAW_COMPLEX_SPRITE		;if not on the grond then update Y pows and draw sprite ELSE

.on_ground:					;landed on ground - do splat anim.
	move.b	OBJAUX1(a5),d0
	addq.b	#1,d0
	cmp.b	#JDROPANIM,d0
	bne.s	.no_wrap
	moveq	#0,d0
	addq.b	#1,OBJFRAME(A5)
	cmp.b	#4,OBJFRAME(A5)
	beq.s	.kill_me

.no_wrap:
	move.b	d0,OBJAUX1(a5)
	JMP	DRAW_COMPLEX_SPRITE

.kill_me:
	jmp	CLEAROBJWVRAM

JAMDROPMAP:
	Soff	0,0,-3,0,-3,6,-3,11,3,0,3,6,3,11
	rept	3
	Soff	0,0,-8,0,-8,4,-8,7,8,0,8,4,8,7
	endr

jamdrop_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
.frame0:
	dc.w	1,0,0,-1
	dc.w	-4,-12,89
.frame1:
	dc.w	1,0,0,-1
	dc.w	-11,-8,90
.frame2:
	dc.w	1,0,0,-1
	dc.w	-17,-14,91
.frame3:
	dc.w	1,0,0,-1
	dc.w	-26,-18,92