.macro	_rsset
	rs_counter	set	\1
	.endm

.macro	_rsreset
	_rsset 0
	.endm
	
.macro	_rsb	label,volume
	\label		set	rs_counter
	rs_counter	set	rs_counter+((\volume)*1)
	.endm

.macro	_rsw	label,volume
	\label		set	rs_counter
	rs_counter	set	rs_counter+((\volume)*2)
	.endm
	
.macro	_rsl	label,volume
	\label		set	rs_counter
	rs_counter	set	rs_counter+((\volume)*4)
	.endm

	_rsreset

	_rsl	ivectors,0
	_rsl	video_service,1
	_rsl	gpu_service,1
	_rsl	object_service,1
	_rsl	timer_service,1
	_rsl	jerry_service,1
	_rsw	screen_height_long,1
	_rsw	scree_height_fred,1
	_rsl	color_ptr,1

	_rsl	clearr,16
	_rsl	memory_used,1
	_rsl	min_memory,1

	_rsl	current_list_pointer,2
	_rsl	backup_list_pointer,2
	_rsl	object_list_pointer,2
	_rsw	bytes_in_object_list,2
	_rsb	made_object_list,1
	_rsb	vbl_counter,1

	_rsset	((rs_counter+2)&(~1))

	_rsb	star_table,12*NUM_STARS
	_rsl	star_ball_pointer,1
	_rsl	credit_screen_pointer,0
	_rsl	hi_screen_pointer,0
	_rsl	star_screen_pointers,2
	_rsl	star_restore_pointer,2
	_rsb	letter_y_table,16*7

	_rsb	en_xdir,1
	_rsb	en_ydir,1
	_rsw	en_x,1
	_rsw	en_y,1
	_rsb	en_xdir2,1
	_rsb	en_ydir2,1
	_rsw	en_x2,1
	_rsw	en_y2,1
	_rsl	sine_pointer,1
	_rsl	half_circle_pointer,1

	_rsl	fred_mod_load_addr,1
	_rsl	intro_fst_pointer,1
	_rsl	intro_hed_pointer,1
	_rsl	font1_fst_pointer,1
	_rsl	font1_hed_pointer,1

	_rsl	intro_gfx_pointer,1
	_rsl	font1_gfx_pointer,1
	_rsl	title_gfx_pointer,1
	_rsl	title_pal_pointer,1
	_rsl	title_rgb_pointer,1
	_rsl	waterfon_pal_pointer,1
	_rsl	logo_hed_pointer,1
	_rsl	logo_gfx_pointer,1
	_rsl	atari_pal_pointer,1
	_rsl	idi_pal_pointer,1

	_rsl	rmw_data,1
	_rsl	rmw_data2,1
	_rsl	mag_pointer,1
	_rsl	temp_pal_pointer,1
	_rsw	border_setting,1
	_rsl	background_setting,1
	_rsw	ex_scale,1
	_rsw	bubsy_action,0
	_rsw	exclamation_action,1
	_rsw	bubsy_yoff,1

	_rsl	original_screen_pointer,1
	_rsl	screen_pointers,NUM_SCREENS+1
	_rsl	text_buffer_pointer,0
	_rsl	circle_screen_pointers,2

	_rsw	hi_out_delay,1
	_rsw	fuck_text_len,0
	_rsw	start_text_len,0
	_rsw	circle_prev,2
	_rsw	circle_radius,1
	_rsw	circle_angle,1
	_rsw	intro_counter,1
	_rsw	random_number,1

	_rsw	cursor_pos,1
	_rsl	score_achieved,1
	_rsw	score_position,1

	_rsl	bubsy_pal_pointer,1
	_rsl	star_pal_pointer,1
	_rsl	credit_text_pointer,1
	_rsw	credit_text_offset,1
	_rsw	credit_screen_offset,1
	_rsw	hi_off,1
	_rsw	intro_counter2,1
	_rsw	current_star_angle,1
	_rsw	star_angle_add,1
	_rsw	star_angle_dec,1
	_rsl	star_angle_pointer,1

	_rsw	bubsy_log,1
	_rsw	fractured,1
	_rsl	fred_hi_mod_load_addr,1
	
	_rsw	star_off_table,1
	_rsb	hi_dir,1
	_rsb	credit_text_done,1
	_rsb	reguler_pal,1
	_rsb	title_faded,1
	_rsb	exit_ex,1
	_rsb	hi_mod_started,1
	_rsb	star_counter,1
	_rsb	no_exit,1
	_rsb	title_pic_being_displayed,1
	_rsb	set_pals,1
	_rsb	dont_load_mod,1
	_rsw	varend,1