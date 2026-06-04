take_over_here_andy:
	lea	my_stack,a7
	st	no_exit(a4)
	bsr	no_objects
	bsr	screen_black
	jmp	andy_start

intro:  
	move.l	#GPUPP_S,a0
	move.l	#GPUPP_E,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	#$b904,$44(a0)		;trevs patch
	jsr	SETUPGPU
	lea	TITLEMUSIC,a0
	jsr	LOAD_MUSIC
	
	tst.b	save_mod_level
	beq.s	.no_start
	bpl.s	.no_start
	
	jsr	START_MO
	jsr	FADEUP
	
.no_start:
	jsr	init_gpu
	clr.l	joyedge1
	clr.l	joyedge2
	clr.l	joycur1
	clr.l	joycur2
	
come_back_here_from_options:
	LOADREG
	sf	dont_load_mod(a4)
	bsr	allocate_and_load_stuff
	sf	no_exit(a4)
	pea	intro_vbl(pc)
	move.l	(sp)+,video_service(a4)

	tst.b	jump_to_title
	bne.s	skip_to_title

intro_loop:
	LOADREG
	lea	my_stack,a7
	sf	no_exit(a4)
 	bsr	no_objects
	move.l	temp_pal_pointer(a4),a0
	move.l	#514,d0
	bsr	clear_bytes

	moveq	#1,d0
	move.l	atari_pal_pointer(a4),a0	
	bsr	fade_logo_screen

	moveq	#0,d0
	move.l	idi_pal_pointer(a4),a0	
	bsr	fade_logo_screen
	
skip_to_title:
 	bsr	no_objects
	clr.b	hi_mod_started(a4)
	bsr	init_exclam
	
exclamation_loop:
	bsr	wait_a_vbl
	bsr	set_intro_pal
	bsr	setup_game_loop_vars	
	bsr	bigexclamation_stuff
	bsr swapscreen
	addq.w	#1,intro_counter(a4)
	tst.b	exit_ex(a4)
	beq	exclamation_loop 

	clr.b	exit_ex(a4)  
	clr.w	intro_counter(a4)
	clr.w	bubsy_action(a4)
	clr.w	bubsy_log(a4)

	move.l	rmw_data2(a4),a1
	move.w	scree_height_fred(a4),d0
	
.loopy:
	clr.l	(a1)+
	clr.l	(a1)+
	subq.w	#1,d0
	bne.s	.loopy

	clr.w	star_off_table(a4)

	st	title_pic_being_displayed(a4)
	st	set_pals(a4)
stary_loop:
	bsr	wait_a_vbl
	bsr	setup_game_loop_vars	
	tst.b	set_pals(a4)
	beq	.no
	bsr	set_intro_pal
	bsr	fade_down_to_reguler_pal
.no:
	bsr	starfield_job
	bsr	setup_screen_objects
	bsr	bubsy_zoom
	bsr 	swapscreen
	addq.w	#1,intro_counter(a4)
	addq.b	#1,star_counter(a4)
	tst.b	exit_ex(a4)
	beq	stary_loop
	sf	title_pic_being_displayed(a4)
	sf	set_pals(a4)
	bra	skip_title
	bsr	init_title
	
title_loop:
	bsr	wait_a_vbl
	bsr	set_full_pal
	bsr	setup_game_loop_vars
 	bsr	fade_down_title_screen
	bsr	fade_black_title_screen
	bsr	swapscreen
	addq.w	#1,intro_counter(a4)
	tst.b	exit_ex(a4)
	beq.s	title_loop

skip_title:
	bsr	read_hi_score_from_eprom
	bsr	init_hi_score
	
display_hi_score_loop:
	bsr	wait_a_vbl
	bsr	setup_game_loop_vars
	bsr	setup_hi_screen
	bsr	swapscreen
	tst.b	exit_ex(a4)
	beq	display_hi_score_loop
	bsr	screen_black
	bra	intro_loop

temp_text:	dc.l	0

credits_part:
	sf	text_half_speed
	move.l	#credit_text,temp_text
	bsr	do_credits_part
	
RETURN_BACK_TO_CREDITS:
	move.w	#1<<OPTIONS,KEY_PRESS_FROM_FRED
	JMP	take_over_here_andy

do_credits_part:
	bsr	fred_take_over
	bsr	init_credits
	move.l	temp_text,credit_text_pointer(a4)
	
en_loop:
	bsr	wait_a_vbl
	bsr	setup_game_loop_vars
	bsr	print_en
	bsr swapscreen
	cmp.l	#RETURN_BACK_TO_CREDITS,(sp)
	bne.s	.no_padcheck
	move.l	joyedge1,d0
	or.l	joyedge2,d0
	and.l	#~(1<<KEY_0),d0
	bne.s	.pad_press
	
.no_padcheck:
	move.l	rmw_data2(a4),a0
	cmp.b	#$80,1(a0)
	bne.s	en_loop
	
.pad_press:
	rts

title_up:
	sf	set_pals(a4)
 	bsr	no_objects
	st	title_pic_being_displayed(a4)
	bsr	init_exclam
	move.l	rmw_data2(a4),a1
	move.w	scree_height_fred(a4),d0
.loopy:
	clr.l	(a1)+
	clr.l	(a1)+
	subq.w	#1,d0
	bne	.loopy

	clr.b	exit_ex(a4)  
	clr.w	intro_counter(a4)
	move.w	#5,bubsy_action(a4)
	move.w	#-70,bubsy_log(a4)
	clr.w	fractured(a4)
	move.w	#0,star_off_table(a4)

	move.l	star_pal_pointer(a4),a0     
	bsr	load_full_marv_palette
	clr.b	vbl_counter(a4)
	bra	stary_loop

init_do_hi_score:
	LOADREG
	bsr	fred_take_over
	bsr	no_objects
	bsr	screen_black
	
	sf	anybody_got_hi_score
	clr.b	hi_mod_started(a4)

	moveq	#1,d1
	move.l	SCORE,d0
	bsr	do_hi_score      	
	
	moveq	#2,d1
	move.l	OTHERPLAYER+8,d0
	bsr	do_hi_score      	
	
	bsr	fred_take_over
	st	no_exit(a4)
	move.l	#GPUPP_S,a0
	move.l	#GPUPP_E,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	#$b904,$44(a0)		;trevs patch
	jsr	SETUPGPU
	lea	TITLEMUSIC,a0
	jsr	LOAD_MUSIC
	
	tst.b	save_mod_level
	beq.s	.no_start
	bpl.s	.no_start
	
	jsr	START_MO
	jsr	FADEUP
	
.no_start:
	jsr	init_gpu
	clr.l	joyedge1
	clr.l	joyedge2
	clr.l	joycur1
	clr.l	joycur2

	tst.b	anybody_got_hi_score
	beq.s	.no
	
	bsr	read_hi_score_from_eprom
	bsr	init_hi_score
	
.display_hi_score_loop:
	bsr	wait_a_vbl
	bsr	setup_game_loop_vars
	bsr	setup_hi_screen
	bsr	swapscreen
	tst.b	exit_ex(a4)
	beq	.display_hi_score_loop
	bsr	screen_black

	clr.l	LAST_LEVEL_PLAYED
	clr.l	LEVEL

.no:
	tst.b	signal_game_complete
	bne	do_game_complete
	bra	intro_loop	;???????????????????????????????

fred_take_over:
	bsr	screen_black
	bsr	setup_mystuff
	clr.l	joyedge1
	clr.l	joyedge2
	clr.l	joycur1
	clr.l	joycur2
	st	no_exit(a4)
	pea	intro_vbl(pc)
	move.l	(sp)+,video_service(a4)
	st	no_exit(a4)
	st	dont_load_mod(a4)
	bsr	allocate_and_load_stuff
	rts

do_game_complete:
	clr.b	signal_game_complete
	move.l	#GPUPP_S,a0
	move.l	#GPUPP_E,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	#$b904,$44(a0)		;trevs patch
	jsr	SETUPGPU
	lea	TITLEMUSIC,a0
	jsr	LOAD_MUSIC
	
	tst.b	save_mod_level
	beq.s	.no_start
	bpl.s	.no_start
	
	jsr	START_MO
	jsr	FADEUP
	
.no_start:
	st	text_half_speed
	jsr	init_gpu
	move.l	#game_done_text,temp_text
	bsr	do_credits_part
;;	bsr	fred_take_over
	sf	no_exit(a4)
	lea	my_stack,a7
	bra	intro_loop

;-------------------------------------------------------------------------

init_exclam:
	bsr	no_objects
	move.l	bubsy_pal_pointer(a4),a0
	bsr	load_full_marv_palette
	move.w	#$77fe,(CLUT+(111*2))-BASE(a5)

	clr.w	star_angle_add(a4)
	clr.w	star_angle_dec(a4)
	move.l	#star_angle_table,star_angle_pointer(a4)

	clr.w	current_star_angle(a4)
	move.w	#$12,ex_scale(a4)
	clr.w	exclamation_action(a4)
	clr.w	intro_counter(a4)
	clr.b	star_counter(a4)
	clr.b	exit_ex(a4)
	clr.w	border_setting(a4)	
	clr.l	background_setting(a4)	
	sf	reguler_pal(a4)
	clr.w	bubsy_yoff(a4)
	clr.w	circle_radius(a4)
	clr.w	circle_angle(a4)
	clr.l	circle_prev(a4)
	move.w	scree_height_fred(a4),fractured(a4)

	move.l	circle_screen_pointers(a4),a0
	move.l	#(BLITTER_WINDOW*BLITTER_WINDOW)/8,d0
	bsr	blitter_clear
	move.l	circle_screen_pointers+4(a4),a0
	move.l	#(BLITTER_WINDOW*BLITTER_WINDOW)/8,d0
	bsr	blitter_clear
	rts

starfield_job:

dest_star_table		equ -1000

	link	a6,#dest_star_table
	lea	dest_star_table(a6),a1
	move.w	current_star_angle(a4),d0
	move.w	d0,d1
	add.w	#SINE_LEN/4,d1
	and.w	#SINE_LEN-1,d0
	and.w	#SINE_LEN-1,d1
	add.w	d0,d0
	add.w	d1,d1
	move.l	sine_pointer(a4),a0
	move.w	(a0,d0),d0
	move.w	(a0,d1),d1
	muls	#5,d0
	muls	#5,d1
	add.l	d0,d0
	add.l	d1,d1
	lea	star_coords,a0
	move.w	#((star_coordse-star_coords)/8)-1,d7

	move.l	#SCREEN_WIDTH<<16,d5
	move.w	scree_height_fred(a4),d6
	swap	d6

.loop:
	movem.l	(a0),d2-d3
	add.l	d0,d2
	add.l	d1,d3
	move.l	d2,d4
	cmp.l	#-20<<16,d4
	bgt.s	.ok1
	add.l	d5,d2
	add.l	#16<<16,d2
.ok1:
	move.l	d3,d4
	cmp.l	#-20<<16,d4
	bgt.s	.ok2
	add.l	d6,d3
	add.l	#16<<16,d3
.ok2:
	cmp.l	d5,d2
	blt.s	.ok3
	sub.l	d5,d2
	sub.l	#16<<16,d2
.ok3:
	cmp.l	d6,d3
	blt.s	.ok4
	sub.l	d6,d3
	sub.l	#16<<16,d3
.ok4:
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	swap	d2
	swap	d3
	move.w	d2,(a1)+	
	add.w	star_off_table(a4),d3
	move.w	d3,(a1)+	
	move.w	#1,(a1)+	
	move.w	#0,(a1)+	
	dbra	d7,.loop

	move.w	star_angle_add(a4),d0
	add.w	d0,current_star_angle(a4)
	subq.w	#1,star_angle_dec(a4)
	bpl.s	.no
	move.l	star_angle_pointer(a4),a0
	cmp.w	#$8000,(a0)
	bne.s	.not_end
	move.l	#star_angle_table,a0
	
.not_end:
	move.w	(a0)+,star_angle_dec(a4)
	move.w	(a0)+,star_angle_add(a4)
	move.l	a0,star_angle_pointer(a4)

.no:
	WAIT_GPU
	lea	sprite_params,a0
	move.l	#((star_coordse-star_coords)/8),(a0)+
	lea	dest_star_table(a6),a1
	move.l	a1,(a0)+
	lea	intro_fst_pointer(a4),a1
	move.l	a1,(a0)+
	move.l	current_list_pointer(a4),(a0)+

	lea	fasta_gpu_sprite_draw_prog,a0
	lea	fastb_gpu_sprite_draw,a1
	move.l	#fastc_gpu_sprite_drawe,d0
	sub.l	#fastb_gpu_sprite_draw,d0
	bsr	fast_copy_bytes

	move.l	#fastb_gpu_sprite_draw,gpu_routine

	WAIT_GPU
	move.l	sprite_return_obytes,d0
	add.w	d0,bytes_in_object_list(a4)
	add.l	d0,current_list_pointer(a4)

	unlk	a6
	rts
            
star_coords:
	dc.l	160<<16,70<<16
	dc.l	300<<16,140<<16
	dc.l	100<<16,50<<16
	dc.l	50<<16,0<<16
	dc.l	98<<16,220<<16
	dc.l	250<<16,130<<16
	dc.l	180<<16,70<<16
	dc.l	50<<16,160<<16
	dc.l	120<<16,210<<16
	dc.l	140<<16,200<<16
	dc.l	180<<16,140<<16

	dc.l	20<<16,270<<16
	dc.l	290<<16,110<<16
	dc.l	210<<16,150<<16
	dc.l	50<<16,210<<16
star_coordse:	

star_angle_table:	
	dc.w	100,3
	dc.w	50,0
	dc.w	100,-5
	dc.w	50,-2
	
	dc.w	50,1
	dc.w	100,0
	dc.w	100,1
	
	dc.w	$8000

led_zero:	dc.w	0
;-------------------------------------------------------------------------
init_hi_score:
	bsr	no_objects

	move.w	#$03c1,BG
	move.l	#$000007f,BORD1	; Black for background/paper

	move.l	bubsy_pal_pointer(a4),a0
	bsr	load_full_marv_palette
	clr.w	intro_counter(a4)
	move.w	scree_height_fred(a4),bubsy_yoff(a4)
	move.l	original_screen_pointer(a4),a0
	move.w	#320*2,d0
	mulu	scree_height_fred(a4),d0
	bsr	blitter_clear	

	lea	hi_score_table_text,a0
	moveq   #0,d5
	moveq   #0,d7  
	move.w  d5,d6     
	moveq   #0,d0
	move.l  font1_hed_pointer(a4),a3
	lea     ascii_table(pc),a2
	moveq   #0,d4
	clr.b	led_zero
	
.text_loop:     	
	move.b  (a0)+,d0
	cmp.b	#$10,d0
	bne.s	.bollox
	addq.l	#1,a0
	bra.s	.text_loop
	
.bollox:
	moveq   #0,d1
	move.b  (a2,d0),d1
	bne.s   .no_special
	cmp.b   #NULL,d0
	beq     .done
	cmp.b   #SPACE,d0
	bne.s   .no_space
	add.w   #12,d6
	bra.s   .text_loop
.no_space:
	cmp.b   #SETX,d0
	bne.s   .no_setx
	clr.b	led_zero
	move.b  (a0)+,d5
	lsl.w   #8,d5
	move.b  (a0)+,d5
	addq.w	#8,d5
	move.w  d5,d6
	bra.s   .text_loop
.no_setx:
	cmp.b   #SETY,d0
	bne.s   .no_sety
	move.b  (a0)+,d7
	lsl.w   #8,d7
	move.b  (a0)+,d7
	bra.s   .text_loop
.no_sety:
	cmp.b   #FIXEDLEN,d0
	bne.s   .no_fixed_len
	st      d4
	bra.s   .text_loop
.no_fixed_len:
	cmp.b   #SETXB,d0
	bne.s   .fucked_up
	move.b  (a0)+,d5
	lsl.w   #8,d5
	move.b  (a0)+,d5
	addq.w	#8,d5
	move.w  d5,d6
.loopp:
	cmp.b	#"0",(a0)
	bne	.text_loop
	addq.l	#1,a0
	bra	.loopp
	
.fucked_up:
	illegal
.no_special:
	subq.w	#1,d1
	PUSH
	mulu	#640,d7
	add.w	d6,d6
	move.l	original_screen_pointer(a4),a0
	add.l	d7,a0
	lea	(a0,d6),a0
	lsl.w	#4,d1
	move.w	jsprite_height(a3,d1),d7	
	move.w	jsprite_paramshrase_width(a3,d1),d3
	lsl.w	#3,d3
	move.w	jsprite_paramsixel_width(a3,d1),d6	
	move.l	jsprite_data(a3,d1),a2
	subq.w	#1,d7
	subq.w	#1,d6
.print_loop0:
	move.w	d6,d5
	pea	640(a0)
	pea	(a2,d3)
.print_loop1:
	move.w	(a2)+,d2
	beq.s	.just_add
	move.w	d2,(a0)
.just_add:
	addq.l	#2,a0
	dbra	d5,.print_loop1
	move.l	(sp)+,a2
	move.l	(sp)+,a0
	dbra	d7,.print_loop0
	PULL

	tst.b	d4
	beq.s	.no_fixed
	add.w	#22,d6
	bra	.text_loop
.no_fixed:
	pea	(a1)
	lea	font_width_table,a1
	move.b	(a1,d1),d1
	move.l	(sp)+,a1
	add.w	d1,d6
	bra	.text_loop
.done:        	
	move.w	scree_height_fred(a4),d0
	add.w	d0,d0
	ext.l	d0
	sub.l	d0,sp
	move.l	sp,a0

	move.l	#$ffffff,d0
	move.l	#$ff00ff,d1
	move.w	scree_height_fred(a4),d2
	lsr.w	#2,d2
	moveq	#TYPE_RGB,d3
	bsr	make_color_spread
	
	move.l	#$ff00ff,d0
	move.l	#$ff0000,d1
	move.w	scree_height_fred(a4),d2
	lsr.w	#2,d2
	moveq	#TYPE_RGB,d3
	bsr	make_color_spread

	move.l	#$ff0000,d0
	move.l	#$00ff00,d1
	move.w	scree_height_fred(a4),d2
	lsr.w	#2,d2
	moveq	#TYPE_RGB,d3
	bsr	make_color_spread
	
	move.l	#$00ff00,d0
	move.l	#$ffffff,d1
	move.w	scree_height_fred(a4),d2
	lsr.w	#2,d2
	moveq	#TYPE_RGB,d3
	bsr	make_color_spread

	move.l	sp,a0
	move.l	original_screen_pointer(a4),a1
	move.w	scree_height_fred(a4),d0
	subq.w	#1,d0
.loop0:
	move.w	#320-1,d1
	move.w	(a0)+,d2
.loop1:
	move.w	(a1),d3
	beq.s	.zero_pixel
	cmp.b	#20,d3
	bcs.s	.zero_pixel
	move.w	d2,(a1)	
.zero_pixel:
	addq.l	#2,a1
	dbra	d1,.loop1
	dbra	d0,.loop0

	move.w	scree_height_fred(a4),d0
	add.w	d0,d0
	lea	(sp,d0),sp

	sf	exit_ex(a4)
	clr.b	hi_dir(a4)
  	move.w	#SCREEN_WIDTH,hi_off(a4)
	move.w	#400,intro_counter(a4)
	move.w	#00,intro_counter2(a4)
	rts

setup_hi_screen: 
	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	bubsy_yoff(a4),d1
	add.w	d1,d1  
	add.w	#ntsc_n_vdb,d1
	move.w	d1,obj_ypos(a0)
	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	hi_screen_pointer(a4),obj_data(a0)
	move.w	#(SCREEN_WIDTH-320)/2,obj_xpos(a0)
	move.w	#OPIXEL8,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#320/8,obj_dwidth(a0)
	move.W	#320/8,obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                

	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	#ntsc_n_vdb,obj_ypos(a0)
	cmp.b	#PAL,tv_type
	bne.s	.no_pal
	add.w	#60,obj_ypos(a0)	

.no_pal:
	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	original_screen_pointer(a4),obj_data(a0)
	move.w	hi_off(a4),obj_xpos(a0)
	move.w	#OPIXEL16,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#320/4,obj_dwidth(a0)
	move.W	#320/4,obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                

	UNSTACKOBJ

	move.l	hi_screen_pointer(a4),a0
	move.w	scree_height_fred(a4),d0
	mulu	#320,d0
	bsr	blitter_clear

	move.w	#320/2,d0
	swap	d0
	move.w	scree_height_fred(a4),d0
	lsr.w	#1,d0
	move.w	intro_counter2(a4),d6
	mulu	#14,d6
	move.w	d6,d7                  
	add.w	#200,d7
	and.w	#CIRC_LEN-1,d6
	and.w	#CIRC_LEN-1,d7
	lsr.w	#1,d6
	lsr.w	#1,d7
	add.w	d6,d6
	add.w	d7,d7
	move.l	sine_pointer(a4),a1
	moveq	#0,d1		  
	moveq	#0,d2
	move.w	(a1,d6),d1		  
	move.w	(a1,d7),d2		  
	muls	#$6000,d1
	muls	#$6000,d2
	add.l	d1,d1
	add.l	d2,d2
	swap	d1
	swap	d2
	mulu	#3,d1
	mulu	#3,d2

	move.l	#WID112+PIXEL8,d3	
	move.l	#WID320+PIXEL8,d4	
	move.l	intro_hed_pointer(a4),a0
	move.l	10*jsprite_e+jsprite_paramsixel_width(a0),d5
	move.w	intro_counter2(a4),d6
	mulu	#15,d6
	move.l	10*16+jsprite_data(a0),a0
	move.l	hi_screen_pointer(a4),a1	
	bsr	blitter_rotate_bitmap

	movem.l	hi_screen_pointer(a4),d0-d1
	exg	d0,d1
	movem.l	d0-d1,hi_screen_pointer(a4)

	addq.w	#1,intro_counter2(a4)

	tst.b	hi_dir(a4)
	bne.s	.back

	subq.w	#2,bubsy_yoff(a4)
	spl	d0
	ext.w	d0
	and.w	d0,bubsy_yoff(a4)

	subq.w	#4,hi_off(a4)
	spl	d0
	ext.w	d0
	and.w	d0,hi_off(a4)

	subq.w	#1,intro_counter(a4)
	seq	hi_dir(a4)	
	rts

.back:
	addq.w	#2,bubsy_yoff(a4)
	move.w	bubsy_yoff(a4),d0 
	cmp.w	scree_height_fred(a4),d0
	sgt	exit_ex(a4)
	addq.w	#4,hi_off(a4)
	rts

no_objects:
	bsr	wait_a_vbl
	bsr	setup_game_loop_vars	
	bsr swapscreen
	bsr	wait_a_vbl
	rts

init_title:
	lea	start_text,a0
	move.l	text_buffer_pointer(a4),a1
	bsr	convert_text_to_sprites
	move.w	d0,start_text_len(a4)
	move.l	temp_pal_pointer(a4),a0
	addq.l	#2,a0

	move.w	#256-1,d0
.loop:
	move.w	#$ffff,(a0)+
	dbra	d0,.loop

	clr.w	intro_counter(a4)
	clr.b	exit_ex(a4)
	clr.b	title_faded(a4)
	rts

init_credits:
	bsr	no_objects

	bsr	screen_black
	move.l	title_pal_pointer(a4),a0
	bsr	load_full_marv_palette
	move.w	#260,en_x(a4)
	move.w	#140,en_y(a4)
	move.w	#80,en_x2(a4)
	move.w	#50,en_y2(a4)
	clr.b	en_xdir(a4)
	clr.b	en_ydir(a4)
	st	en_xdir2(a4)
	st	en_ydir2(a4)
	clr.w	credit_text_offset(a4)
	move.w	#0,credit_screen_offset(a4)	

	move.l	credit_screen_pointer(a4),a0
	move.w	scree_height_fred(a4),d0
	addq.w	#1,d0
	mulu	#344*2,d0
	bsr	blitter_clear		

	sf	credit_text_done(a4)
	
	move.l	rmw_data2(a4),a1
	move.w	scree_height_fred(a4),d0
.loopy:
	move.l	#$800080,(a1)+
	move.l	#$800080,(a1)+
	subq.w	#1,d0
	bne.s	.loopy
	rts

**********************************************************************************************
; pass
; score in d0 
; player number ( 1 or 2 ) in d1

do_hi_score:
	st	no_exit(a4)

	add.b	#"0",d1
	move.b	d1,player_hi_number

	move.l	d0,-(sp)
	lea	star_screen_pointers(a4),a6
	move.l	(a6)+,a0
	move.w	#SCREEN_WIDTH,d0
	mulu	scree_height_fred(a4),d0
	add.l	d0,d0
	bsr	blitter_clear
	move.l	(a6)+,a0
	move.w	#SCREEN_WIDTH,d0
	mulu	scree_height_fred(a4),d0
	add.l	d0,d0
	bsr	blitter_clear
	move.l	(sp)+,d0 	

	move.w	#0,hi_out_delay(a4)	
	clr.l	joyedge1
	clr.l	joyedge2

	lea	hi_name,a0
	moveq	#9-1,d7
.tloop:
	move.b	#".",(a0)+
	dbra	d7,.tloop

	clr.w	cursor_pos(a4)
	move.w	#10,score_position(a4)
	move.l	d0,score_achieved(a4)
	bmi.s	.skip_check
	bsr	check_for_hi_score
	cmp.w	#10,score_position(a4)
	beq	.next_part
	st	anybody_got_hi_score
.skip_check:
	bsr	no_objects
	bsr	init_stars
	tst.b	hi_mod_started(a4)
	bne.s	.hi_loop
	st	hi_mod_started(a4)
	
	move.l	#GPUPP_S,a0
	move.l	#GPUPP_E,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
;;	move.w	#$b904,$44(a0)		;trevs patch
	jsr	SETUPGPU
	lea	hi_mod_name,a0
	jsr	LOAD_MUSIC
	
	tst.b	save_mod_level
	beq.s	.no_start
	bpl.s	.no_start
	
	jsr	START_MO
	jsr	FADEUP
.no_start:
	jsr	init_gpu
.hi_loop:
	bsr	wait_a_vbl
	bsr	setup_game_loop_vars
	bsr	hi_score_stuff
	bsr swapscreen
	tst.w	hi_out_delay(a4)
	beq.s	.hi_loop
	subq.w	#1,hi_out_delay(a4)
	bne.s	.hi_loop

	move.w	score_position(a4),d0
	sub.w	#9,d0
	beq	.no_shift
	neg.w	d0
	subq.w	#1,d0                  
	lea	hi_score_table+1,a0
	lea	hi_score_table+1,a1
	add.l	#26*9,a0
	add.l	#26*10,a1
.loopp:      
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	subq.l	#3,a0               
	subq.l	#3,a1
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	subq.l	#6,a0               
	subq.l	#6,a1
	dbra	d0,.loopp
	
.no_shift: 
 	move.w	score_position(a4),d0
	mulu	#26,d0
	lea	hi_score_table+7,a0
	add.l	d0,a0
		
	move.l	text_buffer_pointer(a4),a1
	move.w	fuck_text_len(a4),d1
	lsl.w	#3,d1
	lea	-72(a1,d1),a1
	
	moveq	#9-1,d7
.sloop:
	move.w	4(a1),d6
	addq.w	#1,d6
	lea	ascii_table,a2
	moveq	#0,d5
.zloop:
	cmp.b	(a2)+,d6
	beq.s	.hit
	addq.w	#1,d5
	bra.s	.zloop	
.hit:
	move.b	d5,(a0)+
	addq.l	#8,a1
	dbra	d7,.sloop	

	move.l	a0,-(sp)
	clr.l	-(sp)
	move.l	score_achieved(a4),-(sp)
	lea	0(sp),a0
	lea	4(sp),a1
	bsr	long_to_bcd
	addq.l	#4,sp
	move.l	(sp)+,d0
	move.l	(sp)+,a0
	addq.l	#3,a0		
	moveq	#4-1,d7
.cloop:
	rol.l	#8,d0
	move.b	d0,d1
	move.b	d0,d2
	and.l	#$f0,d1
	and.l	#$f,d2
	lsr.l	#4,d1
	add.b	#"0",d1
	add.b	#"0",d2
	move.b	d1,(a0)+
	move.b	d2,(a0)+
	dbra	d7,.cloop

;	bsr	write_hi_score_to_eprom
.next_part:
	bsr	no_objects
	sf	no_exit(a4)     
	rts

fade_logo_screen:	
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)       
	
.loop0:
	addq.w	#1,(sp)
	bsr	set_logo_col
	cmp.w	#100,(sp)
	bne.s	.loop0

.loop1:
	subq.w	#1,(sp)
	bsr	set_logo_col
	cmp.w	#0,(sp)
	bne.s	.loop1
	
	addq.l	#8,sp
	rts
	
set_logo_col:
	bsr	wait_a_vbl
	bsr	set_full_pal
	bsr	setup_game_loop_vars
	move.w	10(sp),d2
	move.l	logo_hed_pointer(a4),a0
	move.l	current_list_pointer(a4),a1
	move.w	d2,d3
	lsl.w	#4,d3
 	move.w	jsprite_height(a0,d3),d7
	move.w	jsprite_paramsixel_width(a0,d3),d6
	asr.w	#1,d6
	asr.w	#1,d7
	move.w	#SCREEN_WIDTH/2,d0
	sub.w	d6,d0
	move.w	scree_height_fred(a4),d1
	asr.w	#1,d1
	sub.w	d7,d1	
	sub.w	#10,d1

	bsr	draw_a_jag_sprite
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                

	move.w	#256,d0
	move.w	4(sp),d1
	cmp.w	#32,d1
	ble.s	.ok
	moveq	#32,d1
.ok:
	move.l	6(sp),a0
	addq.l	#2,a0
	move.l	temp_pal_pointer(a4),a1
	addq.l	#2,a1
	bsr	fade_rgb_colors
	bsr	swapscreen
	rts

check_for_hi_score:
	lea	hi_score_table+1,a0
	moveq	#10-1,d7
	moveq	#0,d6
.loop:
	lea	18(a0),a0	; skip name ascii
	bsr	ascii_to_long
	cmp.l	score_achieved(a4),d0
	blt.s	.done

	addq.w	#1,d6
	dbra	d7,.loop
.done:
	move.w	d6,score_position(a4)
	rts

hi_score_stuff:
   	cmp.w	#10,score_position(a4)
	beq	.no_control
	tst.w	hi_out_delay(a4)
	bne	.no_control
	move.w	star_table+6(a4),d1
	cmp.w	#7000,d1
;	bgt	.no_control

	move.l	joyedge1,d0
	cmp.b	#"1",player_hi_number
	beq.s	.player_1
	cmp.w	#1,PLAYERS
	bne.s	.player_1
	move.l	joyedge2,d0
	
.player_1:
 	btst	#LEFT_B,d0
	beq.s	.no_left
	moveq	#POPSOUND3,d0
	jsr	STARTSOUND

	subq.w	#1,cursor_pos(a4)
	bpl	.joy_pushed	
	add.w	#9,cursor_pos(a4)
	bra	.joy_pushed
	
.no_left:
	btst	#RIGHT_B,d0
	beq.s	.no_right
	moveq	#POPSOUND3,d0
	jsr	STARTSOUND

	addq.w	#1,cursor_pos(a4)
	cmp.w	#9,cursor_pos(a4)
	blt	.joy_pushed	
	clr.w	cursor_pos(a4)

.no_right:
   	move.l	d0,d7   
	bsr	.get_cursor_address

	btst	#UP_B,d7
	beq.s	.no_up
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND

	cmp.w	#25,(a0)
	bne.s	.no_special1
	move.w	#35,(a0)                  
	bra	.joy_pushed
	
.no_special1:
	cmp.w	#39,(a0)
	bne.s	.no_special2
	move.w	#0,(a0)                  
	bra	.joy_pushed
	
.no_special2:
	addq.w	#1,(a0)	
	bra	.joy_pushed

.no_up:
	btst	#DOWN_B,d7
	beq.s	.no_down	
	moveq	#POPSOUND3,d0
	jsr	STARTSOUND

	cmp.w	#0,(a0)
	bne.s	.no_special3
	move.w	#39,(a0)                  
	bra	.joy_pushed
	
.no_special3:
	cmp.w	#35,(a0)
	bne.s	.no_special4
	move.w	#25,(a0)                  
	bra	.joy_pushed
	
.no_special4:
	subq.w	#1,(a0)	
	bra	.joy_pushed

.no_down:
   	btst	#FIRE_A,d7
	bne	.scored
	btst	#FIRE_B,d7
	bne	.scored
	btst	#FIRE_C,d7
	bne	.scored
	bra	.no_control
	
.scored:	
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND
	move.w	#100,hi_out_delay(a4)

.joy_pushed:  	 
.no_control:     	
	WAIT_GPU
	MOVE.L	#text_buffer_pointer,D0
	lea	builda_wibbly_text_prog,a0
	lea 	buildb_wibbly_text_gpu,a1
	move.l	#buildc_wibbly_text_gpue,d0
	sub.l	#buildb_wibbly_text_gpu,d0
	bsr	fast_copy_bytes
	move.l	#data,wibbleparams

	move.l	#buildb_wibbly_text_gpu,gpu_routine

	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	#ntsc_n_vdb,obj_ypos(a0)
	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	star_screen_pointers(a4),obj_data(a0)
	move.w	#0,obj_xpos(a0)
	move.w	#OPIXEL16,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#(SCREEN_WIDTH*2)/8,obj_dwidth(a0)
	move.w	#(SCREEN_WIDTH*2)/8,obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	UNSTACKOBJ
	
	tst.w	hi_out_delay(a4)
	bne.s	.skip_flash
	bsr	.get_cursor_address
	move.b	vbl_counter(a4),d0
	and.w	#1,d0
	mulu	#40,d0
	add.w	d0,(a1)

.skip_flash:	
	move.l	text_buffer_pointer(a4),a0
	move.w	fuck_text_len(a4),d0
	move.w	d0,d1                 
	lsl.w	#3,d1
	lea	(a0,d1),a0
	bsr	draw_text
	move.l	screen_pointers(a4),a0
	move.w	#BLITTER_WINDOW,d0
	move.w	scree_height_fred(a4),d1
	sub.w	d1,d0
	asr.w	#1,d0
	mulu	#BLITTER_WINDOW,d0
	add.l	d0,a0
	move.w	#BLITTER_WINDOW,d0
	mulu	scree_height_fred(a4),d0
	bsr	blitter_clear
	bsr	wait_text
	lea	builda_star_prog,a0
	lea	buildb_star_gpu,a1
	move.l	#buildc_star_gpue,d0
	sub.l	#buildb_star_gpu,d0 
	bsr	fast_copy_bytes
	move.l	#data,starparams

;---------------
	move.l	#buildb_star_gpu,gpu_routine

	move.l	screen_pointers(a4),d7
	moveq	#0,d1
	move.w	#OPIXEL8,d2	
	bsr	make_screen_object

	moveq	#0,d0
	move.w	#72,d1
.loop:
	movem.w	d0-d1,-(sp)
	move.w	d1,d4
	move.w	d0,d1
	move.w	d0,d2
	move.w	d4,d0
	swap	d0

	move.l	intro_hed_pointer(a4),a0
	lea	15*jsprite_e(a0),a0
	lsl.w	#4,d1

	lsl.w	#4,d2
	lea	letter_y_table(a4),a2
	move.w	0(a2,d2),d4	; bottom y value
	move.l	half_circle_pointer(a4),a3
	add.w	d4,d4
	move.w	(a3,d4),d4
	bpl.s	.pos
	neg.w	d4
.pos:
	muls	8(a2,d2),d4
	subq.w	#1,10(a2,d2)
	bpl	.no_sprite	
	move.w	#-1,10(a2,d2)
	
	add.l	d4,d4
	swap	d4
;	sub.w	#300,d4
	cmp.b	#PAL,tv_type
	bne	.ntsc
	sub.w	#280+disp_change,d4
	bra.s	.skipe
	
.ntsc:
	sub.w	#280,d4
.skipe:
	neg.w	d4

	move.w	d4,d3
	sub.w	jsprite_height(a0,d1),d3	
	move.w	2(a2,d2),d5	; sine value
	add.w	#40,2(a2,d2)
	and.w	#SINE_LEN-1,d5
	add.w	d5,d5
	move.l	sine_pointer(a4),a3
	move.w	(a3,d5),d5
	muls	4(a2,d2),d5	; scale value
	add.l	d5,d5
	swap	d5
	muls	#40,d5
	add.l	d5,d5
	swap	d5
	add.w	d5,d3	; topy y value	
	tst.b	6(a2,d2)
	beq.s	.ok
	sub.w	#$28,4(a2,d2)
	cmp.w	#$2000,4(a2,d2)
	bge.s	.ok
	move.w	#$2000,4(a2,d2)
.ok:
	move.w	d3,d0
	add.w	d4,d0
	lsr.w	#1,d0

.no_wibble:
	sub.w	#10,0(a2,d2)
	bgt.s	.no_bounce
	tst.b	6(a2,d2)
	bne.s	.no
	st	6(a2,d2)
	move.w	#$7fff,4(a2,d2)
.no:
	add.w	#CIRC_LEN,0(a2,d2)
	sub.w	#70,8(a2,d2)
	bgt.s	.no_bounce
	clr.w	8(a2,d2)
.no_bounce:
	move.w	jsprite_height(a0,d1),d6
	move.l	jsprite_data(a0,d1),a0
	move.w	d4,d2
	sub.w	d3,d2
	ext.l	d2
	divu	d6,d2
	swap	d2
	move.w	d2,d3
	swap	d3
	clr.w	d3
	divu	d6,d3
	move.w	d3,d2
	
	move.l	#$10000,d1
	move.l	#PIXEL8+WID32,d3
	move.l	#PIXEL8+WID384,d4
	move.l	#(32<<16)+48,d5
	
	move.l	screen_pointers(a4),a1
	
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
*	illegal
*	bsr	blitter_scale_bitmap		; problem
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************
******************************************

.no_sprite:
	movem.w	(sp)+,d0-d1
	add.w	#40,d1
	addq.w	#1,d0
	cmp.w	#7,d0
	bne	.loop

	WAIT_GPU

	movem.l	star_restore_pointer(a4),d0-d1
	exg	d0,d1
	movem.l	d0-d1,star_restore_pointer(a4)
	
	movem.l	screen_pointers(a4),d0-d3
	exg	d0,d3
	movem.l	d0-d3,screen_pointers(a4)

	movem.l	star_screen_pointers(a4),d0-d1
	exg	d0,d1
	movem.l	d0-d1,star_screen_pointers(a4)

	addq.w	#1,intro_counter(a4)
	rts

.get_cursor_address:
  	move.w	cursor_pos(a4),d0
	move.l	text_buffer_pointer(a4),a0
	move.w	fuck_text_len(a4),d1
	lsl.w	#3,d1
	sub.w	#9,d0
	asl.w	#3,d0
	add.w	d1,d0
	lea	4(a0,d0),a0
	lea	(a0,d1),a1
	rts

print_title_screen:
	STACKOBJ

	move.w	#BITMAP_OBJECT,obj_type(a0)
	moveq	#0,d0
	cmp.b	#PAL,tv_type
	beq	.pal_machine
	moveq	#-20,d0
.pal_machine:
	move.w	d0,obj_ypos(a0)
	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	title_gfx_pointer(a4),obj_data(a0)
	move.w	#0,obj_xpos(a0)
	move.w	#OPIXEL8,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#(344/8),obj_dwidth(a0)
	move.w	#(344/8),obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	clip_bitmap_object
	moveq	#16,d0                 
	bsr	fix_object_boundry
	add.w	d0,bytes_in_object_list(a4)
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	UNSTACKOBJ
	rts

print_en:    	
	lea	builda_circle_prog,a0
	lea	buildb_circle_gpu,a1
	move.l	#buildc_circle_gpue,d0
	sub.l	#buildb_circle_gpu,d0 
	bsr	fast_copy_bytes
	
	lea	rad_params,a1
	move.b	tv_type,d0
	move.l	d0,(a1)+
	move.l	title_gfx_pointer(a4),(a1)+
	move.l	#mag_pointer+data,(a1)+
	move.l	intro_hed_pointer(a4),a2
	add.l	#jsprite_e*12+jsprite_data,a2
	move.l	a2,(a1)+
	move.l	#en_x+data,(a1)+
	move.l	#en_y+data,(a1)+

	move.l	title_gfx_pointer(a4),(a1)+
	move.l	#mag_pointer+data,(a1)+
	move.l	intro_hed_pointer(a4),a2
	add.l	#jsprite_e*13+jsprite_data,a2
	move.l	a2,(a1)+
	move.l	#en_x2+data,(a1)+
	move.l	#en_y2+data,(a1)+

	move.l	#buildb_circle_gpu,gpu_routine

	bsr	print_title_screen

	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	#ntsc_n_vdb,obj_ypos(a0)
	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	rmw_data(a4),obj_data(a0)
	move.w	#0,obj_xpos(a0)
	move.w	#OPIXEL16,obj_depth(a0)
	move.w	#0,obj_pitch(a0)
	move.w	#1,obj_dwidth(a0)
	move.w	#(344/4),obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#RMW,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	UNSTACKOBJ

	move.w	en_x(a4),d0    
	move.w	en_y(a4),d1
	move.w	#12,d2
	bsr	.draw_it

	move.w	en_x2(a4),d0    
	move.w	en_y2(a4),d1
	move.w	#13,d2
	bsr	.draw_it

	tst.b	credit_text_done(a4)
	bne	.done_text
	bsr	.done_text
	beq	.zoo
	rts

.zoo:
	lea	en_xdir(a4),a0
	lea	en_ydir(a4),a1
	lea	en_x(a4),a2
	lea	en_y(a4),a3
	bsr	.bounce
	lea	en_xdir2(a4),a0
	lea	en_ydir2(a4),a1
	lea	en_x2(a4),a2
	lea	en_y2(a4),a3
	bsr	.bounce

.dont_move:
	tst.b	text_half_speed
	beq.s	.new_line
	moveq	#1,d0
	and.w	clock,d0
	beq	.no_new_line
	
.new_line:
	move.w	credit_screen_offset(a4),d0
	mulu	#344*2,d0
	add.l	credit_screen_pointer(a4),d0
	move.l	d0,a0
	move.l	#344*2,d0
	move.l	a0,-(sp)
	bsr	blitter_clear
	move.l	(sp)+,a6		

	cmp.w	#18,credit_text_offset(a4)
	beq	.done
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d4
	moveq	#0,d6
	lea	ascii_table,a2
	move.l	font1_hed_pointer(a4),a3
	move.l	credit_text_pointer(a4),a0

.text_loop:
	move.b	(a0)+,d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	bne.s	.no_special
	cmp.b	#CR,d0
	beq	.done
	cmp.b	#SPACE,d0
	bne.s	.no_space
	add.w	#12,d6
	bra.s	.text_loop
.no_space:
	cmp.b	#SETX,d0
	bne.s	.no_setx
	move.b	(a0)+,d6
	lsl.w	#8,d6
	move.b	(a0)+,d6
	bra.s	.text_loop
.no_setx:
	cmp.b	#FIXEDLEN,d0
	bne.s	.no_fixed_len
	not.b	d4
	bra.s	.text_loop
.no_fixed_len: 	
	lea	font_width_table,a1
	moveq	#0,d6
	move.l	a0,-(sp)
	moveq	#CR,d1
	moveq	#SPACE,d2
.cloop:
	move.b	(a0)+,d0
	cmp.b	d1,d0
	beq.s	.done_center
	cmp.b	d2,d0
	beq.s	.space
	move.b	(a2,d0),d0
	move.b	-1(a1,d0),d0
	add.w	d0,d6
	bra.s	.cloop
.space:
	add.w	#12,d6
	bra.s	.cloop	

.done_center:
	lsr.w	#1,d6
	move.w	#SCREEN_WIDTH/2,d7
	sub.w	d6,d7
	move.w	d7,d6
	move.l	(sp)+,a0              
	bra	.text_loop

.no_special:
	subq.w	#1,d1
	lea	font_width_table,a1
	move.b	(a1,d1),d2

	lea	(a6,d6),a1
	lea	(a1,d6),a1
	tst.b	d4
	beq.s	.no_fixed
	add.w	#22,d6
	bra	.skipo
.no_fixed:
 	add.w	d2,d6	
.skipo:
	lsl.w	#4,d1	
	move.l	jsprite_data(a3,d1),a5
	move.w	jsprite_paramshrase_width(a3,d1),d7
	move.w	d7,d1
	lsl.w	#3,d7
	mulu	credit_text_offset(a4),d7
	lea	(a5,d7),a5
	subq.w	#1,d1

.print_loop:
	move.l	(a5)+,(a1)+
	move.l	(a5)+,(a1)+
	dbra	d1,.print_loop
	
	bra	.text_loop

.done: 
	lea	BASE,a5
	addq.w	#1,credit_text_offset(a4)
	cmp.w	#19,credit_text_offset(a4)
	bne.s	.cont
	clr.w	credit_text_offset(a4)
	move.l	credit_text_pointer(a4),a0
.zloop:
	cmp.b	#CR,(a0)+
	bne.s	.zloop
	move.l	a0,credit_text_pointer(a4)
	cmp.b	#NULL,(a0)
	bne.s	.cont
	st	credit_text_done(a4)
	rts	
.cont:		
.no_new_line:	
	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	credit_screen_offset(a4),d1
	move.w	scree_height_fred(a4),d0
	sub.w	d1,d0
	
	cmp.b	#PAL,tv_type
	bne	.sss
	subq.w	#1,d0
.sss:
	move.w	d0,d1
	add.w	d0,d0
	add.w	#ntsc_n_vdb,d0
	move.w	d0,obj_ypos(a0)
	move.w	scree_height_fred(a4),d0
	sub.w	d1,d0
	move.w	d0,obj_height(a0)  
	move.l	credit_screen_pointer(a4),obj_data(a0)
	move.w	#0,obj_xpos(a0)
	move.w	#OPIXEL16,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#(344/4),obj_dwidth(a0)
	move.w	#(344/4),obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                

	move.w	#ntsc_n_vdb,obj_ypos(a0)
	move.w	credit_screen_offset(a4),d1
	addq.w	#1,d1
	mulu	#344*2,d1
	add.l	credit_screen_pointer(a4),d1
	move.l	d1,obj_data(a0)

	move.w	scree_height_fred(a4),d1
	sub.w	credit_screen_offset(a4),d1
	move.w	d1,obj_height(a0)	
	ble.s	.zero

	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                

.zero:	UNSTACKOBJ
	tst.b	text_half_speed
	beq.s	.ok
	moveq	#1,d0
	and.w	clock,d0
	beq.s	.no_add_to_screen_y
.ok:
	addq.w	#1,credit_screen_offset(a4)
.no_add_to_screen_y:
	move.w	credit_screen_offset(a4),d0
	cmp.b	#PAL,tv_type
	beq.s	.skipoo
	subq.w	#1,d0
.skipoo:
	cmp.w	scree_height_fred(a4),d0
	bne.s	.pos_screen
	clr.w	credit_screen_offset(a4)
.pos_screen:	
	rts

.done_text:
	tst.b	credit_text_done(a4)
	bne.s	.anyway
	move.l	rmw_data2(a4),a0
	move.w	scree_height_fred(a4),d0
	subq.w	#1,d0
	cmp.b	#0,1(a0)
	beq.s	.finished	
.lighten_loop:
	addq.b	#8,1(a0)
	addq.b	#8,3(a0)
	addq.b	#8,5(a0)
	addq.b	#8,7(a0)
	addq.l	#8,a0
	dbra	d0,.lighten_loop    
	bsr	darken_screen
	moveq	#-1,d0
.finished:
	rts

.anyway:
	bsr	darken_screen
	bsr	rmw_down
	rts
	
.draw_it:
	sub.w	#32,d0
	sub.w	#32,d1
	movem.w	d0-d1,-(sp)
	bsr.s	.do
	movem.w	(sp)+,d0-d1
	moveq	#14,d2
	
.do:
	move.l	intro_fst_pointer(a4),a0
	move.l	current_list_pointer(a4),a1
	move.l	intro_hed_pointer(a4),a2
	bsr 	draw_a_fast_jag_sprite    
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)
	rts

.bounce:	tst.b	(a0)
	beq.s	.addx
	subq.w	#2,(a2)
.addx:	addq.w	#1,(a2)
	cmp.w	#ENLARGE/2,(a2)
	seq	d0
	eor.b	d0,(a0)
	cmp.w	#SCREEN_WIDTH-(ENLARGE/2),(a2)
	seq	d0
	eor.b	d0,(a0)
	
	tst.b	(a1)
	beq.s	.addy
	subq.w	#2,(a3)
.addy:	addq.w	#1,(a3)
	cmp.w	#ENLARGE/2,(a3)
	seq	d0
	eor.b	d0,(a1)
	move.w	scree_height_fred(a4),d3
	sub.w	#ENLARGE/2,d3
	cmp.w	(a3),d3	
	seq	d0
	eor.b	d0,(a1)
	rts

rmw_down:	move.l	rmw_data2(a4),a0
	move.w	scree_height_fred(a4),d0
	subq.w	#1,d0
.darken_loop:	subq.b	#8,1(a0)
	subq.b	#8,3(a0)
	subq.b	#8,5(a0)
	subq.b	#8,7(a0)
	addq.l	#8,a0
	dbra	d0,.darken_loop    
	rts

darken_screen:	bsr.s	.do
	bsr.s	.do
	rts

.do:	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	#ntsc_n_vdb,obj_ypos(a0)
	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	rmw_data2(a4),obj_data(a0)
	move.w	#0,obj_xpos(a0)
	move.w	#OPIXEL16,obj_depth(a0)
	move.w	#0,obj_pitch(a0)
	move.w	#1,obj_dwidth(a0)
	move.w	#(344/4),obj_iwidth(a0)
	move.w	#0,obj_index(a0)
	move.w	#RMW,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	UNSTACKOBJ
	rts

generate_mag_table:

circle_count	equ -50
circle_index	equ -48
circle_add		equ -44

	move.l	half_circle_pointer(a4),a1
	lea	CIRC_LEN(a1),a1
	move.w	#CIRC_LEN/2-1,d0
.cloop:	neg.w	(a1)
	add.w	#-1,(a1)+
	dbra	d0,.cloop	

	link	a6,#circle_count
	clr.w	circle_count(a6)
	clr.l	circle_index(a6)
	move.l	#CIRC_LEN,d0
	divu	#64,d0
	swap	d0
	move.w	d0,d1
	swap	d1
	clr.w	d1
	divu	#64,d1
	move.w	d1,d0
	move.l	d0,circle_add(a6)
 	move.l	half_circle_pointer(a4),a0
	move.l	mag_pointer(a4),a1
	
.gen_loop:	move.w	circle_index(a6),d0
	add.w	d0,d0
	move.w	(a0,d0),d0
	move.w	d0,d1
	mulu	#ENLARGE,d0
	swap	d0
	mulu	#344,d0
	cmp.w	#$8000,d1
	bcs.s	.sign
	sub.w	#$8000,d1
	neg.w	d1
	add.w	#$7fff,d1
.sign:       	mulu	#64,d1
	swap	d1
	move.w	d1,d2
	move.w	d1,d4
	add.w	d4,d4
	neg.w	d2	
	moveq	#-32,d3

.pix_loop:	cmp.w	d3,d2
	bgt.s	.no_pix		
	cmp.w	d3,d1
	ble.s	.no_pix
	moveq	#0,d5
	move.w	d3,d5
	sub.w	d2,d5
	swap	d5
	divu	d4,d5
	mulu	#CIRC_LEN,d5
	swap	d5
	add.w	d5,d5
	move.w	(a0,d5),d5
	mulu	#ENLARGE,d5
	swap	d5
	sub.w	#ENLARGE/2,d5
	add.w	d0,d5
	add.w	#32,d5
	move.w	d5,(a1)+	
	bra.s	.dec
.no_pix:	move.w	#-1,(a1)+
.dec:	addq.w	#1,d3
	cmp.w	#32,d3
	bne.s	.pix_loop

	move.l	circle_add(a6),d0
	add.l	d0,circle_index(a6)
	addq.w	#1,circle_count(a6)
	cmp.w	#64,circle_count(a6)
	bne	.gen_loop

	unlk	a6
	rts

fade_black_title_screen:
	cmp.w	#800,intro_counter(a4)
	bcs.s	.no
	move.w	#256,d0
	move.w	intro_counter(a4),d1
	sub.w	#800,d1
	sub.w	#32,d1
	neg.w	d1
	seq	exit_ex(a4)
	move.l	title_rgb_pointer(a4),a0     
	move.l	temp_pal_pointer(a4),a1
	addq.l	#2,a1
	bsr	fade_rgb_colors	
.no:	rts
	
fade_down_title_screen:	

title_pal	equ -514

	tst.b	title_faded(a4)
	bne	.done
	move.w	intro_counter(a4),d0
	lsl.w	#4,d0

	link	a6,#title_pal
	move.l	title_rgb_pointer(a4),a0     
	subq.l	#2,a0
	sub.w	#$f0,d0
	neg.w	d0
	seq	title_faded(a4)
	lea	title_pal(a6),a1
	move.w	(a0)+,(a1)+
	move.w	#256-1,d1
.loop:
	move.w	(a0)+,d2
	lsr.w	#1,d2
	move.w	d2,d3
	move.w	d3,d4
	moveq	#5,d6
	moveq	#$1f,d7
	lsr.w	d6,d3	
	lsr.w	d6,d4	
	lsr.w	d6,d4
	and.w	d7,d2	
	and.w	d7,d3	
	and.w	d7,d4
	addq.w	#1,d7
	move.w	d7,d5
	move.w	d7,d6
	sub.w	d2,d5
	sub.w	d3,d6
	sub.w	d4,d7
	mulu	d0,d5
	mulu	d0,d6
	mulu	d0,d7
	lsr.w	#8,d5
	lsr.w	#8,d6
	lsr.w	#8,d7
	add.w	d2,d5
	add.w	d3,d6
	add.w	d4,d7
	moveq	#5,d4 
	lsl.w	d4,d6	
	lsl.w	d4,d7	
	lsl.w	d4,d7
	or.w	d5,d6
	or.w	d6,d7
	add.w	d7,d7
	addq.w	#1,d7
	move.w	d7,(a1)+
	dbra	d1,.loop

	move.w	d0,d3
	move.b	d3,d4
	lsl.l	#8,d4
	move.b	d3,d4
	lsl.l	#8,d4
	lsl.l	#8,d4
	move.b	d3,d4
	move.l	d4,background_setting(a4)

	lsr.w	#3,d0
	move.w	d0,d1
	move.w	d1,d2

	lsl.w	#5,d1
	lsl.w	#5,d2
	lsl.w	#5,d2
	or.w	d0,d1
	or.w	d1,d2
	add.w	d2,d2
	addq.w	#1,d2
	move.w	d2,border_setting(a4)

	lea	title_pal(a6),a0
	move.l	temp_pal_pointer(a4),a1
	move.l	#257*2,d0
	bsr	blitter_copy
	unlk	a6

.done: 
	bsr	print_title_screen

	btst	#4,vbl_counter(a4)
	beq.s	.no_display

	move.l	text_buffer_pointer(a4),a0
	move.w	start_text_len(a4),d0
	bsr	draw_text
	bsr	wait_text

.no_display:	
	move.w	#5,d0
	move.w	#80,d1
	moveq	#22,d2
	move.l	intro_hed_pointer(a4),a0
	move.l	current_list_pointer(a4),a1
	bsr	draw_a_jag_sprite
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	rts

bubsy_zoom:
	move.w	bubsy_action(a4),d0
	lsl.w	#2,d0
	jmp	.do_action(pc,d0)

.do_action:
	jmp	wait_bubsy(pc)
	jmp	enlarge_bubsy(pc)
	jmp	launch_bubsy(pc)
	jmp	bubsy_smack(pc)	
	jmp	down_bubsy(pc)
	jmp	flash_start(pc)
	jmp	circle_out(pc)

circle_out:
	move.w	#148,intro_counter(a4)
	bsr	draw_the_logo
	bsr	draw_frac

	btst	#4,vbl_counter(a4)
	beq.s	.no1
	bsr	draw_start

.no1:
	if	STRIP=FALSE
	movem.w	circle_prev(a4),d1-d2
	bsr	blit_circle

	move.w	circle_angle(a4),d1
	
	move.w	d1,d2
	add.w	#SINE_LEN/4,d2
	and.w	#SINE_LEN-1,d1
	and.w	#SINE_LEN-1,d2
	add.w	d1,d1
	add.w	d2,d2
	move.l	sine_pointer(a4),a0
	move.w	(a0,d1),d1	
	move.w	(a0,d2),d2	

	muls	circle_radius(a4),d1
	muls	circle_radius(a4),d2
	asr.l	#3,d1
	asr.l	#3,d2
	add.l	d1,d1
	add.l	d2,d2
	swap	d1
	swap	d2
	movem.w	d1-d2,circle_prev(a4)
	bsr	blit_circle

	add.w	#24,circle_angle(a4)
	addq.w	#7,circle_radius(a4)
	cmp.w	#384*4+150,circle_radius(a4)
	blt.s	.setup_object
	st	exit_ex(a4)
.setup_object:    	
	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	#BLITTER_WINDOW,d0
	move.w	scree_height_fred(a4),d2
	sub.w	d2,d0
	asr.w	#1,d0
	neg.w	d0
	move.w	d0,obj_ypos(a0)

	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	circle_screen_pointers(a4),obj_data(a0)
	move.w	#(-((BLITTER_WINDOW-SCREEN_WIDTH)/2)),obj_xpos(a0)
	move.w	#OPIXEL1,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#(BLITTER_WINDOW/64)*1,obj_dwidth(a0)
	move.w	#(BLITTER_WINDOW/64)*1,obj_iwidth(a0)
	move.w	#55,obj_index(a0)
	move.w	#TRANS+RELEASE,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	clip_bitmap_object
	moveq	#16,d0                 
	bsr	fix_object_boundry
	add.w	d0,bytes_in_object_list(a4)
	bsr	make_object
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	UNSTACKOBJ

	movem.l	circle_screen_pointers(a4),d0-d1
	exg	d0,d1
	movem.l	d0-d1,circle_screen_pointers(a4)
	endif

	move.w	star_off_table(a4),d2
	subq.w	#8,d2
	cmp.w	scree_height_fred(a4),d2
	bgt.s	.no_scroll
	addq.w	#2,star_off_table(a4)
	rts
.no_scroll:
	move.l	current_list_pointer(a4),a1
	moveq	#16,d0                 
	bsr	fix_object_boundry
	add.w	d0,bytes_in_object_list(a4)
	add.l	d0,current_list_pointer(a4)
	move.l	rmw_data2(a4),a1
	bsr	darken_screen
	bsr	rmw_down
	move.l	rmw_data2(a4),a1
	cmp.w	#$80,(a1)
	seq	exit_ex(a4)
.lsk:
	rts

	if	STRIP=FALSE
blit_circle:
	add.w	#384/2,d1
	add.w	#384/2,d2
	sub.w	#32,d1
	sub.w	#32,d2
	move.w	d1,-(sp)
	move.w	d2,-(sp)

; setup the source
	move.l	intro_hed_pointer(a4),a6
	lea	9*jsprite_e(a6),a6

	move.l	jsprite_data(a6),A2_BASE-BASE(a5)
	move.l	#PITCH1|PIXEL1|WID64|XADDPIX,A2_FLAGS-BASE(a5)
	move.l	#0,A2_PIXEL-BASE(a5)
	move.l	#2*65536-64,A2_STEP-BASE(a5)
	
	move.l	circle_screen_pointers(a4),A1_BASE-BASE(a5)
	move.l	#PITCH1|PIXEL1|WID384|XADDPIX,A1_FLAGS-BASE(a5)
	move.l	#384*65536+384,A1_CLIP-BASE(a5)
	move.l	(sp)+,A1_PIXEL-BASE(a5)		
	move.l	#2*65536-64,A1_STEP-BASE(a5)
	
	move.l	#64*65536+64,B_COUNT-BASE(a5)
	move.l	#SRCEN|DSTEN|CLIP_A1|UPDA1|UPDA2|LFU_SORD,B_CMD-BASE(a5)
	rts
	endif
	
draw_frac:
	moveq	#64,d1
	lsr.w	#1,d1
	moveq	#11,d0
	move.w	#SCREEN_WIDTH/2,d2
	move.w	scree_height_fred(a4),d3
	lsr.w	#1,d3
	add.w	#BUBSY_ENLARGEY+10,d3
	add.w	fractured(a4),d3
	bsr	print_scaled_sprite
	rts

flash_start:
	move.w	#148,intro_counter(a4)
	bsr	draw_the_logo
	
	bsr	draw_frac
	btst	#4,vbl_counter(a4)
	beq.s	.no1
	bsr	draw_start
.no1:
	sub.w	#2,bubsy_log(a4)
	cmp.w	#-70,bubsy_log(a4)
	bge.s	.no2
	move.w	#-70,bubsy_log(a4)
.no2:
	subq.w	#4,fractured(a4)
	spl	d4
	ext.w	d4
	and.w	d4,fractured(a4)
.no:
	cmp.b	#250,vbl_counter(a4)
	bne.s	.no_inc
	clr.b	vbl_counter(a4)
	addq.w	#1,bubsy_action(a4)
.no_inc:
	rts

draw_start:
	if	!ONLY_OPTIONS
	moveq	#16,d0                 
	move.l	current_list_pointer(a4),a1
	bsr	fix_object_boundry
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)

	moveq	#70,d0
	moveq	#6,d1
	moveq	#22,d2
	
	cmp.b	#PAL,tv_type
	bne.s	.not_pal1
	add.w	#14,d1
	
.not_pal1:
	move.l	intro_hed_pointer(a4),a0
	move.l	current_list_pointer(a4),a1
	bsr	draw_a_jag_sprite
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                

	moveq	#70,d0
	moveq	#18,d1
	moveq	#23,d2
	
	cmp.b	#PAL,tv_type
	bne.s	.not_pal2
	add.w	#14,d1
	
.not_pal2:
	move.l	intro_hed_pointer(a4),a0
	move.l	current_list_pointer(a4),a1
	bsr	draw_a_jag_sprite
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	else
	moveq	#16,d0                 
	move.l	current_list_pointer(a4),a1
	bsr	fix_object_boundry
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)

	moveq	#(320-144)/2,d0
	moveq	#14,d1
	moveq	#24,d2
	
	cmp.b	#PAL,tv_type
	bne.s	.not_pal1
	add.w	#14,d1
	
.not_pal1:
	move.l	intro_hed_pointer(a4),a0
	move.l	current_list_pointer(a4),a1
	bsr	draw_a_jag_sprite
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)
	endif
	rts

display_smack:
	moveq	#5,d0
	move.w	#148,intro_counter(a4)
	bsr	print_bubsy_logo
	rts

bubsy_smack:
	bsr	display_smack
	cmp.b	#50,vbl_counter(a4)
	bne.s	.no_inc
	addq.w	#1,bubsy_action(a4)
.no_inc:
	rts

down_bubsy:
	bsr	display_smack	
	addq.w	#3,bubsy_yoff(a4)
	cmp.w	#330,bubsy_yoff(a4)
	bne.s	.no_inc
	clr.b	vbl_counter(a4)
	addq.w	#1,bubsy_action(a4)
.no_inc:
	rts	

launch_bubsy:
	moveq	#0,d0
	move.w	intro_counter(a4),d0
	sub.w	#64,d0
	divu	#24,d0	
	addq.w	#1,d0

	bsr	print_bubsy_logo
	cmp.w	#148,intro_counter(a4)
	bne.s	.no_inc
	addq.w	#1,bubsy_action(a4)
	clr.b	vbl_counter(a4)
.no_inc:
	rts

enlarge_bubsy:
	moveq	#0,d0
	bsr	print_bubsy_logo
 	addq.w	#1,intro_counter(a4)
	cmp.w	#64,intro_counter(a4)
	bne.s	.no_inc
	addq.w	#1,bubsy_action(a4)
.no_inc:
	rts

wait_bubsy:
	cmp.w	#40,intro_counter(a4)
	bne.s	.no_inc
	clr.w	intro_counter(a4)                  
	addq.w	#1,bubsy_action(a4)
.no_inc:
	rts

draw_the_logo:	
	moveq	#0,d1
	move.w	intro_counter(a4),d1
	cmp.b	#64,d1
	bcs.s	.ok
	moveq	#64,d1
.ok:
	lsr.w	#1,d1
	moveq	#2,d0
	move.w	#SCREEN_WIDTH/2,d2
	move.w	scree_height_fred(a4),d3
	lsr.w	#1,d3
	add.w	#BUBSY_ENLARGEY,d3
	add.w	bubsy_log(a4),d3

	bsr	print_scaled_sprite
	rts

print_bubsy_logo:
	move.w	d0,-(sp)
	bsr	draw_the_logo
	
	move.w	(sp)+,d0
	addq.w	#3,d0
	moveq	#0,d1
	move.w	intro_counter(a4),d1
	lsr.w	#1,d1
	addq.b	#1,d1
	move.w	#-6,d2
	move.w	#-53,d3
	muls	d1,d2
	muls	d1,d3
	asr.w	#5,d2
	asr.w	#5,d3
	add.w	#SCREEN_WIDTH/2,d2
	move.w	scree_height_fred(a4),d4
	lsr.w	#1,d4
	add.w	d4,d3	
	add.w	#BUBSY_ENLARGEY,d3
	moveq	#0,d4
	move.w	intro_counter(a4),d4
	sub.b	#64,d4
	bcs.s	.no_go
	mulu	#100,d4
	divu	#90,d4       
	add.w	d4,d3	
.no_go:
	add.w	bubsy_yoff(a4),d3
	move.w	d0,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	.add(pc,d7),d2
	add.w	.add+2(pc,d7),d3
	bsr	print_scaled_sprite
	rts

.add:
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	10,0
	dc.w	10,0
	dc.w	35,0
	dc.w	28,0
	dc.w	18,0

clear_intro_screen:
	move.w	#BLITTER_WINDOW,d0
	move.w	scree_height_fred(a4),d1
	sub.w	d1,d0
	asr.w	#1,d0
	mulu	#BLITTER_WINDOW/2,d0
	add.l	d0,a0
	move.w	#BLITTER_WINDOW/2,d0
	mulu	scree_height_fred(a4),d0
	bsr	blitter_clear
	rts

setup_screen_objects:
	if	STRIP=FALSE
star_dest	equ	-500
num_stars	equ	0
	link	a6,#star_dest

	move.l	screen_pointers+(NUM_SCREENS*4)(a4),a0
	bsr	clear_intro_screen
	move.l	sine_pointer(a4),a1
	moveq	#0,d6
	move.b	star_counter(a4),d6
	lsl.w	#4,d6
	move.w	d6,d5
	add.w	#SINE_LEN/4,d5
	and.w	#SINE_LEN-1,d5
	and.w	#SINE_LEN-1,d6
	add.w	d5,d5
	add.w	d6,d6
	move.w	(a1,d6),d4
	move.w	(a1,d5),d5

	moveq	#num_stars-1,d7
	moveq	#0,d6
	move.b	star_counter(a4),d6
	add.w	d6,d6
	lea	star_coords(pc),a0
	lea	star_dest(a6),a1

.star_loop:
	movem.w	(a0)+,d0-d1
	add.w	d0,d0
	add.w	d1,d1
	movem.w	d0-d1,-(sp)
	muls	d5,d0
	muls	d4,d1
	sub.l	d1,d0
	swap	d0
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	muls	d5,d1
	muls	d4,d0
	add.l	d0,d1
	swap	d1
	move.w	d2,d0
	move.w	(a0)+,d2
	muls	#PERSPECTIVE_VAL,d0	    
	muls	#PERSPECTIVE_VAL,d1
	sub.w	d6,d2
	and.w	#$1ff,d2	
	move.w	d2,d3
	add.w	#PERSPECTIVE_VAL,d3
	divs	d3,d0		  
	divs	d3,d1
	add.w	#BLITTER_WINDOW/2,d0
	add.w	#BLITTER_WINDOW/2,d1

	move.w	d0,(a1)+	
	move.w	d1,(a1)+	
	move.w	d2,(a1)+
	add.w	#43,(a0)
	move.w	(a0)+,(a1)+
	dbra	d7,.star_loop

.sort_back:
	moveq	#num_stars-1,d7
	lea	star_dest(a6),a0
.sort_loop:
	cmp.w	#1,d7
	ble.s	.done_sort
	move.w	4+0(a0),d0
	cmp.w	4+8(a0),d0
	bge.s	.ok
	movem.l	(a0),d0-d3
	movem.l	d0-d1,8(a0)
	movem.l	d2-d3,(a0)
	bra.s	.sort_back
.ok:
	addq.l	#8,a0
	subq.w	#1,d7
	bra.s	.sort_loop

.done_sort:
	moveq	#num_stars-1,d7
	lea	star_dest(a6),a0
.star_loop2:
	move.l	(a0)+,d0
	moveq	#0,d1
	move.w	(a0)+,d1
	sub.w	#$200,d1
	neg.w	d1
	move.w	d1,d2
	mulu	#(65536/100)*20,d2
	swap	d2
	add.w	d2,d1
	lsl.l	#7,d1
	move.l	d1,d2

	move.l	#PIXEL4+WID16,d3
	move.l	#PIXEL4+WID384,d4
	move.w	(a0)+,d6
	movem.l	d7/a0-a1/a6,-(sp)
	move.l	intro_hed_pointer(a4),a0
	move.w	jsprite_e+jsprite_paramsixel_width(a0),d5
	swap	d5
	move.w	jsprite_e+jsprite_height(a0),d5
	addq.w	#2,d5
	move.l	jsprite_e+jsprite_data(a0),a0
	move.l	screen_pointers+(NUM_SCREENS*4)(a4),a1
	bsr	blitter_rotate_bitmap
	movem.l	(sp)+,d7/a0-a1/a6
	dbra	d7,.star_loop2

	lea	screen_pointers+((NUM_SCREENS+1)*4)(a4),a1
	lea	-4(a1),a0
	moveq	#NUM_SCREENS-1,d0
	move.l	(a0),-(sp)
.swap_loop:
	move.l	-(a0),-(a1)
	dbra	d0,.swap_loop
	move.l	(sp)+,-(a1)	

	lea	screen_pointers+(NUM_SCREENS*4)(a4),a0
	moveq	#NUM_SCREENS-1,d0
	moveq	#24,d1
.make_loop:
	movem.l	d0-d1/a0,-(sp)
	move.l	-(a0),d7
	move.w	#OPIXEL4,d2	
	bsr	make_screen_object
	movem.l	(sp)+,d0-d1/a0
	subq.w	#8,d1
	subq.l	#4,a0
	dbra	d0,.make_loop
	unlk	a6
	endif
	rts

make_screen_object:
	STACKOBJ
	move.w	d2,-(sp)
	move.w	#BITMAP_OBJECT,obj_type(a0)
	move.w	#BLITTER_WINDOW,d0

	move.w	scree_height_fred(a4),d2
	sub.w	d2,d0
	asr.w	#1,d0
	neg.w	d0
	move.w	d0,obj_ypos(a0)

	move.w	scree_height_fred(a4),obj_height(a0)  
	move.l	d7,obj_data(a0)
	move.w	#(-((BLITTER_WINDOW-SCREEN_WIDTH)/2)),obj_xpos(a0)
	move.w	(sp),obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	#(BLITTER_WINDOW/64)*4,obj_dwidth(a0)
	move.w	#(SCREEN_WIDTH/64)*4,obj_iwidth(a0)
	move.w	d1,obj_index(a0)
	move.w	#TRANS+RELEASE,obj_flags(a0)
	cmp.w	#OPIXEL4,(sp)+
	beq.s	.pixel4
	move.w	#(BLITTER_WINDOW/64)*8,obj_dwidth(a0)
	move.w	#(SCREEN_WIDTH/64)*8+1,obj_iwidth(a0)
	move.w	#TRANS,obj_flags(a0)
.pixel4:
	move.w	#0,obj_firstpix(a0)
	move.l	current_list_pointer(a4),a1
	bsr	clip_bitmap_object
	bsr	make_object

	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	UNSTACKOBJ
	rts

set_intro_pal: 
	move.l	background_setting(a4),BORD1
	move.w	border_setting(a4),BG
	move.l	temp_pal_pointer(a4),a0
	addq.l	#2,a0
	lea	CLUT,a1
	move.l	#NUM_EX_COLS*2,d0
	bsr	fast_copy_bytes
	rts

set_full_pal:
	move.l	background_setting(a4),BORD1
	move.w	border_setting(a4),BG
	move.l	temp_pal_pointer(a4),a0
	bsr	load_full_marv_palette
	rts

fade_down_to_reguler_pal:

PAL_SIZE	equ (NUM_EX_COLS+1)*2
reg_pal		equ -PAL_SIZE

	tst.b	reguler_pal(a4)
	bne	.done
	moveq	#0,d0
	move.w	intro_counter(a4),d0
	lsl.w	#4,d0

	link	a6,#reg_pal
	move.l	star_pal_pointer(a4),a0     
	sub.w	#$f0,d0
	neg.w	d0
	seq	reguler_pal(a4)
	lea	reg_pal(a6),a1
	move.w	(a0)+,(a1)+
	move.w	#NUM_EX_COLS-1,d1
.loop:
	move.w	(a0)+,d2
	lsr.w	#1,d2
	move.w	d2,d3
	move.w	d3,d4
	moveq	#5,d6
	moveq	#$1f,d7
	lsr.w	d6,d3	
	lsr.w	d6,d4	
	lsr.w	d6,d4
	and.w	d7,d2	
	and.w	d7,d3	
	and.w	d7,d4
	addq.w	#1,d7
	move.w	d7,d5
	move.w	d7,d6
	sub.w	d2,d5
	sub.w	d3,d6
	sub.w	d4,d7
	mulu	d0,d5
	mulu	d0,d6
	mulu	d0,d7
	lsr.w	#8,d5
	lsr.w	#8,d6
	lsr.w	#8,d7
	add.w	d2,d5
	add.w	d3,d6
	add.w	d4,d7
	moveq	#5,d4 
	lsl.w	d4,d6	
	lsl.w	d4,d7	
	lsl.w	d4,d7
	or.w	d5,d6
	or.w	d6,d7
	add.w	d7,d7
	addq.w	#1,d7
	move.w	d7,(a1)+
	dbra	d1,.loop

	move.w	d0,d3
	move.b	d3,d4
	lsl.l	#8,d4
	move.b	d3,d4
	lsl.l	#8,d4
	lsl.l	#8,d4
	move.b	d3,d4
	move.l	d4,background_setting(a4)

	lsr.w	#3,d0
	move.w	d0,d1
	move.w	d1,d2

	lsl.w	#5,d1
	lsl.w	#5,d2
	lsl.w	#5,d2
	or.w	d0,d1
	or.w	d1,d2
	add.w	d2,d2
	addq.w	#1,d2
	move.w	d2,border_setting(a4)

	lea	reg_pal(a6),a0
	move.l	temp_pal_pointer(a4),a1
	move.l	#(NUM_EX_COLS+1)*2,d0
	bsr	blitter_copy

	unlk	a6
.done: 	rts

bigexclamation_stuff:
	move.w	exclamation_action(a4),d0
	lsl.w	#2,d0
	jmp	.do_action(pc,d0)

.do_action:
	jmp	fade_up_ex(pc)
	jmp	ex_delay(pc)
	jmp	expand_exclamation(pc)
	jmp	fade_to_white(pc)

	st	exit_ex(a4)
	rts

fade_to_white	equ (NUM_EX_COLS+1)*2
white_pal		equ -fade_to_white

	bsr	print_exclamation
	addq.w	#2,ex_scale(a4)
	cmp.w	#$9c,ex_scale(a4)
	blt.s	.no_inc
	addq.w	#1,exclamation_action(a4)
.no_inc:	moveq	#0,d0
	move.w	intro_counter(a4),d0
	lsl.b	#4,d0

	link	a6,#white_pal
	move.l	star_pal_pointer(a4),a0     
	lea	white_pal(a6),a1
	move.w	(a0)+,(a1)+
	move.w	#NUM_EX_COLS-1,d1
.loop:	move.w	(a0)+,d2
	lsr.w	#1,d2
	move.w	d2,d3
	move.w	d3,d4
	moveq	#5,d6
	moveq	#$1f,d7
	lsr.w	d6,d3	
	lsr.w	d6,d4	
	lsr.w	d6,d4
	and.w	d7,d2	
	and.w	d7,d3	
	and.w	d7,d4
	addq.w	#1,d7
	move.w	d7,d5
	move.w	d7,d6
	sub.w	d2,d5
	sub.w	d3,d6
	sub.w	d4,d7
	mulu	d0,d5
	mulu	d0,d6
	mulu	d0,d7
	lsr.w	#8,d5
	lsr.w	#8,d6
	lsr.w	#8,d7
	add.w	d2,d5
	add.w	d3,d6
	add.w	d4,d7
	moveq	#5,d4 
	lsl.w	d4,d6	
	lsl.w	d4,d7	
	lsl.w	d4,d7
	or.w	d5,d6
	or.w	d6,d7
	add.w	d7,d7
	addq.w	#1,d7
	move.w	d7,(a1)+
	dbra	d1,.loop

	move.w	d0,d3
	move.b	d3,d4
	lsl.l	#8,d4
	move.b	d3,d4
	lsl.l	#8,d4
	lsl.l	#8,d4
	move.b	d3,d4
	move.l	d4,background_setting(a4)

	lsr.w	#3,d0
	move.w	d0,d1
	move.w	d1,d2

	lsl.w	#5,d1
	lsl.w	#5,d2
	lsl.w	#5,d2
	or.w	d0,d1
	or.w	d1,d2
	add.w	d2,d2
	addq.w	#1,d2
	move.w	d2,border_setting(a4)

	lea	white_pal(a6),a0
	move.l	temp_pal_pointer(a4),a1
	move.l	#(NUM_EX_COLS+1)*2,d0
	bsr	blitter_copy

	unlk	a6
	bsr	print_exclamation
	rts

expand_exclamation:
	bsr	print_exclamation
	addq.w	#2,ex_scale(a4)
	cmp.w	#$9e-$20,ex_scale(a4)
	blt.s	.no_inc
	addq.w	#1,exclamation_action(a4)
	clr.w	intro_counter(a4)
.no_inc:	rts

ex_delay:	bsr	print_exclamation
	cmp.w	#130,intro_counter(a4)
	bne.s	.no_inc
	addq.w	#1,exclamation_action(a4)
.no_inc:	rts

fade_up_ex	equ (NUM_EX_COLS+1)*2
faded_pal	equ -fade_up_ex

	link	a6,#faded_pal

	move.l	star_pal_pointer(a4),a0     
	lea	faded_pal(a6),a1
	move.w	(a0)+,(a1)+
	moveq	#0,d0
	move.w	intro_counter(a4),d0
	move.w	#NUM_EX_COLS-1,d1
	moveq	#5,d6
.loop:
	move.w	(a0)+,d2
	lsr.w	#1,d2
	move.w	d2,d3
	move.w	d3,d4
	lsr.w	d6,d3	
	lsr.w	d6,d4	
	lsr.w	d6,d4
	and.w	#$1f,d2	
	and.w	#$1f,d3	
	and.w	#$1f,d4
	mulu	d0,d2	
	mulu	d0,d3	
	mulu	d0,d4
	lsr.w	d6,d2	
	lsr.w	d6,d3	
	lsr.w	d6,d4	
	lsl.w	d6,d3
	lsl.w	d6,d4
	lsl.w	d6,d4
	or.w	d2,d3
	or.w	d3,d4
	add.w	d4,d4
	addq.w	#1,d4
	move.w	d4,(a1)+
	dbra	d1,.loop
	
	cmp.w	#32,d0
	bne.s	.no_inc2
	addq.w	#1,exclamation_action(a4)
.no_inc2:
	lea	faded_pal(a6),a0
	move.l	temp_pal_pointer(a4),a1
	move.l	#(NUM_EX_COLS+1)*2,d0
	bsr	blitter_copy
	unlk	a6
	bsr	print_exclamation
	rts   

print_exclamation:
	moveq	#0,d0
	move.w	ex_scale(a4),d1
	bsr	print_scaled_sprite_in_middle
	rts

print_scaled_sprite_in_middle:
	move.w	#SCREEN_WIDTH/2,d2
	move.w	scree_height_fred(a4),d3
	lsr.w	#1,d3
	bsr	print_scaled_sprite
	rts

print_scaled_sprite:
	movem.w	d0-d3,-(sp)
	moveq	#32,d0
	move.l	current_list_pointer(a4),a1
	bsr	fix_object_boundry
	add.w	d0,bytes_in_object_list(a4)
	move.l	a1,current_list_pointer(a4)
	move.l	intro_hed_pointer(a4),a0

	movem.w	(sp)+,d0-d3
	lsl.w	#4,d0
	lea	(a0,d0),a0	

	move.w	d3,d4
	move.w	d1,d3
	swap	d3
	move.w	d1,d3

	move.w	d2,d0
	move.w	d4,d1
	move.w	d3,d4
	move.w	d3,d5
	muls	jsprite_paramsixel_width(a0),d4	
	muls	jsprite_height(a0),d5
	asr.w	#6,d4		
	asr.w	#6,d5		
	sub.w	d4,d0
	sub.w	d5,d1

	moveq	#0,d2
	move.l	current_list_pointer(a4),a1	                
	bsr	draw_a_scaled_jag_sprite
	move.l	a1,current_list_pointer(a4)
	add.w	d0,bytes_in_object_list(a4)                
	rts

setup_game_loop_vars:	
	move.l	object_list_pointer(a4),current_list_pointer(a4)
	clr.w	bytes_in_object_list(a4)
	rts

swapscreen:
	st	made_object_list(a4)
	bsr	get_random
	rts

allocate_and_load_stuff:
	LOAD_AND_FIX_FAST_SPRITES intro_hed_name,intro_hed_pointer(a4),intro_gfx_name,intro_gfx_pointer(a4),intro_fst_pointer(a4)
	LOAD_AND_FIX_FAST_SPRITES font1_hed_name,font1_hed_pointer(a4),font1_gfx_name,font1_gfx_pointer(a4),font1_fst_pointer(a4)
	STANDARD_LOAD waterfon_pal_name,waterfon_pal_pointer(a4)
	STANDARD_LOAD sine_name,sine_pointer(a4)
	STANDARD_LOAD circ_name,half_circle_pointer(a4)

;	tst.b	dont_load_mod(a4)
;	bne.s	.skp
;	STANDARD_LOAD intro_mod_name,fred_mod_load_addr(a4)
;.skp	STANDARD_LOAD hi_mod_name,fred_hi_mod_load_addr(a4)

	LOAD_AND_FIX_SPRITES logo_hed_name,logo_hed_pointer(a4),logo_gfx_name,logo_gfx_pointer(a4)
	STANDARD_LOAD atari_pal_name,atari_pal_pointer(a4)
	STANDARD_LOAD idi_pal_name,idi_pal_pointer(a4)

	STANDARD_LOAD title_gfx_name,title_gfx_pointer(a4)
	STANDARD_LOAD title_pal_name,title_pal_pointer(a4)
	STANDARD_LOAD title_rgb_name,title_rgb_pointer(a4)
	STANDARD_LOAD star_pal_name,star_pal_pointer(a4)
	STANDARD_LOAD bubsy_pal_name,bubsy_pal_pointer(a4)

	move.l	intro_hed_pointer(a4),a0
	clr.w	jsprite_paramsalindex(a0)
	clr.w	jsprite_paramsalindex+16(a0)

	move.l	#64*64*2,d0
	bsr	allocate_memory
	move.l	a0,mag_pointer(a4)
	bsr	generate_mag_table

	moveq	#32,d1
	move.l	star_pal_pointer(a4),a1
	addq.l	#2,a1
.fade_loop:
	move.l	star_pal_pointer(a4),a0
	addq.l	#2,a0
	moveq	#16,d0
	bsr	fade_rgb_colors
	subq.w	#8,d1
	bne.s	.fade_loop

 	move.w	scree_height_fred(a4),d0
	mulu	#8,d0
	move.l	d0,-(sp)
	bsr	allocate_memory
	move.l	a0,rmw_data(a4)
	move.l	(sp),d0
	bsr	allocate_memory
	move.l	a0,rmw_data2(a4)       
	move.l	(sp)+,d0		
	move.l	rmw_data(a4),a0
.loopy:
	move.l	#$a000a0,(a0)+
	move.l	#$a000a0,(a0)+
	subq.w	#8,d0
	bne.s	.loopy

	lea	screen_pointers(a4),a6
	moveq	#NUM_SCREENS,d7
.alloc_loop:
	move.l	#(BLITTER_WINDOW*BLITTER_WINDOW)/2,d0
	bsr	allocate_memory
	move.l	#(BLITTER_WINDOW*BLITTER_WINDOW)/2,d0
	move.l	a0,(a6)+
	bsr	blitter_clear
	dbra	d7,.alloc_loop
	move.l	screen_pointers(a4),original_screen_pointer(a4)

	lea	circle_screen_pointers(a4),a6
	moveq	#2-1,d7
.alloc_loop2:
	move.l	#(BLITTER_WINDOW*BLITTER_WINDOW)/8,d0
	bsr	allocate_memory
	move.l	#(BLITTER_WINDOW*BLITTER_WINDOW)/8,d0
	move.l	a0,(a6)+
	bsr	blitter_clear
	dbra	d7,.alloc_loop2

	moveq	#2-1,d7
	lea	star_screen_pointers(a4),a6
.alloc_loop3:
	move.w	#SCREEN_WIDTH,d0
	mulu	scree_height_fred(a4),d0
	add.l	d0,d0
	move.l	d0,-(sp)
	bsr	allocate_memory
	move.l	a0,(a6)+
	move.l	(sp)+,d0
	bsr	blitter_clear
	dbra	d7,.alloc_loop3	             

	lea	star_restore_pointer(a4),a6
	moveq	#2-1,d7
.alloc_loop4:
	move.l	#(MAX_STAR_COORDS+1)*4,d0
	bsr	allocate_memory
	move.l	a0,(a6)+
	dbra	d7,.alloc_loop4	             

	move.l	#514,d0
	bsr	allocate_memory
	move.l	a0,temp_pal_pointer(a4)
	move.l	#(NUM_EX_COLS+1)*2,d0
	bsr	blitter_clear
	rts

generate_ball:

zrot	equ -50
xrot	equ -48
xval	equ -46
yval	equ -44

	link	a6,#zrot

	move.l	#MAX_STAR_COORDS*6,d0
	bsr	allocate_memory
	move.l	a0,star_ball_pointer(a4)

	move.w	#SINE_LEN/32,zrot(a6)
.loop0:
	move.w	zrot(a6),d0
	bsr	get_sine_cosine
	
	move.w	#-STAR_RADIUS,d2
	moveq	#0,d3
	move.w	d2,d4	
	move.w	d3,d5	
	muls	d1,d2
	muls	d0,d3
	sub.l	d3,d2
	add.l	d2,d2
	swap	d2
	muls	d1,d5
	muls	d0,d4
	add.l	d4,d5
	add.l	d5,d5
	swap	d5
	
	move.w	d2,xval(a6)	
	move.w	d5,yval(a6)	

	clr.w	xrot(a6)
.loop1:
	move.w	xrot(a6),d0
	bsr	get_sine_cosine

	muls	yval(a6),d1
	add.l	d1,d1
	swap	d1
	
	muls	yval(a6),d0
	add.l	d0,d0
	swap	d0

	move.w	xval(a6),(a0)+
	move.w	d1,(a0)+		           
	move.w	d0,(a0)+		           

	add.w	#SINE_LEN/16,xrot(a6)
	cmp.w	#SINE_LEN,xrot(a6)
	bne	.loop1

	add.w	#SINE_LEN/32,zrot(a6)
	cmp.w	#SINE_LEN/2,zrot(a6)
	bne	.loop0	

	unlk	a6
	rts

init_stars:
	bsr	generate_ball
	move.l	waterfon_pal_pointer(a4),a0
	bsr	load_full_marv_palette
	lea	letter_y_table(a4),a0
	moveq	#7-1,d7
	moveq	#0,d6
.loop:
	move.w	#CIRC_LEN/2,0(a0)                  
	move.w	#0,2(a0)
	move.w	#0,4(a0)
	sf	6(A0)
	move.w	#250,8(a0)	  
	move.w	d6,10(a0)	  
	add.w	#20,d6
	lea	16(a0),a0
	dbra	d7,.loop

	lea	star_table(a4),a0
	moveq	#NUM_STARS-1,d7
	move.w	#14000,d6
.gen_loop:
	bsr	get_random
	and.w	#SINE_LEN-1,d0
	move.w	d0,(a0)+
	bsr	get_random
	muls	#300,d0
	swap	d0
	move.w	d0,(a0)+
	bsr	get_random
	muls	#170,d0
	swap	d0
	move.w	d0,(a0)+
	move.w	d6,(a0)+
	add.w	#3000/NUM_STARS,d6
	move.w	#1<<8+$30,(a0)+	
	bsr	get_random
	and.w	#$ff00,d0
	move.w	d0,(a0)+
	dbra	d7,.gen_loop

	clr.w	intro_counter(a4)

	lea	fuck_text,a0
	move.l	text_buffer_pointer(a4),a1
	bsr	convert_text_to_sprites
	move.w	d0,fuck_text_len(a4)

	movem.l	star_restore_pointer(a4),a0-a1
	st	(a0)
	st	(a1)
	rts

trev_gpu:
	move.l	#GPUPP_S,a0
	move.l	#GPUPP_E,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	#$b904,$44(a0)		;trevs patch
	jsr	SETUPGPU
	rts

write_hi_score_to_eprom:

hi_conv_buffer		equ	128

	movem.l	d0-a6,-(sp)
	link	a6,#hi_conv_buffer
	
	lea	hi_conv_buffer(a6),a0
	move.l	#128,d0
	bsr	clear_bytes

	lea	hi_conv_buffer(a6),a3
	lea	8(a3),a3			; skip andy stuff
	lea	hi_score_table+1,a0
	moveq	#10-1,d7
	moveq	#0,d6

.loop:
	lea	18(a0),a0	; skip name ascii
	bsr	ascii_to_long
	move.l	d0,(a3)+
	dbra	d7,.loop
		
	lea	hi_score_table+1,a0
	moveq	#0,d5
	moveq	#10-1,d4
.loop1:	
	addq.l	#6,a0
	moveq	#9-1,d7
.loop2:
	moveq	#0,d6
	move.b	(a0)+,d6
	cmp.b	#"0",d6
	bne.s	.okseedy
	moveq	#"O",d6
	bra.s	.okseedy2
.okseedy:
	cmp.b	#";",d6
	bne.s	.okseedy2
	moveq	#":",d6
.okseedy2:
	lea	special_conv_table(pc),a2
	cmp.b	#"A",d6
	bcs.s	.lt
	sub.b	#"A",d6
	bra.s	.write
.lt:
	cmp.b	(a2)+,d6              
	beq.s	.found
	addq.l	#1,a2
	bra.s	.lt
.found:
	move.b	(a2)+,d6
.write: 
	move.w	d5,d0
	lsr.w	#3,d0
	moveq	#$7,d1
	and.w	d5,d1
	lsl.b	#3,d6
	ror.l	d1,d6
	or.b	d6,0(a3,d0)
	swap	d6
	lsr.w	#8,d6
	or.b	d6,1(a3,d0)
.ok:
	addq.w	#5,d5
	dbra	d7,.loop2
	lea	11(a0),a0
	dbra	d4,.loop1

	lea	hi_conv_buffer(a6),a0
; A0 POINTS TO BUFFER TO BE WRITTEN TO EEPROM
	lea	hi_conv_buffer(a6),a0

	addq.l	#2,a0
	
	move.w	#EEPROM_SIGNATURE,(a0)+	;write signature

	move.w	PLAYERS,d0
	and.w	#%11,d0
	move.b	PAD_TYPE,d1
	and.w	#%111,d1
	move.w	LEVEL,d2
	and.w	#%1111,d2
	move.b	vol_sfx,d3
	and.w	#%11111,d3
	
	lsl.l	#3,d0
	or.w	d1,d0
	lsl.l	#4,d0
	or.w	d2,d0
	lsl.l	#5,d0
	or.w	d3,d0

	move.w	d0,(a0)+
	move.b	vol_mod,(a0)+
	move.b	save_mod_level,(a0)+	;save status of music
	
	lea	hi_conv_buffer(a6),a0
	jsr	checksum_eeprom
	move.w	d0,(a0)
	jsr	write_eeprom
	
	unlk	a6
	movem.l	(sp)+,d0-a6
	rts
	    
read_hi_score_from_eprom:
	jsr	restore_eeprom
	rts	; not right now

	movem.l	d0-a6,-(sp)
	link	a6,#hi_conv_buffer
	lea	hi_conv_buffer(a6),a0

; A0 POINTS TO BUFFER TO BE READ FROM EEPROM

	jsr	read_eeprom
	jsr	checksum_eeprom
	cmp.w	(a0)+,d0
	bne.s	.not_a_valid_eeprom

	cmp.w	#EEPROM_SIGNATURE,(a0)+
	bne.s	.not_a_valid_eeprom

	move	#%11111,d3
	move	#%1111,d2
	move	#%111,d1
	
	move.w	(a0)+,d0
	and.w	d0,d3
	lsr.l	#5,d0
	
	and.w	d0,d2
	lsr.l	#4,d0
	
	and.w	d0,d1
	lsr.l	#3,d0
	and.w	#%11,d0
	
	move.w	d0,PLAYERS
	move.b	d1,PAD_TYPE
	move.w	d2,LAST_LEVEL_PLAYED
	move.b	d3,vol_sfx
	
	move.b	(a0)+,vol_mod
	move.b	(a0)+,save_mod_level

	bra.s	.exit_eeprom

.not_a_valid_eeprom:
	jsr	restore_eeprom
	bra	.valid_eeprom

.exit_eeprom:
	lea	volume_table,a0

	moveq	#1,d1
	moveq	#$c,d0
	move.b	vol_sfx,d0
	move.b	(a0,d0.w),d0
	jsr	SET_VOLU

	moveq	#0,d2
	moveq	#0,d1
	moveq	#$c,d0
	move.b	vol_mod,d0
	bpl.s	.on
	moveq	#1,d2
	moveq	#0,d0

.on:
	move.b	d2,mustype
	move.b	(a0,d0.w),d0
	jsr	SET_VOLU

	lea	hi_conv_buffer(a6),a2
	
	lea	8(a2),a2
	lea	hi_score_table+1,a3
	moveq	#10-1,d6

.loop:
	lea	18(a3),a3
	clr.l	-(sp)
	move.l	(a2)+,-(sp)
	lea	0(sp),a0
	lea	4(sp),a1
	bsr	long_to_bcd
	addq.l	#4,sp
	move.l	(sp)+,d0
	moveq	#4-1,d7
.cloop:
	rol.l	#8,d0
	move.b	d0,d1
	move.b	d0,d2
	and.l	#$f0,d1
	and.l	#$f,d2
	lsr.l	#4,d1
	add.b	#"0",d1
	add.b	#"0",d2
	move.b	d1,(a3)+
	move.b	d2,(a3)+
	dbra	d7,.cloop
	dbra	d6,.loop	

	move.l	a2,a0
	lea	hi_score_table+1,a1
	moveq	#0,d5
	moveq	#10-1,d4

.loop1:
	addq.l	#6,a1
	moveq	#9-1,d7
.loop4:
	moveq	#0,d6
	moveq	#5-1,d2

.loop2:
	move.w	d5,d0
	lsr.w	#3,d0
	moveq	#$7,d1
	and.w	d5,d1
	eor.w	#7,d1	
	add.w	d6,d6
	btst	d1,0(a0,d0)
	beq.s	.no_set
	addq.w	#1,d6
.no_set:
	addq.w	#1,d5
	dbra	d2,.loop2

	cmp.b	#26,d6
	blt.s	.letter
	lea	special_conv_table(pc),a2
.loop3:
	cmp.b	1(a2),d6
	beq.s	.found_special
	addq.l	#2,a2
	bra.s	.loop3	
.found_special:
	move.b	(a2),d6
	bra.s	.in	
.letter:
	add.b	#"A",d6
.in:
	move.b	d6,(a1)+
	dbra	d7,.loop4
	
	lea	11(a1),a1
	dbra	d4,.loop1
	
.valid_eeprom:
	unlk	a6
	movem.l	(sp)+,d0-a6
	rts

special_conv_table:
	dc.b	":",26
	dc.b	".",27
	dc.b	"<",28		;;	;
	dc.b	"!",29
	dc.b	"?",30

anybody_got_hi_score:	dc.b	0
text_half_speed:		dc.b	0
	even
