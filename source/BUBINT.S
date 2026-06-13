VBlank:
NMI_ROUTINE:
	sf.b	VBlankDone

; ************************************* Do or don't do remainder of vblank

	MOVE.B	VBLANKFLAG,D0	
	AND.B	#SNESVBLDISABLE,D0
	BEQ.w	.DOSNESVBL

	rts

.DOSNESVBL:
	moveq	#0,d0
	move.b	NMIVECSEL,d0
	add.b	d0,d0
	move.L	.NMIVECTAB(PC,d0.W),a0
	jmp	(a0)

.NMIVECTAB:
	dc.L	GAMENMI,TITLENMI,COUNTNMI,LOADLEVELNMI,DODMANMI
	DC.L	LOGONMI,TITLOGONMI

LOADLEVELNMI:
	jsr	NEW_OL

	MOVEM.L	A2/A5,-(SP)
	MOVE.W	BUBX,-(SP)
	MOVE.W	BUBY,-(SP)
	MOVE.W	TEMP5,-(SP)
	MOVE.W	TEMP6,-(SP)

	jsr	FADER

	MOVE.L	LOADCODE,A0
	JSR	(A0)

	; MUST BE DONE AFTER TEXT IS DRAWN

	JSR	ANIMATEBUBFAR

	LEA	BUBOBJ,A5
	MOVE.B	OBJFRAME(A5),D0
	MOVE.W	OBJOAM0(A5),-(SP)
	MOVE.W	D0,-(SP)
	MOVE.L 	OBJAUX0(A5),-(SP)

	CLR.B	OBJFRAME(A5)
	MOVE.W	#$E680,OBJOAM0(A5)

	MOVE.W	LEVEL,D0
	ASL.W	#2,D0
	LEA	LVLTXTS,A0
	MOVE.L	(A0,D0.W),OBJAUX0(A5)
	JSR	DRAWTEXT
	
	tst.w	PLAYERS
	beq.s	.only_one_player
	moveq	#"1",d0
	add.w	PLAYER,d0
	move.b	d0,player_number_in_text
	move.l	#player_text_indicator,OBJAUX0(a5)
	jsr	DRAWTEXT
	
.only_one_player:
	MOVE.L 	(SP)+,OBJAUX0(A5)
	MOVE.W	(SP)+,D0
	MOVE.W	(SP)+,OBJOAM0(A5)
	MOVE.B	D0,OBJFRAME(A5)

	MOVE.W	LOADX,d0
	add.w	WINDX,d0
	move.w	d0,BUBX
	MOVE.W	LOADY,d0
	add.w	WINDY,d0
	move.w	d0,BUBY
	JSR	SETUPBUBSY

	MOVE.W	(SP)+,TEMP6
	MOVE.W	(SP)+,TEMP5
	MOVE.W	(SP)+,BUBY
	MOVE.W	(SP)+,BUBX
	MOVEM.L	(SP)+,A2/A5

GAMENMI:
COUNTNMI:
TITLENMI:
DODMANMI:
	addq.w	#1,NUMVBLS
LOGONMI:
	rts

TITLOGONMI:
	jsr	NEW_OL
	lea	LOAD_LEVEL_SPRITES_HERE,a0
	move.w	#(320-182)/2,d0
	move.w	#(240-142)/2,d1
	moveq	#0,d4
	jmp	print_a_sprite_normal

SPACINGPP	equ	$10

player_text_indicator:
	DC.B	$FD						;,<SPACING2,>SPACING2
	dc.B	(SPACINGPP&$ff00)>>8,(SPACINGPP&$ff)
	dc.b	$fe,ALPHABET
	DC.B	$FF,0-12*SPACING2/2+(320/2),0,$80+$30,0
	dc.b	"PLAYER:"	
player_number_in_text:	
	dc.b	"1",0
	even
