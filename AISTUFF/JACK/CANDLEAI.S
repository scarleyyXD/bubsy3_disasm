; candles flickers after a while drops wax to the floor, candle cannot hurt bubsy !

; wax can - melts him , candle drops to the floor at a fixed rate. If a candle
; has a drop going down screen then it cannot activate another will this one is DEAD

CANDLESTICK_WIDTH	equ	32
CANDLE_SPEED		equ	13
CNEWDROP		equ	100
CDROPXOFFR		equ	31
CDROPYOFF		equ	-4+48
CDROPXOFFL		equ	CANDLESTICK_WIDTH-31-16

CDROPYINC		equ	7
CDROPANIM		equ	6

CANDLESTICKAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPY
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#CANDLE_SPEED-1,OBJAUX0(a5)
	move.b	OBJFRAME(a5),d0
	addq.b	#1,d0
	cmp.b	#3,d0
	bne.s	.no_wrap
	moveq	#0,d0
.no_wrap
	move.b	d0,OBJFRAME(a5)
.same_frame	
	sub.b	#1,OBJAUX2(a5)
	bpl.s	.no_new
	move.b	#CNEWDROP,OBJAUX2(a5)
	
	move.l	a5,a6
	
	move.w	#$0100,d6
	add.w	OBJKEY(a5),d6			;unique drop depending upon candlestick
	jsr	FINDFREEOBJ
	bcs	.no_space
	
	sf	OBJOAM0(a5)			;no flip
	move.w	d6,OBJKEY(a5)			;one existant key

	move.l	#CANDLEDROPAI,OBJAI(a5)
	move.l	#candledrop_dma,OBJINITDMA(a5)
	move.l	#CANDLEDROPMAP,OBJMAP(a5)
	
	move.w	OBJX(a6),d0			;get x,y
	move.w	OBJY(a6),d1
	tst.b	OBJOAM0(a6)
	bne.s	.left
	add.w	#CDROPXOFFR,d0
	bra.s	.cont
.left	add.w	#CDROPXOFFL,d0
.cont	add.w	#CDROPYOFF,d1
	move.w	d0,OBJX(a5)
	move.w	d1,OBJY(a5)			;save position relative to the candle stick

.no_space
	move.l	a6,a5
.no_new
	jmp	DRAW_COMPLEX_SPRITE



candlestick_dma
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2

.frame0	dc.w	2,0,+48,16
	dc.w	0,-29,27
	dc.w	19,-43,24

.frame1	dc.w	2,0,+48,16
	dc.w	0,-29,27
	dc.w	19,-43,25
	
.frame2	dc.w	2,0,+48,16
	dc.w	0,-29,27
	dc.w	19,-43,26


CANDLESTICKMAP
	rept	3
	dcb.b	32,0
	endr



CANDLEDROPAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	
	move.w	#$0601,d6
	move.w	#SMASH,d7
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY			;if splatter then melt bubsy
.no_collide
	move.w	OBJY(a5),-(sp)			;save current y
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	(sp)+,d0
	cmp.w	OBJY(a5),d0
	bge.s	.on_ground
	add.w	#CDROPYINC,d0
	move.w	d0,OBJY(a5)
	jmp	DRAW_COMPLEX_SPRITE		;if not on the grond then update Y pows and draw sprite ELSE
.on_ground					;landed on ground - do splat anim.
	move.b	OBJAUX1(a5),d0
	addq.b	#1,d0
	cmp.b	#CDROPANIM,d0
	bne.s	.no_wrap
	moveq	#0,d0
	addq.b	#1,OBJFRAME(A5)
	cmp.b	#4,OBJFRAME(A5)
	beq.s	.kill_me
.no_wrap
	move.b	d0,OBJAUX1(a5)
	JMP	DRAW_COMPLEX_SPRITE
.kill_me
	jmp	CLEAROBJWVRAM




candledrop_dma
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3


.frame0	dc.w	1,0,0,-1
	dc.w	-2,-6,28
	
.frame1	dc.w	1,0,0,-1
	dc.w	-7,-9,29

.frame2	dc.w	1,0,0,-1
	dc.w	-7,-9,30

.frame3	dc.w	1,0,0,-1
	dc.w	-7,-9,31


CANDLEDROPMAP
	dc.w	0,0
	dc.l	0
	dc.w	-2,0,-2,-3,-2,-5
	dc.w	2,0,2,-3,2,-5
	
	rept	3
	dc.l	0,0
	dc.w	-7,0,-8,0,-3,0,3,0,8,0,7,0
	endr