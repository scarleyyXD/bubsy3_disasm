; walks in the general direction of bubsy to start with and when bubsy gets with a certain range he will kill bubsy


SPOONMAN_KILL_BUBSY	macro
	move.w	#$0601,d6				;see if BUBSY has bopped the guard
	moveq	#BOING2,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide
	endm


SPOONMAN_WALK	equ	6
SPOONMAN_SPEED	equ	10
SPOON_RUN_SPEED	equ	6
SPOON_WIDTH	equ	5

SPOON_KICK_RANGE	equ	30
SPOON_KICK_RANGE_Y	equ	40

SPOON_START_KICK_FRAME	equ	6+3
SPOON_REVERT_TO_WALK	equ	5-1

SPOONMANAI
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE
	JSR	CLIPYSMALL
	
	SPOONMAN_KILL_BUBSY

	
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne	.just_animate
	
	
	move.w	OBJY(A5),d0
	sub.w	BUBY,d0
	bpl.s	.posiy
	neg.w	d0
.posiy	cmp.w	#SPOON_KICK_RANGE_Y,d0
	bgt.s	.no_kill
	
	move.w	OBJX(a5),d0
	sub.w	BUBX,d0		;get distance to bubsy, if object > bub then +ive
	tst.b	OBJOAM0(a5)	;if zero then object facing ->
	beq.s	.ok
	neg.w	d0		;if sprite facing other way then -ive the result
.ok
	tst.w	d0
	bpl.s	.no_kill
	neg.w	d0
	cmp.w	#SPOON_KICK_RANGE,d0
	blt	SPOON_START_KILL
.just_animate
.no_kill
	subq.b	#1,OBJAUX0(a5)
	bpl	.just_draw
	move.b	#SPOONMAN_SPEED-1,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	move.b	#SPOONMAN_WALK-1,OBJFRAME(A5)
.no_wrap
	moveq	#0,d6
	move.b	OBJFRAME(a5),d6
	move.b	.walk_tab(pc,d6.w),d6
	moveq	#SPOON_WIDTH,d1
	add.w	d6,d1
	moveq	#-7,d2
	add.w	OBJY(a5),d2						;set up y to check if we will walk over the edge
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	beq.s	.WALKRIGHT
	neg.w	d1
	neg.w	d6
.WALKRIGHT
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB						;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP5,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB						;x+dx,y-5
	or.w	d0,d0
	bne.s	.use_this_one
	or.w	TEMP7,d0
.use_this_one
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL
	and	d0,d0							;0 then it must be nothing
	beq.s	.change_direction
	bra.s	.all_ok

.CHECKWALL								;check if we will hit a wall
	and.w	#WALL_CTRL,d7
	beq.s	.all_ok
.change_direction
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move
.all_ok
	add.w	d6,OBJX(a5)						;move the guard by d6
.no_move
.DONETHIS

.just_draw
	jsr	STICKOBJECTTOPLAYFIELD
	jmp	DRAW_COMPLEX_SPRITE
	

.walk_tab
	dc.b	SPOON_RUN_SPEED-1,SPOON_RUN_SPEED-2,SPOON_RUN_SPEED+2
	dc.b	SPOON_RUN_SPEED+2,SPOON_RUN_SPEED+2,SPOON_RUN_SPEED
	

SPOON_START_KILL
	move.b	#SPOON_START_KICK_FRAME,OBJFRAME(A5)
	sf	OBJAUX0(a5)
	move.l	#SPOONKILLAI,OBJAI(a5)
SPOONKILLAI
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE
	JSR	CLIPYSMALL
	
	SPOONMAN_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.just_draw
	move.b	#SPOONMAN_SPEED-1,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(a5)

	jsr	DRAW_COMPLEX_SPRITE
	cmp.b	#SPOON_REVERT_TO_WALK,OBJFRAME(a5)
	bne.s	.just_rts
	sf	OBJFRAME(A5)
	sf	OBJAUX0(a5)
	move.l	#SPOONMANAI,OBJAI(a5)
.just_rts
	rts
.just_draw
	jmp	DRAW_COMPLEX_SPRITE
		

spoonman_dma
	dc.l	.frame0
	dc.l	.frame1	;walk
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4
	dc.l	.frame5
	
	dc.l	.frame8	;kill
	dc.l	.frame7
	dc.l	.frame6

.frame0	dc.w	1,0,0,0
	dc.w	-25,-60,43
.frame1	dc.w	1,0,0,0
	dc.w	-25,-60,44
.frame2	dc.w	1,0,0,0
	dc.w	-25,-60,45
.frame3	dc.w	1,0,0,0
	dc.w	-25,-60,46
.frame4	dc.w	1,0,0,0
	dc.w	-25,-60,47
.frame5	dc.w	1,-0,0,0
	dc.w	-25,-60,48
	
.frame6	dc.w	1,0,0,0
	dc.w	-45-4,-55,49
.frame7	dc.w	1,0,0,0
	dc.w	-40-4,-66,50
.frame8	dc.w	1,0,0,0
	dc.w	-26-4,-58,51


SPOONMANMAP

	Soff	1,1,-6,0,-7,51,-24,23,3,58,3,45,32,36
	Soff	1,0,-24,24,-19,50,-2,60,5,42,16,19,7,0
	Soff	1,2,-13,1,13,1,12,27,-20,27,-6,52,6,52

	Soff	1,1,-6,0,-7,51,-24,23,3,58,3,45,32,36
	Soff	1,0,-24,24,-19,50,-2,60,5,42,16,19,7,0
	Soff	1,2,13,1,-13,1,-12,27,20,27,6,52,-6,52
	
	Soff	2,1,0,0,-28,20,-10,57,27,45,34,32,3,27
	Soff	2,1,0,0,-42,37,-21,54,7,65,8,34,33,45
	Soff	2,1,0,0,-47,39,-21,54,12,34,21,55,34,36
