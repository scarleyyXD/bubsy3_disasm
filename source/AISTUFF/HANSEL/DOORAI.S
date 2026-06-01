DOOR1_HEIGHT		equ	3
DOOR3_HEIGHT		equ	3

DOOR1_SWITCH_MASK	equ	%00000001		;== switch 1 to activate the door 1
DOOR2_SWITCH_MASK	equ	%00000010		;== switch 2 to activate the door 2
DOOR3_SWITCH_MASK	equ	%00000100		;== switch 3 to activate the door 3
DOOR4_SWITCH_MASK	equ	%00001000		;== switch 4 to activate the door 4
DOOR5_SWITCH_MASK	equ	%00010000		;== switch 5 to activate the door 5
DOOR6_SWITCH_MASK	equ	%00100000		;== switch 6 to activate the door 6
DOOR7_SWITCH_MASK	equ	%01000000		;== switch 7 to activate the door 7
DOOR8_SWITCH_MASK	equ	%10000000		;== switch 8 to activate the door 8

HANSEL_DOOR_BLOCK	equ	106

.macro	HANSEL_DOOR_KILL_BUBSY
	jsr	NOBOPCOLLIDE
	bcc.s	.nopopbubs
	clr.w	INVTIMER
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.nopopbubs:
	.endm

DOOR1AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	moveq	#DOOR1_SWITCH_MASK,d1
GLOBALDOOR:
	and.b	SWITCHES,d1
	bne	.no_moving_door
	
	HANSEL_DOOR_KILL_BUBSY

	jsr	DRAW_COMPLEX_SPRITE
.no_moving_door:
	rts

******************************************************************

DOOR2AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR2_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

DOOR3AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR3_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

DOOR4AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR4_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

DOOR5AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR5_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

DOOR6AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR6_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

DOOR7AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR7_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

DOOR8AI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	moveq	#DOOR8_SWITCH_MASK,d1
	bra	GLOBALDOOR

******************************************************************

hansel_door_dma:
	dc.l	.door

.door:
	dc.w	1,0,-16,32
	dc.w	0,0,HANSEL_DOOR_BLOCK

HANSELDOORMAP:
	Soff	-10,16,-12,0,-12,-16,-12,-31,30,0,30,-16,30,-31
