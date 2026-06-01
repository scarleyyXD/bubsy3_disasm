NTSC_HMID	equ	823
NTSC_VWIDTH	equ	1409
NTSC_VMID	equ	322
NTSC_HEIGHT	equ	240
	
PAL_HMID	equ	843
PAL_VWIDTH	equ	1281
PAL_VMID	equ	322
PAL_HEIGHT	equ	280
	
	
ON	equ	1
OFF	equ	0

NTSC	equ	OFF
init:	IFNE	NTSC

	move.w	#NTSC_HMID,d2
	move.w	#NTSC_VWIDTH,d0
	move.w	#NTSC_VMID,d6
	move.w	#NTSC_HEIGHT,d4
	
	
	ELSE
	
	move.w	#PAL_HMID,d2
	move.w	#PAL_VWIDTH,d0
	move.w	#PAL_VMID,d6
	move.w	#PAL_HEIGHT,d4
	
	
	ENDC
	
	move.w	d0,width
	move.w	d4,height
	
	move.w	d0,d1
	asr	#1,d1
	
	sub.w	d1,d2
	addq	#4,d2
	
	subq	#1,d1
	eor	#$400,d1
	
	move.w	d1,a_hde
	
	move.w	d2,a_hdb
	
	
	move.w	d6,d5
	sub.w	d4,d5
	move.w	d5,a_vdb
	
	add	d4,d6
	move.w	d6,a_vde
	
	
	illegal
	
a_hdb	dc.w	0
a_hde	dc.w	0
a_vdb	dc.w	0
a_vde	dc.w	0
width	dc.w	0
height	dc.w	0
