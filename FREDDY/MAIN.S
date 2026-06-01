
;;	include	"jaguar.inc"

	section	text

; Global jaguar routines
boot_up_here:	jmp	setup_jaguar(pc)
	dc.b	"AMD REMEMBER THE NAME OF THE GAME IS ONE FRAME !"
	
	even

	
	
	include	"xrefs.s"
	include	"equates.s"
	include	"macros.s"
	include	"68000.s"
	include	"variables.s"
	include	"diskname.s"
	include	"object.s"
	include	"sprite.s"
	include	"color.s"
;;;;	include	"joypad.s"
	include	"setup.s"
	include	"interupt.s"
	include	"gpustuff.s"
	include	"disk.s"
	include	"intro.s"
	include	"blitter.s"
	include	"random.s"
	include	"text.s"
	include	"music.s"

start:	bsr	setup_mystuff
	
main_loop:	bra	intro

setup_mystuff:	
	LOADREG
	move.l	a4,a0
	move.l	#varend,d0

	bsr	clear_bytes
	jsr	init_gpu
	move.w	#PAL_HEIGHT,scree_height_fred(a4)
	cmp.b	#PAL,tv_type
	beq.s	.pal
	move.w	#NTSC_HEIGHT,scree_height_fred(a4)
.pal:	
	move.l	#MAXOBJECTS*16,d0
	bsr	allocate_memory
	move.l	a0,backup_list_pointer(a4)
	ALIGNDATA.l 16,backup_list_pointer(a4)

	move.l	#MAXOBJECTS*16,d0
	bsr	allocate_memory
	move.l	a0,object_list_pointer+0(a4)
	ALIGNDATA.l 16,object_list_pointer+0(a4)

	move.l	#MAXOBJECTS*16,d0
	bsr	allocate_memory
	move.l	a0,object_list_pointer+4(a4)
	ALIGNDATA.l 16,object_list_pointer+4(a4)

	move.l	memory_used(a4),min_memory(a4)

	st	made_object_list(a4)
	bsr	setup_interupt

	rts	


	include	"data.s"


	





