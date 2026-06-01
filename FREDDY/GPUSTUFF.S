color_p	equ	0	; COLOR POINTER BODGE

;---------------------------------------------------
; GPU+ASSOCIATE MACROS

GPU_SUB	macro
	move.l	\1,gpu_routine
	endm

START_GPU	macro
	move.l	#$1,G_CTRL-BASE(a5)
	endm

STOP_GPU	macro
	move.l	#$0,G_CTRL-BASE(a5)
	endm

WAIT_GPU	macro
.\@1:	tst.l	gpu_routine
	bne.s	.\@1
	endm



	xref.l	fasta_gpu_sprite_draw_prog
	xref.l	fastb_gpu_sprite_draw
	xref.l	fastc_gpu_sprite_drawe
	xref.l	gpu_routine
	xref.l	sprite_return_obytes
;;;	xref.l	ar,um
	xref.l	sprite_params
	xref.l	rad_params
	xref.l	builda_star_prog
	xref.l	buildb_star_gpu
	xref.l	buildc_star_gpue
	xref.l	builda_circle_prog
	xref.l	buildb_circle_gpu
	xref.l	buildc_circle_gpue
	xref.l	xxx
	xref.l	init_gpu
	xref.l	builda_wibbly_text_prog
	xref.l	buildb_wibbly_text_gpu
	xref.l	buildc_wibbly_text_gpue
	xref.l	wibbleparams
	xref.l	starparams
	