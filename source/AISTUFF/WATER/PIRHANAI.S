.macro	PIRHANNA_KILL_BUBSY
	move.w	#$0601,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

.macro	PMAP
	if \1=0
	Soff	30,20,0,0,21,14,46,23,54,4,25,-15,47,-20
	endif
	if \1=1
	Soff	10,21,0,0,12,16,30,24,30,0,12,-13,28,-20
	endif
	if \1=2
	Soff	3,0,0,0,-13,13,-9,30,11,13,9,30,0,46
	endif
	if \1=3
	Soff	30+10,34,0,0,3,-25,18,-4,18,-23,36,2,36,-30
	endif
	.endm

PIR_SPEED	equ	6
PIR_SMELL_RANGE	equ	100
PIR_TURN_FRAMES	equ	3
PIR_KILL_FRAMES	equ	6
PIR_MOVE_X	equ	9
PIR_WALL_X	equ	30
PIR_WALL_Y	equ	0
PIR_SMELL_Y	equ	60

PIR_KILL_RANGE	equ	PIR_SMELL_RANGE

PIRHANNAAI:
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY					;do not do a small one
	
	PIRHANNA_KILL_BUBSY

PIR_PROCESS_NOW:
	subq.b	#1,OBJAUX0(a5)
	bmi.s	.move_me
	jmp	DRAW_COMPLEX_SPRITE
.move_me:
	move.b	#PIR_SPEED-1,OBJAUX0(A5)
	
	moveq	#8,d1
	move.w	BUBX,d0
	sub.w	OBJX(A5),d0
	bpl.s	.bubsy_to_right
	moveq	#0,d1
	neg.w	d0

.bubsy_to_right:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.normal_ai			; if dead than no detection

	cmp.w	#PIR_SMELL_RANGE,d0		; only turn if between specific rnage
	bge.s	.normal_ai
	
	move.w	OBJY(a5),d0	
	sub.w	BUBY,d0
	bpl.s	.posi
	neg.w	d0
.posi:
	cmp.w	#PIR_SMELL_Y,d0
	bge.s	.normal_ai
	
	cmp.b	OBJOAM0(A5),d1
	beq.s	.facing_bubsy
	
.turn_fish:
	move.l	#PIRHANNA_TURNAI,OBJAI(a5)
	move.l	#PIRHANNA_TURNMAP,OBJMAP(a5)
	move.l	#pirhanna_turndma,OBJINITDMA(A5)
	move.b	#PIR_TURN_FRAMES-1,OBJFRAME(A5)
	bra	PIR_PROCESS0
.facing_bubsy:
	move.l	#PIRHANNA_KILLAI,OBJAI(a5)
	move.l	#PIRHANNA_KILLMAP,OBJMAP(a5)
	move.l	#pirhanna_killdma,OBJINITDMA(A5)
	move.b	#PIR_KILL_FRAMES-1,OBJFRAME(A5)
	bra	PIR_PROCESS1
.normal_ai:
	moveq	#-PIR_MOVE_X,d3
	move.w	#-PIR_WALL_X,d1
	move.w	#PIR_WALL_Y,d2
	tst.b	OBJOAM0(a5)
	beq.s	.going_left
	neg.w	d3
	neg.w	d1
.going_left:
	add.w	d3,OBJX(A5)
	add.w	OBJX(A5),d1
	add.w	OBJY(A5),d2
	jsr	GETATTRIB
	and.w	#WALL_CTRL,d0
	bne.s	.turn_fish
	
	eor.b	#1,OBJFRAME(A5)
	JMP	DRAW_COMPLEX_SPRITE

pirhanna_dma:
	dc.l	.frame0
	dc.l	.frame1
	
.frame0:	dc.w	2,0,0,0
	dc.w	-29,-34,48
	dc.w	-9,-43,49
	
.frame1:	dc.w	1,0,0,0
	dc.w	-29,-44,50

PIRHANNAMAP:
	PMAP	0
	PMAP	0

******************************************************************

PIRHANNA_TURNAI:
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY					;do not do a small one
	
	PIRHANNA_KILL_BUBSY

PIR_PROCESS0:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.just_draw
.move_me:
	move.b	#PIR_SPEED-1,OBJAUX0(A5)
	subq.b	#1,OBJFRAME(A5)
	bne.s	.no_flip
	eor.b	#8,OBJOAM0(A5)
.just_draw:
	jmp	DRAW_COMPLEX_SPRITE
.no_flip:
	bpl.s	.just_draw
	
	move.l	#PIRHANNAAI,OBJAI(a5)			;reset ai
	move.l	#PIRHANNAMAP,OBJMAP(a5)
	move.l	#pirhanna_dma,OBJINITDMA(A5)
	sf	OBJFRAME(A5)
	bra	PIR_PROCESS_NOW
	
PIRHANNA_TURNMAP:
	PMAP	1
	PMAP	2
	PMAP	1

pirhanna_turndma:
	dc.l	.frame0		
	dc.l	.frame1		
	dc.l	.frame0		

.frame0:	dc.w	1,0,0,0
	dc.w	-11,-43,51

.frame1:	dc.w	1,0,0,0
	dc.w	-16,-45,52

**************************************************************************

PIRHANNA_KILLAI:
	JSR	OBJRANGEBIG
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPY					;do not do a small one
	
	PIRHANNA_KILL_BUBSY

PIR_PROCESS1:
	subq.b	#1,OBJAUX0(a5)
	bmi.s	.move_me
	jmp	DRAW_COMPLEX_SPRITE
.move_me:
	move.b	#PIR_SPEED-1,OBJAUX0(A5)

	subq.b	#1,OBJFRAME(A5)
	bpl.s	.no_wrap
	move.b	#PIR_KILL_FRAMES-1,OBJFRAME(A5)
.no_wrap:
	jsr	DRAW_COMPLEX_SPRITE
	
	moveq	#-PIR_MOVE_X,d3
	move.w	#-PIR_WALL_X,d1
	move.w	#PIR_WALL_Y,d2
	tst.b	OBJOAM0(a5)
	beq.s	.going_left
	neg.w	d3
	neg.w	d1
.going_left:
	add.w	d3,OBJX(A5)
	add.w	OBJX(A5),d1
	add.w	OBJY(A5),d2
	jsr	GETATTRIB
	and.w	#WALL_CTRL,d0
	beq.s	.all_clear
	eor.b	#$8,OBJOAM0(A5)
.all_clear:
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bpl.s	.posi
	neg.w	d0
.posi:	cmp.w	#(PIR_KILL_RANGE*3)/2,d0
	blt.s	.still_attack
	move.l	#PIRHANNAAI,OBJAI(a5)			;reset ai
	move.l	#PIRHANNAMAP,OBJMAP(a5)
	move.l	#pirhanna_dma,OBJINITDMA(A5)
	sf	OBJFRAME(A5)
.still_attack:	
	rts

PIRHANNA_KILLMAP:
	PMAP	0
	PMAP	0
	PMAP	3
	PMAP	3
	PMAP	0
	PMAP	0
	
pirhanna_killdma:
	dc.l	.frame6
	dc.l	.frame5
	dc.l	.frame4
	dc.l	.frame3
	dc.l	.frame2
	dc.l	.frame1

.frame1:	dc.w	2,0,0,0
	dc.w	-29,-34,48
	dc.w	-9,-43,49
	
.frame2:	dc.w	2,0,0,0
	dc.w	-29,-34,53
	dc.w	-9,-43,49
	
.frame3:	dc.w	1,0,0,0
	dc.w	-29,-43,54

.frame4:	dc.w	1,0,0,0
	dc.w	-28+4,-45+5,55

.frame5:	dc.w	2,0,0,0
	dc.w	-37,-34,56
	dc.w	-9,-43,49

.frame6:	dc.w	2,0,0,0
	dc.w	-37,-34,57
	dc.w	-9,-43,49
