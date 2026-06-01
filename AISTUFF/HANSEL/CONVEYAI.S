C_FRAME		equ	107
CONVEROR_SPEED	equ	-2
CONVEYOR_RATE	equ	10
CONVEYOR_FRAMES	equ	16

CONVEYORENDAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL
	
	jsr	OBJECTISLAND
	
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.bub_not_on_me
	
	add.w	#CONVEROR_SPEED,BUBX
.bub_not_on_me
	rts

CONVEYORMIDAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL
	sf	OBJFRAME(A5)
	
	jsr	OBJECTISLAND
	
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	beq.s	.bub_not_on_me
	
	add.w	#CONVEROR_SPEED,BUBX
.bub_not_on_me
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#CONVEYOR_RATE-1,OBJAUX0(a5)

	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	move.b	#CONVEYOR_FRAMES-1,OBJAUX1(a5)
.same_frame
.no_wrap
	rts
	move.b	OBJAUX1(a5),OBJFRAME(a5)
	IFNE	DETECTMODE
	jsr	DRAW_COMPLEX_SPRITE
	sf	OBJFRAME(A5)
	rts
	ELSE
	jmp	DRAW_COMPLEX_SPRITE
	ENDC

conveyorend_dma
conveyormid_dma
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4
	dc.l	.frame5
	dc.l	.frame6
	dc.l	.frame7
	dc.l	.frame8
	dc.l	.frame9
	dc.l	.framea
	dc.l	.frameb
	dc.l	.framec
	dc.l	.framed
	dc.l	.framee
	dc.l	.framef

.frame0	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+0
.frame1	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+1
.frame2	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+2
.frame3	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+3
.frame4	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+4
.frame5	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+5
.frame6	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+6
.frame7	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+7
.frame8	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+8
.frame9	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+9
.framea	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+10
.frameb	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+11
.framec	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+12
.framed	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+13
.framee	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+14
.framef	dc.w	1,0,0,-1
	dc.w	-16,0,C_FRAME+15

CONVEYORENDMAP
CONVEYORMIDMAP
	dc.w	0,0
	dc.l	0
	dc.w	20,40
	dc.w	4,4
	rept	4
	dc.w	0,0
	endr
