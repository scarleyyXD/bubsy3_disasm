CAVE_DOOR_HEIGHT	equ	5
CAVE_SWITCH_MASK	equ	%0000001		;== switch 1 to activate the cave door

ALI_DOOR_BLOCK_VERT	equ	173

GENIE_DOOR_HEIGHT	equ	5
GENIE_SWITCH_MASK	equ	%00000010		;== switch 3 to activate the door to the genie

HORI_DOOR_WIDTH		equ	5
HORI_SWITCH_MASK	equ	%00001000		;== switch 4 to activate the door to the genie

.macro	ADOOR_KILL_BUBSY
	jsr	NOBOPCOLLIDE
	bcs	.popbubs
	.endm

GENIEDOORAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL				; in range y

	moveq	#GENIE_SWITCH_MASK,d1
	and.b	SWITCHES,d1
	bne	.no_moving_door
	
	ADOOR_KILL_BUBSY

.return_to_logic:
	bsr	DRAW_COMPLEX_SPRITE
.no_moving_door:
	rts
.popbubs:
	clr.w	INVTIMER
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
	bra	.return_to_logic
	
cavedoor_dma:
geniedoor_dma:
horidoor_dma:
	dc.l	.door
	
.door:
	dc.w	1,0,-16,32
	dc.w	0,0,ALI_DOOR_BLOCK_VERT

HORIDOORMAP:
CAVEDOORMAP:
GENIEDOORMAP:
	dc.w	0,0
	dc.l	0
	dc.w	-15,0,-15,-16,-15,-31
	dc.w	15,0,15,-16,15,-31

CAVEDOORAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPYSMALL				; in range y
	
	moveq	#CAVE_SWITCH_MASK,d1
	and.b	SWITCHES,d1
	bne	.no_moving_door
	
	ADOOR_KILL_BUBSY

.return_to_logic:
	bsr	DRAW_COMPLEX_SPRITE
.no_moving_door:
	rts
.popbubs:
	clr.w	INVTIMER
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
	bra	.return_to_logic

HORIDOORAI:
	jsr	DOINITIALDMA			;check has been set up
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPYSMALL				; in range y
	
	moveq	#HORI_SWITCH_MASK,d1
	and.b	SWITCHES,d1
	bne	.no_moving_door
	
	ADOOR_KILL_BUBSY

.return_to_logic:
	bsr	DRAW_COMPLEX_SPRITE
.no_moving_door:
	rts
.popbubs:
	clr.w	INVTIMER
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
	bra	.return_to_logic
