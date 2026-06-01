;*********************************
;all sprites must be facing right
;*********************************

;todo
;touches

;*******************************************
;
; options screen - done most - fix exit button and credit screen
;
;*******************************************


	include	"bubequ.s"

;** The  ????  control file....

ON	equ	1
OFF	equ	0

ONLY_OPTIONS	equ	OFF			;latest version

RECORDING	equ	OFF			;whether or not to record demos.

DISABLEDEMO	equ	ON

B_LIVES		equ	$09			; number of lives BUBSY initally has
LEVELTIME	equ	$0959			; time for the level

DBUFF		equ	ON
INFTIME		equ	OFF			; if set to OFF then decrement time otherwise infinite time
EDITME		equ	OFF			; always set to off for the moment !!!

DETECTMODE	equ	OFF			; allows overlaycode for checking collision detection
DEBUG		equ	OFF			; colour bars in the border
CONSULT		equ	OFF			; replaces score with position



BLACK_BOX	equ	ON			; box game recorder
SCRIPTMODE	equ	ON
VERSION_TEXT	equ	OFF			; should version number be displayed on 1st level
DAVE7		equ	OFF			; press 4,5,6 together to get IV=$?fff, lives=80
SCREENSHOTS	equ	OFF			; ability to take screen shots for MARVS convertor
SHOWDEMO	equ	OFF			; final version wait for no keypress to run demo


	.text


;---------------

GO:	
	IF	DEBUG
	bra.s	bubsy_start
	dc.w	0
	dc.b	"SEED"
bad_routine:
	dc.l	0
	dc.b	"SEED"
	ENDIF
bubsy_start:
	move.l	#$00070007,d0
	move.l	d0,G_END
	move.l	d0,D_END
	moveq	#8,d0
	move.l	d0,D_CTRL		;make sure DSP is stopped
	move.l	d0,G_CTRL		;make sure GPU is stopped

	lea	BASE,a5

	Jsr	INIT_SOUND		;start the music driver




	
	lea	CLEAR_BBS_START,a0	;clear all of my bss section - only when the program 1st runs.
	lea	CLEAR_BBS_END,a1
.lp:	clr.w	(a0)+
	cmp.l	a0,a1
	bne.s	.lp

	move.w	#60,FrameRate

	moveq	#%10000,d0
	and.w	PAL_NTSC,d0
	bne	.its_ntsc
	include	"specific.jag\\convertp.s"	;convert to PAL
.its_ntsc:
	move.w	#5,sound_me

rom_file_table	equ	$802a00
ROMBASE		equ	rom_file_table
DEMO_START	equ	$900000

restart_program:
	st	save_mod_level
	sf 	mus
	st	mus_startup
	st	musloaded
	sf	jump_to_title
	sf	signal_game_complete

	
restart_program1:

	sf	writing_eeprom
	jsr	DISABLE_FX
	jsr	ENABLE_FX
	jsr	RESUMEDSP

	jsr	read_hi_score_from_eprom		;decode eeprom
	
	lea	my_stack,sp
	jmp	boot_up_here
andy_start:
	lea.l	my_stack,a7		;reset stack
	move.l	#reset_vbl,LEVEL2.w

	st	jump_to_title
	lea	SFX_NAME,a0
	jsr	locate_rom_file
	move.l	a0,sfxadd
	andi.b	#~DEMOMODE,EDITFLAGS								;init to demo off
	sf	EDITFLAGS
	sf	EDITFLAGS1
	sf	FADEVAL
	
	jsr	set_start_for_ol

	move.l	#GPUPP_S,a0
	move.l	#GPUPP_E,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	#$b904,$44(a0)		;trevs patch
	jsr	SETUPGPU
	
	clr.l	last_music_loaded
	move.w	#0,PLAYER									;set players to 1 and player 1 to play
	move.w	#0,PLAYERS
	clr.w	EDGESTICK1
	clr.w	GFRAMES										;fix to 60/50 frames per sec
	clr.l	YARNADDRESS
	clr.w	PLAYER
	st	disable_reset		;cannot reset the machine except in the game
	clr.w	pause_type
	sf	shake_me
	move.l	#a_vbl,vbl_routine
	jsr	Setup_Initial_Branch

	IF	DBUFF
	jsr	set_start_for_ol
	endif
	jsr	NEW_OL			;no list
	jsr	NEW_OL			;no list
	sf	NMIVECSEL
	
	move.l	#VBlank,vbl_routine

	include	"specific.jag\\set_up.s"	;ok
	
	include	"worldrt.s"		;initialise code first

