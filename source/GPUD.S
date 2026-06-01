;; FREDDY\GPU.O - 10/27/1994
;; Decompiled object file by Scarlett<3 (5/23-5/24)

loc_2C198:
	clr.b	(a0)+
	subq.l	#1,d0
	bne.s	loc_2C198
	rts

sub_2C1A0:
	movem.l d0-d7/a0-a6,-(sp)
loc_2C1A4:
	sub.l	#48,d0
	bmi.s	loc_2C1BA
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	lea	48(a1),a1
	bra.s	loc_2C1A4
loc_2C1BA:
	add.l   #48,d0
	beq.s   loc_2C1D2
loc_2C1C2:
	subq.l	#4,d0
	bmi.s	loc_2C1CA
	move.l	(a0)+,(a1)+
	bra.s	loc_2C1C2
loc_2C1CA:
	addq.l	#4,d0
	beq.s	loc_2C1D2
	bsr.w	sub_2C1D8
loc_2C1D2:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
sub_2C1D8:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	sub_2C1D8
	rts

loc_2C1E0:
	tst.b	(a0)
	beq.s	loc_2C1EA
	cmpm.b	(a0)+,(a1)+
	beq.s	loc_2C1E0
	rts
loc_2C1EA:
	tst.b	(a1)
	rts

loc_2C1EE:
	clr.l	(a1)
	sf	d1
	move.l	(a0),d0
	divu.w	#$2710,d0
	swap	d0
	clr.w	d0
	swap	d0
	divu.w	#$3E8,d0
	not.b	d1
	beq.s	loc_2C20C
	lsl.b	#4,d0
	or.b	d0,(a1)
	bra.s	loc_2C20E
loc_2C20C:
	or.b	d0,(a1)+
loc_2C20E:
	clr.w   d0
	swap    d0
	divu.w  #$64,d0
	not.b   d1
	beq.s   loc_2C220
	lsl.b   #4,d0
	or.b    d0,(a1)
	bra.s   loc_2C222
loc_2C220:
	or.b	d0,(a1)+
loc_2C222:
	clr.w	d0
	swap	d0
	divu.w	#$A,d0
	not.b	d1
	beq.s	loc_2C234
	lsl.b	#4,d0
	or.b	d0,(a1)
	bra.s	loc_2C236
loc_2C234:
	or.b	d0,(a1)+
loc_2C236:
	clr.w	d0
	swap	d0
	or.b	d0,(a1)+
	move.l	(a0),d0
	divu.w	#$2710,d0
	clr.w	d0
	swap	d0
	sf	d1
	divu.w	#$3E8,d0
	not.b	d1
	beq.s	loc_2C256
	lsl.b	#4,d0
	or.b	d0,(a1)
	bra.s	loc_2C258
loc_2C256:
	or.b	d0,(a1)+
loc_2C258:
	clr.w	d0
	swap	d0
	divu.w	#$64,d0
	not.b	d1
	beq.s	loc_2C26A
	lsl.b	#4,d0
	or.b	d0,(a1)
	bra.s	loc_2C26C
loc_2C26A:
	or.b	d0,(a1)+
loc_2C26C:
	clr.w	d0
	swap	d0
	divu.w	#$A,d0
	not.b	d1
	beq.s	loc_2C27E
	lsl.b	#4,d0
	or.b	d0,(a1)
	bra.s	loc_2C280
loc_2C27E:
	or.b	d0,(a1)+
loc_2C280:
	clr.w	d0
	swap	d0
	or.b	d0,(a1)+
	rts

loc_2C288:
	moveq	#0,d1
	moveq	#7,d2

loc_2C28C:
	move.l	d1,d3
	lsl.l	#3,d1
	add.l	d3,d1
	add.l	d3,d1
	moveq	#0,d3
	move.b	(a0)+,d3
	sub.b	#48,d3
	add.l	d3,d1
	dbf	d2,loc_2C28C
	move.l	d1,d0
	rts

	even
dword_2C2A8:	dc.l 0

init_gpu:
sub_2CA50:
	move.l	#0,$2114(a5)
	lea	($2D028).l,a0
	lea	($F03F00).l,a1
	move.l	#$5C,d0
	jsr	(sub_2C1A0).l

	move.l	#0,$2100(a5)
	move.l	#$F03F34,$2110(a5)
	move.l	#1,$2114(a5)
	rts
