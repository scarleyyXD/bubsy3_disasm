CREDCODE		rts

	MOVE.B	#$F8,FADEDIR								;start fade
	CLR.B	FADEVAL

.WFF
	JSR	WVBL
	JSR	FADER
	MOVE.B	FADEVAL,D0
	AND.B	#$F0,D0
	BNE	.WFF

            clr.w   d0									;blank the screen
            jsr     SegaFader

	MOVE.B	#4,NMIVECSEL

            move.l  #W6BGC,A0
	    LEA	MAPBASE,A1
	    JSR	file_load


            move.l  #W6BGM,A0
	LEA	MAPBASE,A1
	JSR	file_load

	LEA	CREDCHAR,A0
	LEA	MAPBASE,A1
	JSR	file_load

            move.l  #CREDPAL,CurPal
            clr.w   d0
            jsr     SegaFader

	CLR	WINDX
	CLR	WINDY
	CLR	STIMER

	CLR.B	FADEVAL										;init fader
	MOVE.B	#4,FADEDIR

	MOVE.B	#2,NMIVECSEL

	CLR	TEMP9
	CLR	TEMP7

	CLR	D0
	JSR	LOADSCREEN_CREDITS									;if titleseq end begin again

	MOVE	#1,D0
	JSR	STARTMUSIC									;start music

PRELOOP_CREDITS
	JSR	WVBL

	ADDQ	#1,STIMER									;handle clock

	JSR	FADER										;fade in

	JSR	GETINPUT									;wait for player to let go of start button

	MOVE	STICK1,D0									;in the title screen and edgestick
	OR	STICK2,D0									;hold or'ed values of both controllers
	MOVE	D0,STICK
	MOVE	EDGESTICK1,D0
	OR	EDGESTICK2,D0
	MOVE	D0,EDGESTICK

	MOVE	STICK,D0
	AND	#JOY_START,D0
	BNE	PRELOOP_CREDITS

TITLELOOP_CREDITS
	ADDQ	#1,STIMER									;handle the clock
	JSR	FADER										;fade in
	JSR	GETINPUT									;wait for a start button press

	MOVE	STICK1,D0
	OR	STICK2,D0
	MOVE	D0,STICK
	MOVE	EDGESTICK1,D0
	OR	EDGESTICK2,D0
	MOVE	D0,EDGESTICK

	MOVE	EDGESTICK,D0
	AND	#JOY_SELECT+JOY_START,D0
	BEQ	.NOINPUT
	MOVE.B	#-8,FADEDIR
	MOVE	FADEOUTSOUND,D0
	JSR	STARTSOUND
.NOINPUT
	MOVE	WINDX,D0									;joy or buttons start screen change
	CMP	TEMP9,D0
	BNE	.NOSEL1
	MOVE	EDGESTICK,D0
	AND	#JOY_RIGHT+JOY_UP,D0
	BEQ	.NOSEL0
	SUB	#$100,TEMP9
	SUB	#1,TEMP7
	AND	#3,TEMP7
	MOVE	TEMP7,D0
	JSR	LOADSCREEN_CREDITS
.NOSEL0
	MOVE	EDGESTICK,D0
	AND	#JOY_LEFT+JOY_DOWN,D0
	BEQ	.NOSEL1
	ADD	#$100,TEMP9
	ADD	#1,TEMP7
	AND	#3,TEMP7
	MOVE	TEMP7,D0
	JSR	LOADSCREEN_CREDITS
.NOSEL1

	MOVE	WINDX,D0
	CMP	TEMP9,D0
	BEQ	.NOSCROLL
	BMI	.SCROLLRIGHT
	SUBQ	#2,WINDX
	BRA	.NOSCROLL
.SCROLLRIGHT
	ADDQ	#2,WINDX
.NOSCROLL
	TST.B	FADEDIR										;if totally faded then bail
	BNE	.NOEXIT
	MOVE.B	FADEVAL,D0
	AND.B	#$F0,D0
	BEQ	EXIT_CREDITS
.NOEXIT
	JSR	WVBL
	JMP	TITLELOOP_CREDITS

;;;ASB: 
;;;ASB: ; ******************************* AND WE'RE OUT OF THERE
;;;ASB: 

EXIT_CREDITS												;blank the screen and exit
        clr.w   d0
        jsr     SegaFader

	JSR	KILLSOUND
	RTS

LOADSCREEN_CREDITS
        andi.w  #$00ff,d0
        asl.w   #2,d0
        lea     CREDSCREENS,a1
        move.l  (a1,d0.w),A0
	LEA	MAPBASE,A1
	JSR	file_load

       rts


CREDCHAR
	dc.b	"CREDCHRM.PP",0
CREDPAL
        dc.b	"CREDPAL.PP",0
CREDM00
	dc.b	"CREDM00.PP",0
CREDM01
      	dc.b	"CREDM01.PP",0
CREDM02
	dc.b	"CREDM02.PP",0
CREDM03
	dc.b	"CREDM03.PP",0

CREDSCREENS
	DC.L	CREDM00
	DC.L	CREDM03
	DC.L	CREDM02
	DC.L	CREDM01
