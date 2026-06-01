ALICE_DOOR_BLOCK	equ	47
alice_door_dma:
	dc.l	.door
.door:
	dc.w	1,0,-16,32
	dc.w	0,0,ALICE_DOOR_BLOCK