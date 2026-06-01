ENEMYOAM8:
ENEMYOAMS:
	moveq	#0,d7
	MOVE.B	OBJFRAME(A5),D7
	move.w	d7,a0
	add.l	OBJINITDMA(a5),a0							;a0 points to correct frame
	MOVE.L	OBJMAP(A5),A1								;get x position and store in temp0
	ASL.w	#5,D7									;d7*$20 to point to correct frame in sequence
	add.w	d7,a1
	MOVE.w	OBJX(A5),D0
	SUB.w	WINDX,D0
	ADD.w	(A1)+,D0
	MOVE.w	OBJY(A5),D1								;get y position and store in temp1
	SUB.w	WINDY,D1
	ADD.w	(A1)+,D1
	jmp	DRAW_JAGUAR_SPRITE

ENEMYOAM:
	moveq	#0,d7
	move.b	OBJFRAME(a5),d7
	move.w	d7,a0
	add.l	OBJINITDMA(a5),a0
	MOVE.L	OBJMAP(A5),A1								;get x position and store in temp0
	MOVE.w	OBJX(A5),D0
	SUB.w	WINDX,D0
	ADD.w	(A1)+,D0
	MOVE.w	OBJY(A5),D1								;get y position and store in temp1
	SUB.w	WINDY,D1
	ADD.w	(A1)+,D1
	jmp	DRAW_JAGUAR_SPRITE

ENEMYOAM81:
ENEMYOAMS1:
	moveq	#0,d7
	MOVE.B	OBJFRAME(A5),D7
	move.w	d7,a0
	add.l	OBJINITDMA(a5),a0							;a0 points to correct frame
	MOVE.L	OBJMAP(A5),A1								;get x position and store in temp0
	ASL.w	#5,D7									;d7*$20 to point to correct frame in sequence
	add.w	d7,a1
	MOVE.w	OBJX(A5),D0
	SUB.w	WINDX,D0
	ADD.w	(A1)+,D0
	MOVE.w	OBJY(A5),D1								;get y position and store in temp1
	SUB.w	WINDY,D1
	ADD.w	(A1)+,D1
	jmp	DRAW_JAGUAR_SPRITE_1

ENEMYOAM1:
	MOVE.L	OBJMAP(A5),A1								;get x position and store in temp0
	moveq	#0,d7
	move.b	OBJFRAME(a5),d7
	move.w	d7,a0
	add.l	OBJINITDMA(a5),a0
	MOVE.w	OBJX(A5),D0
	SUB.w	WINDX,D0
	ADD.w	(A1)+,D0
	MOVE.w	OBJY(A5),D1								;get y position and store in temp1
	SUB.w	WINDY,D1
	ADD.w	(A1)+,D1
	jmp	DRAW_JAGUAR_SPRITE_1
;d0=flip
;d1=x
;d2=y
;a0=index to bank number,sprite number hi-word:low-word