;format for object is
;	0				.w	oam set for direction as well as flags
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	0				.b	aux0
;	0				.b	aux1
;	0				.b	aux2
;	0				.b	aux3
;	0				.b	flags
;	0				.b	aux4

;	OBJECT	%0000100000000000,SPLIZZAI,spinny_dma,SPLIZZ_MAP,$00,$00,$00,$00,$00,$00			;spinny left
;	OBJECT	%0000000000000000,SPLIZZAI,spinny_dma,SPLIZZ_MAP,$00,$00,$00,$00,$00,$00			;spinny right


;the lizzard sits there and occassionaly blinks his eyes
;when bubsy hits it he will pop

SPLIZZ_WAIT0	equ	200
SPLIZZ_WAIT1	equ	9
SPLIZZ_WAIT2	equ	15
SPLIZZ_WAIT3	equ	5

SPLIZ_RANGE1	equ	80
SPLIZ_RANGE2	equ	140

SPLIZZAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPY				; in range y

	move.w	#$0601,d6			;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	moveq	#0,d1
	move.w	OBJX(A5),d0
	sub.w	BUBX,d0
	bpl.s	.ok
	neg.w	d0
.ok:	cmp.w	#SPLIZ_RANGE1,d0
	blt.s	.in
	addq	#1,d1
	cmp.w	#SPLIZ_RANGE2,d0
	blt.s	.in
	addq	#1,d1
.in:	move.b	d1,OBJFRAME(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE
	
spinny_dma:
	dc.l	.frame_1
	dc.l	.frame_2
	dc.l	.frame_3
.frame_1:
	dc.w	1,-23,-22,46
	dc.w	0,0,77
.frame_2:
	dc.w	1,-23,-22,46
	dc.w	0,0,75
.frame_3:
	dc.w	1,-23,-22,46
	dc.w	0,0,76

SPLIZZ_MAP:
;	x-off.w , y-off.w , pad.l ,6 * collision points(x.w,y.w)
	rept	3
	dc.w	0,0
	dc.l	0
	dc.w	0,-22
	dc.w	22,0
	dc.w	16,-20
	dc.w	-16,-22
	dc.w	-22,0
	dc.w	-16,-22
	endr