RMW_OFFSET	equ	2*$f*16+2
RR1	equ	$007f
RR2	equ	$0020
RR3	equ	$00e0

MAX_DEMO	equ	1

LVLINIT:
	jsr	DISABLE_
	jsr	ENABLE_F
	
	CLR.L	SCORE								;set score to 0
	CLR.L	DSCORE

	sf.b	NoWater
	move.b	#4,NMIVECSEL

	clr.w	NUMVBLS							;clear numvbls

	move.W	OTHERPLAYER+14,d0
	move.w	d0,-(a7)

	move.w	#PLAYERLEN-1,d6
	lea	OTHERPLAYER,a0
	
.COP:
	sf	(a0)+
	dbf.w	d6,.COP

	move.w	(a7)+,d0							;pop the level
	move.w	d0,OTHERPLAYER+14

	move.w	#$00ff,CURRENTPLAYER						;set continues + lives for both players
	move.w	#$00ff,OTHERPLAYER

	lea	BUBBLENAME,a0
	move.l	LOAD_BUBBLE_GRAPHICS_ADDR,a1
	jsr	file_load
	move.l	#$f0,d7								; add to base colour
	jsr	make_rmw
	jsr	relocate_sprites

	lea	ARROWNAME,a0
	move.l	LOAD_ARROW_GRAPHICS_ADDR,a1
	jsr	file_load
	jsr	relocate_sprites

	lea	PAWSEDNAME,a0
	move.l	LOAD_PAWSED_GRAPHICS_ADDR,a1
	jsr	file_load
	jsr	relocate_sprites

	lea	BUBSY_GRAPHICS,a0
	MOVE.L	LOAD_BUBSY_ADDR,a1
	jsr	file_load
	jsr	relocate_sprites
	
	sf	SWITCHES							;turn off all the switches in game
	sf	SWAP_SWITCH							;turn off all the switches and for the other player

;;;ASBx: ;************************************************************************
;;;ASBx: ;*									 *
;;;ASBx: ;* CONTINUE LOOP							 *
;;;ASBx: ;*									 *
;;;ASBx: ;************************************************************************

CONTINUEINIT:
;	CLR.L	SCORE								;set score to 0
;	CLR.L	DSCORE

	MOVE.B	#B_LIVES-1,LIVES						;set number of bubsy's

	moveq	#0,d6
	MOVE.w	d6,YARNS							;set yarns to 0
	MOVE.w	d6,YARNPALETTE							; 0 FOR SEGA

	move.b	#SHOWLVLTXT,PLAYERFLAGS						;flag show title & enable bonus

	move.w	#OBJENFLAGSLEN-1,d6						;init objenflags to 0
	lea	OBJENFLAGS,a0
	
.OEC:
	sf	(a0)+
	dbf.w	d6,.OEC

	move.w	#MIDPTSLEN-1,d6
	lea	MIDPTS,a0

.MPC:
	sf	(a0)+
	dbf.w	d6,.MPC

	move.w	LEVEL,d0							;find addr of the level data table
	asl.w	#2,d0								;init start time and location
	move.w	d0,a0
	add.l	#LEVELTAB,a0
	move.l	(a0),a0
	move.w	LVLINITX(a0),BUBSTARTX
	move.w	LVLINITY(a0),BUBSTARTY

	move.w	#LEVELTIME,BUBSTARTTIME

	sf	GAMEFLAG0							; allow bonus
	sf	GAMEFLAG1

;;;ASBx: ;************************************************************************
;;;ASBx: ;*									*
;;;ASBx: ;* LIFE LOOP								*
;;;ASBx: ;*									*
;;;ASBx: ;************************************************************************

BUBSYINIT:
LIFEINIT:
;;;ASBx: ; \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ 
;;;ASBx: ; LOAD SCREEN INIT
;;;ASBx: ;******************************** LEVEL INIT SOUND SYSTEM
	jsr	write_hi_score_to_eprom						;encode eeprom ensure we save the last level
	sf	MUSICCUR							;kill H & M DMA - init sound status shadow, get ready to start sound
	
.NOVOICE:
	moveq	#%00100000,d1
	move.w	LEVEL,d0
	lea	start_directions(pc),a0
	or.b	(a0,d0.w),d1
	move.b	d1,BUBSYFLAGS

	sf	VBLANKFLAG

	clr	INVTIMER							;disable invincibility
	clr	SHADOWTIMER

	move.w	PLAYER,d0							;set palette select
	andi.b	#$01,d0
	asl.b	#1,d0
	move.b	d0,BUBPALSEL

	clr.w	d0
	bsr	SegaFader

	move.w	LEVEL,d0							;init for load
	asl.w	#2,d0
	lea	LEVELTAB,a0
	move.l	0(a0,d0.w),a0

	move.w	LVLLOADX(a0),LOADX						;load bubsy init x
	move.w	LVLLOADY(a0),LOADY						;load bubsy init y
	move.l	LVLLOADCODE(a0),LOADCODE					;load bubsy code vector

	clr.w	WINDX
	clr.w	WINDY
	
	move.l	LVLLOADINIT(a0),a1						;exectue load init code
	jsr	(a1)

	CLR.W	BUBSYFRAME							;start the animation
	CLR.L	ANIMSCRPTR
	MOVE.L	LVLLOADANIM(A0),D0
	JSR	STARTANIMATIONFAR

	moveq	#6,d6								;set NMI for load level
	moveq	#BONUSFLAG,d0							;happens in load screen
	and.b	GAMEFLAG1,d0
	beq.s	.NOBONUS

	clr.w	d0								;if exciting bonus do fancy NMI
	bsr	SegaFader
	moveq	#8,d6

.NOBONUS:
	move.b	d6,NMIVECSEL
	move.b	#16,FADEDIR
	
	moveq	#19,d6
	cmp.w	LEVEL,d6
	bne.s	.NOT19
	moveq	#0,d6
	
.NOT19:
	move.b	d6,WOOLYLEVEL
	sf	RANDOMPTR

	clr.w	STIMER								;clear software timer

	move.w	LEVEL,d6
	asl.w	#2,d6

	lea	LEVELTAB,a4
	move.l	0(a4,d6.w),a4
	
	move.b	#$f0,SOUNDSTAT							;init sound status shadow
	sf	MUSICCUR							;get ready to start music
	bsr	LOADLEVEL							;load level data

	clr.w	WINDXMIN							;set map bounds
	clr.w	WINDYMIN
	move.w	MAPWIDP,d0
	subi.w	#340-16,d0
	move.w	d0,WINDXMAX
	
	move.w	MAPHTP,d0
	sub.w	screen_height,d0
	move.w	d0,WINDYMAX

;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS CODE GETS BUBSY READY FOR A ROUND OF PLAY
;;;ASBx: ; IS USUALLY CALLED WHEN BUBSY DIES AND GETS REINCARNATED AT THE START OF THE LEVEL

	jsr	INITOBJS							;clear the objects

;;;ASBx: ;******************************** INIT OBJCECT VRAM DMA SLOTS

;;;ASBx: ;******************************** INIT LEVEL REGS

	move.w	#$100,BUBAVESLOPE						;init slope

	move.w	#170,d0							;init bubsy coordinates
	move.w	d0,BUBWX
	move.w	d0,BUBDWX
	move.w	#$90,d0
	move.w	d0,BUBWYTOP
	move.w	d0,BUBWYBOT
	move.w	d0,BUBDWYTOP
	move.w	d0,BUBDWYBOT
	move.w	BUBSTARTX,d0
	move.w	d0,BUBX
	move.w	d0,BUBXOLD
	move.w	BUBSTARTY,d0
	move.w	d0,BUBY
	move.w	d0,BUBYOLD
	move.w	#16,BUBXMIN

	bsr	LOADSCREEN							;load the screen
	
	move.l	#SCRIPT,SCRIPTPTR						;intialise the script pointer
	jsr	SCRINIT								;start initial flags
	move.b	#READYSTATE,BUBSTATE
	clr.w	BUBVX								;set bubsys velocity to 0
	andi.b	#%01000011,PLAYERFLAGS						;clear all playerflags .not.SHOWLVTXT .not.BONUSDONEFLAG
	andi.b	#%00010000,GAMEFLAG1						;clear other game flags - not bonusflag
	andi.b	#%00010000,GAMEFLAG0						;not yarnlifeflag

	move.w	BUBSTARTTIME,TIME						;load the time

	sf	NMIVECSEL

	moveq	#%00100010,d1
	move.w	LEVEL,d0
	lea	start_directions(pc),a0
	or.b	(a0,d0.w),d1
	move.b	d1,BUBSYFLAGS

	move.b	#16,FADEDIR							;init fader

	clr.w	STICK1								;clear stick for recorder & controls
	clr.w	BUBSYFRAME							;clear current and last bubsy frame

	jsr	SegaFader
	sf	PAUSE_ENABLED
	
	sf	GAME_OVER_FLAG
	rts

LOADLEVEL:
	move.w	#LVLMUSIC,d7							;load the sound system for this level
	move.l	0(a4,d7.w),a0
	jsr	LOAD_MUSIC
	clr.l	last_music_loaded			; for next time round load in a new tune - even if it is the same
	
	move.w	LEVEL,d6								;this routine load all the data for a level
	asl.w	#2,d6

	lea	LEVELTAB,a4
	move.l	0(a4,d6.w),a4

;;;ASBx: ;******************************** LOAD THE LEVEL SPECIFIC OBJTABLES

	lea	GLOBAL_GRAPHICS,a0
	MOVE.L	LOAD_GLOBAL_GRAPHICS_ADDR,a1
	jsr	file_load
	jsr	relocate_sprites

	jsr	LEVELSPEECH

	moveq	#60,d0
	jsr	waitvbls
	
	tst.b	save_mod_level
	beq.s	.no_start
	bpl.s	.no_start
	
	jsr	START_MO
	jsr	FADEUP
	
.no_start:
	lea	WOBJTABLES,a0	;target
	move.w	#LVLAILIST,d7
	move.l	0(a4,d7.w),a1
	move.w	#WOBJTABLEN,d0
	lsr.w	#2,d0
	subq.w	#1,d0
	
.a1:
	move.l	(a1)+,(a0)+
	dbf.w	d0,.a1

;;;ASBx: ;******************************** EXPLODE BACKGROUND MAP DATA 

	move.w	LEVEL,d6
	asl.w	#2,d6
	lea	BGINDEX,a0
	move.l	(a0,d6.w),A0

	LEA	LOAD_BACKGROUND_MAP_HERE,A1
	jsr	file_load

;;;ASBx: ;******************************** DECOMPRESS CHARACTER DATA INTO VRAM

	move.w	LEVEL,d6
	mulu	#MGINDEXLEN,d6
	lea	MGINDEX,a0
	move.l	MGPALADD(a0,d6.w),a0
	move.w	#$7c1,VMODE

	pea	(a0)
	lea	MAPWID,a1
	jsr	file_load
	move.l	(sp)+,a0

	cmp.l	#W4PAL,a0
	bne.s	.its_rgb
	
	move.w	#$6c1,VMODE
	
	lea	2+(64*2)(a1),a1
	bra.s	.cont1
	
.its_rgb:
	lea	64*2(a1),a1
	
.cont1:	
	lea	view_pal+(64*2),a0
	move.w	#256-64-16-1,d0
	
.lpp:
	move.w	(a1)+,(a0)+
	dbf	d0,.lpp
	move.w	#RR1,view_pal+RMW_OFFSET
	move.w	#RR2,view_pal+RMW_OFFSET+2
	move.w	#RR3,view_pal+RMW_OFFSET+4
	st	NEW_PALETTE
	
	move.w	LEVEL,d6
	mulu	#MGINDEXLEN,d6
	lea	MGINDEX,a0
	
	move.l	MGINDEXBTRADD(a0,d6.w),a0
	
	lea	MAPWID,A1			;load it into the map area
	JSR	file_load
	
	move.w	(a1)+,d0
	subq	#1,d0
	move.w	d0,BLOCKS_LOADED_IN
	move.w	d0,d1
	lea	DYTAB,a0			;and then copy it to the right places
	lea	VXTAB,a2
	
.lp:
   	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+			;dytab = 16 bytes per entry
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a2)+			;gravity vxtab = word per entry
	dbf	d1,.lp
	
	clr.w	(a1)				;ensure attribute 0 if blank
	lea	ATTRTABLE,a0
	
.lpx:
	move.w	(a1)+,(a0)+			;attr  word per entry
	dbf	d0,.lpx
	
	move.w	LEVEL,d6
	mulu	#MGINDEXLEN,d6
	lea	MGINDEX,a0
	
	move.l	MGINDEXMPRADD(a0,d6.w),a0
	
	lea	MAPWID,A1			;load it into the map area
	JSR	file_load
	
	move.w	(a1)+,d0
	move.w	d0,CONTROL_TYPES
	subq	#1,d0
	move.w	d0,d1
	lea	DOUBLETAKE,a0			;and then copy it to the right places
	
.lp2:
	move.l	(a1)+,(a0)+
	dbf	d0,.lp2
	
	move.w	LEVEL,d6
	mulu	#MGINDEXLEN,d6
	lea	MGINDEX,a0
	
	move.l	MGCHARADD(a0,d6.w),a0
	MOVE.L	LOAD_MAP_CHARACTERS_HERE,A1
	JSR	file_load
	lsr.l	#8,d0
	move.w	d0,BLOCKS_LOADED_IN

;;;ASBx: ;******************************** DECOMPRESS MAP DATA
	move.w	LEVEL,d6
	mulu	#MGINDEXLEN,d6
	lea	MGINDEX,a0
	move.l	MGMAPADD(a0,d6.w),a0
	LEA	MAPWID,A1
	JSR	file_load

	move.w	MAPHT,d0							;calculate pixel mapwid/wapht
	asl.w	#4,d0
	move.w	d0,MAPHTP

	move.w	MAPWID,d0
	asl.w	#4,d0
	move.w	d0,MAPWIDP

	subi.w	#16,d0							;use bubwidp to calc bubxmax and then bubxmin
	move.w	d0,BUBXMAX

	move.w	MAPWID,d0						;set up the scroll routine
	add.w	d0,d0
	mulu	#PLAYFIELD_HEIGHT-3,d0
	
	move.w	d0,MAP_1ALTER
	move.w	d0,MAP_3ALTER
	
	moveq	#-1,d0
	add.w	MAPWID,d0
	add.w	d0,d0
	move.w	d0,MAP_2ALTER
	move.w	d0,MAP_4ALTER

;;;ASBx: ;******************************** LOAD IN THE RELEVANT SPRITES FOR THIS LEVEL

	move.w	LEVEL,d0
	asl.w	#2,d0
	move.l	d0,a0
	LEA	BADDIETAB,A0
	MOVE.L	(A0,D0.W),A0
	MOVE.L	LOAD_LEVEL_SPRITES_HERE,A1
	jsr	file_load
	jsr	relocate_sprites

;;;ASBx: ;******************************** START FADEOUT

	move.b	#$f0,FADEDIR
	jsr	SegaFader

;;;ASBx: ;******************************** EXPLODE PALETTE TO BE TUNPACK

.WAITFORFADE:
	move.w	LEVEL,d6
	mulu	#MGINDEXLEN,d6
	lea	MGINDEX,a0
	move.l	MGPALADD(a0,d6.w),a0
	
;;;ASBx: ;******************************** COPY SCRIPT TO RAM (TO BE UNPACKED)

	move.w	#LVLSCRIPT,d7
	move.l	0(a4,d7.w),a0
	LEA	SCRIPT,A1
	clr.l	(a1)+
	jsr	file_load
	lea	points_ctrl,a2
	move.w	#256-1,d0
	
.lppts:
	sf	(a2,d0.w)
	dbf	d0,.lppts
	moveq	#0,d0
	move.w	(a1),d0
	clr.w	(a1)+
	subq	#1,d0
	
.scrlp:
	move.l	(a1),d1
	lsl.l	#4,d1
	move.l	d1,(a1)+
	move.w	(a1),d1
	move.b	(a2,d1.w),d2
	addq.b	#1,(a2,d1.w)
	lsl.w	#8,d1
	move.b	d2,d1
	move.w	d1,(a1)+
	dbf	d0,.scrlp
	move.w	#$7fff,(a1)+
	clr.l	(a1)+
	
	clr.w	d7										;now convert midpts back
	clr.w	d6
	move.b	#MIDGOT,d0
	lea	MIDPTS,a0
	lea	SCRIPT,a1

.MP0:
	move.w	0(a0,d7.w),d6
	beq.s	.MP1
	move.b	d0,4(a1,d6.w)
	addq.w	#2,d7
	cmpi.w	#MIDPTSLEN,d7
	blt.s	.MP0
	
.MP1:

;;;ASBx: ;******************************** INIT WARPLIST AND TAKELIST AND FLIPLIST AND MUSICLIST

	move.w	#LVLWARPLIST,d7
	move.l	0(a4,d7.w),WARPLIST
	move.l	4(a4,d7.w),TAKELIST
	move.l	8(a4,d7.w),FLIPLIST
	move.l	12(a4,d7.w),MUSICLIST

;;;ASBx: ;******************************** SET CNT VECTOR & DO LEVEL INIT

	move.w	#LVLCODE,d7
	move.l	0(a4,d7.w),LVLCODEVEC

	move.l	4(a4,d7.w),a3

	jsr	(a3)
	
DUMMY:
	rts

BGINDEX:
	dc.l	W5BGM
	dc.l	W5BGM
	dc.l	W5BGM

	dc.l	W2BGM
	dc.l	W2BGM
	dc.l	W2BGM
	
	dc.l	W1BGM
	dc.l	W1BGM
	dc.l	W1BGM

	dc.l	W4BGM
	dc.l	W4BGM
	dc.l	W4BGM

	dc.l	W3BGM
	dc.l	W3BGM
	dc.l	W3BGM

MGCHARADD			equ	0
MGMAPADD			equ	4
MGPALADD			equ	8
MGINDEXBTRADD		equ	12
MGINDEXMPRADD		equ	16
MGINDEXLEN			equ	20	

MGINDEX:
	dc.l	W5CELLS,W5L1MAP,W5PAL,W5BTR,W5L1MPR
	dc.l	W5CELLS,W5L2MAP,W5PAL,W5BTR,W5L2MPR
	dc.l	W5CELLS,W5L3MAP,W5PAL,W5BTR,W5L3MPR
	
	dc.l	W2CELLS,W2L1MAP,W2PAL,W2BTR,W2L1MPR
	dc.l	W2CELLS,W2L2MAP,W2PAL,W2BTR,W2L2MPR
	dc.l	W2CELLS,W2L3MAP,W2PAL,W2BTR,W2L3MPR
	
	dc.l	W1CELLS,W1L1MAP,W1PAL,W1BTR,W1L1MPR
	dc.l	W1CELLS,W1L2MAP,W1PAL,W1BTR,W1L2MPR
	dc.l	W1CELLS,W1L3MAP,W1PAL,W1BTR,W1L3MPR

	dc.l	W4CELLS,W4L1MAP,W4PAL,W4BTR,W4L1MPR
	dc.l	W4CELLS,W4L2MAP,W4PAL,W4BTR,W4L2MPR
	dc.l	W4CELLS,W4L3MAP,W4PAL,W4BTR,W4L3MPR

	dc.l	W3CELLS,W3L1MAP,W3PAL,W3BTR,W3L1MPR
	dc.l	W3CELLS,W3L2MAP,W3PAL,W3BTR,W3L2MPR
	dc.l	W3CELLS,W3L3MAP,W3PAL,W3BTR,W3L3MPR

;;;ASBx: ;****************************************************************
;;;ASBx: ;*								*
;;;ASBx: ;*	PLAYER TURNOVER						*
;;;ASBx: ;*								*
;;;ASBx: ;****************************************************************

PLAYERTURNOVER:
	clr.w	INVTIMER								;disable invincibility
	clr.w	SHADOWTIMER

	move.w	LEVEL,d0
	cmpi.b	#15,d0
	bne.s	.NOEND

	st	signal_game_complete							;indicate 1 player has finished the game

	subq.w	#1,PLAYERS								;turn this player off and decrement number of players
	bpl.s	.ESWAP									;if there is still a player left swap
	bra	.GAMEOVER

.NOEND:
.ESWAP:

.NOWIN:												;both players are alive so do normal turnover
	moveq	#WARP4STATE,d0								;only if dead or warping
	and.b	BUBSTATE,d0									;find and save 8 triggered midpts
	beq.s	.SAVEMP
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.SAVEMP

	move.w	#MIDPTSLEN-1,d6								;otherwise clear those regs. continue, end of level
	lea	MIDPTS,a0
	
.MPC:
	sf	(a0)+
	dbf.w	d6,.MPC
	bra.s	.NOSAVEMP

.SAVEMP:
	moveq	#0,d6
	moveq	#0,d7
	lea	SCRIPT,a0
	lea	MIDPTS,a1

.MP0:
	move.b	4(a0,d6.w),d0
	cmpi.b	#MIDGOT,d0
	bne.s	.MP1
	move.w	d6,(a1,d7.w)
	addq.w	#2,d7
	cmpi.w	#MIDPTSLEN,d7
	bge.s	.MP2

.MP1:
	addq.w	#6,d6
	cmpi.w	#SCRIPTLEN,d6
	bCS.s	.MP0

.MP2:												;see if swap necessary
.NOSAVEMP:
	move.w	PLAYERS,d0
	beq.s	.PROCPLAYER									;one player
	move.b	OTHERPLAYER,d0								;if continues is negative the player is dead
	bmi.s	.PROCPLAYER

.SWAP:												;swap players
	move.w	#PLAYERLEN-1,d6
	lea	CURRENTPLAYER,a0
	lea	OTHERPLAYER,a1
	
.SWAPLOOP:
	move.b	0(a0,d6.w),d0
	move.b	0(a1,d6.w),0(a0,d6.w)
	move.b	d0,0(a1,d6.w)
	dbf.w	d6,.SWAPLOOP

	move.b	SWITCHES,d0
	move.b	SWAP_SWITCH,SWITCHES
	move.b	d0,SWAP_SWITCH
	
	eori.w	#$01,PLAYER									;flag proper player

	move.l	SCORE,DSCORE								;load display score

.PROCPLAYER:
	move.b	CONTINUES,d0
	bpl.s	.NOTDEAD

.GAMEOVER:
	move.l	SCORE,d0
	move.l	8+OTHERPLAYER,d1
	tst.w	PLAYER
	beq.s	.no_swap
	exg.l	d0,d1
	
.no_swap:
	move.l	d0,SCORE
	move.l	d1,8+OTHERPLAYER

	lea	SCORE,a0
	jsr	my_bcd_to_decimal
	
	lea	OTHERPLAYER+8,a0
	jsr	my_bcd_to_decimal

	st	jump_to_title		; once done just jump to title
	st	disable_reset		; no more resets just yet
	
	jmp	init_do_hi_score

.NOTDEAD:
	move.b	LIVES,d0
	CMP.B	#$90,D0
	bCC.s	.CONT

.LIFE:
	bsr	BUBSYINIT
	lea	my_stack,a7

	moveq	#0,d0
	bsr	SegaFader

	bra	GAMELOOP

.CONT:
	bsr	CONTINUEINIT
	lea	my_stack,a7

	moveq	#0,d0
	bsr	SegaFader

	bra	GAMELOOP

waitvbl:
wait_vbl:
WVBL:
	move.l	d0,-(sp)
	move.l	clock,d0
.wait:
	cmp.l	clock,d0
	beq.s	.wait
	move.l	(sp)+,d0
	RTS

RANDOM:
	moveq	#0,d0
	move.b	RANDOMPTR,d0
	addq.b	#1,d0
	move.b	d0,RANDOMPTR
	move.b	RANDOMTAB(PC,d0.w),d0
	rts

RANDOMTAB:
	dc.b	73,98,11,4,150,250,8,13,198,183,128,186,192,178,171,208
	dc.b	147,203,144,2,243,162,94,49,231,112,116,61,141,184,227,46
	dc.b	124,74,251,22,10,117,63,1,136,161,151,159,205,100,236,234
	dc.b	244,107,216,102,153,241,31,0,77,27,190,83,111,45,91,17
	dc.b	229,29,89,82,240,175,35,209,223,33,37,215,164,7,138,194
	dc.b	137,180,189,38,235,60,67,181,168,157,51,5,201,182,119,84
	dc.b	177,125,154,160,44,131,69,247,155,57,85,221,58,66,130,219
	dc.b	15,109,26,179,96,204,172,3,220,197,129,42,146,252,19,110
	dc.b	105,93,218,14,248,199,143,213,56,253,210,16,123,242,79,120
	dc.b	80,23,212,228,86,103,135,122,54,127,126,52,6,39,92,148
	dc.b	97,249,246,101,106,70,217,232,245,87,41,193,188,139,76,207
	dc.b	211,156,21,225,118,255,238,226,167,237,40,64,65,149,224,191
	dc.b	12,200,163,121,166,30,214,62,152,133,254,132,20,68,233,185
	dc.b	71,95,206,104,176,187,72,239,18,145,165,53,34,113,88,81
	dc.b	158,50,75,202,47,174,222,99,196,230,169,173,43,170,114,134
	dc.b	142,25,28,32,36,24,48,55,78,59,108,90,115,195,140,9

LEVELVOICES:
	dc.b	0,1,2
	dc.b	3,4,5
	dc.b	6,6,7,7,8,8
	dc.b	9,10,11
	dc.b	12,13,14
	dc.b	15
	dc.b	0
	even

BLOCKS_LOADED_IN:	dc.w	0
CONTROL_TYPES:		dc.w	0

start_directions:
	dc.b	0,0,BUBSYHFLIP			;alice in wonderland
	dc.b	BUBSYHFLIP,0,BUBSYHFLIP		;jack & bean
	dc.b	0,0,BUBSYHFLIP			;ali baba
	dc.b	0,0,0				;water babies
	dc.b	0,0,0				;hansel & gretel
	even
	
make_rmw:
	movem.l	d0-a6,-(sp)
	lsl.l	#5,d7
	bset	#14,d7
	move.l	a1,d0
	move.l	(a1),d1
	lsr.l	#5,d1
	subq.w	#1,d1
	
.loop:
	or.l	d7,8(a1)
	lea	32(a1),a1
	dbf	d1,.loop
	movem.l	(sp)+,d0-a6
	rts

my_bcd_to_decimal:
	movem.l	d0-d2,-(sp)
	moveq	#0,d2
	moveq	#4-1,d0
	
.lp:	
	lsl.l	#2,d2		;*4	04
	move.l	d2,-(sp)
	lsl.l	#3,d2		;*4*8	32
	add.l	d2,(sp)
	add.l	d2,d2		;*4*8*2	64
	add.l	(sp)+,d2	;	100
	
	moveq	#0,d1
	move.b	(a0)+,d1
	move.l	d1,d3
	and.w	#$f,d3
	lsr.w	#4,d1
	mulu	#10,d1
	add.l	d1,d2
	add.l	d3,d2
	dbf	d0,.lp
	subq.w	#4,a0
	move.l	d2,(a0)
	movem.l	(sp)+,d0-d2
	rts
