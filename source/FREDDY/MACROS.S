.macro	IFNOTPAL
	cmpi.b	#PAL,tv_type
	bne.w	\1
	.endm
.macro	LOADREG
	lea	video_branches,a4
	lea	BASE,a5
	.endm