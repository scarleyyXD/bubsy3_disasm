MER_WAIT	equ	7
MER_FRAMES	equ	5

MER_MOVE_DX	equ	6
MER_TURN_DX	equ	(MER_MOVE_DX+30)

.macro	MERMAID_KILL_BUBSY
	move.w	#$0401,d6				;see if BUBSY has bopped the cactus
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

MERMAIDAI:
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY					;do not do a small one
	
	MERMAID_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#MER_WAIT-1,OBJAUX0(a5)
	
	sub.b	#1,OBJFRAME(a5)
	bpl.s	.no_wrap
	move.b	#MER_FRAMES-1,OBJFRAME(a5)
.no_wrap:
	move.w	#MER_TURN_DX,d1
	move.w	#MER_MOVE_DX,d6
	move.w	OBJY(a5),d2
	tst.b	OBJOAM0(a5)
	bne.s	.going_left
	neg.w	d1
	neg.w	d6
.going_left:
	add.w	OBJX(a5),d1
	jsr	GETATTRIB
	and.w	#WALL_CTRL,d0
	beq.s	.no_change
	eor.b	#8,OBJOAM0(a5)
	bra.s	.same_frame
.no_change:
	add.w	d6,OBJX(a5)
.same_frame:
	jmp	DRAW_COMPLEX_SPRITE
	
mermaid_dma:
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1
	dc.l	.frame0
	
.frame0:	dc.w	1,0,0,0
	dc.w	-26,-18,91
.frame1:	dc.w	1,0,0,0
	dc.w	-30,-16,92
.frame2:	dc.w	1,0,0,0
	dc.w	-36,-13,93
.frame3:	dc.w	1,0,0,0
	dc.w	-34,-14,94
.frame4:	dc.w	1,0,0,0
	dc.w	-28,-14,95

MERMAIDMAP:
	Soff	0,0,17,+10,-9,5,-4,-12,4,3,21,-2,38,-2			;4
	Soff	0,0,-18,11,-29,-7,-11,-3,6,3,21,-6,35,-13		;3
	Soff	0,0,-11,1,-18,8,18,8,13,-2,27,-7,40,-10			;2
	Soff	0,0,-26,-2,-16,9,2,12,8,-2,23,-2,39,-2			;1
	Soff	0,0,-19,-9,-21,6,-7,13,8,-3,14,-12,32,6			;0
