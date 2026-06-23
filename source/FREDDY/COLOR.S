.macro	CL
	dc.w	\1
	dc.l	\2
	.endm

; converts an apl palette to a jag RGB palette
; a0 - apl file
; a1 - pointer to a full palette 

	if	STRIP=FALSE
conert_apl_palette:
	lea	$24(a0),a0
	move.w	#256-1,d7
.loop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	lsr.w	#1,d0	
	lsr.w	#1,d1	
	lsr.w	#1,d2
	lsl.w	#5,d0	
	lsl.w	#5,d0	
	lsl.w	#5,d1
	or.w	d0,d1
	or.w	d1,d2	
	add.w	d2,d2
	bset	#0,d2
	move.w	d2,(a1)+
	dbra	d7,.loop
	rts
	endif

load_full_marv_palette:
	addq.l	#2,a0
load_full_palette:
	lea	CLUT,a1
	move.l	#256*2,d0
	bsr	fast_copy_bytes
	rts

	if	STRIP=FALSE
load_full_marv_cry_palette:
	addq.l	#2,a0
load_full_cry_palette:
	lea	CLUT,a1
	move.w	#256-1,d0
.loop:
	move.w	(a0)+,d1
	bclr	#0,d1
	move.w	d1,(a1)+
	dbra	d0,.loop
	rts
	endif

; d0 - full 24bit RGB color  (source)
; d1 - full 24bit RGB color  (dest)
; d2 - number of colors
; d3 - fade typpe
; a0 - string for spread

TYPE_RGB	equ	0
TYPE_CRY	equ	1

make_color_spread:

original_red	equ -50
original_green	equ -48
original_blue	equ -46
change_red		equ -44
change_green	equ -42
change_blue		equ -40

	move.l	d1,-(sp)
	link	a6,#original_red
	movem.w	d2-d3,-(sp)

	moveq	#0,d2
	moveq	#0,d3
	move.b	d0,d2
	move.b	d1,d3
	move.w	d2,original_blue(a6)
	sub.w	d2,d3
	move.w	d3,change_blue(a6)
	lsr.l	#8,d0	
	lsr.l	#8,d1
	
	moveq	#0,d2
	moveq	#0,d3
	move.b	d0,d2
	move.b	d1,d3
	move.w	d2,original_green(a6)
	sub.w	d2,d3
	move.w	d3,change_green(a6)
	lsr.l	#8,d0	
	lsr.l	#8,d1
	
	moveq	#0,d2
	moveq	#0,d3
	move.b	d0,d2
	move.b	d1,d3
	move.w	d2,original_red(a6)
	sub.w	d2,d3
	move.w	d3,change_red(a6)

	movem.w	(sp)+,d2-d3
	moveq	#0,d7
	move.w	d3,d4
	move.w	d2,d3

.loop:
	move.w	change_red(a6),d0
	muls	d7,d0
	divs	d3,d0
	add.w	original_red(a6),d0

	move.w	change_green(a6),d1
	muls	d7,d1
	divs	d3,d1
	add.w	original_green(a6),d1

	move.w	change_blue(a6),d2
	muls	d7,d2
	divs	d3,d2
	add.w	original_blue(a6),d2

	cmp.w	#TYPE_RGB,d4
	beq.s	.rgb
	bra.s	.rgb
	PUSH
	lsl.l	#8,d0
	lsl.l	#8,d0
	lsl.l	#8,d1
	or.l	d2,d1
	or.l	d1,d0
	bsr	rgb_to_cry
	PULL
	bra.s	.skip

.rgb:	
	lsr.w	#3,d0
	lsr.w	#3,d1
 	lsr.w	#3,d2

	lsl.w	#6,d0
	lsl.w	#5,d0
	lsl.w	#6,d1
	lsl.w	#1,d2

	or.w	d2,d1
	or.w	d1,d0

	addq.w	#1,d0
.skip:
	move.w	d0,(a0)+

	addq.w	#1,d7
	cmp.w	d3,d7
	bne.s	.loop
	unlk	a6
	move.l	(sp)+,d0
	rts

; d0 - number of colours
; d1 - intensity ( 1-256 )
; a0 - source list
; a1 - dest list
	if	STRIP=FALSE
fade_cry_colors:
	subq.w	#1,d0
.loop:
	move.w	(a0)+,d2
	moveq	#0,d3
	move.b	d2,d3
	mulu	d1,d3
	lsr.w	#8,d3
	move.b	d3,d2
	bclr	#0,d2
	move.w	d2,(a1)+	
	dbra	d0,.loop
	rts
	endif

; d0 - number of colours
; d1 - intensity ( 1-32 )
; a0 - source list
; a1 - dest list

fade_rgb_colors:
	subq.w	#1,d0
.loop:
	move.w	(a0)+,d2
	lsr.w	#1,d2
	move.w	d2,d3
	move.w	d3,d4
	lsr.w	#5,d3
	lsr.w	#5,d4
	lsr.w	#5,d4
	and.w	#$1f,d2
	and.w	#$1f,d3
	and.w	#$1f,d4
	mulu	d1,d2
	mulu	d1,d3
	mulu	d1,d4
	lsr.w	#5,d2
	lsr.w	#5,d3
	lsr.w	#5,d4
	lsl.w	#5,d3
	lsl.w	#5,d4
	lsl.w	#5,d4
	or.w	d4,d3
	or.w	d3,d2
	add.w	d2,d2
	addq.w	#1,d2
	move.w	d2,(a1)+	
	dbra	d0,.loop
	rts

; a0 - color list source pointer

	if	STRIP=FALSE
get_color_list_length:
	moveq	#0,d0
	addq.l	#4,a0
.loop:
	move.w	(a0),d1
	bmi.s	.done
	add.w	d1,d0
	add.w	d1,d0
	addq.l	#6,a0
	bra.s	.loop
.done:
	rts

; a0 - color list source pointer
; a1 - color list to build to

make_color_list:
	exg	a0,a1
	move.l	(a1)+,d0
.loop:
	move.w	(a1)+,d2
	bmi.s	.done
	move.l	(a1)+,d1
	moveq	#TYPE_RGB,d3
	bsr	make_color_spread
	bra.s	.loop
.done:
	rts
	endif

; d0 color (RGB)
; d0 color (CRY) ( make sure bottom bit is zero )

rgb_to_cry:
	illegal
