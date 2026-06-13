.macro	FRACDIV O1,O2
	tst.w	\O1
	bne.s	.1\~
	moveq	#0,\O2
	bra.s	.2\~
.1\~:
	ext.l	\O2
	divu	\O1,\O2
	swap	\O2
	move.l	d7,-(sp)
	moveq	#1,d7
	swap	d7
	divu	\O1,d7
	mulu	\O2,d7
	clr.w	\O2
	add.l	d7,\O2
	move.l	(sp)+,d7
.2\~:
	.endm

.macro	ABSSET O1,O2,O3
	if "\{O1}"="b"
		tst.b	\O2
	endif
	if "\{O1}"="w"
		tst.w	\O2
	endif
	if "\{O1}"="l"
		tst.l	\O2
	endif
	smi	\O3
	ABS	\O1,\O2
	.endm

.macro	INC O1,O2
	if "\{O1}"="b"
		addq.b #1,\O2
	endif
	if "\{O1}"="w"
		addq.w #1,\O2
	endif
	if "\{O1}"="l"
		addq.l #1,\O2
	endif
	.endm

.macro	DEC O1,O2
	if "\{O1}"="b"
		subq.b #1,\O2
	endif
	if "\{O1}"="w"
		subq.w #1,\O2
	endif
	if "\{O1}"="l"
		subq.l #1,\O2
	endif
	.endm

.macro	INCCMPRES O1,O2,O3
	if "\{O1}"="b"
		addq.b #1,\O2
		cmp.b	#\O3,\O2
		bne.s	.1\~
		clr.b	\O2
	endif
	if "\{O1}"="w"
		addq.w #1,\O2
		cmp.w	#\O3,\O2
		bne.s	.1\~
		clr.w	\O2
	endif
	if "\{O1}"="l"
		addq.l #1,\O2
		cmp.l	#\O3,\O2
		bne.s	.1\~
		clr.l	\O2
	endif
.1\~:
	.endm

.macro	ABS O1,O2
	if "\{O1}"="b"
		tst.b	\O2
		bpl.s	.1\~
		neg.b	\O2
	endif
	if "\{O1}"="w"
		tst.w	\O2
		bpl.s	.1\~
		neg.w	\O2
	endif
	if "\{O1}"="l"
		tst.l	\O2
		bpl.s	.1\~
		neg.l	\O2
	endif
.1\~:
	.endm

.macro	EX O1,O2,O3
	if "\{O1}"="b"
		move.b \O2,-(sp)
		move.b \O3,\O2
		move.b (sp)+,\O3
	endif
	if "\{O1}"="w"
		move.w \O2,-(sp)
		move.w \O3,\O2
		move.w (sp)+,\O3
	endif
	if "\{O1}"="l"
		move.l \O2,-(sp)
		move.l \O3,\O2
		move.l (sp)+,\O3
	endif
	.endm

.macro	ALIGNDATA O1,O2,O3
	if "\{O1}"="b"
		add.b	#\O2-1,\O3
		and.b	#-\O2,\O3
	endif
	if "\{O1}"="w"
		add.w	#\O2-1,\O3
		and.w	#-\O2,\O3
	endif
	if "\{O1}"="l"
		add.l	#\O2-1,\O3
		and.l	#-\O2,\O3
	endif
	.endm

.macro	PUSH
	movem.l	d0-d7/a0-a6,-(sp)
	.endm

.macro	PULL
	movem.l	(sp)+,d0-d7/a0-a6
	.endm

clear_bytes:
	clr.b	(a0)+
	subq.l	#1,d0
	bne.s	clear_bytes
	rts

fast_copy_bytes:
	PUSH
.loop:
	sub.l	#48,d0
	bmi.s	.done
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	lea	48(a1),a1
	bra.s	.loop
.done:
	add.l	#48,d0
	beq.s	.no_more
.loop1:
	subq.l	#4,d0
	bmi.s	.no_more2
	move.l	(a0)+,(a1)+
	bra.s	.loop1
.no_more2:
	addq.l	#4,d0
	beq.s	.no_more
	bsr	copy_bytes
.no_more:
	PULL
	rts

copy_bytes:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	copy_bytes
	rts

compare_string:
	tst.b	(a0)
	beq.s	.done
	cmp.b	(a0)+,(a1)+
	beq.s	compare_string
	rts
.done:
	tst.b	(a1)
	rts

.macro	BCDDIVIDE
	divu	#\1,d0
	not.b	d1
	beq.s	.1\~
	lsl.b	#4,d0
	or.b	d0,(a1)
	bra.s	.2\~
.1\~:
	or.b	d0,(a1)+
.2\~:
	clr.w	d0
	swap	d0
	.endm

long_to_bcd:
	clr.l	(a1)
	sf	d1
	move.l	(a0),d0
	divu	#10000,d0
	swap	d0
	clr.w	d0
	swap	d0
	BCDDIVIDE 1000
	BCDDIVIDE 100
	BCDDIVIDE 10
	or.b	d0,(a1)+
	move.l	(a0),d0
	divu	#10000,d0
	clr.w	d0
	swap	d0
	sf	d1
	BCDDIVIDE 1000
	BCDDIVIDE 100
	BCDDIVIDE 10
	or.b	d0,(a1)+
	rts

ascii_to_long:
	moveq	#0,d1
	moveq	#8-1,d2
.loop1:
	move.l	d1,d3
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
