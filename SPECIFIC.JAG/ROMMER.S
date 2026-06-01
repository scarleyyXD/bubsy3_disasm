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

load_file_no_wait:
	bsr	locate_rom_file
	moveq	#0,d0
	jsr	DECOMPRESSGPUPP1
	rts

load_file:
	move.l	a1,-(sp)
	cmp.l	#"RNC"<<8+1,(a0)
	bne.s	.not_compressed
	move.l	4(a0),-(sp)
	bsr	MYWAITFORGPU
	moveq	#0,d0
	jsr	DECOMPRESSGPUPP1
	bsr	MYWAITFORGPU
	bra.s	.exit_loader
.not_compressed:
	move.l	d0,-(sp)
.loop:	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.loop
.exit_loader:
	movem.l	(sp)+,d0/a0
	rts

; a0 - pointer to file name
; returns
; d0 - length of file

get_file_length:
	bsr	locate_rom_file
	cmp.l	#"RNC"<<8+1,(a0)
	bne.s	.not_compressed
	move.l	4(a0),d0
.not_compressed:
	rts	


; returns
; a0 - pointer to file
; d0 - length

locate_rom_file:
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	a0,a6
	lea	ROMBASE,a2
	move.w	(a2)+,d0
	subq.w	#1,d0
.loop:	move.l	a2,a1
	move.l	a0,-(sp)
	bsr	.compare_string
	movem.l	(sp)+,a0
	bne.s	.dec
	move.l	18(a2),a0
	add.l	#ROMBASE,a0
	move.l	14(a2),d0
	bra.s	.exit
.dec:	lea	22(a2),a2
	dbra	d0,.loop
	lea	filename_error_name,a1
.lp:	move.b	(a6)+,(a1)+
	bne.s	.lp
	pea	filename_error(pc)
	move.w	#$f000,-(sp)
	move.w	#5,-(sp)
	move.w	#$b,-(sp)
	trap	#14
	illegal
.exit:	movem.l	(sp)+,d1-d7/a1-a6
	rts

.compare_string:
	tst.b	(a0)
	beq.s	.done
	cmp.b	(a0)+,(a1)+
	beq.s	.compare_string
	rts
.done:	tst.b	(a1)
	rts

MYWAITFORGPU:	move.l	d0,-(sp)
.lp:		moveq	#0,d0
		move.l	GPUSEMAPHORE,d0
		beq.s	.not_end
		move.l	(sp)+,d0
		rts
.not_end:	jsr	waitvbl
		bra.s	.lp

loaded_in_no_wait:
		moveq	#0,d0
		move.l	GPUSEMAPHORE,d0
		rts


filename_error:	dc.b	"The following file is missing form the ROM image ::::::::: "
filename_error_name:
		dc.b	"0123456789ABCDEF",0
		even	
