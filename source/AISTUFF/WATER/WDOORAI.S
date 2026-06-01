WATER_DOOR_BLOCK	equ	88
water_door_dma:
	dc.l	.door
	
.door:
	dc.w	1,0,-16,32
	dc.w	0,0,WATER_DOOR_BLOCK
