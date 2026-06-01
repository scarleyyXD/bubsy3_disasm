BANNER_XOFF	equ	37
BANNER_YOFF	equ	40-5-5

GOVER2		equ	32
G_FINAL_X	equ	-(50+120+50)

GAMEOVERAI
	st	GAME_OVER_FLAG
	st	FADEVAL						;andyseed
	st.b	NoWater
	or.b	#NOPAUSEFLAG,GAMEFLAG1						;defeat pause

	lea	GAMEOVERTXT,a0
	move.l	LOAD_LEVEL_SPRITES_HERE,a1
	jsr	load_file_no_wait
	move.l	#GAMEOVERAI1,OBJAI(a5)
	rts
	
GAMEOVERAI1
	or.b	#NOPAUSEFLAG,GAMEFLAG1						;defeat pause
	jsr	loaded_in_no_wait
	bne.s	.yes_loaded
	rts
.yes_loaded
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	relocate_sprites
	jsr	STOP_MOD
	moveq	#GAMEOVERSPEECH,d0
	jsr	sfxplay
	sf	musloaded
	lea	GAMEOVERMUSIC,a0
	move.l	a0,last_music_loaded
	lea	mod_load_addr,a1	;addr to load
	jsr	load_file_no_wait
	move.l	#GAMEOVERAI2,OBJAI(a5)
	rts

GAMEOVERAI2
	or.b	#NOPAUSEFLAG,GAMEFLAG1						;defeat pause
	jsr	loaded_in_no_wait
	bne.s	.yes_loaded
	rts
.yes_loaded
	lea	mod_load_addr,a0	;addr to load
	jsr	PT_MOD_INIT		;setup song and player
	
	tst.b	save_mod_level
	beq.s	.no_start
	bpl.s	.no_start
	
	jsr	START_MOD
	jsr	FADEUP
.no_start

	
	move.w	#VIEW_RESOLUTION&$feff,VMODE
	
	move.l	#GAMEOVERAI3,OBJAI(a5)
	move.w	#320,OBJX(a5)
	move.w	screen_height,d0
	asr.w	#1,d0
	sub.w	#GOVER2,d0
	move.w	d0,OBJY(a5)
	clr.l	OBJAUX0(a5)
	rts
	
GAMEOVERAI3
	or.b	#NOPAUSEFLAG,GAMEFLAG1						;defeat pause
	subq.b	#1,OBJAUX7(a5)
	bpl.s	.no_movement
	move.b	#5,OBJAUX7(a5)
	subq.w	#1,OBJAUX0(a5)
	bpl.s	.no_wrap0
	move.w	#3,OBJAUX0(a5)
.no_wrap0
	subq.w	#1,OBJAUX2(a5)
	bpl.s	.no_wrap1
	move.w	#5,OBJAUX2(a5)
.no_wrap1
.no_movement	
	subq.w	#1,OBJX(a5)
	move.w	OBJX(a5),d0
	move.w	OBJY(a5),d1
	
	move.w	OBJAUX2(a5),d2
	move.w	d2,d4
	lsl.w	#2,d2
	add.w	#BANNER_XOFF,d0
	add.w	#BANNER_YOFF,d1
	neg.w	d4
	addq	#5,d4
	move.l	LOAD_LEVEL_SPRITES_HERE,a0
	jsr	print_a_sprite_normal



	move.w	OBJX(a5),d0
	move.w	OBJY(a5),d1
	
	moveq	#3,d2
	sub.w	OBJAUX0(a5),d2
	move.w	d2,d4
	addq	#6,d4
	lsl.w	#2,d2
	lea	.vulture(pc,d2.w),a0
	add.w	(a0)+,d0
	add.w	(a0)+,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0
	jsr	print_a_sprite_normal


	cmp.w	#G_FINAL_X,OBJX(a5)
	beq.s	.exit

	MOVE.w	EDGESTICK,D0
	AND.w	#JOY_START|JOY_A|JOY_B|JOY_C,D0
	bne.s	.exit
	rts
.exit	jsr	NEW_OL
	jsr	NEW_OL
	move.l	#.wait,OBJAI(a5)
	rts
.wait	or.b	#NOPAUSEFLAG,GAMEFLAG1						;defeat pause
	move.w	#VIEW_RESOLUTION,VMODE
	
	jmp	PLAYERTURNOVER

.vulture
	dc.w	0,41-17
	dc.w	4,17-17
	dc.w	1,19-17
	dc.w	0,35-17+1

