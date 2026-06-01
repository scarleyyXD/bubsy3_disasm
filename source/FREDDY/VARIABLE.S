ivectors				equ 0
video_service			equ 0
gpu_service				equ 4
object_service			equ 8
timer_service			equ 12
jerry_service			equ 16
screen_height_long		equ 20
scree_height_fred		equ 22
color_ptr				equ 24

clearr					equ 28
memory_used				equ 92
min_memory				equ 96

current_list_pointer	equ 100
backup_list_pointer		equ 108
object_list_pointer		equ 116
bytes_in_object_list	equ 124
made_object_list		equ 128
vbl_counter				equ 129

star_off				equ (12*NUM_STARS)
screen_off				equ (4*NUM_SCREENS)
star_screen				equ	(star_off+screen_off)

star_table				equ 132
star_ball_pointer		equ 132+star_off
credit_screen_pointer	equ 136+star_off
hi_screen_pointer		equ 136+star_off
star_screen_pointers	equ 136+star_off
star_restore_pointer	equ 144+star_off
letter_y_table			equ 152+star_off

en_xdir					equ 264+star_off
en_ydir					equ 265+star_off
en_x					equ 266+star_off
en_y					equ 268+star_off
en_xdir2				equ 270+star_off
en_ydir2				equ 271+star_off
en_x2					equ 272+star_off
en_y2					equ 274+star_off
sine_pointer			equ 276+star_off
half_circle_pointer		equ 280+star_off

fred_mod_load_addr		equ 284+star_off
intro_fst_pointer		equ 288+star_off
intro_hed_pointer		equ 292+star_off
font1_fst_pointer		equ 296+star_off
font1_hed_pointer		equ 300+star_off

intro_gfx_pointer		equ 304+star_off
font1_gfx_pointer		equ 308+star_off
title_gfx_pointer		equ 312+star_off
title_pal_pointer		equ 316+star_off
title_rgb_pointer		equ 320+star_off
waterfon_pal_pointer	equ 324+star_off
logo_hed_pointer		equ 328+star_off
logo_gfx_pointer		equ 332+star_off
atari_pal_pointer		equ 336+star_off
idi_pal_pointer			equ 340+star_off

rmw_data				equ 344+star_off
rmw_data2				equ 348+star_off
mag_pointer				equ 352+star_off
temp_pal_pointer		equ 356+star_off
border_setting			equ 360+star_off
background_setting		equ 362+star_off
ex_scale				equ 366+star_off
bubsy_action			equ 368+star_off
exclamation_action		equ 368+star_off
bubsy_yoff				equ 370+star_off

original_screen_pointer	equ 372+star_off
screen_pointers			equ 376+star_off
text_buffer_pointer		equ 380+star_screen
circle_screen_pointers	equ 380+star_screen
hi_out_delay			equ 388+star_screen

fuck_text_len			equ 390+star_screen
start_text_len			equ 390+star_screen
circle_prev				equ 390+star_screen
circle_radius			equ 394+star_screen
circle_angle			equ 396+star_screen
intro_counter			equ 398+star_screen
random_number			equ 400+star_screen

cursor_pos				equ 402+star_screen
score_achieved			equ 404+star_screen
score_position			equ 408+star_screen

bubsy_pal_pointer		equ 410+star_screen
star_pal_pointer		equ 414+star_screen
credit_text_pointer		equ 418+star_screen
credit_text_offset		equ 422+star_screen
credit_screen_offset	equ 424+star_screen
hi_off					equ 426+star_screen
intro_counter2			equ 428+star_screen
current_star_angle		equ 430+star_screen
star_angle_add			equ 432+star_screen
star_angle_dec			equ 434+star_screen
star_angle_pointer		equ 436+star_screen

bubsy_log				equ 440+star_screen
fractured				equ 442+star_screen
fred_hi_mod_load_addr	equ 444+star_screen

star_off_table			equ 448+star_screen
hi_dir					equ 450+star_screen
credit_text_done		equ 451+star_screen
reguler_pal				equ 452+star_screen
title_faded				equ 453+star_screen
exit_ex					equ 454+star_screen
hi_mod_started			equ 455+star_screen
star_counter			equ 456+star_screen
no_exit					equ 457+star_screen
title_pic_being_displayed	equ 458+star_screen
set_pals				equ 459+star_screen
dont_load_mod			equ 460+star_screen
varend					equ 461+star_screen
