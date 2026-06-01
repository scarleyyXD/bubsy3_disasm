	rsreset
	
ivectors 	rs.l	0
video_service	rs.l	1
gpu_service	rs.l	1
object_service	rs.l	1
timer_service	rs.l	1
jerry_service	rs.l	1
screen_height_long	rs.w	1
scree_height_fred	rs.w	1
color_ptr	rs.l	1

clearr		rs.l	16
memory_used	rs.l	1
min_memory	rs.l	1

current_list_pointer	rs.l	2
backup_list_pointer	rs.l	2
object_list_pointer	rs.l	2
bytes_in_object_list	rs.w	2
made_object_list	rs.b	1
vbl_counter	rs.b	1

	RSSET	((__RS+2)&(~1))

star_table		rs.b	12*NUM_STARS
star_ball_pointer	rs.l	1
credit_screen_pointer	rs.l	0
hi_screen_pointer	rs.l	0
star_screen_pointers	rs.l	2
star_restore_pointer	rs.l	2
letter_y_table		rs.b	16*7

en_xdir	rs.b	1
en_ydir	rs.b	1
en_x	rs.w	1
en_y	rs.w	1
en_xdir2	rs.b	1
en_ydir2	rs.b	1
en_x2	rs.w	1
en_y2	rs.w	1
sine_pointer		rs.l	1
half_circle_pointer	rs.l	1

fred_mod_load_addr	rs.l	1
intro_fst_pointer	rs.l	1
intro_hed_pointer	rs.l	1
font1_fst_pointer	rs.l	1
font1_hed_pointer	rs.l	1

intro_gfx_pointer	rs.l	1
font1_gfx_pointer	rs.l	1
title_gfx_pointer	rs.l	1
title_pal_pointer	rs.l	1
title_rgb_pointer	rs.l	1
waterfon_pal_pointer	rs.l	1
logo_hed_pointer	rs.l	1
logo_gfx_pointer	rs.l	1
atari_pal_pointer	rs.l	1
idi_pal_pointer	rs.l	1

rmw_data	rs.l	1
rmw_data2	rs.l	1
mag_pointer	rs.l	1
temp_pal_pointer	rs.l	1
border_setting	rs.w	1
background_setting	rs.l	1
ex_scale	rs.w	1
bubsy_action	rs.w	0
exclamation_action	rs.w	1
bubsy_yoff	rs.w	1

original_screen_pointer	rs.l	1
screen_pointers	rs.l	NUM_SCREENS+1
text_buffer_pointer	rs.l	0
circle_screen_pointers	rs.l	2

hi_out_delay	rs.w	1
fuck_text_len	rs.w	0
start_text_len	rs.w	0
circle_prev	rs.w	2
circle_radius	rs.w	1
circle_angle	rs.w	1
intro_counter	rs.w	1
random_number	rs.w	1

cursor_pos	rs.w	1
score_achieved	rs.l	1
score_position	rs.w	1

bubsy_pal_pointer	rs.l	1
star_pal_pointer	rs.l	1
credit_text_pointer	rs.l	1
credit_text_offset	rs.w	1
credit_screen_offset		rs.w	1
hi_off	rs.w	1
intro_counter2	rs.w	1
current_star_angle		rs.w	1
star_angle_add	rs.w	1
star_angle_dec	rs.w	1
star_angle_pointer	rs.l	1
	
bubsy_log	rs.w	1
fractured	rs.w	1
fred_hi_mod_load_addr	rs.l	1


star_off_table	rs.w	1
hi_dir	rs.b	1
credit_text_done	rs.b	1
reguler_pal	rs.b	1
title_faded	rs.b	1
exit_ex	rs.b	1
hi_mod_started  	rs.b	1               
star_counter	rs.b	1
no_exit	rs.b	1
title_pic_being_displayed rs.b	1
set_pals	rs.b	1
dont_load_mod	rs.b	1
varend	rs.w	1
