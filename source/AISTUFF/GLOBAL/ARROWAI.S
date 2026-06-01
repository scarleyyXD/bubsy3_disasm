ARROW_ON_SCREEN	equ	(15*50)

ARROWMAP:
arrowdma:
ARROWAI:
	jsr	DOINITIALDMA
	jsr	OBJRANGE
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
	
.INRANGE:
	jsr	CLIPYSMALL
	cmp.w	#ARROW_ON_SCREEN,OBJAUX2(a5)
	bgt.s	.seen
	addq.w	#1,OBJAUX2(a5)
	rts

.seen:
	moveq	#0,d0
	move.b	OBJFLAGS(a5),d0
	addq.b	#1,d0
	and.b	#31,d0
	move.b	d0,OBJFLAGS(a5)

	move.b	.vector_table(pc,d0.w),d0
	ext.w	d0
	btst	#1,OBJAUX0(a5)
	beq.s	.not_x
	add.w	d0,OBJX(a5)
	
.not_x:
	btst	#0,OBJAUX0(a5)
	beq.s	.not_y
	add.w	d0,OBJY(a5)
	
.not_y:	
	moveq	#-16,d0
	moveq	#-16,d1
	add.w	OBJX(a5),d0
	add.w	OBJY(a5),d1
	sub.w	WINDX,d0
	sub.w	WINDY,d1
	moveq	#0,d4
	move.b	OBJAUX1(a5),d4
	move.l	LOAD_ARROW_GRAPHICS_ADDR,a0
	jmp	print_a_sprite_normal
	
.vector_table:
	rept	12
	dc.b	1
	endr
	rept	4
	dc.b	0
	endr
	rept	12
	dc.b	-1
	endr
	rept	4
	dc.b	0
	endr

	even	
