S_BMO			equ	0
S_SBMO			equ	1
S_GPO			equ	2
S_BO			equ	3
S_SO			equ	4
Q_BMO			equ	5
Q_SBMO			equ	6
Q_GPO			equ	7
Q_BO			equ	8
Q_SO			equ	9
;JUMP_ME		equ	10
;JUMP_ME1		equ	11
S_BMO_BIG		equ	12
;JUMP_OVER_ME	equ	13
O_BMO			equ	14

VIDINT			equ	1
GPUINT			equ	2
STOPINT			equ	4
TIMERINT		equ	8
DSPINT			equ	16
MOUSEINT		equ	32

TIMERINTBIT		equ	3
INTMASK1		equ	VIDINT

TITLE_MOD_SIZE	equ	233954		;length in bytes

MAX_NUMBER_OF_MAP_COMBINATIONS	equ	30000

.macro	ADD_OL_MACRO
	move.l	olist_pointer,a0
	add.l	#OBJ_SIZE,olist_pointer
	addq.w	#1,number_of_items+2
	.endm

.macro	ADD_OL_DISPLAY_MACRO
	move.l	display_olist_pointer,a0
	add.l	#OBJ_SIZE,display_olist_pointer
	addq.w	#1,display_number_of_items+2
	.endm

.macro	ADD_OL_MACRO_NO_ADD
	move.l	olist_pointer,a0
	add.l	#OBJ_SIZE,olist_pointer
	.endm

.macro	INC_OL_MACRO
	addq.w	#1,number_of_items+2
	.endm
	
.macro	FACE_CORRECT_WAY
	tst.b	OBJOAM0(a5)
	bpl.s	.no_need
	moveq	#0,d7
	move.w	OBJX(A5),d0
	cmp.w	BUBY,d0
	blt.s	.flip
	moveq	#8,d7
.flip:
	move.b	d7,OBJOAM0(a5)
.no_need:
	.endm
