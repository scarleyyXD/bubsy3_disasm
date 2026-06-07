color_p	equ	0	; COLOR POINTER BODGE

;---------------------------------------------------
; GPU+ASSOCIATE MACROS
.macro	GPU_SUB	O1
	move.l	\O1,gpu_routine
	.endm

.macro	START_GPU
	move.l	#1,G_CTRL-BASE(a5)
	.endm

.macro	STOP_GPU
	move.l	#0,G_CTRL-BASE(a5)
	.endm

.macro	WAIT_GPU
.1\~:	tst.l	gpu_routine
	bne.s	.1\~
	.endm

	.globl	fasta_gpu_sprite_draw_prog
	.globl	fastb_gpu_sprite_draw
	.globl	fastc_gpu_sprite_drawe
	.globl	gpu_routine
	.globl	sprite_return_obytes
;;;	.globl	ar,um
	.globl	sprite_params
	.globl	rad_params
	.globl	builda_star_prog
	.globl	buildb_star_gpu
	.globl	buildc_star_gpue
	.globl	builda_circle_prog
	.globl	buildb_circle_gpu
	.globl	buildc_circle_gpue
	.globl	xxx
	.globl	init_gpu
	.globl	builda_wibbly_text_prog
	.globl	buildb_wibbly_text_gpu
	.globl	buildc_wibbly_text_gpue
	.globl	wibbleparams
	.globl	starparams