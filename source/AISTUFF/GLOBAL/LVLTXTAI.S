FONT_SPACER	equ	2
;SPACE_WIDTH	equ	18

.macro	show_version
	if	VERSION_TEXT
	DC.B	$FF,0-12*SPACING2/2+(320/2),0,$80+$30,0
	DC.B	'VERSION 7:10'
	endif
	.endm

SPACING2	equ	$C

DRAWTEXT:
	move.l	load_overlay_graphics,a4
	lea	WIDTH_TABLE,a3

; OAM SHOULD HAVE PALETTE BITS

	MOVE.L	OBJAUX0(A5),a6
	
.DRAWLOOP:
	moveq	#0,d4
	MOVE.B	(a6)+,d4
	BEQ.s	.DRAWDONE
	BPL	.NOTCODE
	
.CODE:
	CMP.B	#$FF,d4
	BNE.s	.NOTPOS
	MOVE.B	(a6)+,d7
	MOVE.B	(a6)+,d4
	ASL	#8,d4
	move.b	d7,d4
	MOVE	d4,OBJX(A5)
	MOVE.B	(a6)+,d7
	MOVE.B	(a6)+,d4
	ASL	#8,d4
	move.b	d7,d4
	MOVE	d4,OBJY(A5)
	BRA.s	.DRAWLOOP

.DRAWDONE:
	RTS

.NOTPOS:
	CMP.B	#$FE,d4
	BNE.s	.NOTOAMHIGH
	MOVE.B	(a6)+,OBJOAM0(A5)
	BRA.s	.DRAWLOOP
	
.NOTOAMHIGH:
	CMP.B	#$FD,d4
	BNE.s	.NOTTXTSPACING
	MOVE.B	(a6)+,d4
	ASL.w	#8,d4
	MOVE.B	(a6)+,d4
	MOVE.w	d4,TXTSPACING
	BRA.s	.DRAWLOOP
	
.NOTTXTSPACING:
.NOTCODE:
	move.w	OBJY(a5),d1				;convert the scanline to jaguar y
	add.w	#ntsc_n_vdb/2,d1
	lsl.w	#4,d1
	
	moveq	#0,d2
	move.b	OBJOAM0(a5),d2
	
	pea	(a6)
	bsr	get_width_in_d0
	move.l	(sp)+,a6
	
	asr.w	#1,d0					;width /2
	neg.w	d0
	add.w	#160,d0					;160-(width/2)
	
.line:
	moveq	#SPACE_WIDTH,d5
	SUB.B	#' ',d4
	BEQ.s	.WASSPACE
	MOVE.B	CHRTAB(PC,d4.W),d4			;get the character
	move.b	(a3,d4),d5				;get the width
	add.b	d2,d4
	ext.w	d4

	movem.l	d3-d7,-(sp)
	ADD_OL_MACRO
	lsl.w	#5,d4				;index into table entry
	movem.l	0(a4,d4.w),d3/d4/d5/d6		;now pointing to entry in table
	lsl.l	#8,d3
	add.w	d1,d4				;and the y position
	or.w	d0,d6
	movem.l	d3/d4/d5/d6,(a0)
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	(sp)+,d3-d7

.WASSPACE:
	CONVERT_FONT_WIDTH_SCALED
	moveq	#0,d4
	move.b	(a6)+,d4
	beq.s	.eol
	bpl.s	.line
	
.eol:
	subq.l	#1,a6
	BRA	.DRAWLOOP

CHRTAB:
TITLEASC:
	DC.B	$00,$26,$00,$00,$00,$00,$00,$28	;  !"#$%&'
	DC.B	$00,$00,$00,$00,$24,$00,$25,$00	; ()*+,-./
	DC.B	$0e,$1a,$1b,$1c,$1d,$1e,$1f,$20 ; 0-7
	DC.B	$21,$22,$23,$00,$00,$00,$00,$27	; 89:;<=>?
	DC.B	$00,$00,$01,$02,$03,$04,$05,$06	; @A-G
	DC.B	$07,$08,$09,$0a,$0b,$0c,$0d,$0e	; H-O
	DC.B	$0f,$10,$11,$12,$13,$14,$15,$16	; P-W
	DC.B	$17,$18,$19			; XYZ

WIDTH_TABLE:
	dc.b	12+FONT_SPACER,12+FONT_SPACER,12+FONT_SPACER,13+FONT_SPACER,12+FONT_SPACER
	dc.b	12+FONT_SPACER,16+FONT_SPACER,13+FONT_SPACER,6+FONT_SPACER,10+FONT_SPACER
	dc.b	13+FONT_SPACER,10+FONT_SPACER,19+FONT_SPACER
	dc.b	14+FONT_SPACER,18+FONT_SPACER,12+FONT_SPACER,17+FONT_SPACER,13+FONT_SPACER
	dc.b	12+FONT_SPACER,12+FONT_SPACER,12+FONT_SPACER,14+FONT_SPACER,18+FONT_SPACER
	dc.b	14+FONT_SPACER,12+FONT_SPACER,13+FONT_SPACER
	dc.b	8+FONT_SPACER,14+FONT_SPACER,12+FONT_SPACER,13+FONT_SPACER,11+FONT_SPACER
	dc.b	13+FONT_SPACER,13+FONT_SPACER,13+FONT_SPACER,13+FONT_SPACER
	dc.b	7+FONT_SPACER,8+FONT_SPACER,5+FONT_SPACER,7+FONT_SPACER,13+FONT_SPACER
	dc.b	5+FONT_SPACER
	
	EVEN

get_width_in_d0:
	pea	(a6)
	subq.w	#1,a6				; point to the char we are interested in
	moveq	#0,d0				;reset width
.lp:
	moveq	#0,d5
	move.b	(a6)+,d5			;get character
	beq.s	.eol				; if 0 or -ive then quit
	bmi.s	.eol
	sub.b	#' ',d5				;if space then add width for space
	bne.s	.not_space
	add.w	#SPACE_WIDTH,d0
	bra.s	.lp
.not_space:
	move.b	CHRTAB(pc,d5.w),d5		;get character
	move.b	WIDTH_TABLE(pc,d5.w),d5		;get the width
	add.w	d5,d0
	bra.s	.lp
	
.eol:
	mulu	TXTSPACING,d0			;d5==(width*TXTSPACING)
	asr.w	#4,d0				;d5==(width*TXTSPACING)/16

	move.l	(sp)+,a6
	rts

DRAWTEXT_DISPLAY:
	movem.l	d0-a6,-(sp)
	lea	CHRTAB(pc),a2
	move.l	load_overlay_graphics,a4
	lea	WIDTH_TABLE,a3
	
; OAM SHOULD HAVE PALETTE BITS

	MOVE.L	OBJAUX0(A5),a6
	
.DRAWLOOP:
	moveq	#0,d4
	MOVE.B	(a6)+,d4
	BEQ.s	.DRAWDONE
	BPL	.NOTCODE
	
.CODE:
	CMP.B	#$FF,d4
	BNE.s	.NOTPOS
	MOVE.B	(a6)+,d7
	MOVE.B	(a6)+,d4
	ASL	#8,d4
	move.b	d7,d4
	MOVE	d4,OBJX(A5)
	MOVE.B	(a6)+,d7
	MOVE.B	(a6)+,d4
	ASL	#8,d4
	move.b	d7,d4
	MOVE	d4,OBJY(A5)
	BRA.s	.DRAWLOOP

.DRAWDONE:
	movem.l	(sp)+,d0-a6
	RTS

.NOTPOS:
	CMP.B	#$FE,d4
	BNE.s	.NOTOAMHIGH
	MOVE.B	(a6)+,OBJOAM0(A5)
	BRA.s	.DRAWLOOP
	
.NOTOAMHIGH:
	CMP.B	#$FD,d4
	BNE.s	.NOTTXTSPACING
	MOVE.B	(a6)+,d4
	ASL.w	#8,d4
	MOVE.B	(a6)+,d4
	MOVE.w	d4,TXTSPACING
	BRA.s	.DRAWLOOP
	
.NOTTXTSPACING:
.NOTCODE:
	move.w	OBJY(a5),d1				;convert the scanline to jaguar y
	add.w	#ntsc_n_vdb/2,d1
	lsl.w	#4,d1
	
;	jsr	ADD_OL
;	move.w	number_of_items,-(sp)
;	move.l	a0,-(sp)
;	move.b	#JUMP_OVER_ME,O_TYPE(a0)
	
;	move.w	#%0100000000000000+3,d0
;	or.w	d1,d0
;	move.w	d0,(a0)

	pea	(a6)
	bsr	get_width_in_d0
	move.l	(sp)+,a6
	
	asr.w	#1,d0					;width /2
	neg.w	d0
	add.w	#160,d0					;160-(width/2)
	
.line:
	moveq	#SPACE_WIDTH,d5
	SUB.B	#' ',d4
	BEQ.s	.WASSPACE
	MOVE.B	(a2,d4.W),d4			;get the character
	move.b	(a3,d4),d5				;get the width
	add.b	#ALPHABET,d4
	ext.w	d4

	ADD_OL_DISPLAY_MACRO
	movem.l	d3-d7,-(sp)
	lsl.w	#5,d4				;index into table entry
	movem.l	0(a4,d4.w),d3/d4/d5/d6		;now pointing to entry in table
	lsl.l	#8,d3
	add.w	d1,d4				;and the y position
	or.w	d0,d6
	movem.l	d3/d4/d5/d6,(a0)
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	(sp)+,d3-d7

.WASSPACE:
	CONVERT_FONT_WIDTH_SCALED
	moveq	#0,d4
	move.b	(a6)+,d4
	beq.s	.eol
	bpl.s	.line
	
.eol:
;	move.l	number_of_items,d0
;	sub.w	(sp)+,d0
;	bne.s	.ok
;	JSR	KILL_LAST_OBJECT
;
;.ok	
;	move.l	d0,2(a0)

	subq.l	#1,a6
	BRA	.DRAWLOOP

DRAWTEXT_UN:
	lea	CHRTAB(pc),a2
	move.l	load_overlay_graphics,a4
	lea	WIDTH_TABLE,a3
	move.w	OBJX(a5),-(sp)
	move.w	OBJY(a5),-(sp)
	
; OAM SHOULD HAVE PALETTE BITS

	MOVE.L	OBJAUX0(A5),a6
	
.DRAWLOOP:
	moveq	#0,d4
	MOVE.B	(a6)+,d4
	BEQ.s	.DRAWDONE
	BPL	.NOTCODE
	
.CODE:
	CMP.B	#$FF,d4
	BNE.s	.NOTPOS
	MOVE.B	(a6)+,d7
	MOVE.B	(a6)+,d4
	ASL	#8,d4
	move.b	d7,d4
	MOVE	d4,OBJX(A5)
	MOVE.B	(a6)+,d7
	MOVE.B	(a6)+,d4
	ASL	#8,d4
	move.b	d7,d4
	MOVE	d4,OBJY(A5)
	BRA.s	.DRAWLOOP

.DRAWDONE:
	move.w	(sp)+,OBJY(a5)
	move.w	(sp)+,OBJX(a5)
	RTS

.NOTPOS:
	CMP.B	#$FE,d4
	BNE.s	.NOTOAMHIGH
	MOVE.B	(a6)+,OBJOAM0(A5)
	BRA.s	.DRAWLOOP
	
.NOTOAMHIGH:
	CMP.B	#$FD,d4
	BNE.s	.NOTTXTSPACING
	MOVE.B	(a6)+,d4
	ASL.w	#8,d4
	MOVE.B	(a6)+,d4
	MOVE.w	d4,TXTSPACING
	BRA.s	.DRAWLOOP
	
.NOTTXTSPACING:
.NOTCODE:
	move.w	OBJY(a5),d1				;convert the scanline to jaguar y
	add.w	#ntsc_n_vdb/2,d1
	lsl.w	#4,d1
	
;	jsr	ADD_OL
;	move.w	number_of_items,-(sp)
;	move.l	a0,-(sp)
;	move.b	#JUMP_OVER_ME,O_TYPE(a0)
	
;	move.w	#%0100000000000000+3,d0
;	or.w	d1,d0
;	move.w	d0,(a0)

	moveq	#0,d2
	move.b	OBJOAM0(a5),d2
	
	move.w	OBJX(a5),d0
	
.line:
	moveq	#SPACE_WIDTH,d5
	SUB.B	#' ',d4
	BEQ.s	.WASSPACE
	MOVE.B	(a2,d4.W),d4			;get the character
	move.b	(a3,d4),d5				;get the width
	add.b	d2,d4
	ext.w	d4

	ADD_OL_MACRO
	movem.l	d3-d7,-(sp)
	lsl.w	#5,d4				;index into table entry
	movem.l	0(a4,d4.w),d3/d4/d5/d6		;now pointing to entry in table
	lsl.l	#8,d3
	add.w	d1,d4				;and the y position
	or.w	d0,d6
	movem.l	d3/d4/d5/d6,(a0)
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	(sp)+,d3-d7

.WASSPACE:
	CONVERT_FONT_WIDTH_SCALED
	moveq	#0,d4
	move.b	(a6)+,d4
	beq.s	.eol
	bpl.s	.line
	
.eol:
;	move.l	number_of_items,d0
;	sub.w	(sp)+,d0
;	bne.s	.ok
;	JSR	KILL_LAST_OBJECT
;
;.ok	
;	move.l	d0,2(a0)

	subq.l	#1,a6
	BRA	.DRAWLOOP
	
	rts	

LVLTXTS:
	DC.L	LVL13TXT,LVL14TXT,LVL15TXT	;5
	DC.L	LVL4TXT,LVL5TXT,LVL6TXT		;2
	DC.L	LVL1TXT,LVL2TXT,LVL3TXT		;1
	DC.L	LVL10TXT,LVL11TXT,LVL12TXT	;4
	DC.L	LVL7TXT,LVL8TXT,LVL9TXT		;3

LVL1TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 7'
	DC.B	$FF,0-16*SPACING2/2+(320/2),0,110,0
	DC.B	'RUSHING ROULETTE'
	dc.b	0

LVL2TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 8'
	DC.B	$FF,0-12*SPACING2/2+(320/2)+$20,0,110,0
	DC.B	'DESERT STORM',0

LVL3TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 9'
	DC.B	$FF,0-13*SPACING2/2+(320/2),0,110,0
	DC.B	'BUBSY AND THE'
	DC.B	$FF,0-5*SPACING2/2+(320/2),0,140,0
	DC.B	'BEAST',0

LVL4TXT:	;123456789ABCDEF0123
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 4'
	DC.B	$FF,0-13*SPACING2/2+(320/2),0,110,0
	DC.B	'OUT ON A LIMB'
	dc.b	0

LVL5TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 5'
	DC.B	$FF,0-12*SPACING2/2+(320/2),0,110,0
	DC.B	'HIGHLY STUNG',0
	
LVL6TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$13*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 6'
	DC.B	$FF,0-13*SPACING2/2+(320/2),0,110,0
	DC.B	'JUNGLE FURVOR',0

LVL7TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$0a*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 13'
	DC.B	$FF,0-5*SPACING2/2+(320/2),0,110,0
	DC.B	'SUGAR'
	DC.B	$FF,0-9*SPACING2/2+(320/2),0,140,0
	DC.B	'AND SPICE',0
LVL8TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$0a*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 14'
	DC.B	$FF,0-11*SPACING2/2+(320/2),0,110,0
	DC.B	'ROCK AROUND'
	DC.B	$FF,0-8*SPACING2/2+(320/2),0,140,0
	DC.B	'THE CHOC',0
LVL9TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$0a*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 15'
	DC.B	$FF,0-13*SPACING2/2+(320/2),0,110,0
	DC.B	'CAT ON A HOT'
	DC.B	$FF,0-15*SPACING2/2+(320/2),0,140,0
	DC.B	'CHOCOLATE ROOF',0
	
LVL10TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$0A*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 10'
	DC.B	$FF,0-11*SPACING2/2+(320/2),0,110,0
	DC.B	'RUN SILENT,'
	DC.B	$FF,0-8*SPACING2/2+(320/2),0,140,0
	DC.B	'RUN DEEP',0

LVL11TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
   	DC.B	$FF,0-$F*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 11'
	DC.B	$FF,0-14*SPACING2/2+(320/2),0,110,0
	DC.B	'BUBBLE TROUBLE',0
	
LVL12TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
	DC.B	$FF,0-$0A*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 12'
	DC.B	$FF,0-14*SPACING2/2+(320/2),0,110,0
	DC.B	'RESERVOIR CATS',0

LVL13TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
   	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 1'
	DC.B	$FF,0-13*SPACING2/2+(320/2),0,110,0
	DC.B	'GO ASK ALICE!'
	show_version
	dc.b	0
LVL14TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
   	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 2'
	DC.B	$FF,0-15*SPACING2/2+(320/2),0,110,0
	DC.B	'TWEEDLE DUM AND'
	DC.B	$FF,0-14*SPACING2/2+(320/2),0,140,0
	DC.B	'TWEEDLE DUMMER',0

LVL15TXT:	;123456789ABCDEF
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACING2&$ff00)>>8,(SPACING2&$ff)
	dc.b	$fe,ALPHABET
	
   	DC.B	$FF,0-$09*SPACING2/2+(320/2),0,80,0
	DC.B	'CHAPTER 3'
	DC.B	$FF,0-18*SPACING2/2+(320/2),0,110,0
	DC.B	"ALICE DOESN'T LIVE"
	DC.B	$FF,0-21*SPACING2/2+(320/2),0,140,0
	DC.B	'AROUND HERE ANYMORE.',0

	even