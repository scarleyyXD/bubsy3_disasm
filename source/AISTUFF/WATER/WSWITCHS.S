WSWITCH_FRAMES	equ	89
wswitch_dma:
	dc.l	.frame0
	dc.l	.frame1
	
.frame0:	dc.w	1,-12,-37+16,-1
	dc.w	0,0,WSWITCH_FRAMES+0
.frame1:	dc.w	1,-12,-37+16,-1
	dc.w	0,0,WSWITCH_FRAMES+1
