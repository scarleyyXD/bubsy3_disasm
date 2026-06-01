;43/44/45 46
; the pea sits there going though a quiver anim.
;	when bubsy gets too clode then it explodes and fires up 6 peas into
;	the air which foolow a simple path and if the hit BUBSY then he's dead..


PEAPOD_ANIM_SPEED	equ	5
PEAPOD_LAST_FRAME	equ	3
PEAPOD_KILLX		equ	100
PEAPOD_KILLY		equ	80
PEA_EX_XY		equ	$00010001

PEA_XY_1		equ	$02000200
PEA_XY_2		equ	$02000000
PEA_XY_3		equ	$0200fd00
PEA_XY_4		equ	$fd000200
PEA_XY_5		equ	$fd000200
PEA_XY_6		equ	$fd00fd00
PEA_XY_7		equ	$fe000300
PEA_XY_8		equ	$01000300
PEA_XY_9		equ	$0100fc00
PEA_XY_10		equ	$fe00fc00

MAKE_PEA	macro
		move.w	#$7fff,d6
		jsr	FINDFREEOBJ			; else self destruct with as many pea pods as available
		bcs	.no_more_free
		move.l	#\1,d0
		move.l	(sp),d1
		bsr	make_pea_explode
		endm


PEAPODAI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPY
	
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.just_draw_frame1
	move.b	#PEAPOD_ANIM_SPEED,OBJAUX0(a5)
	
	subq.b	#1,OBJFRAME(a5)
	bpl.s	.just_draw_frame1
	move.b	#PEAPOD_LAST_FRAME,OBJFRAME(a5)
	
.just_draw_frame1
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bpl.s	.okx
	neg.w	d0
.okx	cmp.w	#PEAPOD_KILLX,d0
	bgt.s	.just_draw_frame
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.oky
	neg.w	d0
.oky	cmp.w	#PEAPOD_KILLY,d0
	ble.s	.kill_bubsy
.just_draw_frame
	jmp	DRAW_COMPLEX_SPRITE
.kill_bubsy
	move.w	OBJX(a5),-(sp)
	move.w	OBJY(a5),-(sp)
	move.l	#PEA_EX_XY,d0
	tst.b	OBJOAM0(a5)
	beq.s	.posi
	neg.l	d0
.posi	add.l	d0,(sp)
	
	move.l	a5,a6
	
	move.w	#$7fff,d6
	jsr	FINDFREEOBJ
	bcs	.none_free_at_all		; if no objects available then do not kill the peapod
	move.l	#PEA_XY_1,d0
	move.l	(sp),d1
	bsr	make_pea_explode
	
	MAKE_PEA	PEA_XY_2
	MAKE_PEA	PEA_XY_3
	MAKE_PEA	PEA_XY_4
	MAKE_PEA	PEA_XY_5
	MAKE_PEA	PEA_XY_6
	MAKE_PEA	PEA_XY_7
	MAKE_PEA	PEA_XY_8
	MAKE_PEA	PEA_XY_9
	MAKE_PEA	PEA_XY_10

.no_more_free
	move.l	a6,a5
	addq	#4,sp					;get rid of x and y on the stack
	jmp	CLEAROBJWVRAM
.none_free_at_all
	move.l	a6,a5
	addq.l	#4,sp
	jmp	DRAW_COMPLEX_SPRITE
	
	
make_pea_explode
	move.w	d1,OBJX(a5)
	swap	d1
	move.w	d1,OBJY(a5)
	move.l	d0,OBJAUX0(a5)
	move.l	#PEA_EX_AI,OBJAI(a5)
	move.l	#pea_ex_dma,OBJINITDMA(a5)
	sf	OBJFRAME(a5)
	move.l	#PEA_MAP,OBJMAP(a5)
	move.w	#$7e00,OBJKEY(A5)
	rts





PEAPODMAP
	rept	PEAPOD_LAST_FRAME+1
	dcb.b	32,0
	endr


peapod_dma
	dc.l	.frame1
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	
.frame0	dc.w	1,0,0,-1			;4x4 sprite
	dc.w	0,0,43
.frame1	dc.w	1,0,0,-1			;4x4 sprite
	dc.w	0,0,44
.frame2	dc.w	1,0,0,-1			;4x4 sprite
	dc.w	0,0,45
	
***************************************************************************************************


PEAGRAVITY	equ	$0020
MAXPGRAVITY	equ	$0800



PEA_MAP	dc.l	0,0
 	dc.w	+0002,-2
 	dc.w	+0003,+0
 	dc.w	+0002,-2
 	dc.w	-0002,-2
 	dc.w	-0002,-2
 	dc.w	-0003,+0

pea_ex_dma
	dc.l	.frame
	
.frame	dc.w	1,-4,-4,-1			;4x4 sprite
	dc.w	0,0,46


PEA_EX_AI
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPYSMALL
	
	
	jsr	CLIPY
	move.w	#$0601,d6
	move.w	#SMASH,d7
	jsr	NOBOPCOLLIDE
	bcc.s	.no_collide
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY			;if splatter then melt bubsy
.no_collide

	
	
	move.w	OBJAUX0(a5),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,OBJX(A5)
	
	
	move.w	OBJAUX6(a5),d0
	add.w	#PEAGRAVITY,d0
	cmp.w	#MAXPGRAVITY,d0
	blt.s	.ok
	move.w	#MAXPGRAVITY,d0
.ok	move.w	d0,OBJAUX6(a5)
	add.w	OBJAUX0+2(a5),d0
.okg	ext.l	d0
	asl.l	#8,d0
	add.l	d0,OBJY(A5)			;update the x and y co-ordinates

	JMP	DRAW_COMPLEX_SPRITE