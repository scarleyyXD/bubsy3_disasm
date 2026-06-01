.macro	DANCER_KILL_BUBSY
	move.w	#$0401,d6				;see if BUBSY has bopped the guard
	move.w	#HIGHCHINK,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

DANCER_NORMAL_SPEED	equ	6
DANCER_NORMAL_FRAMES	equ	11

DANCER_KILL_Y_RANGE	equ	40
DANCER_KILL_X_RANGE	equ	90
DANCER_KILL_FRAMES	equ	15

DANCERAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY
	
	DANCER_KILL_BUBSY

	sf	OBJOAM0(a5)
	move.w	OBJX(a5),d0
	cmp.w	BUBX,d0
	blt.s	.ok
	bset	#3,OBJOAM0(a5)
.ok:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0								;zombie fix
	bne.s	.bubdead

	move.w	OBJY(a5),d0
	sub.w	BUBY,d0
	bpl.s	.pos1
	neg.w	d0
.pos1:	cmp.w	#DANCER_KILL_Y_RANGE,d0
	bgt.s	.no_kill
	
	move.w	OBJX(a5),d0
	sub.w	BUBX,d0		;get distance to bubsy, if object > bub then +ive
	tst.b	OBJOAM0(a5)	;if zero then object facing ->
	beq.s	.ok1
	neg.w	d0		;if sprite facing other way then -ive the result
.ok1:
	tst.w	d0
	bpl.s	.no_kill
	neg.w	d0
	cmp.w	#DANCER_KILL_X_RANGE,d0
	blt.s	.start_kill_bubsy
.bubdead:
.no_kill:
	jsr	STICKOBJECTTOPLAYFIELD
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#DANCER_NORMAL_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.no_wrap
	move.b	#DANCER_NORMAL_FRAMES-1,OBJFRAME(A5)
.no_wrap:
.same_frame:
	jmp	DRAW_COMPLEX_SPRITE
.start_kill_bubsy:
	move.l	#DANCERKILLAI,OBJAI(A5)
	move.l	#dancerkill_dma,OBJINITDMA(a5)
	move.l	#DANCERKILLMAP,OBJMAP(a5)
	
	move.b	#DANCER_KILL_FRAMES,OBJFRAME(A5)
	sf	OBJAUX0(a5)
	bra.s	DANCER_OFFSET
DANCERKILLAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY
	
	DANCER_KILL_BUBSY

DANCER_OFFSET	equ	*

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#DANCER_NORMAL_SPEED-1,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.no_wrap
	move.l	#DANCERAI,a0
	move.l	a0,OBJAI(A5)
	move.l	#dancer_dma,OBJINITDMA(a5)
	move.l	#DANCERMAP,OBJMAP(a5)
	
	sf	OBJAUX0(a5)
	sf	OBJFRAME(A5)
	jmp	(a0)
.no_wrap:
.same_frame:
	jmp	DRAW_COMPLEX_SPRITE

dancerkill_dma:
	dc.l	.frame015
	dc.l	.frame014
	dc.l	.frame011
	dc.l	.frame011
	dc.l	.frame011
	dc.l	.frame010
	dc.l	.frame009
	dc.l	.frame009
	dc.l	.frame008
	dc.l	.frame007
	dc.l	.frame001
	dc.l	.frame001
	dc.l	.frame001
	dc.l	.frame001
	dc.l	.frame001
	dc.l	.frame001

.frame001:
	dc.w	4,0,0,0
	dc.w	124-135,068-116,66
	dc.w	100-135,084-116,62
	dc.w	135-135,090-116,72
	dc.w	112-135,108-116,77
.frame007:
	dc.w	4,0,0,0
	dc.w	120-135,067-116,67
	dc.w	103-135,093-116,62
	dc.w	160-135,062-116,70
	dc.w	112-135,108-116,77
.frame008:
	dc.w	4,0,0,0
	dc.w	115-135,068-116,67
	dc.w	099-135,080-116,63
	dc.w	155-135,045-116,70
	dc.w	112-135,097-116,82
.frame009:
	dc.w	4,0,0,0
	dc.w	116-135,072-116,67
	dc.w	092-135,071-116,64
	dc.w	151-135,065-116,69
	dc.w	112-135,104-116,75
.frame010:
	dc.w	4,0,0,0
	dc.w	119-135,073-116,67
	dc.w	089-135,070-116,64
	dc.w	147-135,089-116,68
	dc.w	112-135,108-116,83
.frame011:
	dc.w	4,0,0,0
	dc.w	112-135,075-116,67
	dc.w	089-135,070-116,64
	dc.w	168-135,089-116,68
	dc.w	112-135,108-116,83
.frame014:
	dc.w	4,0,0,0
	dc.w	115-135,068-116,67
	dc.w	098-135,079-116,64
	dc.w	155-135,045-116,70
	dc.w	112-135,096-116,76
.frame015:
	dc.w	4,0,0,0
	dc.w	119-135,067-116,67
	dc.w	100-135,086-116,62
	dc.w	137-135,063-116,71
	dc.w	112-135,101-116,84

dancer_dma:
	dc.l	.frame10
	dc.l	.frame9
	dc.l	.frame8
	dc.l	.frame7
	dc.l	.frame6
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0
	
.frame0:	dc.w	4,0,0,0
	dc.w	(126-137),75-122,66
	dc.w	(103-137),92-122,62
	dc.w	(132-137),99-122,72
	dc.w	(114-137),115-122,77
.frame1:	dc.w	4,0,0,0
	dc.w	(127-137),73-122,66
	dc.w	(092-137),87-122,62
	dc.w	(137-137),98-122,72
	dc.w	(114-137),115-122,77
.frame2:	dc.w	4,0,0,0
	dc.w	(133-137),74-122,65
	dc.w	(100-137),67-122,64
	dc.w	(139-137),95-122,72
	dc.w	(108-137),109-122,78
.frame3:	dc.w	4,0,0,0
	dc.w	(133-137),77-122,65
	dc.w	(103-137),67-122,64
	dc.w	(137-137),97-122,72
	dc.w	(108-137),111-122,80
.frame4:	dc.w	4,0,0,0
	dc.w	(133-137),78-122,65
	dc.w	(102-137),75-122,64
	dc.w	(136-137),98-122,72
	dc.w	(109-137),114-122,79
.frame5:	dc.w	4,0,0,0
	dc.w	(127-137),73-122,65
	dc.w	(092-137),87-122,62
	dc.w	(137-137),100-122,72
	dc.w	(114-137),115-122,77
.frame6:	dc.w	4,0,0,0
	dc.w	(126-137),75-122,66
	dc.w	(096-137),89-122,62
	dc.w	(137-137),97-122,72
	dc.w	(114-137),115-122,77
.frame7:	dc.w	4,0,0,0
	dc.w	(122-137),74-122,67
	dc.w	(101-137),93-122,62
	dc.w	(141-137),93-122,72
	dc.w	(114-137),115-122,77
.frame8:	dc.w	4,0,0,0
	dc.w	(117-137),75-122,67
	dc.w	(101-137),97-122,63
	dc.w	(139-137),88-122,72
	dc.w	(114-137),108-122,81
.frame9:	dc.w	1,0,0,0
	dc.w	103-137,79-122,74
.frame10:
	dc.w	1,0,0,0
	dc.w	103-137,81-122,73

DANCERMAP:
	;	        -        -        -        -       -      -
	Soff	0,0,-23,003,-23,016,-23,025,-11,034,17,006,27,005
	Soff	0,0,-23,003,-24,015,-21,032,-10,037,19,023,27,010
	Soff	0,0,-22,004,-23,019,-11,040,004,033,40,025,27,011
	Soff	0,0,-22,004,-23,022,-06,043,006,028,43,020,22,004
	Soff	0,0,-22,005,-30,026,000,045,001,024,22,004,39,016
	Soff	0,0,-22,004,-34,028,005,043,001,021,22,004,39,013
	Soff	0,0,-27,005,-26,039,009,037,000,023,22,004,35,016
	Soff	0,0,-28,010,-25,047,012,040,002,024,22,004,39,016
	Soff	0,0,-28,010,-26,045,010,041,003,026,22,004,19,014
	Soff	0,0,-22,004,-34,028,001,023,005,045,22,004,40,015
	Soff	0,0,-22,004,-24,023,-01,046,002,021,22,004,34,013

DANCERKILLMAP:
	Soff	0,0,-22,4,-25,21,-8,41,-9,45,25,11,26,29
	Soff	0,0,-22,4,-29,28,-12,39,-32,18,24,41,29,63
	rept	3
	Soff	0,0,-37,37,-4,32,29,4,56,23,70,23,78,23
	endr
	Soff	0,0,-22,4,-37,37,-8,35,32,23,46,23,56,23
	Soff	0,0,-22,4,-34,35,-11,37,37,9,24,26,38,41
	Soff	0,0,-23,4,-25,25,13,41,33,16,22,32,29,62
	Soff	0,0,-22,4,-21,16,-6,40,22,4,27,14,34,45
	rept	7
	Soff	0,0,-22,4,24,23,0,44,1,24,-22,4,39,15
	endr
