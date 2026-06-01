SETUPBUBSY:
	moveq	#0,d4
	moveq	#49,d3
	move.b	BUBSYFRAME,d4
	MOVE.B	d4,d7								;if invincible or shadow and stimer= 0 show alternative frame
	MOVE.w	INVTIMER,D0
	OR.w	SHADOWTIMER,D0
	BEQ.s	.NOINVTIMER
	CMP.w	#50*5,D0
	BCS.s	.INV1
	moveq	#1,D0
	and.B	STIMER+1,D0							;reg inv
	BNE.s	.NOINVTIMER
	MOVEq	#49,d4
	BRA.s	.NOINVTIMER
.INV1
	moveq	#3,D0
	and.B	STIMER+1,D0
	BNE.s	.NOINVTIMER
	MOVEq	#49,d4
.NOINVTIMER
	CMP.B	d3,d4								;draw shell, if frame 49 and invincible not warping
	BNE.s	.NOSHELL
	CMP.w	#4,INVTIMER
	BCS.s	.NOSHELL
	CMP.B	d3,d7
	BEQ.s	.NOSHELL
.no_draw
	rts

.NOSHELL
	
	cmp.b	d4,d3
	beq.s	.no_draw
	MOVE.B	BUBSYXOFFSET(pc,D4.W),D0					;get the associated offsets for this sprite
	EXT.W	D0
	
	LEA	BUBSYYOFFSET(pc),A1
	MOVE.B	(A1,D4.W),D1
	EXT.W	D1
	
	add.w	BUBY,D1								;calculate Y position of corner in d2
	sub.w	WINDY,D1
	
	move.l	LOAD_BUBSY_ADDR,a0
	moveq	#BUBSYHFLIP,D3
	and.B	BUBSYFLAGS,D3							;see if bubsy is h flipped
	beq.s	.DRAWBUB
	neg.w	d0
	add.w	BUBX,d0
	sub.w	WINDX,d0
	addq	#8,d0
	jmp	print_a_sprite_flipped_minus
.DRAWBUB
	add.w	BUBX,d0
	sub.w	WINDX,d0
	jmp	print_a_sprite_normal
