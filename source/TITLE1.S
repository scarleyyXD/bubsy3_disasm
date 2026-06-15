TITLE_WAIT_VBLS	equ	10*60		; 10 seconds

LAST_LEVEL	equ	15
FONT_WIDTH	equ	16
SPACE_WIDTH	equ	18

.macro	CONVERT_FONT_WIDTH_SCALED		;assume correct width == 16
	mulu	TXTSPACING,d5				;d5==(width*TXTSPACING)
	asr.w	#4,d5						;d5==(width*TXTSPACING)/16
	add.w	d5,d0						;ie 16 ==> width
	.endm

;;;ASBx: ;************************************************************************
;;;ASBx: ;*									*
;;;ASBx: ;* BUBSY TITLE MODULE							*
;;;ASBx: ;*									*
;;;ASBx: ;************************************************************************

REPDEL	equ	20	; BUTTON DELAY
REPRATE	equ	3	; BUTTON REPEAT RATE

TITLE:	
	move.w	#$100,WINDX
	move.w	#$100,TEMP9

	clr.w	EDITOBJVEC
	andi.b	#~DEMOMODE,EDITFLAGS			;init to demo off

	move.b	#2,NMIVECSEL				;title loop
	
.ok1:
	lea	TITLE_PIC_NAME,a0
	move.l	load_title_pic_here,a1
	jsr	file_load

	lea	TITLE_RGB_NAME,a0
	lea	view_pal,a1
	jsr	file_load
	st	NEW_PALETTE

	lea	RESET_GRAPHICS,a0
	MOVE.L	LOAD_RESET_ADDR,a1
	jsr	file_load
	jsr	relocate_sprites
	
	sf	TEMP5
	
PRELOOP:
	jsr	FADER
	jsr	GETINPUT				;wait for player to let go of start button

	move.w	KEY_PRESS_FROM_FRED,d0
	and.w	#1<<OPTIONS,d0
	bne.s	TITLELOOP

	clr.w	STICK1					;if fire was pressed then bye bye to all controls
	clr.w	STICK2
	clr.w	EDGESTICK1
	clr.w	EDGESTICK2
	
TITLELOOP:
	move.w	STICK1,d0				;in the title screen stick and edge stick
	or.w	STICK2,d0				;hold the ored values of both controllers
	move.w	d0,STICK
	move.w	EDGESTICK1,d0
	or.w	EDGESTICK2,d0
	move.w	d0,EDGESTICK

	jsr	NEW_OL
	addq.w	#1,STIMER				;handle the clock
	
	tst.b	TEMP5
	bne.w	EXIT	;bne.s->bne.w
	
	jsr	add_title_screen
	
	tst.w	reset_eeprom_timer			; if counting down then ignore OPTIONS BUTTON
	beq.s	.no_eeprom_message

	tst.b	allow_eeprom_reset
	beq.s	.no_reset
	
	bsr	clear_that_eeprom
	
.no_reset:
.no_eeprom_message:
	jsr	MENUSCREEN				;chow menu screen
	jsr	FADER
	jsr	GETINPUT				;wait for a start button press

	move.w	KEY_PRESS_FROM_FRED,d0
	and.w	#1<<OPTIONS,d0
	seq	d0
	or.b	d0,TEMP5					; if 0 then options not pressed

.NOSTART2:					;select into menu
	if	DEBUG
	move.l	#-1,BORD1
	endif

	move.w	NUMVBLS,d0
.L10:
	cmp.w	NUMVBLS,d0
	beq.s	.L10
	
	bra	TITLELOOP
	
EXIT:
	move.w	#8,TEMP8				;fade out sound
	moveq	#FADEOUTSOUND,d0
	jsr	STARTSOUND

	move.b	#$f0,FADEDIR

TITLEEXIT:
	jsr	NEW_OL
	jsr	NEW_OL
	move.w	NUMVBLS,d0
	
.L10:
	cmp.w	NUMVBLS,d0
	beq.s	.L10
	move.w	LEVEL,LAST_LEVEL_PLAYED		;allow player to start on last level played
	rts

**********************************************************************************************
**********************************************************************************************

MENUSCREEN:
	move.w	WINDX,d0				;process input
	cmpi.w	#$100,d0				;no processing if not in menu
	bne.s	DRAWMENU

	move.w	TEMP7,d0				;be sure not editing passcode
	cmpi.w	#7,d0
	beq.s	.DOCTRLS
	cmpi.w	#0,d0
	bne.s	.DOLOGIC

.DOCTRLS:
	jsr	UDSOUND
	move.w	EDGESTICK,d0
	andi.w	#CTRL_UP,d0
	beq.s	.NOUP
	clr.w	TEMP7
	subq.w	#2,TEMP8
	move.w	TEMP8,d0
	bpl.s	.NOUP
	move.w	#8,TEMP8

.NOUP:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_DOWN,d0
	beq.s	.NODN
	clr.w	TEMP7
	addq.w	#2,TEMP8
	move.w	TEMP8,d0
	cmpi.w	#10,d0
	blt.s	.NODN
	clr.w	TEMP8

.NODN:
.DOLOGIC:
	move.w	TEMP8,d6
	asl.w	#1,d6
	lea	MENULOGIC,a0
	move.l	(a0,d6.w),a0
	jsr	(a0)

DRAWMENU:
	moveq	#3,d3
	and.w	STIMER,d3
	lea	CURSCOLS,a0
	move.b	(a0,d3.w),d3

	move.w	#C0,d2				;initally color type 0
	
	lea	PLAYERSTABLE(pc),a6
	move	PLAYERS,d0			;draw the players string
	lsl.w	#2,d0
	move.l	(a6,d0.w),a6
	
.DRW1PLR:
	move.w	TEMP8,d6
	bne.s	.NOTPLRCURS
	move.w	d3,d2

.NOTPLRCURS:
	jsr	DRAWMENUTEXT

	lea	JMPTABLE,a6
	moveq	#0,d0
	move.b	PAD_TYPE,d0
	and.w	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a6,d0.w),a6
	
.JMPA:
	move.w	#C0,d2
	move.w	TEMP8,d6
	cmpi.w	#2,d6
	bne.s	.NOTBUTTCURS
	move.w	d3,d2

.NOTBUTTCURS:
	jsr	DRAWMENUTEXT

	move.w	TEMP7,d0			;draw passcode string
	bne.s	.DRAWPAS1

	move.w	#C0,d2
	lea	ENTPASTXT(pc),a6			;enter passcode prompt
	move.w	TEMP8,d6
	cmpi.w	#6,d6
	bne.s	.NOTPASCURS
	move.w	d3,d2

.NOTPASCURS:
	jsr	DRAWMENUTEXT
	bra	.ENDPAS

.DRAWPAS1:
	cmpi.w	#7,d0
	bne.s	.NOTENTERED

	move.w	#C0,d2
	lea	PASTXT2(pc),a6			;passcode entered
	move.w	TEMP8,d6
	cmpi.w	#6,d6
	bne.s	.NOTPASCURS1
	move.w	d3,d2

.NOTPASCURS1:
	jsr	DRAWMENUTEXT
	bra.s	.ENDPAS

.NOTENTERED:
	blt.s	.ENTERING

	lea	PASTXT1(pc),a6			;entered bad passcode
	move.w	#C1,d2
	jsr	DRAWMENUTEXT
	bra.s	.ENDPAS

.ENTERING:					;entering passcode
	lea	PASTXT(pc),a6
	move.w	#C0,d2
	jsr	DRAWMENUTEXT
	move.w	d6,d1				;flash character at cursor
	move.w	TEMP7,d6
	lea	STRIPBUF-1,a0
	move.b	(a0,d6.w),d0
	move.w	d0,-(a7)
	btst.b	#1,STIMER+1
	bne.s	.NOFLASH
	move.w	d3,d2
	move.b	#' ',(a0,d6.w)

.NOFLASH:
	move.w	d1,d6
	lea	STRIPBUF,a6
	jsr	DRAWMENUTEXT
	move.w	TEMP7,d6
	move.w	(a7)+,d0
	lea	STRIPBUF-1,a0
	move.b	d0,(a0,d6.w)

.ENDPAS:						;draw info text
	move.w	LEVEL,d6
	cmp.w	#LAST_LEVEL,d6
	blt.s	.ok
	move.w	LAST_LEVEL_PLAYED,LEVEL
.ok:
	add.b	d6,d6
	lea	LVLDIGS,a2
	move.b	(a2,d6.w),STEXT
	move.b	1(a2,d6.w),STEXT+1
	
	lea	STARTTEXT,a6

	move.w	#C0,d2
	move.w	TEMP8,d6
	cmpi.w	#8,d6
	bne.s	.NOTSTART
	move.w	d3,d2
	
.NOTSTART:
	jsr	DRAWMENUTEXT
	
	lea	CREDITTXT,a6

	move.w	#C0,d2
	move.w	TEMP8,d6
	cmpi.w	#4,d6
	bne.s	.NOTCREDIT
	move.w	d3,d2
.NOTCREDIT:
	jsr	DRAWMENUTEXT
	
	tst.w	reset_eeprom_timer
	beq.s	.no_reset_timer
	
	subq.w	#1,reset_eeprom_timer
	
	jsr	DRAWRESETSPRITE

.no_reset_timer:
	rts

;;;ASBx: ; *************************************** SELECTION ROUTINES
;;;ASBx:		; THESE 2 ROUTINES GENERATE CONTROLLER
;;;ASBx:		; INPUT SOUND FOR ALL MENU SELECTIONS IN 
;;;ASBx:		; THE ENTIRE GAME!

SELSOUND:
	move.w	EDGESTICK,d0
	andi.w	#JOY_SELECT,d0
	beq.s	.NOL
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND

.NOL:
	rts

LRSOUND:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_LEFT,d0
	beq.s	.NOL
	moveq	#POPSOUND3,d0
	jsr	STARTSOUND

.NOL:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_RIGHT,d0
	beq.s	.NOR
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND

.NOR:
	rts

UPSOUND1:
UDSOUND:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_UP,d0
	beq.s	.NOU
	moveq	#POPSOUND2,d0
	jsr	STARTSOUND

.NOU:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_DOWN,d0
	beq.s	.NOD
	moveq	#POPSOUND,d0
	jsr	STARTSOUND

.NOD:
	rts

MENUPLAYERS:
	move.w	EDGESTICK,d0
	AND	#CTRL_RIGHT|JOY_A|JOY_B|JOY_C|JOY_X|JOY_Y,D0
	beq.s	.NOSEL
	
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND

	ADDQ.W	#1,PLAYERS
	CMP.W	#3,PLAYERS
	bne.s	.no_wrap
	clr.w	PLAYERS
	
.no_wrap:
	rts
	
.NOSEL:
	move.w	EDGESTICK,d0
	AND	#CTRL_LEFT,D0
	beq.s	.no_wrap
	
	moveq	#POPSOUND3,d0
	jsr	STARTSOUND

	subq.w	#1,PLAYERS
	CMP.W	#-1,PLAYERS
	bne.s	.no_wrap
	move.w	#2,PLAYERS
	rts

MENUSTART:
	move.w	EDGESTICK,d0
	AND	#CTRL_LEFT|CTRL_RIGHT|JOY_A|JOY_B|JOY_C|JOY_X|JOY_Y,D0
	beq.s	.no
	st	TEMP5
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND

.no:
	rts

MENUCREDITS:
	move.w	EDGESTICK,d0
	AND	#CTRL_LEFT|CTRL_RIGHT|JOY_A|JOY_B|JOY_C|JOY_X|JOY_Y,D0
	beq.s	.no
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND
	jmp	credits_part
	
.no:
	rts

MENUJUMPGLIDE:
	move.w	EDGESTICK,d0
	AND	#CTRL_RIGHT|JOY_A|JOY_B|JOY_C|JOY_X|JOY_Y,D0
	beq.s	.NOSEL
	
	moveq	#POPSOUND4,d0
	jsr	STARTSOUND

	addq.b	#1,PAD_TYPE
	cmp.b	#6,PAD_TYPE
	bne.s	.ok
	sf	PAD_TYPE
	
.ok:
	rts
	
.NOSEL:
	move.w	EDGESTICK,d0
	AND	#CTRL_LEFT,D0
	beq.s	.ok
	
	moveq	#POPSOUND3,d0
	jsr	STARTSOUND

	subq.b	#1,PAD_TYPE
	cmp.b	#-1,PAD_TYPE
	bne.s	.ok
	move.b	#5,PAD_TYPE
	rts

MENUPASSCODE:			;input passcode if in that mode
	lea	STRIPBUF-1,a0
	lea	PASSCHARS,a1
	move.w	TEMP7,d0		;see if one has already been entered
	cmpi.w	#7,d0
	beq.s	.LOOKFORPASSCODE
	cmpi.w	#0,d0
	bne.s	.INPASSCODE

.LOOKFORPASSCODE:			;we are entering passcode, see if we should start entering a passcode
	jsr	SELSOUND
	move.w	EDGESTICK,d0
	AND.w	#CTRL_RIGHT,D0
	beq.s	.NOPASSCODE
	move.w	#1,TEMP7
	move.l	#'!!!!',d0
	move.l	d0,STRIPBUF+0
	move.w	d0,STRIPBUF+4
	clr.w	STRIPBUF+6
	rts

.NOPASSCODE:
	rts

.INPASSCODE:			;if greater then delay due to bad passcode
	move.w	TEMP7,d0
	cmpi.w	#7,d0
	blt.s	.INPASSCODE1
	addq.w	#1,TEMP7
	cmpi.w	#70,TEMP7
	bne.s	.NOPASSCODE
	clr.w	TEMP7
	rts

.INPASSCODE1:			;we are currently entering the passcode
	jsr	LRSOUND
	jsr	UDSOUND
	move.w	EDGESTICK,d0		;handle debounced keys
	beq.s	.DB0
	clr.b	EDITDEBOUNCE

.DB0:
	addq.b	#1,EDITDEBOUNCE
	move.b	EDITDEBOUNCE,d0
	cmpi.b	#REPDEL,d0
	bne.s	.MI3
	subi.b	#REPRATE,d0
	move.b	d0,EDITDEBOUNCE

	move.w	STICK,d0
	andi.w	#CTRL_UP,d0
	beq.s	.NOTUPDB
	moveq	#POPSOUND2,d0
	jsr	STARTSOUND
	bra	.DOUP

.NOTUPDB:
	move.w	STICK,d0
	andi.w	#CTRL_DOWN,d0
	beq.s	.NOTDOWNDB
	moveq	#POPSOUND,d0
	jsr	STARTSOUND
	bra	.DODOWN

.NOTDOWNDB:
.MI3:
	move.w	EDGESTICK,d0
	AND	#JOY_B|JOY_Y|JOY_C|JOY_A|JOY_X,D0
	beq.s	.NOTSEL
	move.w	#7,TEMP7
	bra	.EVALPASSCODE

.NOTSEL:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_LEFT,d0
	beq.s	.NOTLEFT
	move.w	TEMP7,d6
	subq.w	#1,d6
	beq.s	.NOTLEFT
	move.w	d6,TEMP7

.NOTLEFT:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_RIGHT,d0
	beq.s	.NOTRIGHT
	move.w	TEMP7,d6
	move.b	(a0,d6.w),d0
	cmpi.b	#'!',d0
	beq.s	.NOTRIGHT1
	addq.w	#1,TEMP7
	cmpi.w	#6,d6
	bne.s	.NOTRIGHT1
	subq.w	#1,TEMP7

.NOTRIGHT1:
.NOTRIGHT:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_UP,d0
	beq.s	.NOTUP

.DOUP:
	move.w	TEMP7,d6
	move.b	(a0,d6.w),d0
	moveq	#-1,d7

.UPLOOP:
	addq.w	#1,d7
	cmp.b	0(a1,d7.w),d0
	bne.s	.UPLOOP
	move.b	1(a1,d7.w),(a0,d6.w)

.NOTUP:
	move.w	EDGESTICK,d0
	andi.w	#CTRL_DOWN,d0
	beq.s	.NOTDOWN

.DODOWN:
	move.w	TEMP7,d6
	move.b	(a0,d6.w),d0
	move.w	#-1,d7

.DOWNLOOP:
	addq.w	#1,d7
	cmp.B	1(a1,d7.w),d0
	bne.s	.DOWNLOOP
	move.b	0(a1,d7.w),0(a0,d6.w)

.NOTDOWN:
	bsr	get_pad_press
	addq	#1,d0
	beq.s	.NOTRIGHT2
	move.b	0(a1,d0.w),d0
	cmpi.b	#'!',d0
	beq.s	.NOTRIGHT3
	move.w	TEMP7,d6
	move.b	d0,0(a0,d6.w)
	addq.w	#1,TEMP7
	cmpi.w	#6,d6
	bne.s	.NOTRIGHT3
	subq.w	#1,TEMP7
	
.NOTRIGHT3:	
	and.w	#3,d6
	moveq	#POPSOUND,d0
	add.w	d6,d0
	jsr	STARTSOUND

.NOTRIGHT2:
	rts

.EVALPASSCODE:
	clr.w	LEVEL
	clr.w	d6

	LEA	PASSCODES,A1
	
.EVALPC:
	moveq	#0,d7
	move.w	1(a0,d7.w),d0
	cmp.w	0(a1,d6.w),d0
	bne.s	.NOCODE
	move.w	3(a0,d7.w),d0
	cmp.w	2(a1,d6.w),d0
	bne.s	.NOCODE
	move.w	5(a0,d7.w),d0
	cmp.w	4(a1,d6.w),d0
	bne.s	.NOCODE
	move.w	d6,d0

.EVALPC1:
	subq.w	#6,d0
	bmi.s	.DONE
	addq.w	#1,LEVEL
	bra.s	.EVALPC1

.NOCODE:
	addq.w	#6,d6
	cmpi.w	#15*6,d6
	blt.s	.EVALPC
	addq.w	#1,TEMP7

.DONE:				;legal code, set up text
	move.w	LEVEL,d6
	move.w	d6,OTHERPLAYER+14
	asl.w	#1,d6
	lea	LVLDIGS,a2
	move.b	(a2,d6.w),PASSSS
	move.b	1(a2,d6.w),PASSSS+1
	rts

MENULOGIC:
	dc.l	MENUPLAYERS
	dc.l	MENUJUMPGLIDE
	dc.l	MENUCREDITS
	dc.l	MENUPASSCODE
	dc.l	MENUSTART

JMPTABLE:
	DC.L	JMPTXT1
	DC.L	JMPTXT2
	DC.L	JMPTXT3
	DC.L	JMPTXT4
	DC.L	JMPTXT5
	DC.L	JMPTXT6
	DC.L	JMPTXT1
	DC.L	JMPTXT2

PLAYERSTABLE:
	dc.l	PLRTXT1
	dc.l	PLRTXT2
	dc.l	PLRTXT3

POS		equ	$FF
COLOR	equ	$FE
C0		equ	ALPHABET
C1		equ	ALPHABET1

SCREEN_MID		EQU	160
SCREEN_MID_PASS	EQU	120

PLRTXT1:
	dc.b	POS,SCREEN_MID,(5*8)-(4*8)
	dc.b	'1 PLAYER',0
	
PLRTXT2:
	dc.b	POS,SCREEN_MID,(5*8)-(4*8)
	dc.b	'2 PLAYERS : 2 PADS',0
	
PLRTXT3:
	dc.b	POS,SCREEN_MID,(5*8)-(4*8)
	dc.b	'2 PLAYERS : 1 PAD',0

JMPTXT1:
	dc.b	POS,SCREEN_MID,(8*8)-(4*8)
	dc.b	'GLIDE:A JUMP:B'
JMPTXT12:
	dc.b	POS,SCREEN_MID,(10*8)-(4*8)+4
	dc.b	'LOOK:C',0
	
JMPTXT2:
	dc.b	POS,SCREEN_MID,(8*8)-(4*8)
	dc.b	'GLIDE:A JUMP:C'
JMPTXT22:
	dc.b	POS,SCREEN_MID,(10*8)-(4*8)+4
	dc.b	'LOOK:B',0
	
JMPTXT3:
	dc.b	POS,SCREEN_MID,(8*8)-(4*8)
	dc.b	'GLIDE:B JUMP:A'
JMPTXT32:
	dc.b	POS,SCREEN_MID,(10*8)-(4*8)+4
	dc.b	'LOOK:C',0
	
JMPTXT4:
	dc.b	POS,SCREEN_MID,(8*8)-(4*8)
	dc.b	'GLIDE:B JUMP:C'
JMPTXT42:
	dc.b	POS,SCREEN_MID,(10*8)-(4*8)+4
	dc.b	'LOOK:A',0
	
JMPTXT5:
	dc.b	POS,SCREEN_MID,(8*8)-(4*8)
	dc.b	'GLIDE:C JUMP:A'
JMPTXT52:
	dc.b	POS,SCREEN_MID,(10*8)-(4*8)+4
	dc.b	'LOOK:B',0

JMPTXT6:
	dc.b	POS,SCREEN_MID,(8*8)-(4*8)
	dc.b	'GLIDE:C JUMP:B'
JMPTXT62:
	dc.b	POS,SCREEN_MID,(10*8)-(4*8)+4
	dc.b	'LOOK:A',0

ENTPASTXT:
	dc.b	POS,SCREEN_MID,($10*8)-(4*8)+(5*8)-16-2
	dc.b	'ENTER PASSCODE',0
	
PASTXT:
	dc.b	POS,SCREEN_MID_PASS,($10*8)-(4*8)+(5*8)-16-2
	dc.b	'PASSCODE:'
	dc.b	0
	
PASTXT1:
	dc.b	POS,SCREEN_MID,($10*8)-(4*8)+(5*8)-16-2
	dc.b	'BOGUS PASSCODE!',0
	
PASTXT2:
	dc.b	POS,SCREEN_MID,($10*8)-(4*8)+(5*8)-16-2
	dc.b	'CHAPTER '
	
PASSSS:	dc.b	'00',0

CREDITTXT:
	dc.b	POS,SCREEN_MID,($10*8)-(4*8)+(5*8)-16-(3*8)
	dc.b	'CREDITS',0

STARTTEXT:
	dc.b	POS,SCREEN_MID,($10*8)-(4*8)+(7*8)+4-16
	dc.b	'START CHAPTER:'
STEXT:
	dc.b	"00",0

PASSCHARS:
	dc.b	'!123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!'
	even
	
LVLDIGS:
	dc.b	'1',0,'2',0,'3',0
	dc.b	'4',0,'5',0,'6',0
	dc.b	'7',0,'8',0,'9',0
	dc.b	'10','11','12'
	dc.b	'13','14','15'

CURSCOLS:
	dc.b	C0,C1,C0,C1
	even

VFLIP	equ	$1000
HFLIP_TITLE	equ	$0800
	even

DRAWMENUTEXT:
	move.l	load_overlay_graphics,a5
	move.w	text_old_x,d0
	move.w	text_old_y,d1
	lea	TITLEASC,a1
	lea	WIDTH_TABLE,a2
	move.w	#160,d7
	
.DRAWMENUTEXT:					;read and draw the map
	moveq	#0,d4
	move.b	(a6)+,d4
	beq	.MENUTEXTDONE
	
.control_code:	
	cmpi.b	#POS,d4
	bne.s	.NOTPOS
	
	moveq	#0,d7
	moveq	#0,d1
	move.b	(a6)+,d7
	move.b	(a6)+,d1
	
	cmp.w	#260,screen_height
	blt.s	.not_pal
	add.w	#16,d1
	
.not_pal:
	add.w	#ntsc_n_vdb/2,d1
	lsl.l	#4,d1
	
	bra.s	.DRAWMENUTEXT
	
.NOTPOS:
	cmpi.b	#COLOR,d4
	bne.s	.NOTCOLOR
	move.b	(a6)+,d2
	bra.s	.DRAWMENUTEXT

.NOTCOLOR:
	cmp.l	#STRIPBUF,a6
	blt.s	.no_passcode
	
	cmp.l	#STRIPBUF+10,a6
	blt.s	.next_letter
	
.no_passcode:	
	bsr	menu_centre_text
	
.next_letter:
	moveq	#SPACE_WIDTH,d5
	subi.b	#' ',d4
	beq.s	.ok
	move.b	(a1,d4.w),d4			;get character code
	move.b	(a2,d4.w),d5			;get width

	ADD_OL_MACRO
	movem.l	d3-d7,-(sp)
	add.w	d2,d4				;update the color
	lsl.w	#5,d4				;index into table entry
	movem.l	0(a5,d4.w),d3/d4/d5/d6		;now pointing to entry in table
	lsl.l	#8,d3
	add.w	d1,d4				;and the y position
	or.w	d0,d6
	movem.l	d3/d4/d5/d6,(a0)
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	(sp)+,d3-d7
	
.ok:	
	cmp.l	#STRIPBUF,a6
	blt.s	.no_passcode1
	
	cmp.l	#STRIPBUF+10,a6
	bge.s	.no_passcode1

	add.w	#FONT_WIDTH,d0
	bra.s	.cont
	
.no_passcode1:	
	add.w	d5,d0
	
.cont:
	moveq	#0,d4
	move.b	(a6)+,d4
	beq.s	.MENUTEXTDONE
	bpl.s	.next_letter
	bra	.control_code

.MENUTEXTDONE:
	move.w	d0,text_old_x
	move.w	d1,text_old_y
	rts

text_old_x:	dc.w	0
text_old_y:	dc.w	0

menu_centre_text:
	pea	(a6)
	subq.w	#1,a6
	moveq	#0,d0
	
.lp:
	moveq	#0,d5
	move.b	(a6)+,d5
	beq.s	.end_1
	cmp.b	#POS,d5
	bne.s	.not_pos
	addq.w	#2,a6
	bra.s	.lp
	
.not_pos:
	cmp.b	#COLOR,d5
	bne.s	.not_col
	addq.w	#1,a6
	bra.s	.lp
	
.not_col:
	sub.b	#' ',d5
	beq.s	.space
	move.b	(a1,d5.w),d5			;get character code
	bra.s	.not_space
	
.space:	
	add.w	#SPACE_WIDTH,d0
	bra.s	.cont_space
	
.not_space:
	move.b	(a2,d5.w),d5			;get width
	add.w	d5,d0
	
.cont_space:
	moveq	#0,d5
	move.b	(a6)+,d5
	beq.s	.end_1
	bpl.s	.not_col
	
.end_1:	
	asr.w	#1,d0
	neg.w	d0
	add.w	d7,d0	
	move.l	(sp)+,a6
	rts

RESET_Y_POS_NTSC	equ	(($10*8)-(4*8)+(7*8)+4+30-16)	;($10*8-4*8+7*8+4+30-16)
RESET_Y_POS_PAL		equ	RESET_Y_POS_NTSC+32
	
DRAWRESETSPRITE:
	move.w	#(320-224)/2,d0
	move.w	#RESET_Y_POS_NTSC,d1
	cmp.w	#240,screen_height
	blt.s	.pal
	move.w	#RESET_Y_POS_PAL+16,d1
	
.pal:
	moveq	#0,d4
	move.l	LOAD_RESET_ADDR,a0
	jmp	print_a_sprite_normal