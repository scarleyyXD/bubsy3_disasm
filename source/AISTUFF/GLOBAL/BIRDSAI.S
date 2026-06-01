;;;ASBx: ; THESE ARE THE BIRDS THAT ARE SEEN WHEN BUBSY IS UNCONCIOUS
BIRDSAI:
	JSR	DOINITIALDMA
	move.w	OBJAUX0(A5),d1
	ADDQ.w	#1,d1
	moveq	#%111,d0
	and.w	d1,D0
	BNE.s	.NOFRAME
	move.w	d1,d0
	LSR.w	#3,D0
	MOVE.B	.FRAMELIST(PC,D0.W),D0
	CMP.B	#$FF,D0
	BEQ.s	.DIE
	MOVE.B	D0,OBJFRAME(A5)
	
.NOFRAME:
	MOVE.w	d1,OBJAUX0(A5)
	JMP	ENEMYOAMS
	
.DIE:
	JMP	CLEAROBJWVRAM

.FRAMELIST:
	dc.b 4,3,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0,1,2
	dc.b 0
	dc.b 3,4,$FF
	even