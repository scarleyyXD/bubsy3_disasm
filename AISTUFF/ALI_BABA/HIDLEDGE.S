
;	OBJECT	%0000000000000000,HIDLEDGEAI,hidledge_dma,HIDLEDGEMAP,$00,$00,$00,$00,$00,$00			;HIDDEN LEDGE

LEDGE_FRAME		equ	172
HID_WOBBLE_SPEED	equ	3


HIDLEDGEAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL			; in range y
	
	move.w	INVTIMER,-(sp)
	move.w	SHADOWTIMER,-(sp)
	clr.w	INVTIMER
	clr.w	SHADOWTIMER
	jsr	NOBOPCOLLIDE			;has BUBSY hit this area
	bcc.s	.no_detection
	
	move.w	BUBVY,d0			;and is he moving up screen
	bpl.s	.falling_down_screen
	

	
	move.l	#VIEWLEDGEAI,OBJAI(a5)
	
	MOVE.w	#SCRKEY,D7			;tell midyarn to mid coin in script, find self
	MOVE.L	#SCRIPT,A0
.LOOKING
	ADDQ.w	#6,D7	; SCRLEN
	MOVE.w	OBJKEY(A5),D0
	CMP.w	(A0,D7.W),D0
	BNE.s	.LOOKING
	ADD.w	#$0100,(A0,D7.W)		;change mode to not invisible
	move.b	#HID_WOBBLE_SPEED-1,OBJAUX3(A5)
	move.b	#8,OBJAUX5(a5)
	clr.w	BUBVY				;chenge BUBSY's velocity so that he will fall
.falling_down_screen
.no_detection
	move.w	(sp)+,SHADOWTIMER
	move.w	(sp)+,INVTIMER
	rts
	


VIEWLEDGEAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL
	jsr	OBJECTISLAND
	
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0

	cmp.b	OBJAUX4(a5),d0
	beq.s	.both_same
	moveq	#2,d1
	tst.b	d0
	beq.s	.going_up
	neg.w	d1
.going_up
	sub.w	d1,OBJY(a5)	
	move.b	d0,OBJAUX4(a5)			;save new state of flags
.both_same
	moveq	#0,d0
	move.b	OBJAUX5(a5),d0
	beq.s	.no_y_change
	addq.b	#1,OBJAUX3(a5)
	cmp.b	#HID_WOBBLE_SPEED,OBJAUX3(a5)
	bne.s	.no_y_change
	sf	OBJAUX3(a5)
	subq	#1,d0
	move.b	d0,OBJAUX5(a5)
	add.w	d0,d0
	move.w	.y_tab(pc,d0.w),d0
	add.w	d0,OBJY(a5)
.no_y_change	
	move.b	#1,OBJFRAME(a5)			;change map so that it is now visible
	jmp	DRAW_COMPLEX_SPRITE
	
	
	
.y_tab
	dc.w	-4,-2,0,2,4,-2,2,0
	
hidledge_dma
	dc.l	.ledge1				;never draw frame 0
	dc.l	.ledge1


.ledge1	dc.w	1,0,0,-1			;never flipped
	dc.w	-16,0,LEDGE_FRAME


HIDLEDGEMAP
	dc.w	0,0
	dc.l	0
	
	dc.w	-16,-16
	dc.w	0,-16
	dc.w	16,-16
	dc.w	-16,0
	dc.w	0,0
	dc.w	16,0
	
	
	dc.w	0,0
	dc.l	0
	dc.w	16,32
	dc.w	4,4
	rept	4
	dc.w	0,0
	endr




