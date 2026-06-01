NULL_PAUSE	equ	0*4
START_PAUSE	equ	1*4
RETURN1_PAUSE	equ	2*4
RETURN2_PAUSE	equ	3*4

HANDLE_PAUSE:
	tst.b	GAME_OVER_FLAG
	beq.s	.alive
	rts
.alive:
	tst.b	PAUSE_ENABLED
	bne.s	.ok
	rts
.ok:
	move.w	pause_type,d0
	jmp	.pause_table(pc,d0.w)
.pause_table:
	bra.w	init_pause
	bra.w	do_pause
	bra.w	return1_pause

****************************************************************************************
init_pause:
	move.w	#JOY_START,d1
	and.w	EDGESTICK,d1
	bne.s	.paused_pressed
	rts

.paused_pressed:
	move.w	STIMER,TEMP9
	move.l	display_number_of_items,pause_items	;save object list pointers
	move.l	display_olist_pointer,pause_pointer
	clr.w	pause_button
	move.w	#START_PAUSE,pause_type
	move.l	#GAMELOOP,(sp)			; force the return address
	
	moveq	#$3f,d0
	jsr	HALTDSP
	jsr	DISABLE_
	jsr	ENABLE_F
	rts
****************************************************************************************

P_NOWT	equ	0
P_FIREA	equ	4
P_FIREB	equ	8
P_123	equ	12

do_pause:
	move.l	#GAMELOOP,(sp)			; force the return address
	move.w	#JOY_START,d1
	and.w	EDGESTICK,d1
	beq.s	.still_in_pause
	move.w	#RETURN1_PAUSE,pause_type
	rts

.still_in_pause:
	move.l	pause_items,display_number_of_items	;restore object list pointers
	move.l	pause_pointer,display_olist_pointer
	move.w	pause_button,d0
	jmp	.pause_type(pc,d0.w)

.pause_type:
	bra.w	pause_nothing
	bra.w	pause_fire_a
	bra.w	pause_fire_b
	bra.w	pause_no_show

pause_fire_a:
	bsr	display_game_paused
	bsr	get_button_status
	lea	mod_slider,a6
	move.l	2(a6),a5			;a5== address of the byte in memory of value
	jsr	move_slider_mod
	moveq	#0,d5
	jsr	display_slider
	rts

pause_fire_b:
	bsr	display_game_paused
	bsr	get_button_status
	lea	sfx_slider,a6
	move.l	2(a6),a5			;a5== address of the byte in memory of value
	jsr	move_slider_sfx
	bsr	beep_sound_fx
	moveq	#8,d5
	jsr	display_slider
	rts

pause_nothing:
	bsr	display_game_paused
	bsr	get_button_status
	rts

pause_no_show:
	if	SCREENSHOTS
	jmp	build_pause
	endif
	rts

****************************************************************************************

return1_pause:
	if	DEBUG
	move.l	#-1,BORD1
	endif
	move.l	#GAMELOOP,(sp)				;force the return address
	move.l	pause_items,display_number_of_items	;restore object list pointers
	move.l	pause_pointer,display_olist_pointer
	jsr	RESUMEDS
	jsr	DISABLE_
	jsr	ENABLE_F
	
;	jsr	write_hi_score_to_eprom			;decode eeprom
	
	move.w	TEMP9,STIMER
	clr.w	pause_type
	if	DEBUG
	move.l	#0,BORD1
	endif
	rts

****************************************************************************************

display_game_paused:
	move.w	#(320-156)/2,d0
	move.w	screen_height,d1					;set y = (height-16)/2
	sub.w	#18,d1
	asr.w	#1,d1
	move.l	LOAD_PAWSED_GRAPHICS_ADDR,a0
	moveq	#0,d4
	jmp	print_a_sprite_normal_display

****************************************************************************************

get_button_status:
	cmp.w	#P_123,pause_button
	bne.s	.ok
	rts

.ok:
	jsr	get_current_joy_pad_status
	cmp.w	#P_FIREA,pause_button
	beq.s	.no_a
	move.l	#1<<FIRE_A,d1
	and.l	d0,d1
	bne.s	.handle_volumes

.no_a:
	cmp.w	#P_FIREB,pause_button
	beq.s	.no_b
	move.l	#1<<FIRE_B,d1
	and.l	d0,d1
	bne.s	.handle_sfx

.no_b:
	cmp.w	#P_123,pause_button
	beq.s	.no_c
	move.l	#1<<KEY_1|1<<KEY_3,d1
	and.l	d1,d2
	cmp.l	d1,d2
	beq.s	.handle_123

.no_c:
	rts

.handle_123:
	move.w	#P_123,pause_button
	rts

.handle_volumes:
	jsr	RESUMEDS
	moveq	#$30,d0
	jsr	HALTDSP
	move.w	#P_FIREA,pause_button
	rts

.handle_sfx:
	jsr	RESUMEDS
	moveq	#$0f,d0
	jsr	HALTDSP
	move.w	#P_FIREB,pause_button
	rts

****************************************************************************************

;depends on the player.
;return in d0 just press buttons whilst
;	   d2 is what is currently pressed

;if in 2 player with 2 pads then read pad 2 else read pad 1

get_current_joy_pad_status:
	cmp.w	#1,PLAYERS
	bne.s	.player_1
	cmp.w	#1,PLAYER
	beq.s	.player_2

.player_1:
	move.l	joyedge1,d0
	move.l	joycur1,d2
	rts

.player_2:
	move.l	joyedge2,d0
	move.l	joycur2,d2
	rts

****************************************************************************************

move_slider_mod:
	bsr	get_current_joy_pad_status
	move.l	#1<<RIGHT_B|1<<UP_B,d2
	and.l	d0,d2
	bne.s	.move_slider_right
	move.l	#1<<LEFT_B|1<<DOWN_B,d2
	and.l	d0,d2
	bne.s	.move_slider_left
	rts

.move_slider_right:				;increase value
	move.b	(a5),d0
	bpl.s	.music_was_not_off
	beq.s	.music_was_not_off
	eor.b	#1,mustype						;change the state of the music
	sf	save_mod_level
	sf	(a5)				;reset the volume back to 0 then 1st one is for sligh volume
	jsr	START_MO

.music_was_not_off:
	cmp.b	#MAX_SLIDER_VALUE,(a5)
	beq.s	.at_max_already
	addq.b	#1,(a5)

.at_max_already:
	bra.s	.set_new_volume_level

.move_slider_left:				;decrease value
	moveq	#-1,d7
	cmp.b	(a5),d7
	beq.s	.at_minimum
	subq.b	#1,(a5)
	cmp.b	(a5),d7
	bne.s	.music_not_turned_off

	eor.b	#1,mustype						;change the state of the music
	move.b	#1,save_mod_level
	jsr	STOP_MOD
	
.music_not_turned_off:
.at_minimum:
.set_new_volume_level:
	tst.b	(a5)				;if -1 then music and no need to set volume
	bmi.s	.no_change
	
	moveq	#0,d1
	move.b	1(a6),d1			;set value mod/sfx
	
	moveq	#0,d0				;get the volume for that specific value
	move.b	(a5),d0
	
	lea	volume_table,a4
	move.b	(a4,d0.w),d0
	
	jsr	SET_VOLU

.no_change:
	rts

****************************************************************************************

move_slider_sfx:
	bsr	get_current_joy_pad_status
	move.l	#1<<RIGHT_B|1<<UP_B,d2
	and.l	d0,d2
	bne.s	.move_slider_right
	move.l	#1<<LEFT_B|1<<DOWN_B,d2
	and.l	d0,d2
	bne.s	.move_slider_left
	rts

.move_slider_right:				;increase value
	cmp.b	#MAX_SLIDER_VALUE,(a5)
	beq.s	.at_max_already
	addq.b	#1,(a5)

.at_max_already:
	bra.s	.set_new_volume_level

.move_slider_left:				;decrease value
	tst.b	(a5)
	beq.s	.at_minimum
	subq.b	#1,(a5)

.at_minimum:
.set_new_volume_level:
	moveq	#0,d1
	move.b	1(a6),d1			;set value mod/sfx
	
	moveq	#0,d0				;get the volume for that specific value
	move.b	(a5),d0
	
	lea	volume_table,a4
	move.b	(a4,d0.w),d0
	
	jsr	SET_VOLU
.no_change:
	rts

****************************************************************************************

beep_sound_fx:
	moveq	#63,d0
	and.w	STIMER,d0
	bne.s	.no_play
	
	cmp.w	#P_FIREB,pause_button
	bne.s	.no_play
	
	moveq	#SCREENHIT,d0
	jsr	sfxplay

.no_play:
	rts

****************************************************************************************

;	this routine will display a box in the centre of the screen
;	with a scaled rotating ball as an indicator of the volume.

display_slider:
	move.l	load_overlay_graphics,a0

	move.w	#160-16,d0
	move.w	screen_height,d1			; screen_height/4
	asr.w	#2,d1
	sub.w	#16,d1
	
	moveq	#0,d4
	move.b	(a6),d4
	
	tst.b	(a5)
	bmi	.no_show				; if 0 or -1 then no show
	beq	.no_show

	move.w	d5,-(sp)
	jsr	print_a_sprite_normal_display
	move.w	(sp)+,d5

	move.w	#160+80,d0					; screen_width/2
	move.w	screen_height,d1			; screen_height/4
	asr.w	#2,d1
	
	moveq	#0,d2
	move.b	(a5),d2

	move.w	d2,d3
	mulu	#20,d3
	asr.w	#4,d3
	sub.w	d3,d0					; x=x-offset
	
	move.w	d2,d3
	mulu	#16,d3
	asr.w	#4,d3
	sub.w	d3,d1					; y=y-offset
	
	lsl.w	#2,d2					;*4 == (32/8)
	
	move.w	STIMER,d4
	asr.w	#2,d4
	and.w	#7,d4
	add.w	#BALLS_OF_WOOL,d4
	add.w	d5,d4
	move.l	load_overlay_graphics,a0
	
	move.w	d5,-(sp)
	jsr	print_a_sprite_scaled_display
	move.w	(sp)+,d5
	
	move.w	#160-80,d0				; screen_width/2
	move.w	screen_height,d1			; screen_height/4
	asr.w	#2,d1
	
	moveq	#0,d2
	move.b	(a5),d2

	move.w	d2,d3
	mulu	#20,d3
	asr.w	#4,d3
	sub.w	d3,d0					; x=x-offset
	
	move.w	d2,d3
	mulu	#16,d3
	asr.w	#4,d3
	sub.w	d3,d1					; y=y-offset
	
	lsl.w	#2,d2					;*4 == (32/8)
	
	move.w	STIMER,d4
	asr.w	#2,d4
	and.w	#7,d4
	add.w	#BALLS_OF_WOOL,d4
	add.w	d5,d4
	move.l	load_overlay_graphics,a0
	
	jmp	print_a_sprite_scaled_display

.no_show:			;if no volume or OFF then display the box with shading.
	addq	#2,d4				; point to the darker images
	jmp	print_a_sprite_normal_display
	
;expects	d0/d1	== x,y
;		d2/d3	== sx,sy
;		d4	== sprite number
;		a0	== sprite bank addr
;no clipping done on the sprite..

****************************************************************************************

PAUSE_ENABLED:	dc.b	0,0
mod_slider:	dc.b	MOD_ICON,0
			dc.l	vol_mod
		
sfx_slider:	dc.b	SFX_ICON,1
			dc.l	vol_sfx

pause_button:	dc.w	0
pause_items:	dc.l	0
pause_pointer:	dc.l	0
pause_type:		dc.w	0
