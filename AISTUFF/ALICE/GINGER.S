
ACOOKIE	equ	116

agingerhead_dma
	dc.l	.frame7
	dc.l	.frame6
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0


.frame0	dc.w	1,0,0,-1
	dc.w	-16,-31,31-31+ACOOKIE
.frame1	dc.w	1,0,0,-1
	dc.w	-16,-31,32-31+ACOOKIE
.frame2	dc.w	1,0,0,-1
	dc.w	-16,-31,33-31+ACOOKIE
.frame3	dc.w	1,0,0,-1
	dc.w	-16,-31,34-31+ACOOKIE
.frame4	dc.w	1,0,0,-1
	dc.w	-16,-31,35-31+ACOOKIE
.frame5	dc.w	1,0,0,-1
	dc.w	-16,-31,36-31+ACOOKIE
.frame6	dc.w	1,0,0,-1
	dc.w	-16,-31,37-31+ACOOKIE
.frame7	dc.w	1,0,0,-1
	dc.w	-16,-31,38-31+ACOOKIE


