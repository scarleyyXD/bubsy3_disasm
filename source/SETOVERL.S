TOP_Y		EQU	((28)+ntsc_n_vdb)*8
BOTTOM_Y	EQU	((disp_height-40)*2+ntsc_n_vdb)*8

EX_NUMBER	EQU	0
YARNX_NUMBER	EQU	1
BUBSYX_NUMBER	EQU	YARNX_NUMBER
CLOCKF_NUMBER	EQU	2
CLOCKC_NUMBER	EQU	3
BUBSYH_NUMBER	EQU	4
DIGITS		EQU	5
ALPHABET	EQU	(DIGITS+10+6)
ALPHABET1	EQU	(ALPHABET+41)
BALLS_OF_WOOL	EQU	(ALPHABET1+41)
YARNB_NUMBER	EQU	BALLS_OF_WOOL
BALL_OF_WOOL_EXPLOSION	equ	(BALLS_OF_WOOL+32)
MOD_ICON	equ	BALL_OF_WOOL_EXPLOSION+3
SFX_ICON	equ	MOD_ICON+1

SCR_OFF		equ	16

EX_X		EQU	(SCR_OFF+16)
YARNB_X		EQU	(SCR_OFF+16-2)
CLOCKF_X	EQU	(SCR_OFF+127-16)
BUBSYH_X	EQU	(SCR_OFF+256-16)

SCORE_X1	EQU	EX_X+8
YARNX_X		EQU	YARNB_X+(16+4)
YARN_X1		EQU	YARNX_X+8+1
TIME_X1		EQU	CLOCKF_X+16
CLOCKC_X	EQU	TIME_X1+7+2
TIME_X2		EQU	CLOCKC_X+6
TIME_X3		EQU	TIME_X2+8
TIME_X4		EQU	TIME_X3+8
BUBSYX_X	EQU	BUBSYH_X+16
LIVES_X1	EQU	BUBSYX_X+8+1

SETUPOVERLAYS:
	moveq	#OVERLOFF,D0
	and.B	VBLANKFLAG,D0
	BEQ.s	.OVERLON
	; SAVE CURRENT SCB POINTER
	RTS

.OVERLON:
	lea	TIME,a6
	lea	CLOCKCOUNT,a3
	move.w	STIMER,d4
		
	; ROLL THE DSCORE
	; DSCORE = DSCORE+(SCORE-DSCORE/4)

.ROLLSCORE:
	lea	SCORE+3,a0
	lea	DSCORE+3,a1
	lea	TEMP0+3,a2
	
	moveq	#0,d2
	AND	#%01111,CCR		; CLEAR X FLAG

	MOVE.B	(a0),D0
	MOVE.B	(a1),D1
	SBCD	D1,D0
	MOVE.B	D0,(a2)

	MOVE.B	-(a0),D0
	MOVE.B	-(a1),D1
	SBCD	D1,D0
	MOVE.B	D0,-(a2)

	MOVE.B	-(a0),D0
	MOVE.B	-(a1),D1
	SBCD	D1,D0
	MOVE.B	D0,-(a2)

	MOVE.B	-(a0),D0
	MOVE.B	-(a1),D1
	SBCD	D1,D0
	MOVE.B	D0,-(a2)

	MOVE.L 	(a2),D0
	BEQ.s	.NOROLL
	LSR.L	#4,D0
	BNE.s	.NOT0
	ADDQ.B	#1,D0

.NOT0:
	MOVE.L	D0,(a2)
	AND	#%01111,CCR		; CLEAR X FLAG

	MOVE.B	3(a1),D1
	ABCD	D0,D1
	MOVE.B	D1,3(a1)

	MOVE.B	2(a2),D0
	MOVE.B	2(a1),D1
	ABCD	D0,D1
	MOVE.B	D1,2(a1)

	MOVE.B	1(a2),D0
	MOVE.B	1(a1),D1
	ABCD	D0,D1
	MOVE.B	D1,1(a1)

	MOVE.B	(a2),D0
	MOVE.B	(a1),D1
	ABCD	D0,D1
	MOVE.B	D1,(a1)

.NOROLL:
;	ADD_OL_MACRO_NO_ADD
;	move.l	number_of_items,-(sp)
;	move.l	a0,-(sp)
;	move.b	#JUMP_OVER_ME,O_TYPE(a0)
;	INC_OL_MACRO
;	move.w	#%0100000000000000+3|(TOP_Y),(a0)

	MOVEQ	#SCORE_X1,D0
	MOVE.w	#TOP_Y,D1
	MOVE.L	(a1),D7
	MOVEq	#8-1,D6		; DO 8 DIGITS

.KILLLEADING00:
	ROL.L	#4,D7
	moveq	#$F,D2
	and.B	D7,D2
	bne.s	.LOADSCORE
	DBNE	D6,.KILLLEADING00
	moveq	#0,d6

.LOADSCORE:
	ADDq.W	#DIGITS,D2						;OFFSET IN CHARACTER FILE
	ADD_OL_MACRO_NO_ADD						;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	ADDQ.W	#8,D0
	ROL.L	#4,D7
	moveq	#$F,D2
	and.B	D7,D2
	DBRA	D6,.LOADSCORE

.SCOREDONE:
	MOVEq	#EX_NUMBER,D2
	MOVEq	#EX_X,D0
	MOVE	#TOP_Y,D1

	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
;	move.l	(sp)+,a0
;	move.l	number_of_items,d0
;	sub.l	(sp)+,d0
;	move.l	d0,2(a0)

;	ADD_OL_MACRO_NO_ADD
;	move.l	number_of_items,-(sp)
;	move.l	a0,-(sp)
;	move.b	#JUMP_OVER_ME,O_TYPE(a0)
;	
;OVER1	move.w	#%0100000000000000+3|(BOTTOM_Y-(1<<4)),(a0)
;	INC_OL_MACRO

	MOVE.B	d4,D0			;UPDATE YARN COUNTER
	ADDq.B	#1,D0
	AND.B	#%11,D0
	BNE.s	.YARN10
	moveq	#%11100,D0
	and.w	d4,D0
	LSR	#2,D0
	MOVE.B	D0,YARNCOUNT
	BNE.s	.YARN00

	ADDq	#1,YARNPALETTE

.YARN00:						;SET UP PALETTE OF YARN BALL
	moveq	#BONUSFLAG,D0
	and.B	GAMEFLAG1,D0
	BEQ.s	.NOBONUS
	MOVE	#20*8,D0
	BRA.s	.BONUS

.NOBONUS:
	MOVE	LEVEL,D0

.BONUS:
	moveq	#3,d1
	ADD	YARNPALETTE,D0
	AND	d1,d0
	ASL	d1,D0
	
	moveq	#0,d1
	MOVE.B	YARNCOUNT,D1
	add.w	d0,d1
	MOVE.L	D1,YARNADDRESS
	
.YARN10:						; REWRITE OF DRAW SCORE LEFT JUST
	MOVEQ	#YARN_X1,D0

OVER2:
	MOVE	#BOTTOM_Y,D1

	MOVE	YARNS,D7 			; LOAD SCORE ACCUM
	BNE.s	.YARNNOTONLY0
	MOVEQ	#0,D2
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
	BRA.s	.YARNSDONE

.YARNNOTONLY0:	
	MOVEq	#4-1,D6				; DO 4 DIGITS

.KILLLEADING01:
	ROL	#4,D7
	moveq	#$f,d2
	and.B	D7,D2
	bne.s	.LOADYARNS
	DBNE	D6,.KILLLEADING01
	moveq	#0,d6

.LOADYARNS:
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
	ADDQ.w	#8,D0				; NEXT SCB
	ROL	#4,D7
	moveq	#$F,D2
	and.B	D7,D2
	DBRA	D6,.LOADYARNS

.YARNSDONE:
	moveq	#TIMEFLAG,D0
	and.B	GAMEFLAG1,D0
	beq.s	SHOWCLOCK
	MOVE	(a6),D0
	BNE.s	.NOTOUTOFTIME			; OUT OF TIME, WAIT UNTIL BUBSY IS ANCHORED TO DO DEMISE
	move.b	BUBSYFLAGS,d1
	moveq	#ANCHORFLAG,D0
	and.B	d1,D0
	BEQ.s	.TIME00
	moveq	#DEADFLAG,D0
	and.B	d1,D0
	BNE.s	.TIME00
	MOVE.B	#NOTIMESTATE,BUBSTATE
	BRA.s	.TIME00

.NOTOUTOFTIME:
	ADDQ.B	#1,(a3)
	MOVE.B	(a3),D0
	CMP.B	FrameRate+1,D0

	if	INFTIME
	bra.s	.TIME00
	endif
	
	BLO.s	.TIME00
	sf	(a3)
	MOVEq	#1,D1
	AND	#%01111,CCR			; CLEAR X FLAG
	MOVE.B	1(a6),D0
	SBCD	D1,D0	
	MOVE.B	D0,1(a6)
	MOVE.B	(a6),D0
	sf	D1
	SBCD	D1,D0	
	MOVE.B	D0,(a6)				;CHECK IF SECONDS HAVE CYCLED BACK TO 99, IF SO, MAKE 59
	MOVE.B	1(a6),D0
	CMP.B	#$60,D0
	BLO.s	.TIME00
	MOVE.B	#$59,1(a6)

.TIME00:
						; FLASH CLOCK AT DIFFERENT RATES BASED ON REMAINING TIME
	MOVE.B	(a6),D0
	BNE.s	SHOWCLOCK
	MOVE.B	1(a6),D0
	CMP.B	#$10+1,D0
	BGE.s	.MORETHAN10

.STROBE:
	moveq	#%010,D0
	and.B	d4,D0
	BEQ	CLOCKEND			; SKIP REST TO NOT DRAW CLOCK
	BRA.s	SHOWCLOCK

.MORETHAN10:
	CMP.B	#$20+1,D0
	BGE.s	.MORETHAN20
	moveq	#%0100,D0
	and.B	d4,D0
	BEQ	CLOCKEND			; SKIP REST TO NOT DRAW CLOCK

.MORETHAN20:
SHOWCLOCK:
	moveq	#$f,d2
	and.B  (a6)+,D2
	
OVER3:
	MOVE	#BOTTOM_Y,D1
	MOVE.W	#TIME_X1,D0
	
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO

	MOVE.B  (a6),D2
	AND	#$F0,D2
	LSR.B	#4,D2				; LOAD DIGIT SCB

	MOVE.W	#TIME_X2,D0
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO

	moveq	#$f,d2
	and.B  (a6),D2				; LOAD DIGIT SCB
	MOVE.W	#TIME_X3,D0
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO

CLOCKEND:
	moveq	#1,d3
	MOVE.W	#LIVES_X1,D0
	move.b	LIVES,d2
	AND	#%01111,CCR			; CLEAR X FLAG
	abcd	d3,d2
	move.w	d2,-(sp)
	AND.w	#$F0,D2
	BEQ.s	LT10LIVES

OVER5:
	MOVE	#BOTTOM_Y,D1
	LSR	#4,D2
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
	addq.w	#8,d0

LT10LIVES:
OVER4:
	MOVE	#BOTTOM_Y,D1
	moveq	#$f,d2
	and.w	(sp)+,d2
	ADDq.W	#DIGITS,D2			;OFFSET IN CHARACTER FILE
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
	LEA	OVERLSCB(PC),A5
	
	MOVE.W	(A5)+,D2
	MOVE.W	(A5)+,D0
	MOVE.W	(A5)+,D1
	add.l	YARNADDRESS,d2

	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
	moveq	#(END_OF_LSCB-OVERLSCB)/6-2,d7	;-1 for one above just printed
.LOOP:
	MOVE.W	(A5)+,D2
	MOVE.W	(A5)+,D0
	MOVE.W	(A5)+,D1
	
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	movem.w	d0-d2,(a0)
	move.b	#O_BMO,O_TYPE(a0)		;indicate type of object
	INC_OL_MACRO
	
	dbf	d7,.LOOP

;	move.l	(sp)+,a0
;	move.l	number_of_items,d0
;	sub.l	(sp)+,d0
;	move.l	d0,2(a0)

	RTS

PRINT_OVERLAY_NUMBER:
	ADDq.W	#DIGITS,D2						;OFFSET IN CHARACTER FILE

PRINT_OVERLAY_CHARACTER:
	lsl.w	#5,d2				;index into table entry
	movem.l	0(a4,d2.w),d2/d3/d4/d5			;now pointing to entry in table
	lsl.l	#8,d2
	add.w	d1,d3				;and the y position
	or.w	d0,d5
	ADD_OL_MACRO_NO_ADD				;a0 returns with address to make an object at
	move.b	#Q_BMO,O_TYPE(a0)		;indicate type of object
	movem.l	d2/d3/d4/d5,(a0)
	INC_OL_MACRO
	rts

OVER_TABLE_START:
OVERLSCB:
	DC.W	YARNB_NUMBER,YARNB_X,BOTTOM_Y				;	YARN BALL
	DC.W	YARNX_NUMBER,YARNX_X,BOTTOM_Y+(4<<4)		;	YARN X
	DC.W	CLOCKF_NUMBER,CLOCKF_X,BOTTOM_Y				;	CLOCK FACE
	DC.W	CLOCKC_NUMBER,CLOCKC_X,BOTTOM_Y+(3<<4)		;	CLOCK COLON
	DC.W	BUBSYH_NUMBER,BUBSYH_X,BOTTOM_Y				;	BUBSY'S HEAD
	DC.W	BUBSYX_NUMBER,BUBSYX_X,BOTTOM_Y+(4<<4)		;	BUBSY X
END_OF_LSCB:
OVER_TABLE_END: