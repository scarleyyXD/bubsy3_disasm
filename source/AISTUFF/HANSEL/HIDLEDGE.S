HLEDGE_FRAME		equ	103
	
hhidledge_dma:
	dc.l	.ledge1				;never draw frame 0
	dc.l	.ledge1

.ledge1:	dc.w	1,0,0,-1			;never flipped
	dc.w	-16,0,HLEDGE_FRAME