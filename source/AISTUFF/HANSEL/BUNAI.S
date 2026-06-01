;The cream bun will jump about the screen at a nominal height,towards its first encounter with bubsy

.macro	CREAMBUN_KILL_BUBSY
	move.w	#$0901,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

CREAMBUN_X_RANGE	equ	160
CREAMBUB_XKILL_RANGE	equ	060

CREAMBUN_INJUMP_FRAME	equ	0
CREAMBUN_STOOD_FRAME	equ	2
CREAMBUN_LAND_FRAME	equ	1
CREAMBUN_JUMPUP_FRAME	equ	3

CREAMBUN_JUMPUP_TIME	equ	8
CREAMBUN_LAND_TIME	equ	8

CREAMBUN_NORMAL_SPEED	equ	5
CREAMBUN_KILL_SPEED	equ	5

CREAMBUNAI:
	move.w	BUBX,d0
	cmp.w	OBJX(a5),d0
	blt.s	.left
	move.b	#8,OBJOAM0(a5)
.left:
	move.l	#CREAMBUNAIGO,OBJAI(A5)

CREAMBUNAIGO:
	jsr	OBJRANGE
	bcc.s	.inx
	jmp	CLEAROBJWVRAM
.inx:
	jsr	CLIPY
	
	CREAMBUN_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl	.no_frame_change
	move.b	#CREAMBUN_INJUMP_FRAME,OBJFRAME(A5)
	move.b	#CREAMBUN_NORMAL_SPEED,OBJAUX0(a5)
	
.loop:	moveq	#0,d2
	move.b	OBJAUX6(a5),d2
	lsl.w	#2,d2				; *4 = 2words
	lea	normal_jump_table(pc),a0
	move.w	2(a0,d2.w),d1
	move.w	(a0,d2.w),d0
	bpl.s	.posi_x_step
	move.w	2-4(a0,d2.w),d1
	move.w	-4(a0,d2.w),d0
	bra.s	.cont
.posi_x_step:
	addq.b	#1,OBJAUX6(a5)				;update pointer
.cont:	tst.b	OBJOAM0(a5)
	bne.s	.posi
	neg.w	d0
.posi:	add.w	d0,OBJX(A5)
	add.w	d1,OBJY(A5)
	
	move.w	OBJX(A5),d1
	move.w	OBJY(A5),d2
	jsr	GETATTRIB				;if nothing there then 0
	and.w	#ATTR_MASK,d0
	beq.s	.nothing_here

	eor.b	#8,OBJOAM0(a5)
	jsr	STICKOBJECTTOPLAYFIELD
	
	sf	OBJAUX6(a5)
	
	move.l	#CREAMBUN_TWITCHAI,OBJAI(A5)
	move.b	#CREAMBUN_TWITCH_FRAME-1,OBJAUX1(A5)
	sf	OBJAUX0(A5)
.no_check:
.nothing_here:
	
.no_frame_change:	
	JMP	DRAW_COMPLEX_SPRITE

CREAMBUN_TWITCH_FRAME	equ	1
CREAMBUN_TWITCH_SPEED	equ	5
MAX_TWITCH		equ	5

CREAMBUN_TWITCHAI:
	jsr	OBJRANGE
	bcc.s	.inx
	jmp	CLEAROBJWVRAM
.inx:	jsr	CLIPY
	
;	CREAMBUN_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.no_frame_change
	move.b	#CREAMBUN_TWITCH_SPEED,OBJAUX0(a5)
	addq.b	#1,OBJAUX1(a5)
	cmp.b	#MAX_TWITCH,OBJAUX1(a5)
	bne.s	.ok
	move.l	#CREAMBUNAIGO,OBJAI(A5)
	sf	OBJAUX0(A5)
	bra.s	.cont
.ok:	move.b	OBJAUX1(a5),OBJFRAME(A5)
.no_frame_change:
.cont:	jmp	DRAW_COMPLEX_SPRITE	

normal_jump_table:
	dc.w	6,-10
	dc.w	6,-9
	dc.w	6,-8
	dc.w	6,-7
	dc.w	6,-6
	dc.w	6,-5
	dc.w	6,-4
	dc.w	6,-3
	dc.w	6,-2
	dc.w	6,-1
	dc.w	6,0
	dc.w	6,1
	dc.w	6,2
	dc.w	6,3
	dc.w	6,4
	dc.w	6,5
	dc.w	6,6
	dc.w	6,7
	dc.w	6,8
	dc.w	6,9
	dc.w	6,10
	dc.l	-1

creambun_dma:
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame1
	dc.l	.frame3
	dc.l	.frame0

.frame0:	dc.w	1,0,0,0
	dc.w	0,-28,27
.frame1:	dc.w	1,0,0,0
	dc.w	0,-21,28
.frame2:	dc.w	1,0,0,0
	dc.w	0,-29,29
.frame3:	dc.w	1,0,0,0
	dc.w	0,-29,30

CREAMBUNMAP:
	Soff	0,0,7,1,18,1,0,10,5,27,16,14,18,1	;2
	Soff	0,0,0,21,5,1,5,12,12,28,21,15,18,2	;3
	Soff	0,0,1,2,0,17,3,10,13,18,19,8,13,0	;1
	Soff	0,0,0,21,5,1,5,12,12,28,21,15,18,2	;3
	Soff	0,0,5,0,13,0,0,15,18,15,4,27,14,27	;0
	