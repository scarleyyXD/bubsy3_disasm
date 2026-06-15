setup_interupt:	
	pea	interupt_server(pc)
	move.l	(sp)+,$100.w
	pea	standard_video(pc)
	move.l	(sp)+,video_service(a4)
	move.w	#0,INT2-BASE(a5)
	move.w	#$101,INT1-BASE(a5)
	bsr	wait_a_vbl
	rts

interupt_server:
	PUSH
	LOADREG
	move.w	INT1-BASE(a5),d0
	lea	ivectors(a4),a0
.loop:
	lsr.w	#1,d0
	bcc.s	.no_bit
	move.l	(a0),a1
	jsr	(a1)
	bra.s	exit_interupt
.no_bit:
	addq.l	#4,a0
	bra.s	.loop
exit_interupt:
	move.w	#0,INT2-BASE(a5)
	PULL
	rte

standard_timer:
	move.w	#$2100,sr
	move.w	#$808,INT1-BASE(a5)
	rts

intro_vbl:
	bsr	standard_video
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	play_music
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	readpad
	move.l	joycur1,d0
	btst	#HASH,d0
	beq.s	.no_reset1
	btst	#STAR,d0
	bne.s	.reset

.no_reset1:
	move.l	joycur2,d0
	btst	#HASH,d0
	beq.s	.no_reset
	btst	#STAR,d0
	beq.s	.no_reset

.reset:
	move.l	#boot_up_here,66(sp)
	movem.l	d0-a6,-(sp)
	jsr	STOP_MOD	;bsr->jsr
	jsr	DISABLE_
	movem.l	(sp)+,d0-a6
	rts

.no_reset:	
	jsr	sound_flip		;handle sound

	tst.b	no_exit(a4)	
	bne	.no_checking
	move.l	joyedge1,d0
	btst	#FIRE_A,d0
	bne.s	.pressed
	btst	#FIRE_B,d0
	bne.s	.pressed
	btst	#FIRE_C,d0
	bne.s	.pressed
	btst	#OPTIONS,d0
	bne.s	.pressed
	
	move.l	joyedge2,d0
	btst	#FIRE_A,d0
	bne.s	.pressed
	btst	#FIRE_B,d0
	bne.s	.pressed
	btst	#FIRE_C,d0
	bne.s	.pressed
	btst	#OPTIONS,d0
	bne.s	.pressed
	bra.s	.no_checking
.pressed:	
	bsr	screen_black
	tst.b	title_pic_being_displayed(a4)
	bne	.not_dis
	move.l	#title_up,66(sp)
	rts
.not_dis:
	if	ONLY_OPTIONS
	btst	#OPTIONS,d0
	beq.s	.not_options
	endif
	move.w	d0,KEY_PRESS_FROM_FRED
	move.l	#take_over_here_andy,66(sp)
.not_options:
.no_checking:
	rts

KEY_PRESS_FROM_FRED:	dc.w	0

standard_video:
	tst.b	made_object_list(a4)
	beq.s	.copy_old_list
	clr.b	made_object_list(a4)

	move.l	object_list_pointer(a4),a1
	moveq	#0,d0
	move.w	bytes_in_object_list(a4),d0
	add.l	d0,a1
	STACKOBJ
	move.w	#STOP_OBJECT,obj_type(a0)
	bsr	make_object
	add.w	d0,bytes_in_object_list(a4)
	move.w	#BRANCH_OBJECT,obj_type(a0)
	move.w	#BRANCHEQ,obj_cc(a0)
	move.w	#$7ff,obj_ypos(a0)
	move.l	object_list_pointer(a4),obj_link(a0)
	lea	video_branches+(3*8),a1
	bsr	make_object
	UNSTACKOBJ
	move.l	object_list_pointer(a4),a0
	move.l	backup_list_pointer(a4),a1
	moveq	#0,d0
	move.w	bytes_in_object_list(a4),d0
	bsr	fast_copy_bytes	
	EX	l,object_list_pointer(a4),object_list_pointer+4(a4)
	EX	w,bytes_in_object_list(a4),bytes_in_object_list+2(a4)
	bra.s	.done

.copy_old_list:
	move.l	object_list_pointer+4(a4),a1
	move.l	backup_list_pointer(a4),a0
	moveq	#0,d0
	move.w	bytes_in_object_list+2(a4),d0
	bsr	fast_copy_bytes	
	
.done:
	move.l	#video_branches+8,d0
	swap	d0
	move.l	d0,OLP-BASE(a5)
	addq.b	#1,vbl_counter(a4)
	addq.w	#1,clock
	move.w	#$101,INT1-BASE(a5)
	rts

play_music:
	jmp	play_my_music 	

	btst	#0,mus
	bne.s	.no_sound1		; see if we have a sound interrupt
	tst.b	musloaded
	beq.s	.no_sound1
	
.pal_mus_start:
	cmp.b	#PAL,tv_type
	beq	.ok
	move.w	sound_me,d0
	dbf	d0,.ok
	moveq	#5,d0
	bra	.no_sound
.pal_mus_end:
.ok: 
	jsr	NT_VBL			; oh yes we do

.no_sound:
	move.w	d0,sound_me
.no_sound1:
	rts
              
wait_some_vbls:
	move.w	d0,d1
.wait_loop:
	bsr	wait_a_vbl	
	subq.w	#1,d1
	bne.s	.wait_loop
	rts

wait_a_vbl:
	move.b	vbl_counter(a4),d0
.wait_loop:
	cmp.b	vbl_counter(a4),d0
	beq.s	.wait_loop
	rts
