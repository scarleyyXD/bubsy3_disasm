SCRLA_HANDLER	EQU	(160+64)
SCRLA		EQU	SCRLA_HANDLER
SCRLAY		equ	64

SCRINIT	
	MOVE.L	SCRIPTPTR,D0			;MAKE SOME DUMMY VALUES
	MOVE.L	D0,SCRIPT_0X
	MOVE.L	D0,SCRIPT_1X
	MOVE.L	D0,SCRIPT_2X


	lea	SCRIPT_0X(pc),a1
	MOVE.W	WINDX,D0
	MOVE.W	D0,D1
	SUB.W	#SCRLA-160,D0
	ADD.W	#320+(SCRLA-160),D1		;D0 --> D1 X
	
	
	MOVE.W	WINDY,D2
	MOVE.W	D2,D3
	SUB.W	#SCRLAY,D2
	ADD.W	#SCRLAY,D3
	ADD.W	screen_height,D3		;D2 --> D3 Y
	BRA	DO_SCRIPT_BOX
	
DOSCRIPT
	LEA	SCRIPT_1X(PC),A1
	MOVE.W	WINDX,D0
	MOVE.W	WINDXOLD,D1
	and.w	#$fff0,d0
	and.w	#$fff0,d1
	CMP.W	D1,D0
	beq.s	.NODSXMOVE
.DSXMOVE
	BCS.S	.LEFT
	EXG.L	D0,D1				;D0-->D1
	LEA	SCRIPT_2X(PC),A1
	add.w	#320+(SCRLA-160),d0
	add.w	#320+(SCRLA-160),d1
	bra.s	.RIGHT
.LEFT	SUB.W	#SCRLA-160,D0
	SUB.W	#SCRLA-160,D1
.RIGHT	MOVE.W	WINDY,D2
	MOVE.W	D2,D3
	SUB.W	#SCRLAY,D2
	ADD.W	#SCRLAY,D3
	ADD.W	screen_height,D3		;D2 --> D3 Y
	
	BSR	DO_SCRIPT_BOX
	
.NODSXMOVE
	LEA	SCRIPT_0X(PC),A1
	MOVE.W	#SCRLAY,D0
	MOVE.W	WINDY,D2
	MOVE.W	WINDYOLD,D3
	and.w	#$fff0,d2
	and.w	#$fff0,d3
	CMP.W	D3,D2
	BNE.S	.DSYMOVE
	RTS
.DSYMOVE
	BCS.S	.UP
	ADD.W	screen_height,D0
	EXG.L	D2,D3				;D2-->D3
	ADD.W	D0,D2
	ADD.W	D0,D3
	BRA.S	.DOWN
.UP	SUB.W	D0,D2
	SUB.W	D0,D3
	
.DOWN

	MOVE.W	WINDX,D0			;D0-->D1
	MOVE.W	D0,D1
	SUB.W	#SCRLA-160,D0
	ADD.W	#320+(SCRLA-160),D1		;D0 --> D1 X
	
	BSR	DO_SCRIPT_BOX
	RTS

SCRIPT_0X	DC.L	0	
SCRIPT_1X	DC.L	0	
SCRIPT_2X	DC.L	0	
	
	

FIND_SCRIPT_START				;A0 POINTER TO LAST
	tst.w	d0
	beq.s	.exit
	bpl.s	.ok
.exit	lea	SCRIPT,a0
	rts
.ok	CMP.W	(A0),D0				;D0 = XVALUE TO SEEK TO
	BCC.S	.LESS_THAN
.MORE_THAN
	SUBQ.W	#6,A0
	CMP.W	(A0),D0
	BCS.S	.MORE_THAN
	RTS	
	
.LESS_THAN
	ADDQ.W	#6,A0
	CMP.W	(A0),D0
	BCC.S	.LESS_THAN
	RTS	


DO_SCRIPT_BOX
	tst.w	d0				;start cannot be negative
	bpl.s	.ok1
	moveq	#0,d0				;if end is negative then no comparision
.ok1	tst.w	d1
	bpl.s	.ok2
	rts
.ok2	tst.w	d2
	bpl.s	.ok3
	moveq	#0,d2
.ok3	tst.w	d3
	bpl.s	.ok4
	rts
.ok4	cmp.w	d0,d1
	bne.s	.ok5
	rts
.ok5	cmp.w	d2,d3
	bne.s	.ok6
	rts
.ok6	

	MOVE.L	(A1),A0
	IFNE	DEBUG
	move.l	#$ff000000,BORD1
	ENDC
	BSR	FIND_SCRIPT_START		; HOME IN ON D0 {X}  WHERE WE ARE
	IFNE	DEBUG
	move.l	#-1,BORD1
	ENDC
	

	MOVE.L	A0,(A1)
	LEA	OBJENFLAGS,A1
	lea	OBJBASEEND,a6
	
.LOOP	
	MOVE.W	(A0),D0
	
	CMP.W	D1,D0
	BGT.S	.OUT_OF_HERE
	
	MOVE.w	SCRKEY(A0),D0
	BMI.s	.NOT_IN_RANGE
	
	
	MOVE.W	2(A0),D0
	CMP.W	D0,D2
	BGT.S	.NOT_IN_RANGE
	CMP.W	D0,D3
	BLT.S	.NOT_IN_RANGE
	
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	move.w	d3,-(sp)			;A0 saved in routine
	
	IFNE	DEBUG
	move.l	#$ffff0000,BORD1
	ENDC
	JSR	STARTOBJ			;D1/D2/D3/A0 MUST BE PRESERVED
	IFNE	DEBUG
	move.l	#-1,BORD1
	ENDC
	
	move.w	(sp)+,d3
	move.w	(sp)+,d2
	move.w	(sp)+,d1

.NOT_IN_RANGE
	ADDQ.W	#6,A0
	BRA.S	.LOOP
.OUT_OF_HERE
	RTS
	
	
	
	
	
	
	
	