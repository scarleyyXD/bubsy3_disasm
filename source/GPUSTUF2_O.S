;; GPUSTUF2.O - 10/14/1993
;; Decompiled object file by Scarlett<3 (5/20-5/24)

unkreg			equ	G_RAM+$430
GPUSEMAPHORE	equ	G_RAM+$43C
PAL_NTSC		equ $F14002

SETUPGPU:
	movem.l d0/a0-a1,-(sp)
	move.l  #8,G_CTRL
	movea.l #G_RAM,a1
	move.l  a1,G_PC
	sub.l   a0,d0
	lsr.l   #2,d0
.lp:
	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	move.l	#1,GPUSEMAPHORE
	tst.w	d1
	bne.s	.lp2
	move.l	#0,G_FLAGS
	bra.s	.lp3
.lp2:
	move.l	#$8000,G_FLAGS
.lp3:
	tst.w	d2
	bne.s	.lp4
	move.l	#17,G_CTRL
.lp4:
	movem.l (sp)+,d0/a0-a1
	rts

WAITFORGPU:
	move.l  a0,-(sp)
	movea.l GPUSEMAPHORE,a0
.lp:
	tst.l	(a0)
	beq.w	.lp
	movea.l	(sp)+,a0
	rts

DECOMPRESSGPUPP1:
	movem.l a3,-(sp)
	movea.l #unkreg,a3
	move.l  a0,(a3)+
	move.l  a1,(a3)+
	move.l  #0,(a3)+
	move.l  #0,(a3)
	movem.l (sp)+,a3
	rts

STARTGPU:
	move.l  #17,G_CTRL
	rts
STOPGPU:
	move.l  #8,G_CTRL
	rts

GPUPP_S:
	rts

	.68000

GPUPP_E:	dc.w 0