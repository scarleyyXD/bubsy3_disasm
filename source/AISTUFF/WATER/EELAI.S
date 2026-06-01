.macro	EEL_KILL_BUBSY
	move.w	#$0301,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

EEL_MOVE_SPEED		equ	9
NORMAL_EEL_FRAMES	equ	6
EEL_LAND_DETECT_X	equ	30
EEL_LAND_DETECT_Y	equ	0
EEL_MOVE_X		equ	-10

EEL_SHOCK_X_RANGE	equ	60
EEL_SHOCK_Y_RANGE	equ	60
EEL_SHOCK_SPEED		equ	3

EELAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPYSMALL					;do not do a small one
	
	EEL_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bmi.s	.move_eel
	jmp	DRAW_COMPLEX_SPRITE
.move_eel:
	move.b	#EEL_MOVE_SPEED-1,OBJAUX0(a5)
	
	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.xok
	neg.w	d0
.xok:	cmp.w	#EEL_SHOCK_X_RANGE,d0
	bgt.s	.dont_start_to_shock

	move.w	BUBY,d1
	sub.w	OBJY(a5),d1
	bpl.s	.yok
	neg.w	d1
.yok:	cmp.w	#EEL_SHOCK_Y_RANGE,d1
	bgt.s	.dont_start_to_shock
	move.l	#EELSHOCKAI,OBJAI(A5)
	move.l	#EELSHOCKMAP,OBJMAP(A5)
	move.l	#eelshockdma,OBJINITDMA(a5)
	sf	OBJFRAME(a5)
	jmp	DRAW_COMPLEX_SPRITE
.dont_start_to_shock:
	moveq	#-EEL_LAND_DETECT_X,d1
	moveq	#EEL_LAND_DETECT_Y,d2
	moveq	#EEL_MOVE_X,d3
	
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d3
	neg.w	d0
.going_right:
	add.w	d3,OBJX(A5)				;move the eel
	add.w	OBJX(A5),d1
	add.w	OBJY(A5),d2
	jsr	GETATTRIB

	tst.w	d0
	beq.s	.nothing_in_front
.hit_wall:
	eor.b	#8,OBJOAM0(A5)
	move.b	#NORMAL_EEL_FRAMES-1+1,OBJFRAME(a5)
	move.b	#EEL_MOVE_SPEED-1,OBJAUX0(a5)
	
.nothing_in_front:
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.no_wrap
	
	jsr	RANDOM
	
	and.w	#%1100,d0
	lea	eel_make(pc,d0.w),a0
	move.l	(a0)+,OBJINITDMA(a5)
.normal_frames:
	move.b	#NORMAL_EEL_FRAMES-1,OBJFRAME(A5)
.no_wrap:
	JMP	DRAW_COMPLEX_SPRITE

eel_make:
	dc.l	eel_dma			;buzz 2
	dc.l	eel_dma2		;no buzz
	dc.l	eel_dma1		;buzz 1
	dc.l	eel_dma2		;no buzz

eel_dma:
	dc.l	eelframe4
	dc.l	eelframe3
	dc.l	eelframe2
	dc.l	eelframe1
	dc.l	eelframe6
	dc.l	eelframe5
	dc.l	eelframe6				; buzz frame 2

eel_dma1:
	dc.l	eelframe4
	dc.l	eelframe3
	dc.l	eelframe2
	dc.l	eelframe1
	dc.l	eelframe0
	dc.l	eelframe5
	dc.l	eelframe7				; buzz frame

eel_dma2:
	dc.l	eelframe4
	dc.l	eelframe3
	dc.l	eelframe2
	dc.l	eelframe1
	dc.l	eelframe0
	dc.l	eelframe5
	dc.l	eelframe7

eelframe0:
	dc.w	1,0,0,0
	dc.w	-27,-6,58

eelframe1:
	dc.w	1,0,0,0
	dc.w	-27,-6,59

eelframe2:
	dc.w	1,0,0,0
	dc.w	-27,-6,60

eelframe3:
	dc.w	1,0,0,0
	dc.w	-27,-6,61

eelframe4:
	dc.w	1,0,0,0
	dc.w	-27,-6,62

eelframe5:
	dc.w	1,0,0,0
	dc.w	-27,-6,63

eelframe6:
	dc.w	1,0,0,0
	dc.w	-45,-21,64

eelframe7:
	dc.w	1,0,0,0
	dc.w	-27,-6,84
	
EELMAP:
	rept	7
	dcb.b	32,0
	endr

EELSHOCKAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPYSMALL					;do not do a small one
	
	EEL_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bmi.s	.move_eel
	jmp	DRAW_COMPLEX_SPRITE
.move_eel:
	move.b	#EEL_SHOCK_SPEED-1,OBJAUX0(a5)
	
	moveq	#-EEL_LAND_DETECT_X,d1
	moveq	#EEL_LAND_DETECT_Y,d2
	moveq	#EEL_MOVE_X/2,d3
	
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	neg.w	d3
	neg.w	d0
.going_right:
	add.w	d3,OBJX(A5)				;move the eel
	add.w	OBJX(A5),d1
	add.w	OBJY(A5),d2
	jsr	GETATTRIB

	tst.w	d0
	beq.s	.nothing_in_front
.hit_wall:
	eor.b	#8,OBJOAM0(A5)
.nothing_in_front:
	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.xok
	neg.w	d0
.xok:	cmp.w	#EEL_SHOCK_X_RANGE,d0
	bgt.s	.dont_start_to_shock

	move.w	BUBY,d1
	sub.w	OBJY(a5),d1
	bpl.s	.yok
	neg.w	d1
.yok:	cmp.w	#EEL_SHOCK_Y_RANGE,d1
	bgt.s	.dont_start_to_shock
	eor.b	#1,OBJFRAME(A5)
	jmp	DRAW_COMPLEX_SPRITE
.dont_start_to_shock:
	move.l	#EELAI,OBJAI(A5)
	move.l	#EELMAP,OBJMAP(A5)
	move.l	#eel_dma,OBJINITDMA(a5)
	sf	OBJFRAME(a5)
	JMP	DRAW_COMPLEX_SPRITE

eelshockdma:
	dc.l	.frame0
	dc.l	.frame1
	
.frame0:	dc.w	1,0,0,0
	dc.w	-65,-28,85

.frame1:	dc.w	1,0,0,0
	dc.w	-51,-26,86

EELSHOCKMAP:
	rept	2
	Soff	0,0,-30,-16,0,-16,30,-16,-30,16,0,16,30,16
	endr
