main_startup:
	clr.w   TITLESEQNUM					;init the title sequence
	clr.w   TITLESCRPTR

BIGLOOP:
	clr.w	LAST_LEVEL_PLAYED
	clr.w	LEVEL

	move.w	#$10,TXTSPACING

	clr.w	reset_eeprom_timer
	sf	VBLANKFLAG

	clr.w	OTHERPLAYER+14

	sf	CurPal

	MOVE.W	#JOY_X+JOY_Y,GLIDEBUTTON
	MOVE.W	#JOY_A+JOY_B,JUMPBUTTON				;init the jump and glide buttons

	clr.w	GFRAMES						;init game speed

	clr.w	WINDY				;position background (indirectly)
	clr.w	WINDX

	clr.b	FADEVAL				;init fader
	move.b	#16,FADEDIR

	clr.w	VRAMCURSOR			;set initial debug string ptr

	clr.w	TITLESCRPTR
	sf	TITLESCRCTR
	clr.w	TEMP9
	clr.w	TEMP8
	clr.w	TEMP7
	clr.w	TEMP6
	sf	TEMP5

	move.w	LAST_LEVEL_PLAYED,LEVEL
	move.w	LEVEL,OTHERPLAYER+14

	lea	OVERLAY_GRAPHICS,a0
	move.l	load_overlay_graphics,a1
	jsr	file_load
	jsr	relocate_sprites

	sf	 MenuFlag				;Al change for speed
	
	MOVE.L	#my_stack,A7

.do_options:
	st	disable_reset				;allow the machine to be reset
	bsr	TITLE					;do the title sequence
	sf	disable_reset				;allow the machine to be reset

	bsr	NEW_OL
	bsr	NEW_OL
	jsr	wait_vbl

	lea	OVERLAY_GRAPHICS,a0
	move.l	load_overlay_graphics,a1
	jsr	file_load
	jsr	relocate_sprites

	lea	new_palette+2,a0
	lea	view_pal,a1
	moveq	#256/2-1,d0
	
.lp1a:
	move.l	(a0)+,d1
	and.l	#$fffefffe,d1
	move.l	d1,(a1)+
	dbf	d0,.lp1a

	st	NEW_PALETTE
	
	bsr	LVLINIT					;initalise the level

	move.w  NUMVBLS,OLDVBLS ;WWW seems necessary for now
	clr.w	STIMER
	bra	GAMELOOP