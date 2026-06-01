
get_random:	move.w	HC-BASE(a5),d0
	move.w	VC-BASE(a5),d1
	add.w	d1,d0
	ror.w	#3,d0
	add.w	d0,random_number(a4)
	move.w	random_number(a4),d0
	rts

