.macro	SHARK_KILL_BUBSY
	move.w	#$0801,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	endm

SHARK_HEAD_OFFSET		equ	-63
SHARK_BASE_OFFSET		equ	2

SHARK_KILL_TIMER		equ	7
SHARK_X_DIVE			equ	$00030000
SHARK_Y_DIVE			equ	$00019000

SHARK_KILL_X_RANGE		equ	160

SHARK_MOVE_TIME			equ	6
MAX_SHARK_FRAME			equ	6

SHARK_MOVE_Y			equ	$0000a900		;int:frac

SHARK_KILLY			equ	10		; distance form the line

SHARK_KILL_BUBSY_Y_OFFSET	equ	80			; point above bubsy for the shark to dive from

SHARKAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY					;do not do a small one
	
	SHARK_KILL_BUBSY

	sf	OBJOAM0(a5)				;get right direction to face bubsy
	move.w	OBJX(A5),d0
	cmp.w	BUBX,d0
	blt.s	.move_right
	move.b	#$08,OBJOAM0(a5)
.move_right:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.no_new_frame
	move.b	#SHARK_MOVE_TIME-1,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.no_wrap
	move.b	#MAX_SHARK_FRAME-1,OBJFRAME(A5)
.no_wrap:
.no_new_frame:
	move.l	#SHARK_MOVE_Y,d6
	move.w	OBJX(a5),d0				;get the distance from bubsy to the shark, use this as a guide
	sub.w	BUBX,d0
	bpl.s	.plus
	neg.w	d0					;dx
.plus:
	cmp.w	#SHARK_KILL_X_RANGE,d0
	bgt.s	.just_draw
	
	asr.w	#1,d0
	move.w	BUBY,d2
	sub.w	OBJY(a5),d2
	sub.w	d0,d2
	moveq	#SHARK_HEAD_OFFSET,d0
	sub.w	#SHARK_KILLY,d2
	bmi.s	.move_up
	
	moveq	#SHARK_BASE_OFFSET,d0
	cmp.w	#SHARK_KILLY*2,d2
	bgt.s	.move_down
	
	move.l	#SHARKATTACK_AI,OBJAI(a5)
	move.l	#SHARKATTACKMAP,OBJMAP(a5)
	move.l	#sharkattack_dma,OBJINITDMA(a5)
	move.b	#SHARK_KILL_TIMER-1,OBJAUX0(a5)
	sf	OBJFRAME(a5)
.just_draw:
	jmp	DRAW_COMPLEX_SPRITE
.move_down:
	neg.l	d6
.move_up:
	sub.l	d6,OBJY(a5)
.no_move:
	jmp	DRAW_COMPLEX_SPRITE

shark_dma:
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0

.frame0:	dc.w	2,0,0,0
	dc.w	-25,-40-23,6
	dc.w	-10,-23,0
	
.frame1:	dc.w	2,0,0,0
	dc.w	-25,-40-23,6
	dc.w	-14+1,-23,1
	
.frame2:	dc.w	2,0,0,0
	dc.w	-25,-39-25,7
	dc.w	-18,-25,2
	
.frame3:	dc.w	2,0,0,0
	dc.w	-25,-39-25,7
	dc.w	-19,-25,3
	
.frame4:	dc.w	2,0,0,0
	dc.w	-25,-49-25,8
	dc.w	-18,-25,4
	
.frame5:	dc.w	2,0,0,0
	dc.w	-25,-49-25,8
	dc.w	-12-1,-25,5

SHARKMAP:
	rept	6
	Soff	16,8,0,0,-8,22,12,53,30,63,40,25,26,-4
	endr
	
*************************************************
*						*
*	shark diving				*
*						*
*************************************************

SHARKATTACK_AI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY				;do not do a small one
	
	SHARK_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)			;time out the turning
	bpl.s	.same_frame
	
	move.b	#1,OBJFRAME(A5)			;indicate diving
	move.b	#SHARK_KILL_TIMER-1,OBJAUX0(a5)
	
.same_frame:
	tst.b	OBJFRAME(a5)			;if turning the not diving
	beq.s	.turning
	
	move.l	#SHARK_X_DIVE,d0
	
	tst.b	OBJOAM0(a5)
	beq.s	.dive_right
	neg.l	d0
.dive_right:
	add.l	d0,OBJX(A5)
	add.l	#SHARK_Y_DIVE,OBJY(a5)
.turning:
;	move.w	OBJX(A5),d1
;	move.w	OBJY(A5),d2
;	jsr	GETATTRIB
;	tst.w	d0
;	bne.s	.die
	jmp	DRAW_COMPLEX_SPRITE
;.die:	move.l	#CRATEEXPLODE,a0
;	move.l	#CRATE10002,OBJINITDMA(a5)
;	move.l	#CRATEMAP,OBJMAP(a5)
;	move.l	a0,OBJAI(a5)
;	add.w	#32,OBJY(a5)
;	sf	OBJAUX1(a5)
;	sf	OBJAUX0(a5)
;	jmp	(a0)

sharkattack_dma:
	dc.l	.frame0
	dc.l	.frame1
	
.frame0:	dc.w	1,0,0,0
	dc.w	-20,-51,9
.frame1:	dc.w	1,0,0,0
	dc.w	-56,-57,10

SHARKATTACKMAP:
	Soff	3,19,0,0,-17,28,17,27,53,11,28,4,23,-10
	Soff	48,56,0,0,39,-5,24,-30,55,-52,61,-36,85,-21
