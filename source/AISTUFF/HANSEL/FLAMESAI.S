FLAME_TIME	equ	6

.macro	FLAMES_BURN_BUBSY
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide

	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

FLAMESAI:
	jsr	OBJRANGE
	bcc.s	.inrange
	jmp	CLEAROBJWVRAM
.inrange:
	JSR	CLIPYSMALL

	FLAMES_BURN_BUBSY
	
	subq.b	#1,OBJAUX2(a5)
	bpl.s	.just_draw
	move.b	#FLAME_TIME-1,OBJAUX2(a5)
	bchg	#0,OBJAUX0(A5)
.just_draw:
	move.b	OBJAUX0(a5),OBJFRAME(A5)
	jmp	DRAW_COMPLEX_SPRITE
	
flames_dma:
	dc.l	.flame10,.flame11
	dc.l	.flame20,.flame21
	dc.l	.flame30,.flame31
	dc.l	.flame40,.flame41
	dc.l	.flame50,.flame51

.flame10:	dc.w	1,2,9,-1
		dc.w	0,0,97
.flame11:	dc.w	1,2,9,-1
		dc.w	0,0,102

.flame20:	dc.w	1,2,9,-1
		dc.w	0,0,96
.flame21:	dc.w	1,2,9,-1
		dc.w	0,0,101

.flame30:	dc.w	1,2,9,-1
		dc.w	-16,0,95
.flame31:	dc.w	1,2,9,-1
		dc.w	-16,0,100

.flame40:	dc.w	1,2,9,-1
		dc.w	-16,0,94
.flame41:	dc.w	1,2,9,-1
		dc.w	-16,0,99

.flame50:	dc.w	1,2,9,-1
		dc.w	-32,0,93
.flame51:	dc.w	1,2,9,-1
		dc.w	-32,0,98
	
FLAMESMAP:
.l0:
	rept	2
	Soff	0,-32,0,0,0,16,8,16,16,16,16,0,8,0
	endr
.l1:
	rept	2
	Soff	0,-32,0,0,0,16,8,16,16,16,32,0,24,8
	endr
.l2:
	rept	2
	Soff	16,-32,0,0,0,16,16,16,32,16,48,16,48,0
	endr
.l3:
	rept	2
	Soff	16,-32,0,0,0,16,16,16,32,16,48,16,48,0
	endr
.l4:
	rept	2
	Soff	32,-32,0,16,12,16,24,16,36,16,50,16,64,16
	endr
.l5:
	rept	2
	Soff	32,-32,0,16,12,16,24,16,36,16,50,16,64,16
	endr
