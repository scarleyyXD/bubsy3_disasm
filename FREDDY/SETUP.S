SCREEN_WIDTH	equ	324
NTSC_HEIGHT	equ	(disp_height)
PAL_HEIGHT	equ	(disp_height+disp_change)



PAL	equ	0
NTSC	equ	1


setup_jaguar:
	
	move.w	#0,INT1
	move.l	#null_ol,d0
	swap	d0
	move.l	d0,OLP
	move.w	#$2100,sr
	lea	my_stack,a7	; Top of ram for stack
	move.w	#$7c1,VMODE	; variable colour mode (bit0=0=CRY)
	bsr	screen_black	; Clear border and paper
	move.l	#0,G_FLAGS
	move.l	#0,G_CTRL 	; Kill GPU
	move.l	#0,G_DIVCTRL
	
;	move.l	#0,D_CTRL
;	move.l	#0,D_FLAGS	; Kill DSP

	move.l	#$00070007,d0
	move.l	d0,G_END
;	move.l	d0,D_END


	move.l	JOYSTICK,d0
	btst	#4,d0	; Test pal/ntsc bit
	bne.s	.ntsc	; 0, then we are running ntsc

.pal:	move.b	#PAL,tv_type
	move.w	#pal_n_hde,HDE
	move.w	#pal_n_vde+1,VI
	bra.s	.done

.ntsc:	move.b	#NTSC,tv_type
	move.w	#ntsc_n_hde,HDE
	move.w	#ntsc_n_vde+1,VI

.done:	move.w	#ntsc_n_hdb1,HDB1
	move.w	#ntsc_n_hdb2,HDB2
	move.w	#ntsc_n_vdb,VDB
	
	move.w	#-1,VDE
	move.w	#999,PIT0
	move.w	#531,PIT1

	lea	video_branches,a1
	STACKOBJ
	move.w	#STOP_OBJECT,obj_type(a0)
	bsr	make_object
	IFNOTPAL	.ntsc_branches
	move.w	#BRANCH_OBJECT,obj_type(a0)
	move.l	#video_branches,obj_link(a0)
	move.w	#BRANCHLT,obj_cc(a0)
	Move.w	#pal_n_vde,obj_ypos(a0)
	bsr	make_object
	move.w	#BRANCH_OBJECT,obj_type(a0)
	move.l	#video_branches,obj_link(a0)
	move.w	#BRANCHGT,obj_cc(a0)
	Move.w	#pal_n_vdb,obj_ypos(a0)
	bsr	make_object
	bra.s	.done_branches

.ntsc_branches:	move.w	#BRANCH_OBJECT,obj_type(a0)
	move.l	#video_branches,obj_link(a0)
	move.w	#BRANCHLT,obj_cc(a0)
	Move.w	#ntsc_n_vde,obj_ypos(a0)
	bsr	make_object
	move.w	#BRANCH_OBJECT,obj_type(a0)
	move.l	#video_branches,obj_link(a0)
	move.w	#BRANCHGT,obj_cc(a0)
	Move.w	#ntsc_n_vdb,obj_ypos(a0)
	bsr	make_object

.done_branches:	move.w	#STOP_OBJECT,obj_type(a0)
	bsr	make_object
	UNSTACKOBJ
	jmp	start(pc)	; Finished initializing	


screen_black:
	move.w	#0,BG
	move.l	#0,BORD1	; Black for background/paper
	rts

