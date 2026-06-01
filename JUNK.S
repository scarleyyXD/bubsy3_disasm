	include	"c:\\bin\\jaguar.inc"
	
	.68000
	
hello:	lea	gpu_go,a0
	illegal


	.gpu
	
	.org	G_RAM
	
gpu_go:
	movei	#hello,r0
	dc.l	hello
	dc.l	gpu_go
	
	.68000
	
