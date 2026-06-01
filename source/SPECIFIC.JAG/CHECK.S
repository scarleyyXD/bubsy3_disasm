	.text
	
start:
	lea	$802000,a0		;start of the rom
	lea	$a00000,a1		;end of rom
	lea	checksum_area,a2
	
.outer:
	move.w	#$2000/4-1,d0		;number of comparisons to do
	moveq	#0,d1			;reset check sum to 0
	moveq	#0,d2			;used for addc (overflow)
	
.inner:
	move.l	(a0)+,d3		;get value

	add.l	d3,d1			;add this value to check sum
	addx.l	d2,d1			;if overflow then add 1 else 0
	rol.l	#3,d1			;rotate the number by 3
	dbf	d0,.inner
	move.l	d1,(a2)+		;save the check sum

	cmp.l	a0,a1			;see if end on memory
	bne.s	.outer			;if not then repeat
	
	lea	checksum_area,a0	; point to start of the buffer
	move.l	a2,d0
	sub.l	a0,d0			; length of the buffer
	
	lea	checksum_area,a0
	lea	was_sum_area,a1
	lea	was_sum_area_end,a2
	
.lp:
	move.l	(a0)+,d0
	move.l	(a1)+,d1
	eor.l	d1,d0
	bne.s	.err
	cmp.l	a1,a2
	bne.s	.lp
	moveq	#0,d0
	move.l	d0,a0
	illegal
	
.err:
	exg	d1,a0
	sub.l	#checksum_area+4,d1
	mulu	#$2000,d1
	add.l	#$802000,d1
	exg.l	a0,d1
	illegal
	
	.data
was_sum_area:	incbin	"c:\\check.img"
was_sum_area_end:
	.bss
checksum_area:	ds.l	($a00000-$802000)/($2000/4)