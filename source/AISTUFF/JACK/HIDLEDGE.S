;call using the hidden ledge code from ALI but replace the DMA address with jhidledge_dma ...
JLEDGE_FRAME	equ	85

jhidledge_dma:
	dc.l	.ledge1				;never draw frame 0
	dc.l	.ledge1

.ledge1:
	dc.w	1,0,0,-1			;never flipped
	dc.w	-15,0,JLEDGE_FRAME
