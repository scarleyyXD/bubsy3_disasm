; made from the ground up

.macro	IFNOTPAL	O1
	cmpi.b	#PAL,tv_type
	bne.w	\O1
	.endm

.macro	LOADREG
	lea	video_branches,a4
	lea	BASE,a5
	.endm