color_p	equ	0	; COLOR POINTER BODGE

;---------------------------------------------------
; GPU+ASSOCIATE MACROS
.macro	GPU_SUB	O1
	move.l	\O1,gpu_routine
	.endm

.macro	START_GPU
	move.l	#$1,G_CTRL-BASE(a5)
	.endm

.macro	STOP_GPU
	move.l	#$0,G_CTRL-BASE(a5)
	.endm

.macro	WAIT_GPU
.1\~:	tst.l	gpu_routine
	bne.s	.1\~
	.endm
	
	extern	fasta_gpu_sprite_draw_prog
	extern	fastb_gpu_sprite_draw
	extern	fastc_gpu_sprite_drawe
	extern	gpu_routine
	extern	sprite_return_obytes
;;;	extern	ar,um
	extern	sprite_params
	extern	rad_params
	extern	builda_star_prog
	extern	buildb_star_gpu
	extern	buildc_star_gpue
	extern	builda_circle_prog
	extern	buildb_circle_gpu
	extern	buildc_circle_gpue
	extern	xxx
	extern	init_gpu
	extern	builda_wibbly_text_prog
	extern	buildb_wibbly_text_gpu
	extern	buildc_wibbly_text_gpue
	extern	wibbleparams
	extern	starparams