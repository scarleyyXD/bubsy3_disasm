CAT_ANIM_SPEED	equ	7
LAST_CAT_FRAME	equ	20

MAX_WAIT	equ	(60*4)			; turns on before 4 seconds - US frames
CAT_WAIT	equ	45			; will not appear for 3/4 seconds
FIRST_CAT	equ	10

CATAI
	jsr	OBJRANGE
	bcc.s	.inrange
.end_it_all
	jmp	CLEAROBJWVRAM
.inrange
	jsr	CLIPYSMALL
	
	tst.b	OBJAUX7(a5)
	bne.s	.count_down
	
	st	OBJAUX7(a5)
	
	move.w	HC,d0
	add.w	VC,d0
	divu	#MAX_WAIT,d0
	swap	d0
	add.w	#CAT_WAIT,d0
	move.w	d0,OBJAUX0(a5)
	
	
	
.count_down
	sub.w	#1,OBJAUX0(a5)
	bmi.s	.show_me
	rts
.show_me
	move.l	#CATACTIVEAI,OBJAI(a5)
	move.b	#CAT_ANIM_SPEED,OBJAUX0(A5)
	rts
	
CAT_KILL_BUBSY	macro
	move.w	#$0901,d6
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm


CATACTIVEAI
	jsr	OBJRANGE
	bcc.s	.inrange
.end_it_all
	jmp	CLEAROBJWVRAM
	
.licks	dc.b	0,0,0,0,0
	dcb.b	10,-1
	dc.b	0,0,0,0,0
	even	
.inrange


	
	jsr	CLIPYSMALL
	
	moveq	#0,d7
	move.b	OBJFRAME(a5),d7
	move.b	.licks(pc,d7.w),d7
	beq.s	.no_detect
	
	sub.b	#FIRST_CAT,OBJFRAME(A5)
	CAT_KILL_BUBSY
	
	add.b	#FIRST_CAT,OBJFRAME(A5)
.no_detect
	
	tst.b	OBJFLAGS(a5)
	bne.s	.already_set_up
	

	add.w	#16,OBJY(a5)
	moveq	#0,d1
	move.w	OBJX(a5),d7
	sub.w	BUBX,d7
	bmi.s	.facing_right
	moveq	#8,d1
.facing_right
	move.b	d1,OBJOAM0(A5)
	st	OBJFLAGS(a5)
.already_set_up

	
	
	subq.b	#1,OBJAUX0(a5)
	bne.s	.same_frame
	move.b	#CAT_ANIM_SPEED,OBJAUX0(A5)
	
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#LAST_CAT_FRAME,OBJFRAME(a5)
	bne.s	.same_frame
;	sf	OBJFRAME(a5)
	beq	.end_it_all
.same_frame	
	jmp	DRAW_COMPLEX_SPRITE



cat_dma
	dc.l	.vis1
	dc.l	.vis2
	dc.l	.vis3
	dc.l	.vis4
	dc.l	.vis5

	dc.l	.facea
	dc.l	.faceb
	dc.l	.faceo
	dc.l	.faceo1
	dc.l	.faceo2
	dc.l	.faceo
	dc.l	.facea
	dc.l	.facea
	dc.l	.facea
	dc.l	.facea

	dc.l	.vis5
	dc.l	.vis4
	dc.l	.vis3
	dc.l	.vis2
	dc.l	.vis1


.vis1	dc.w	1,0,0,0
	dc.w	-31,-26*0,32
.vis2	dc.w	1,0,0,0
	dc.w	-31,-26*0,33
.vis3	dc.w	1,0,0,0
	dc.w	-31,-26*0,34
.vis4	dc.w	1,0,0,0
	dc.w	-31,-26*0,35
.vis5	dc.w	1,0,0,0
	dc.w	-31-1,-26*0,36
	
.facea	dc.w	1,0,0,0
	dc.w	-31,-26*0-1,37
.faceb	dc.w	1,0,0,0
	dc.w	-31,-26*0,38
.faceo	dc.w	1,0,0,0
	dc.w	-31,-26*0,39
.faceo1	dc.w	5,0,0,0
	dc.w	-31,-26*0,39
	dc.w	-31+27-1,-26*0+41-1,41
	dc.w	-31+84-1,-26*0+85-1,42
	dc.w	-31+61-1,-26*0+74-1,43
	dc.w	-31+90-1,-26*0+74-1,44

.faceo2	dc.w	5,0,0,0
	dc.w	-31,-26*0,39
	dc.w	-31+26-1,-26*0+40-2,40
	dc.w	-31+91-1,-26*0+98-2,42
	dc.w	-31+55-1,-26*0+87-2,43
	dc.w	-31+109-1,-26*0+48-2,44



CAT_MAP1	macro
	Soff	(32-12),0,0,0,23,-13,10,-29,22,-41,44,-3,51,-30
	endm
CAT_MAP2	macro
	Soff	(32-19),23,0,0,33,1,17,-28,36,-29,49,-48,63,-47
	endm
CAT_MAP3	macro
	Soff	(32-12),0,0,0,1,-24,18,-47,43,-3,47,-31,47,-56
	endm

CATMAP
	rept	3
	CAT_MAP1
	endr

	CAT_MAP2
	CAT_MAP3
	
	rept	5
	CAT_MAP1
	endr
	