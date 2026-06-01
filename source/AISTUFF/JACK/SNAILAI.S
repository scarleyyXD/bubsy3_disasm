; the snail moves left and right and if bubsy comes anywhere near he goes into
; his shell

.macro	SNAIL_KILL_BUBSY
	move.w	#$0901,d6
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_detection
	
	moveq	#POPSTATE,d0
	jsr	KILLBUBSY
.no_detection:
	.endm

SNAIL_HIDE_XRANGE	equ	100
SNAIL_HIDE_YRANGE	equ	80
SNAIL_DX			equ	2
SNAIL_WALK_SPEED	equ	10
SNAIL_WIDTH			equ	50

SNAILAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL			; in range y
	SNAIL_KILL_BUBSY
	jsr	STICKOBJECTTOPLAYFIELD
	
	subq.b	#1,OBJAUX0(a5)
	bpl	.NOINCREMENT						;if not time for new frame then just draw old one !!
	
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bpl.s	.plusx
	neg.w	d0

.plusx:
	cmp.w	#SNAIL_HIDE_XRANGE,d0
	bgt.s	.no_hide
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.plusy
	neg.w	d0

.plusy:
	cmp.w	#SNAIL_HIDE_YRANGE,d0
	bgt.s	.no_hide
	
	lea	SNAIL_HIDEAI(pc),a0
	move.l	a0,OBJAI(a5)
	lea	snail_hide_dma(pc),a1
	tst.b	OBJOAM0(A5)
	bne.s	.ok
	lea	snail_hide_right_dma(pc),a1

.ok:
	move.l	a1,OBJINITDMA(a5)
	move.l	#SNAIL_HIDEMAP,OBJMAP(a5)
	st	OBJFRAME(a5)
	sf	OBJAUX0(a5)
	jmp	(a0)

.no_hide:
	moveq	#-SNAIL_DX-SNAIL_WIDTH,d1
	moveq	#-SNAIL_DX,d6
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	bne.s	.WALKLEFT
	neg.w	d1
	neg.w	d6

.WALKLEFT:
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	move.w	OBJY(a5),d2
	subq.w	#8,d2
	jsr	GETATTRIB
	or.w	d0,d0
	bne.s	.change_direction					; flat land required go this block must be sky ==0
	move.w	d0,TEMP7
	
	move.w	OBJY(a5),d2
	addq.w	#6,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB
	or.w	d0,d0
	beq.s	.change_direction					; if nothing there then change direction
	
	move.w	OBJY(a5),d2
	addq.w	#6,d2
	move.w	TEMP6,d1
	jsr	GETOBJECTGRAVITY
	or.w	d0,d0
	beq.s	.all_ok							;flat land is reuired == 0

.change_direction:
	lea	SNAIL_TURNAI(pc),a0
	move.l	a0,OBJAI(A5)
	move.l	#snail_turn_dma,OBJINITDMA(a5)
	move.l	#SNAIL_TURNMAP,OBJMAP(a5)
	sf	OBJAUX0(a5)
	move.b	#SNAIL_TURN_FRAMES,OBJFRAME(A5)
	jmp	(a0)

.all_ok:
	add.w	d6,OBJX(a5)						;move the guard by d6

.no_move:
.DONETHIS:
	move.b	#SNAIL_WALK_SPEED-1,OBJAUX0(a5)
	move.b	OBJAUX1(a5),d0
	addq.b	#1,d0
	and.b	#3,d0
	move.b	d0,OBJAUX1(a5)						;pointer to frame number
	move.b	d0,OBJFRAME(a5)

.MAKE_SNAIL_DROP:
	move.w	OBJX(A5),d0
	addq.w	#2,d0
	and.w	#$f,d0
;	bne.w	DRAW_COMPLEX_SPRITE	;bne->bne.w
	beq.w	.nolol
	jmp	DRAW_COMPLEX_SPRITE	;bne->jmp

.nolol:
	cmp.b	#6,DROPS_ACTIVE
	beq.s	.NOWAY
	
	addq.b	#1,DROPS_ACTIVE
	move.l	a5,a6
	
	move.w	#$3fff,d6
	jsr	FINDFREEOBJ
	bcs.s	.cant
	
	moveq	#SDROP_ROFFSET,d0
	tst.b	OBJOAM0(a6)
	beq.s	.right
	moveq	#SDROP_LOFFSET,d0

.right:
	add.w	OBJX(A6),d0
	move.w	d0,OBJX(A5)
	move.w	OBJY(a6),OBJY(a5)
	
	move.w	#$7e00,OBJKEY(a5)
	move.l	#SNAIL_DROPAI,OBJAI(A5)
	move.l	#snail_drop_dma,OBJINITDMA(A5)
	move.l	#SNAILDROPMAP,OBJMAP(a5)
	sf	OBJOAM0(a5)	
	sf	OBJAUX0(a5)
	move.b	#SDROP_TIMES,OBJAUX1(a5)
	sf	OBJAUX2(a5)
	sf	OBJFRAME(A5)

.cant:
	move.l	a6,a5

.NOWAY:
.NOINCREMENT:
	jmp	DRAW_COMPLEX_SPRITE	;bra->jmp

SNAILMAP:
SNAIL_TURNMAP:
SNAIL_HIDEMAP:
	rept	4
	Soff	16,0,0,0,1,30,8,46,25,53,39,42,43,0
	endr

snail_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
.frame0:
	dc.w	1,0,0,0
	dc.w	-46,-70,70
.frame1:
	dc.w	1,0,0,0
	dc.w	-46,-71,71
.frame2:
	dc.w	1,0,0,0
	dc.w	-46,-70,72
.frame3:
	dc.w	1,0,0,0
	dc.w	-46-6,-71,73

**********************************************************************************

SNAIL_HIDE_SPEED	equ	4
SNAIL_HIDE_FRAME	equ	2

SNAIL_HIDEAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL			; in range y

	SNAIL_KILL_BUBSY	; SNAIL_KILL_BUBSY_BOING

	cmp.b	#SNAIL_HIDE_FRAME,OBJFRAME(a5)
	beq.s	.end_of_anim
	
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#SNAIL_HIDE_SPEED,OBJAUX0(a5)
	addq.b	#1,OBJFRAME(A5)

.same_frame:
.end_of_anim:
	jmp	DRAW_COMPLEX_SPRITE	;bra->jmp
	
snail_hide_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
.frame0:
	dc.w	2,0,0,0
	dc.w	-34,-71,76
	dc.w	-41,-38,78
.frame1:
	dc.w	2,0,0,0
	dc.w	-31,-71,76
	dc.w	-31,-35,77
.frame2:
	dc.w	1,0,0,0
	dc.w	-29,-71,76

snail_hide_right_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
.frame0:
	dc.w	2,0,0,0
	dc.w	-34,-71,76
	dc.w	-41,-38,78
.frame1:
	dc.w	2,0,0,0
	dc.w	-31,-71,76
	dc.w	-31,-35,77
.frame2:
	dc.w	2,0,0,0
	dc.w	-29,-71,76
	dc.w	-2,-27,92

**********************************************************************************

SNAIL_TURN_SPEED		equ	10
SNAIL_TURNED_FRAME		equ	0
SNAIL_TURN_FRAMES		equ	3

SNAIL_TURNAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL			; in range y

	SNAIL_KILL_BUBSY

	tst.b	OBJFRAME(a5)
	beq.s	.end_of_anim
	
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#SNAIL_TURN_SPEED,OBJAUX0(a5)
	subq.b	#1,OBJFRAME(A5)
	cmp.b	#SNAIL_TURNED_FRAME,OBJFRAME(a5)
	bne.s	.no_wrap
	eor.b	#8,OBJOAM0(a5)

.no_wrap:
.same_frame:
	jmp	DRAW_COMPLEX_SPRITE	;bra->jmp

.end_of_anim:
	lea	SNAILAI(pc),a0
	move.l	a0,OBJAI(A5)
	move.l	#snail_dma,OBJINITDMA(a5)
	move.l	#SNAILMAP,OBJMAP(A5)
	sf	OBJAUX0(A5)
	jmp	(a0)
	
snail_turn_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame0
.frame0:
	dc.w	1,0,0,0
	dc.w	-30,-66,74
.frame1:
	dc.w	1,0,0,0
	dc.w	-30,-67,75

;aux 0 = anim timer
;aux 1 = anim times left
;aux 2 = flag fade out

SDROP_ROFFSET	equ	-50
SDROP_LOFFSET	equ	(-SDROP_ROFFSET-16)

SNAIL_DROP_REPT_RATE	equ	3
SDROP_TIMES		equ	10

.macro	SNAIL_DROPPINGS_KILL_BUBSY
	; does nothing? 4/26/2026
	.endm

SNAIL_DROPAI:
	subq.b	#1,DROPS_ACTIVE
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM

.INRANGE:
	jsr	CLIPYSMALL			; in range y
	addq.b	#1,DROPS_ACTIVE

	SNAIL_DROPPINGS_KILL_BUBSY

	subq.b	#1,OBJAUX0(a5)
	bpl.s	.same_frame
	move.b	#SNAIL_DROP_REPT_RATE,OBJAUX0(a5)

	tst.b	OBJAUX2(a5)
	bne.s	.fade_out
	
	eor.b	#1,OBJFRAME(A5)
	
	tst.b	OBJFRAME(a5)
	bne.s	.no_wait_till_fade
	
	subq.b	#1,OBJAUX1(A5)
	bne.s	.no_wait_till_fade
	
	st	OBJAUX2(a5)

.same_frame:
.no_wait_till_fade:
.just_draw:
	jmp	DRAW_COMPLEX_SPRITE

.fade_out:
	addq.b	#1,OBJFRAME(a5)
	cmp.b	#4,OBJFRAME(a5)
	bne.s	.just_draw
	subq.b	#1,DROPS_ACTIVE
	jmp	CLEAROBJWVRAM

snail_drop_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
.frame0:
	dc.w	1,0,0,-1
	dc.w	-8,-3,93
.frame1:
	dc.w	1,0,0,-1
	dc.w	-8,-3,94
.frame2:
	dc.w	1,0,0,-1
	dc.w	-8,-3,95
.frame3:
	dc.w	1,0,0,-1
	dc.w	-8,-3,96

DROPS_ACTIVE:	dc.w	0

SNAILDROPMAP:
	rept	4
	dc.l	0,0

	dc.w	0,0
	dc.w	0,-2
	
	dc.w	-2,0
	dc.w	-2,-2
	
	dc.w	2,0
	dc.w	2,-2
	endr