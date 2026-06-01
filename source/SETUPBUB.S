SETUPBUBSY:
	moveq	#0,d4
	moveq	#49,d3
	move.b	BUBSYFRAME,d4
	move.b	d4,d7								;if invincible or shadow and stimer= 0 show alternative frame
	move.w	INVTIMER,D0
	or.w	SHADOWTIMER,D0
	beq.s	.NOINVTIMER
	cmp.w	#50*5,D0
	bcs.s	.INV1
	moveq	#1,D0
	and.b	STIMER+1,D0							;reg inv
	bne.s	.NOINVTIMER
	moveq	#49,d4
	bra.s	.NOINVTIMER

.INV1:
	moveq	#3,d0
	and.b	STIMER+1,d0
	bne.s	.NOINVTIMER
	moveq	#49,d4

.NOINVTIMER:
	cmp.b	d3,d4								;draw shell, if frame 49 and invincible not warping
	bne.s	.NOSHELL
	cmp.w	#4,INVTIMER
	bcs.s	.NOSHELL
	cmp.b	d3,d7
	beq.s	.NOSHELL

.no_draw:
	rts

.NOSHELL:
	cmp.b	d4,d3
	beq.s	.no_draw
	move.b	BUBSYXOFFSET(pc,d4.w),d0					;get the associated offsets for this sprite
	ext.w	D0
	
	lea	BUBSYYOFFSET(pc),a1
	move.b	(a1,d4.w),d1
	ext.w	d1
	
	add.w	BUBY,d1								;calculate Y position of corner in d2
	sub.w	WINDY,d1
	
	move.l	LOAD_BUBSY_ADDR,a0
	moveq	#BUBSYHFLIP,d3
	and.b	BUBSYFLAGS,d3							;see if bubsy is h flipped
	beq.s	.DRAWBUB
	neg.w	d0
	add.w	BUBX,d0
	sub.w	WINDX,d0
	addq	#8,d0
	jmp	print_a_sprite_flipped_minus

.DRAWBUB:
	add.w	BUBX,d0
	sub.w	WINDX,d0
	jmp	print_a_sprite_normal