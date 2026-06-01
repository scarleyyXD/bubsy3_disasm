compare_string:
	tst.b	(a0)
	beq.s	.done
	cmp.b	(a0)+,(a1)+
	beq.s	compare_string
	rts
.done:
	tst.b	(a1)
	rts
