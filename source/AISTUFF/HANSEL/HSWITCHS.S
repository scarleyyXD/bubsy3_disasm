HSWITCH_FRAMES	equ	104
hswitch_dma:
	dc.l	.frame0
	dc.l	.frame1

.frame0:	dc.w	1,-12,-37+16,-1
	dc.w	0,0,HSWITCH_FRAMES+0
.frame1:	dc.w	1,-12,-37+16,-1
	dc.w	0,0,HSWITCH_FRAMES+1
