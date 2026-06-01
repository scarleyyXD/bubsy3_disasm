FRACDIV	macro
	tst.w	\1
	bne.s	.\@1	
    	moveq	#0,\2
	bra.s	.\@2
.\@1:	ext.l	\2
	divu	\1,\2
	swap	\2
	move.l	d7,-(sp)
	moveq	#1,d7
	swap	d7
	divu	\1,d7
	mulu	\2,d7
	clr.w	\2
	add.l	d7,\2	
	move.l	(sp)+,d7
.\@2:
	endm	

ABSSET	macro
	tst.\0	\1
	smi	\2
	ABS	\1
	endm

INC	macro
	addq.\0	#1,\1
	endm

DEC	macro
	subq.\0	#1,\1
	endm


INCCMPRES macro
	addq.\0	#1,\1
	cmp.\0	#\2,\1
	bne.s	.\@1
	clr.\0	\1
.\@1:
	endm
	
ABS	macro
	tst.\0	\1
	bpl.s	.\@1
	neg.\0	\1
.\@1:	
	endm

EX	macro
	move.\0	\1,-(sp)
	move.\0	\2,\1
	move.\0	(sp)+,\2
	endm

ALIGNDATA	macro
	add.\0	#\1-1,\2
	and.\0	#-\1,\2
	endm	


PUSH	macro
	movem.l	d0-d7/a0-a6,-(sp)
	endm

PULL	macro
	movem.l	(sp)+,d0-d7/a0-a6
	endm


clear_bytes:	clr.b	(a0)+
	subq.l	#1,d0
	bne.s	clear_bytes
	rts

fast_copy_bytes:	PUSH
.loop:	sub.l	#48,d0
	bmi.s	.done
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	lea	48(a1),a1
	bra.s	.loop
.done:	add.l	#48,d0
	beq.s	.no_more
.loop1:	subq.l	#4,d0
	bmi.s	.no_more2
	move.l	(a0)+,(a1)+
	bra.s	.loop1
.no_more2:	addq.l	#4,d0
	beq.s	.no_more
	bsr	copy_bytes
.no_more:	PULL
	rts

copy_bytes:	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	copy_bytes
	rts

compare_string:	tst.b	(a0)
	beq.s	.done
	cmp.b	(a0)+,(a1)+
	beq.s	compare_string
	rts
.done:	tst.b	(a1)
	rts

	
BCDDIVIDE macro
	divu    #\1,d0
	not.b    d1
	Beq.s   .\@1
	Lsl.b   #4,d0
	Or.b    d0,(a1)
	Bra.s   .\@2
.\@1:    	Or.b    d0,(a1)+
.\@2:    	Clr.w   d0
	Swap    d0
	endm

long_to_bcd:       Clr.l   (a1)
	Sf      d1
	Move.l  (a0),d0
	Divu    #10000,d0
	Swap    d0
	Clr.w   d0
	Swap    d0
	BCDDIVIDE 1000
	BCDDIVIDE 100
	BCDDIVIDE 10
	Or.b    d0,(a1)+
	Move.l  (a0),d0
	Divu    #10000,d0
	Clr.w   d0
	Swap    d0
	Sf      d1
	BCDDIVIDE 1000
	BCDDIVIDE 100
	BCDDIVIDE 10
	Or.b    d0,(a1)+
	Rts


ascii_to_long:	moveq	#0,d1
	moveq	#8-1,d2
.loop1:	move.l	d1,d3
	lsl.l	#3,d1
	add.l	d3,d1
	add.l	d3,d1
	moveq	#0,d3
	move.b	(a0)+,d3
	sub.b	#"0",d3
	add.l	d3,d1
	dbra	d2,.loop1       
	move.l	d1,d0
	rts

