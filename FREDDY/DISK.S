
SUBTRACT_MEMORY  macro
	sub.l	#\1,memory_used(a4)
	endm

ADD_MEMORY	macro
	add.l	#\1,memory_used(a4)
	endm

STANDARD_LOAD macro
	lea	\1,a0
	bsr	load_in_file_from_rom_fred
	move.l	a0,\2
	endm

LOAD_AND_FIX_SPRITES macro
	STANDARD_LOAD \3,\4
	STANDARD_LOAD \1,\2
	move.l	\2,a0
	move.l	\4,a1
	clr.w	jsprite_palindex(a0)
	clr.w	jsprite_palindex+16(a0)
	bsr	format_jag_sprites
	endm	

LOAD_AND_FIX_FAST_SPRITES macro
	STANDARD_LOAD \3,\4
	STANDARD_LOAD \1,\2
	move.l	\2,a0
	move.l	\4,a1
	clr.w	jsprite_palindex(a0)
	clr.w	jsprite_palindex+16(a0)
	move.l	d0,-(sp)
	bsr	format_jag_sprites
	move.l	(sp)+,d0
	bsr	allocate_memory
	move.l	a0,a1
	move.l	a1,\5
	move.l	\2,a0
	bsr	generate_fast_sprites
	endm	

LOAD_AND_FIX_MAP	macro
	STANDARD_LOAD \1,\2
	move.l	\2,a0
	bsr	fix_map
	endm

LOAD_AND_FIX_APL macro	;	aplname,aplpointer,objpointer,palpointer
	STANDARD_LOAD \1,\2
	
	ifeq	(NARG-4)
	move.l	d0,-(sp)
	SUBTRACT_MEMORY $400
	move.l	#512,d0
	bsr	allocate_memory
	move.l	a0,\4
	move.l	a0,a1
        move.l	\2,a0
	bsr	conert_apl_palette
	move.l	(sp)+,d0
	ADD_MEMORY $400
	endc
	
	move.l	\2,a1
	lea	$400(a1),a0
	sub.l	#$400,d0
	bsr	copy_bytes	
	SUBTRACT_MEMORY $400
	
	ifeq	(NARG-3)
	moveq	#16,d0
	bsr	allocate_memory
	move.l	a0,\3
	moveq	#STANDARD_BLOCKDIM,d1
	move.l	a0,a1
	move.l	\2,a2
	moveq	#OPIXEL8,d0
	bsr	make_attribute_block
	bsr	strip_data
	endc
	endm



LOAD_APL_TO_OBJ macro
	STANDARD_LOAD \1,\2
	moveq	#16,d0
	bsr	allocate_memory
	move.l	a0,\3
	moveq	#STANDARD_BLOCKDIM,d1
	move.l	a0,a1
	move.l	\3,a2
	moveq	#OPIXEL8,d0
	bsr	make_attribute_block
	bsr	strip_data
	endm

LOAD_APL_TO_OBJ4BITS	macro
	STANDARD_LOAD \1,\2
	moveq	#16,d0
	bsr	allocate_memory
	move.l	a0,\3
	moveq	#STANDARD_BLOCKDIM,d1
	move.l	a0,a1
	move.l	\2,a2
	moveq	#OPIXEL4,d0
	bsr	make_attribute_block
	bsr	strip_data
	endm
	
; pass
; d0 - number of bytes to allocate

; returns
; a0 - pointer to memory

allocate_memory:	lea	file_area,a0
	add.l	memory_used(a4),a0	
	add.l	d0,memory_used(a4)
	bsr	fix_memory_used
	rts


; pass
; a0 - file to load

; returns
; d0 - length
; a0 - pointer to file

file_load_file:
load_in_file_from_rom_fred:
	bsr	locate_rom_file_fred
	lea	file_area,a1
	add.l	memory_used(a4),a1
	bsr	load_file_fred
	add.l	d0,memory_used(a4)
	bsr	fix_memory_used
	rts

; pass
; a0 - file to load
; a1 - destination

; returns
; d0 - length
; a0 - pointer to file

fixed_load_in_file_from_rom:
	move.l	a1,-(sp)
	bsr	locate_rom_file_fred
	move.l	(sp)+,a1
	bsr	load_file_fred
	rts

load_file_fred:
	move.l	a1,-(sp)
	cmp.l	#"RNC"<<8+1,(a0)
	bne.s	.not_compressed
	move.l	4(a0),-(sp)
	moveq	#0,d0
	movem.l	d0/a0,-(sp)
	STOP_GPU
	jsr	trev_gpu
	movem.l	(sp)+,d0/a0
	jsr	DECOMPRESSGPUPP1
	jsr	WAITFORGPU
	STOP_GPU
;	jsr	init_gpu
	jsr	xxx
	bra.s	.exit_loader
.not_compressed:	move.l	d0,-(sp)
	bsr	blitter_copy
.exit_loader:	movem.l	(sp)+,d0/a0
	rts

.error:	illegal		; cant find file !

fix_memory_used:	ALIGNDATA.l 8,memory_used(a4)
	rts

; a0 - pointer to file name
; returns
; d0 - length of file

get_file_length_fred:
	bsr	locate_rom_file_fred
	cmp.l	#"RNC"<<8+1,(a0)
	bne.s	.not_compressed
	move.l	4(a0),d0
.not_compressed:	rts	


; returns
; a0 - pointer to file
; d0 - length

locate_rom_file_fred:	movem.l	d1-d7/a1-a6,-(sp)
	lea	ROMBASE,a2
	move.w	(a2)+,d0
	subq.w	#1,d0
.loop:	move.l	a2,a1
	move.l	a0,-(sp)
	bsr	compare_string
	movem.l	(sp)+,a0
	bne.s	.dec
	move.l	18(a2),a0
	add.l	#ROMBASE,a0
	move.l	14(a2),d0
	bra.s	.exit
.dec:	lea	22(a2),a2
	dbra	d0,.loop
	illegal
.exit:	movem.l	(sp)+,d1-d7/a1-a6
	rts

