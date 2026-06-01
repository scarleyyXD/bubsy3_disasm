	include	"jaguar.inc"

	extern	GPUPP_S
	extern	GPUPP_E

	extern	SETUPGPU
	extern	DECOMPRESSGPUPP1
	extern	WAITFORGPU
	extern	GPUSEMAPHORE

		.text

rom_file_table	equ	$802a00
ROMBASE			equ	rom_file_table
two_meg_sp		equ	$200000-8
LEVEL2			equ	4*$40

rom_pc:
	lea	two_meg_sp,sp
	lea	BASE,a6
	move.l	#$00070007,d0
	move.l	d0,G_END-BASE(a6)
	move.l	d0,D_END

	move.l	#$8,G_CTRL-BASE(a6)		;make sure GPU is stopped
	move.l	#no_vbl,LEVEL2.w
	moveq	#1,d1
	move.w	d1,INT1-BASE(a6)
	move.w	d1,INT2-BASE(a6)
	moveq	#0,d1
	move.w	d1,PIT0-BASE(a6)
	move.w	d1,PIT1-BASE(a6)

	lea	GPUPP_S(pc),a0
	move.l	#GPUPP_E,d0
	moveq.l	#1,d1			;dma priority
	moveq.l	#0,d2			;start running now
	bsr	SETUPGPU
	
	move.w	sr,d0
	and.w	#$f8ff,d0
	move.w	d0,sr
	
	lea	$4000.w,a1
	lea	prog_name(pc),a0
	bsr.s	file_load
	add.l	d0,a1
	lea	prog_data(pc),a0
	bsr.s	file_load
	move.w	sr,d0
	or.w	#$0700,d0
	move.w	d0,sr
	
	jmp	$4000.w
	
no_vbl:	
	move.w	#$101,INT1
	rte

prog_name:	dc.b	"GAME.TXT",0
prog_data:	dc.b	"GAME.DTA",0

***************
; pass
; a0 - file to load
; a1 - where to load it
; returns
; d0 - length
; a0 - pointer to file

file_load:				;my label
load_in_file_from_rom:			;fred's label
	bsr	locate_rom_file
	bsr	load_file
	rts

load_file:
	move.l	a1,-(sp)
	cmp.l	#"RNC"<<8+1,(a0)
	bne.s	.not_compressed
	move.l	4(a0),-(sp)
	moveq	#0,d0
	bsr	MYWAITFORGPU
	jsr	DECOMPRESSGPUPP1
	bsr	MYWAITFORGPU
	bra.s	.exit_loader
.not_compressed:
	move.l	d0,-(sp)
.loop:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.loop
.exit_loader:
	movem.l	(sp)+,d0/a0
	rts

; a0 - pointer to file
; d0 - length

locate_rom_file:
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	a0,a6
	lea	ROMBASE,a2
	move.w	(a2)+,d0
	subq.w	#1,d0
.loop:
	move.l	a2,a1
	move.l	a0,-(sp)
	bsr	.compare_string
	movem.l	(sp)+,a0
	bne.s	.dec
	move.l	18(a2),a0
	add.l	#ROMBASE,a0
	move.l	14(a2),d0
	bra.s	.exit
.dec:
	lea	22(a2),a2
	dbra	d0,.loop
	illegal
.exit:
	movem.l	(sp)+,d1-d7/a1-a6
	rts

.compare_string:
	tst.b	(a0)
	beq.s	.done
	cmp.b	(a0)+,(a1)+
	beq.s	.compare_string
	rts
.done:
	tst.b	(a1)
	rts

MYWAITFORGPU:
	move.l	d0,-(sp)
.lp:
	moveq	#0,d0
	move.l	GPUSEMAPHORE,d0
	beq.s	.lp
	move.l	(sp)+,d0
	rts
