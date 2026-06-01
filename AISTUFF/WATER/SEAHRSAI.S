SEA_HORSE_RATE		equ	4
MAX_SEAHORSE_FRAME	equ	6
MAX_SEAH_STEPS		equ	17
SEA_LOOK_X		equ	9

SEE_HY			equ	10

SEAHORSE_KILL_BUBSY	macro
	move.w	#$0601,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm

SEAHORSEAI
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE
	JSR	CLIPY

	SEAHORSE_KILL_BUBSY

	subq.b	#1,OBJAUX0(A5)
	bpl	.same_frame
	move.b	#SEA_HORSE_RATE-1,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	move.b	#MAX_SEAHORSE_FRAME-1,OBJFRAME(A5)
.no_wrap
	
	subq.b	#1,OBJAUX1(a5)
	bpl.s	.in_table
	move.b	#MAX_SEAH_STEPS-1,OBJAUX1(a5)
.in_table
	moveq	#0,d0
	move.b	OBJAUX1(a5),d0
	add.b	d0,d0
	add.b	d0,d0
	lea	.sea_table(pc),a0
	add.w	d0,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	moveq	#SEA_LOOK_X,d7
	tst.b	OBJOAM0(a5)
	bne.s	.facing_right
	neg.w	d7
	neg.w	d0
.facing_right
	move.w	d0,TEMP1
	move.w	d1,TEMP2

	move.w	OBJX(A5),d1
	add.w	d7,d1
	move.w	d1,TEMP3
	
	move.w	OBJY(A5),d2
	add.w	TEMP2,d2
	
	jsr	GETATTRIB
	move.w	d0,d7


	move.w	TEMP3,d1
	moveq	#+SEE_HY,d2
	add.w	OBJY(A5),d2
	add.w	TEMP2,d2
	jsr	GETATTRIB
	or.w	d0,d7
	
	move.w	TEMP3,d1
	moveq	#-SEE_HY,d2
	add.w	OBJY(A5),d2
	add.w	TEMP2,d2
	jsr	GETATTRIB
	
	or.w	d7,d0
	and.w	#~ATTR_MASK,d0
	beq.s	.just_draw
.turn_direction
	eor.b	#8,OBJOAM0(a5)
	bra.s	.cont
.just_draw
	move.w	TEMP1,d0
	move.w	TEMP2,d1
	add.w	d0,OBJX(A5)
	add.w	d1,OBJY(a5)
.cont	
.same_frame
	jmp	DRAW_COMPLEX_SPRITE

;***********************************************************************
;	table for seahorse movement..
;***********************************************************************

.sea_table
	dc.w	5,0	;0
	dc.w	5,6	;2
	dc.w	5,4	;3
	dc.w	5,0	;4
	dc.w	5,0	;5
	dc.w	5,-4	;6
	dc.w	5,-5	;7
	dc.w	5,-5	;8
	dc.w	-2,-4	;9
	dc.w	-3,-2	;10
	dc.w	-4,4	;11
	dc.w	3,5	;12
	dc.w	3,5	;13
	dc.w	5,4	;14
	dc.w	5,2	;15
	dc.w	5,0	;16
	dc.w	5,-6	;17
	



seahorse_dma
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0

.frame0
	dc.w	3,0,0,0
	dc.w	-24,-43,78
	dc.w	-16,-20,80
	dc.w	-10,-30,83
.frame1
	dc.w	2,0,0,0
	dc.w	-24,-43,78
	dc.w	-16,-20,81
.frame2
	dc.w	3,0,0,0
	dc.w	-24,-44,79
	dc.w	-16,-20,82
	dc.w	-10,-30,83
.frame3
	dc.w	2,0,0,0
	dc.w	-24,-43,78
	dc.w	-16,-20,80
.frame4
	dc.w	3,0,0,0
	dc.w	-24,-43,78
	dc.w	-16,-20,81
	dc.w	-10,-30,83
.frame5
	dc.w	2,0,0,0
	dc.w	-24,-44,79
	dc.w	-16,-20,82

SEAHORSEMAP
	rept	6
	Soff	22,38,0,0,19,1,9,-20,21,-17,35,-30,25,-36
	endr
