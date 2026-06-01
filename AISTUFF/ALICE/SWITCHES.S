ASWITCH_FRAMES	equ	45
aswitch_dma
	dc.l	.frame0
	dc.l	.frame1
	
.frame0	dc.w	1,-12,-37+16,-1
	dc.w	0,0,ASWITCH_FRAMES+0
	
.frame1	dc.w	1,-12,-37+16,-1
	dc.w	0,0,ASWITCH_FRAMES+1
