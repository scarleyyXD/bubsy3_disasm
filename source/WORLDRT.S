;;		check all file loading - into correct place in memory

		.text

		include	"jaguar.inc"		;ok

		include	"specific.jag/jaguar.s"				;ok
		include	"specific.jag/vidinit.s"			;ok
		
		include	"bubboot.s"				;ok

		include	"sega.asm"				;needs looking at	

		even
	
		include	"sega.inc"				;ok
		include "o_frames.s"			;update as memory is required
		include	"b_frames.s"			;ok

OBJLEN2			equ	OBJLEN*2
OBJLEN4			equ	OBJLEN*4
OBJLEN7			equ	OBJLEN*7

;;;		music related stuff
TITLESBLOCK		equ	0				;addr where music driver is loaded into - I don't load - via NEW_DOWNLOAD_APU

FADER:
INITAPU:
SegaFader:
		rts

		even
		include	"jag_bub.inc"				;all the stuff relating to the jaguar
		if	SCREENSHOTS
		include	"specific.jag/freeze.s"
		endif
		include	"bubctrl.s"					;ok
		include	"gameloop.s"				;ok
		include	"snesctrl.s"				;ok
		
		include	"lvlinit.s"					;ok - check allocating memory correctly
		include	"maphndlr.s"				;rewrite for bitmap screen and the attributes..
		include	"setoverl.s"				;ok - I think
		include	"title1.s"					;ok - I think - load routines look at and screen handling
		include	"w1lvlcod.s" 				;ok - I think - keep an an eye on as it had some sega specific stuff in it
		
		include	"stuff.map/init2.s"			;init2.s
		
		include	"bubint.s"					;ok - but examine parallax stuff
		include	"lvltabs.s"					;ok
		include	"objtabs.s"					;ok
		
new_palette:	incbin	"specific.jag/bubtask.cpl"
		include	"stuff.map/scroll2a.s"	;new2.s	
		
		include	"draw_oam.s"				;seems ok
		include	"dma_vram.s"				;seems ok
		include	"setupbub.s"				;seems ok
		include	"bubdata.s"					;must follow on
		
		if	DETECTMODE
		include	"specific.jag/detect.s"
		endif
		include	"loadcode.s"					;ok
		include	"scrhndlr.s"					;ok
		include	"getsin.s"					;ok
		include	"objhndlr.s"					;ok
		include	"bubbop.s"					;ok

		include	"worldai.s"					;ok - I think
		include	"enemymap.s"

		include	"freddy/main.s"

		.data
		
		include	"bubpal0.s"
		include	"level01.s"
		
screen_height:				dc.w	disp_height						;if pal then 280
phrase_align:
LOAD_BUBSY_ADDR:			dc.l	view_bubsy
LOAD_MAP_CHARACTERS_HERE:	dc.l	view_foreground_characters
load_overlay_graphics:		dc.l	view_overlay_graphics
map_addr:					dc.l	view_me_land_1
map_addr1:					dc.l	view_me_land_2
load_title_pic_here:		dc.l	title_stuff_load_in_andy

bank_of_sprites:
LOAD_GLOBAL_GRAPHICS_ADDR:	dc.l	view_global_graphics
LOAD_LEVEL_SPRITES_HERE:	dc.l	view_level_sprites
LOAD_RESET_ADDR:			dc.l	view_level_sprites
LOAD_BUBBLE_GRAPHICS_ADDR:	dc.l	view_bubble_sprites
LOAD_ARROW_GRAPHICS_ADDR:	dc.l	view_arrow_sprites
LOAD_PAWSED_GRAPHICS_ADDR:	dc.l	view_paused_sprites
							dc.l	0

		include	"bubram.s"					;of course this will be altered
		even

clock:				ds.l	1
view_pal:			ds.w	256
					ds.b	1024*10
my_stack:
Stack:				ds.l	1

FrameRate:   		ds.w	1
VBlankDone:  		ds.w    1                  				 ;vblank done flag 
points_ctrl:		ds.b	256

mus_startup:		ds.b	1
jump_through_allowed:	ds.b	1
jump_to_title:		ds.b	1
		even
			
CLEAR_BBS_END:

mod_load_addr:		ds.b	117000
file_area			equ	mod_load_addr+((TITLE_MOD_SIZE+8)&$fffffff8)

view_foreground_characters:	ds.b	193792
view_level_sprites:			ds.b	297000
LOAD_BACKGROUND_MAP_HERE:	ds.b	400*400

					ds.b	OBJ_SIZE
olist_data:			ds.b	OBJ_SIZE*MAX_SPRITES
					ds.b	OBJ_SIZE
olist_master:		ds.b	OBJ_SIZE*MAX_SPRITES
					ds.b	OBJ_SIZE
	if	DBUFF
olist_master1:		ds.b	OBJ_SIZE*MAX_SPRITES
					ds.b	OBJ_SIZE
	endif

		even
MAPWIDP:			ds.w	1
MAPHTP:				ds.w	1
MAPWID:				ds.w	1								;area where the maps are loaded into
MAPHT:				ds.w	1
MAPBASE:			ds.w	700*100
land1:				ds.b	MAP_DEF
land2:				ds.b	MAP_DEF

	if	DETECTMODE-SCREENSHOTS
dect_scr1:		ds.b	40*240
dect_scr2:		ds.b	40*240
dect_scr3:		ds.b	40*240
	endif

DYTAB:			ds.b	1024*16
DOUBLETAKE:		ds.l	MAX_NUMBER_OF_MAP_COMBINATIONS
VXTAB:			ds.w	1024
ATTRTABLE:		ds.w	1024

view_bubble_sprites:	ds.b	13000
view_arrow_sprites:		ds.b	17000
view_paused_sprites:	ds.b	5648
view_overlay_graphics:	ds.b	80864
view_bubsy:				ds.b	312400
view_global_graphics:	ds.b	116728

title_stuff_load_in_andy	equ	*

view_me_land_1:			ds.b	PLAY_SCREEN
view_me_land_2:			ds.b	PLAY_SCREEN+(700*16*2)

level_speech			equ	$200000-40000

		.end