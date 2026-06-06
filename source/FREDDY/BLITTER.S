;;;;	include	"c:\bin\blit.inc"

; not needed, coz blitter kills 68000
; gpu may need it though, and everyone forgets which bit to test

wait_blitter:
	move.l	d0,-(sp)
	move.l	B_CMD-BASE(a5),d0
	btst	#0,d0
	beq.s	wait_blitter	
	move.l	(sp)+,d0
	rts

; copies bytes the fastest way possible
; d0 - number of bytes to copy
; a0 - pointer to source 
; a1 - pointer to dest 

blitter_copy:
	sub.l	#65535,d0
	ble.s	.done
	move.l	d0,-(sp)
	move.w	#65535,d0
	bsr	blitter_copy_upto64k
	move.l	(sp)+,d0
	add.l	#65535,a0
	add.l	#65535,a1
	bra.s	blitter_copy
.done:
	add.l	#65535,d0
	beq.s	.exit
	bsr	blitter_copy_upto64k
.exit:
	rts

; same as above, but only upto 65535 bytes

blitter_copy_upto64k:
	move.l	#WID256|PITCH1|PIXEL8|XADDPIX,d2
	move.l	d2,A1_FLAGS-BASE(a5)
	move.l	d2,A2_FLAGS-BASE(a5)

	move.l	a1,d1
	moveq	#-8,d2
	and.l	d1,d2
	sub.l	d2,d1
	move.l	d1,A1_PIXEL-BASE(a5)		
	move.l	d2,A1_BASE-BASE(a5)

	move.l	a0,d1
	moveq	#-8,d2
	and.l	d1,d2
	sub.l	d2,d1
	move.l	d1,A2_PIXEL-BASE(a5)		
	move.l	d2,A2_BASE-BASE(a5)
	bsr	word_to_bcount
;	tst.w	d1
;	beq.s	.phrased
;	move.l	#SRCEN|SRCENX|LFU_S,B_CMD-BASE(a5)
;         	rts
.phrased:
	move.l	#SRCEN|LFU_S,B_CMD-BASE(a5)
	rts
	
word_to_bcount:
	swap	d0
	move.w	#1,d0
	swap	d0
	move.l	d0,B_COUNT-BASE(a5)
	rts

; Set patern registers to 0.  ie , clear memory.

blitter_clear:
	moveq	#0,d1
	moveq	#0,d2
	bsr	blitter_fill_pattern
	rts

; fills memory with a specific pattern of 8 bytes

; d0 - number of bytes
; d1 - pattarn a
; d2 - pattarn b
; a0 - pointer to fill region

blitter_fill_pattern:
	sub.l	#32768,d0
	ble.s	.done
	move.l	d0,-(sp)
	move.w	#32768,d0
	bsr	blitter_fill_pattern_upto_64k
	move.l	(sp)+,d0
	add.l	#32768,a0
	bra.s	blitter_fill_pattern
.done:
	add.l	#32768,d0
	beq.s	.exit
	bsr	blitter_fill_pattern_upto_64k
.exit:
	rts

; same as above, but only upto 65535 bytes

blitter_fill_pattern_upto_64k:
	movem.l	d1-d2,-(sp)
	move.l	#PITCH1|PIXEL16|XADDPHR,A1_FLAGS-BASE(a5)
	move.l	a0,d1
	moveq	#-8,d2
	and.l	d1,d2
	sub.l	d2,d1
	move.l	d1,A1_PIXEL-BASE(a5)
	move.l	d2,A1_BASE-BASE(a5)
	lsr.w	#1,d0
	bsr	word_to_bcount
	movem.l	(sp)+,d1-d2
	movem.l	d1-d2,B_PATD-BASE(a5)
	move.l	#PATDSEL,B_CMD-BASE(a5)
	rts

; d0 - x1
; d1 - y1
; d2 - x2
; d3 - y2
; d4 - color ( as a word )
; d5 - width+pixel depth ( source ) (CODED IN BLITTER FORMAT)
; d6 - WIDTH/HEIGHT of destination window in pixels

; a0 - pointer to destination window
	if	STRIP=FALSE
blitter_line_8bit:
	move.b    d4,d7
	lsl.b     #8,d4              
	move.b    d7,d4
blitter_line:
	move.w	d6,d7
	swap	d7
	swap	d6
	move.w	d6,d7
	move.l	d7,A1_CLIP-BASE(a5)

	move.l	a0,A1_BASE-BASE(a5)
	or.l	#PITCH1+XADDINC,d5
	move.l	d5,A1_FLAGS-BASE(a5)
	move.l	#0,A1_FPIXEL-BASE(a5)
	
	move.b	d4,d7
	swap	d7
	move.w	d4,d7
	move.l	d7,B_PATD+0-BASE(a5)
	move.l	d7,B_PATD+4-BASE(a5)

	move.w	d1,d7
	swap	d7
	move.w	d0,d7
	move.l	d7,A1_PIXEL-BASE(a5)
	sub.w	d0,d2
	sub.w	d1,d3
	ABSSET	d2,d0
	ABSSET	d3,d1

	moveq	#1,d5
	swap	d5
	move.w	d2,d5  
	cmp.w	d2,d3       
	ble.s	.use_x_as_distance
	move.w	d3,d5    

; the longest axis is the one in which we increment by 1
; and the shortest is the one we increment by a fraction

.use_x_as_distance:
	move.l	d5,B_COUNT-BASE(a5)
	cmp.w	d2,d5
	bne.s	.no_x_line              
	moveq	#1,d2
	swap	d2               
	bra.s	.skip1
.no_x_line:
	swap	d2 
	clr.w	d2 
	divu	d5,d2	
	swap	d2
	clr.w	d2
	swap	d2

.skip1:   
	cmp.w	d3,d5
	bne.s	.no_y_line              
	moveq	#1,d3
	swap	d3               
	bra.s	.skip2
.no_y_line:
	swap	d3
	clr.w	d3 
	divu	d5,d3
	swap	d3
	clr.w	d3
	swap	d3

.skip2:	
	tst.b	d0
	beq.s	.no_neg_x
	neg.l	d2

.no_neg_x:
	tst.b	d1
	beq.s	.no_neg_y
	neg.l	d3
.no_neg_y:	
	move.w	d3,d4
	swap	d4
	move.w	d2,d4
	move.l	d4,A1_FINC-BASE(a5)

	swap	d2
	swap	d3

	move.w	d3,d4
	swap	d4
	move.w	d2,d4
	move.l	d4,A1_INC-BASE(a5)
		
	move.l	#PATDSEL+CLIP_A1,B_CMD-BASE(a5)
	rts
	endif

; this blitter routine scales a bitmap
; beware of zero height bitmaps !

; d0 - pixel in destination window ( from center )
; d1 - scale factor ( x-axis ) (HI-WORD INT , LO-WORD FRAC)
; d2 - scale factor ( y-axis )
; d3 - width+pixel depth ( source ) (CODED IN BLITTER FORMAT)
; d4 - width+pixel depth ( dest )
; d5 - width/height of source in pixels (HI-WORD WIDTH , LO-WORD HEIGHT)
; a0 - pointer to source window ( must be on a phrase boundry !)
; a1 - pointer to dest window  ( must be on a phrase boundry !)

blitter_scale_bitmap:
; A2 - is used as the destination for scaling !
	move.l	a0,A1_BASE-BASE(a5)
	move.l	a1,A2_BASE-BASE(a5)
	or.l	#PITCH1+XADDPHR,d3
	or.l	#PITCH1+XADDPHR,d4

;	or.l	#PITCH1+XADDINC,d3
;	or.l	#PITCH1+XADDPIX,d4

	move.l	d3,A1_FLAGS-BASE(a5)
	move.l	d4,A2_FLAGS-BASE(a5)
	move.l	d3,-(sp)
	move.l	#0,A1_PIXEL-BASE(a5)
	move.l	#0,A1_FPIXEL-BASE(a5)
	swap	d5
	move.w	d5,d6	; width in pixels in d6
	swap	d5
	move.w	d5,d7	; height in pixels in d7
	mulu	d1,d6		
	mulu	d2,d7	; fractional parts multiplied by width height		
	swap	d6
	swap	d7	; divide em both by 65536

	move.w	d5,d4	; hright in d4
	swap	d5
	move.w	d5,d3	; width in d3
	swap	d1	
	swap	d2
	mulu	d1,d3	
	mulu	d2,d4	; multiply integer scale values by width/height
	add.w	d3,d6	; this is the full width in pixels of the scaled image		
	beq	.no_height
	add.w	d4,d7	; this is the full height in pixels of the scaled image
	beq	.no_width
	move.w	d6,d3		  
	move.w	d7,d4		  
	lsr.w	#1,d3	
	lsr.w	#1,d4	; offset from origin of image
	sub.w	d4,d0
	swap	d0	
	sub.w	d3,d0
	move.l	d0,A2_PIXEL-BASE(a5)	; coardinate

	moveq	#1,d3
	swap	d3
	move.w	d6,d3
	neg.w	d3
	move.l	d3,A2_STEP-BASE(a5)	; full width in pixels back !

	moveq	#0,d3
	move.w	d5,d3
	divu	d6,d3
	moveq	#0,d4
	move.w	d3,d4
	move.l	d4,A1_INC-BASE(a5)
	clr.w	d3
	divu	d6,d3
	swap	d3
	clr.w	d3
	swap	d3
	move.l	d3,A1_FINC-BASE(a5)
	mulu	d6,d3
	mulu	d6,d4
	swap	d4
	add.l	d4,d3
	move.l	d3,d0
	neg.l	d0

	swap	d5

	moveq	#0,d3
	move.w	d5,d3
	divu	d7,d3
	moveq	#0,d4
	move.w	d3,d4
	swap	d4
	swap	d0
	move.w	d0,d4
	move.l	d4,A1_STEP-BASE(a5)
	clr.w	d3
	divu	d7,d3
	swap	d3
	swap	d0
	move.w	d0,d3
	move.l	d3,A1_FSTEP-BASE(a5)

	swap	d7
	move.w	d6,d7
	move.l	d7,B_COUNT-BASE(a5)
	move.l	(sp),d3
	lsr.w	#3,d3
	and.w	#$7,d3
	cmp.w	#3,d3
	bge.s	.no_ex
	move.l	#SRCEN+UPDA1F+UPDA1+UPDA2+DSTA2+LFU_SAND+LFU_SAD+DSTEN,B_CMD-BASE(a5)
	bra.s	.no_width
.no_ex:           
	move.l	#SRCEN+UPDA1F+UPDA1+UPDA2+DSTA2+LFU_SAND+LFU_SAD+DSTEN-DSTEN,B_CMD-BASE(a5)
.no_height:
.no_width:
	addq.l	#4,sp
	rts

; this routine scales/rotates a bitmap by so many degrees into another bitmap window

; d0 - pixel in destination window ( from center )
; d1 - scale factor ( x-axis ) (HI-WORD INT , LO-WORD FRAC)
; d2 - scale factor ( y-axis )
; d3 - width+pixel depth ( source ) (CODED IN BLITTER FORMAT)
; d4 - width+pixel depth ( dest )
; d5 - width/height of source in pixels (HI-WORD WIDTH , LO-WORD HEIGHT)
; d6 - angle to rotate

; a0 - pointer to source window ( must be on a phrase boundry !)
; a1 - pointer to dest window  ( must be on a phrase boundry !)

blitter_rotate_bitmap:

brotverts		equ -50
newwidth		equ -34
newheight		equ -32
rotangle		equ -30
rotscale		equ -28
angle_off		equ -20

	link	a6,#brotverts
	movem.l	d1-d2,rotscale(a6)
	move.w	d6,rotangle(a6)

	move.l	d3,-(sp)
	move.l	a0,A1_BASE-BASE(a5)
	move.l	a1,A2_BASE-BASE(a5)
	or.l	#PITCH1+XADDINC,d3
	or.l	#PITCH1+XADDPIX,d4
	move.l	d3,A1_FLAGS-BASE(a5)
	move.l	d4,A2_FLAGS-BASE(a5)
	swap	d5
	move.l	d5,A1_CLIP-BASE(a5)
	move.l	#0,A1_FPIXEL-BASE(a5)

	PUSH
	clr.l	angle_off(a6)
	move.w	d6,d7
	and.w	#SINE_LEN-1,d7
	beq.s	.done
	cmp.w	#(SINE_LEN/4)*3,d7
	bgt.s	.done
	cmp.w	#(SINE_LEN/4)*2,d7
	ble.s	.less2
	move.w	#1,angle_off+2(a6)
	bra.s	.done
.less2:
	cmp.w	#(SINE_LEN/4)*1,d7
	ble.s	.less1
	move.w	#1,angle_off(a6)
	move.w	#1,angle_off+2(a6)
	bra.s	.done
.less1:
	move.w	#1,angle_off(a6)
.done:
	move.w	d5,d0
	swap	d5
	move.w	d5,d1
	lsr.w	#1,d0
	lsr.w	#1,d1	
	lea	brotverts(a6),a0
	bsr	write_out_quad

	moveq	#4,d0
	move.w	d6,d1
	lea	brotverts(a6),a0
	move.l	a0,a1
	bsr	z_rotate_verts

	lea	brotverts(a6),a0
	moveq	#4,d0
	bsr	get_min_max_coard
	lea	brotverts(a6),a0
	addq.w	#1,d2
	addq.w	#1,d3

	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d0,(a0)+
	move.w	d3,(a0)+	

	sub.w	d0,d2
	sub.w	d1,d3

	move.w	d2,d1
	swap	d1
	clr.w	d1
	move.l	rotscale(a6),d0
	bsr	thirty_2_bit_mul
	swap	d0
	move.w	d0,newwidth(a6)

	move.w	d3,d1
	swap	d1
	clr.w	d1
	move.l	rotscale+4(a6),d0
	bsr	thirty_2_bit_mul
	swap	d0
	move.w	d0,newheight(a6)

	lea	brotverts(a6),a0
	move.l	a0,a1
	moveq	#4,d0
	move.w	rotangle(a6),d1
	neg.w	d1	
	bsr	z_rotate_verts

	PULL

	move.w	newwidth(a6),d6
	beq	.no_blitter
	move.w	newheight(a6),d7
	beq	.no_blitter
	asr.w	#1,d6
	asr.w	#1,d7
	sub.w	d7,d0
	swap	d0
	sub.w	d6,d0
	move.l	d0,A2_PIXEL-BASE(a5)	; coardinate

	moveq	#4,d0
	lea	brotverts(a6),a0
	move.w	d5,d1
	swap	d5
	move.w	d5,d2
	asr.w	#1,d1
	asr.w	#1,d2
	bsr	translate_coords

	movem.w	newwidth(a6),d6-d7
	moveq	#1,d3
	swap	d3
	move.w	d6,d3
	neg.w	d3
	move.l	d3,A2_STEP-BASE(a5)

	move.l	brotverts(a6),d0
	swap	d0
	move.l	d0,A1_PIXEL-BASE(a5)

	movem.w	brotverts(a6),d0-d3
	sub.w	d0,d2
	sub.w	d1,d3
	ext.l	d2
	ext.l	d3
	divs	d6,d2	
	divs	d6,d3	
	swap	d2
	swap	d3

	move.l	#$10000,d0
	divu	d6,d0
	move.l	d0,d1
	muls	d2,d0
	muls	d3,d1		
	clr.w	d2
	clr.w	d3
	add.l	d0,d2
	add.l	d1,d3

	move.w	d3,d4
	swap	d4
	move.w	d2,d4
	move.l	d4,A1_FINC-BASE(a5)

	swap	d2
	swap	d3

	move.w	d3,d4
	swap	d4
	move.w	d2,d4
	move.l	d4,A1_INC-BASE(a5)

	swap	d2
	swap	d3

	move.w	d2,d0
	mulu	d6,d0
	swap	d2
	muls	d6,d2
	swap	d2
	add.l	d0,d2
	neg.l	d2

	move.w	d3,d0
	mulu	d6,d0
	swap	d3
	muls	d6,d3
	swap	d3
	add.l	d0,d3
	neg.l	d3

	move.l	d2,d4
	move.l	d3,d5

	movem.w	brotverts(a6),d0-d1
	movem.w	brotverts+12(a6),d2-d3

	sub.w	d0,d2
	sub.w	d1,d3
	ext.l	d2
	ext.l	d3
	divs	d7,d2	
	divs	d7,d3	
	swap	d2
	swap	d3

	move.l	#$10000,d0
	divu	d7,d0
	move.l	d0,d1
	muls	d2,d0		
	muls	d3,d1		
	clr.w	d2
	clr.w	d3
	add.l	d0,d2
	add.l	d1,d3

	add.l	d2,d4
	add.l	d3,d5

	move.l	d4,d2
	move.l	d5,d3

	move.w	d3,d0
	swap	d0
	move.w	d2,d0
	move.l	d0,A1_FSTEP-BASE(a5)

	swap	d2
	swap	d3

	move.w	d3,d0
	add.w	angle_off(a6),d0
	swap	d0
	move.w	d2,d0
	add.w	angle_off+2(a6),d0
	move.l	d0,A1_STEP-BASE(a5)

	swap	d7
	move.w	d6,d7
	move.l	d7,B_COUNT-BASE(a5)
	move.l	(sp),d3
	lsr.w	#3,d3
	and.w	#$7,d3
	cmp.w	#3,d3
	bge.s	.no_ex
	move.l	#SRCEN+UPDA1F+UPDA1+UPDA2+DSTA2+CLIP_A1+LFU_SAND+LFU_SAD+DSTEN,B_CMD-BASE(a5)
	bra.s	.no_width
.no_ex:
	move.l	#SRCEN+UPDA1F+UPDA1+UPDA2+DSTA2+CLIP_A1+LFU_SAND+LFU_SAD+DSTEN-DSTEN,B_CMD-BASE(a5)
.no_height:
.no_width:
.no_blitter:
	addq.l	#4,sp
	unlk	a6
	rts

; d0 - pixel in destination window ( from center )
; d2 - pixel skew top 
; d2 - pixel skew bottom
; d3 - width+pixel depth ( source ) (CODED IN BLITTER FORMAT)
; d4 - width+pixel depth ( dest )
; d5 - width/height of source in pixels (HI-WORD WIDTH , LO-WORD HEIGHT)

; a0 - pointer to source window ( must be on a phrase boundry !)
; a1 - pointer to dest window  ( must be on a phrase boundry !)

	if	STRIP=FALSE
blitter_skew_horizontal:
	move.l	a0,A1_BASE-BASE(a5)
	move.l	a1,A2_BASE-BASE(a5)
	or.l	#PITCH1+XADDPIX,d3
	or.l	#PITCH1+XADDPIX,d4
	move.l	d3,A1_FLAGS-BASE(a5)
	move.l	d4,A2_FLAGS-BASE(a5)
	swap	d5
	move.l	d5,A1_CLIP-BASE(a5)
	move.l	#0,A1_FPIXEL-BASE(a5) 

	move.w	d5,d6
	swap	d5
	move.w	d5,d7
	
	sub.w	d1,d2
	move.w	d2,d3
	ABS	d3
	add.w	d3,d6

	move.w	d6,d3
	move.w	d7,d4
	asr.w	#1,d3
	asr.w	#1,d4
	sub.w	d4,d0
	swap	d0
	sub.w	d3,d0

	move.l	d0,A2_PIXEL-BASE(a5)	
	moveq	#1,d3
	swap	d3
	move.w	d6,d3
	neg.w	d3
	move.l	d3,A2_STEP-BASE(a5)

	ext.l	d2
	moveq	#0,d3
	tst.w	d2
	bpl.s	.posy
	move.w	d2,d3
.posy:
	move.l	d3,A1_PIXEL-BASE(a5)
	divs	d7,d2
	swap	d2
	move.l	#$10000,d0
	divu	d7,d0
	muls	d2,d0
	clr.w	d2
	add.l	d0,d2
	swap	d2
	add.w	d6,d2
	swap	d2
	neg.l	d2

	moveq	#$0,d3
	swap	d3
	move.w	d2,d3
	move.l	d3,A1_FSTEP-BASE(a5)
	swap	d2
	moveq	#$1,d3
	swap	d3
	move.w	d2,d3

	move.l	d3,A1_STEP-BASE(a5)

	swap	d7
	move.w	d6,d7
	move.l	d7,B_COUNT-BASE(a5)

	move.l	#SRCEN+UPDA1F+UPDA1+UPDA2+DSTA2+CLIP_A1+LFU_SAND+LFU_SAD,B_CMD-BASE(a5)
	rts
	endif

; d0 - top y / bottom y in destination window  ( top y being the furthest back )
; d1 - top width / bottom width of destination 
; d2 - width / height of source
; d3 - width+pixel depth ( source ) (CODED IN BLITTER FORMAT)
; d4 - width+pixel depth ( dest )
; d5 - x offset into destintion window for center

; a0 - pointer to source window ( must be on a phrase boundry !)
; a1 - pointer to dest window  ( must be on a phrase boundry !)

	if	STRIP=FALSE
blitter_perspective:

bper_var			equ -50
bper_desty			equ -50
bper_height			equ -48

bper_sourcey		equ -46
bper_current_width	equ -42
bper_ystep			equ -38
bper_xstep			equ -34
bper_wstep			equ -30
bper_x				equ -26
bper_sourcewidth	equ -22
bper_upscreen		equ -20

	link	a6,#bper_var

	move.l	a0,A1_BASE-BASE(a5)
	move.l	a1,A2_BASE-BASE(a5)
	or.l	#PITCH1+XADDINC,d3
	or.l	#PITCH1+XADDPIX,d4
	move.l	d3,A1_FLAGS-BASE(a5)
	move.l	d4,A2_FLAGS-BASE(a5)
	
	move.w	d0,d4
	swap	d0
	move.w	d0,bper_desty(a6)
	sub.w	d0,d4
	swap	d0
	tst.w	d4
	smi	bper_upscreen(a6)
	ABS	d4
	move.w	d4,bper_height(a6)	; height for the destination window
	beq	.no_blitter	

	swap	d1
	move.w	d1,d4
	swap	d1
	swap	d4
	clr.w	d4
	move.l	d4,bper_current_width(a6)

	clr.l	bper_sourcey(a6)

	moveq	#0,d4
	move.w	d2,d4
	divu	bper_height(a6),d4
	swap	d4
	move.l	#$10000,d3
	divu	bper_height(a6),d3
	mulu	d4,d3
	clr.w	d4
	add.l	d3,d4
	move.l	d4,bper_ystep(a6)

	swap	d1
	move.w	d1,d4
	swap	d1
	lsr.w	#1,d4
	sub.w	d4,d5
	swap	d5
	clr.w	d5
	move.l	d5,bper_x(a6)

	moveq	#0,d4
	move.w	d1,d4
	swap	d1
	sub.w	d1,d4
	swap	d1
	asr.w	#1,d4
	
	divu	bper_height(a6),d4
	swap	d4
	move.l	#$10000,d3
	divu	bper_height(a6),d3
	mulu	d4,d3
	clr.w	d4
	add.l	d3,d4
	move.l	d4,bper_xstep(a6)
	add.l	d4,d4
	move.l	d4,bper_wstep(a6)	
	swap	d2
	move.w	d2,bper_sourcewidth(a6)

	moveq	#1,d0
	tst.b	bper_upscreen(a6)
	beq.s	.ready
	neg.w	d0
.ready:
	move.w	d0,bper_upscreen(a6)

.loop:
	move.l	bper_x(a6),d1
	move.l	d1,d0
	move.w	bper_desty(a6),d0
	swap	d0
	move.l	d0,A2_PIXEL-BASE(a5)
	move.w	bper_upscreen(a6),d0
	add.w	d0,bper_desty(a6)
	
	sub.l	bper_xstep(a6),d1
	move.l	d1,bper_x(a6)
	
	move.l	bper_sourcey(a6),d1
	move.l	d1,d0
	clr.w	d0
	move.l	d0,A1_PIXEL-BASE(a5)
	move.l	#0,A1_FPIXEL-BASE(a5)
	add.l	bper_ystep(a6),d1
	move.l	d1,bper_sourcey(a6)

	moveq	#0,d3
	move.w	bper_sourcewidth(a6),d3
	divu	bper_current_width(a6),d3
	swap	d3
	move.l	#$10000,d5
	divu	bper_current_width(a6),d5
	mulu	d3,d5
	clr.w	d3
	add.l	d5,d3
	move.l	d3,d1

	moveq	#0,d0
	move.w	d1,d0
	move.l	d0,A1_FINC-BASE(a5)
	swap	d1
	move.w	d1,d0
	move.l	d0,A1_INC-BASE(a5)

	move.l	bper_current_width(a6),d1
	move.l	d1,d0
	move.w	#1,d0
	swap	d0
	move.l	d0,B_COUNT-BASE(a5)
	add.l	bper_wstep(a6),d1
	move.l	d1,bper_current_width(a6)

	move.l	#SRCEN+DSTA2+LFU_SAND+LFU_SAD,B_CMD-BASE(a5)

	DEC.w	bper_height(a6)
	bne	.loop
.no_blitter:
	unlk	a6
	rts

;-------------------------------------------
; SOME LITTLE MATHS ROUTINES TO AID
; IN THE USE OF THE BLITTER 
;-------------------------------------------


perspective:
	subq.w	#1,d0
	move.w	d0,d7
.loop:
	movem.w	(a0)+,d0-d2
	muls	#PERSPECTIVE_VAL,d0
	muls	#PERSPECTIVE_VAL,d1
	add.w	#PERSPECTIVE_VAL,D2
	divs	d2,d0
	divs	d2,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbra	d7,.loop
	rts
	endif

;thirty 2 bit multply
; d0 - int / frac
; d1 - int / frac

thirty_2_bit_mul:
	movem.l	d1-d5,-(sp)
	move.w	d1,d2
	mulu	d0,d2
	clr.w	d2
	swap	d2
	swap	d1
	move.w	d1,d3
	mulu	d0,d3
	swap	d0
	move.w	d1,d4
	mulu	d0,d4
	swap	d4
	swap	d1
	move.w	d1,d5
	mulu	d0,d5
	move.l	d2,d0
	add.l	d3,d0	
	add.l	d4,d0	
	add.l	d5,d0	
	movem.l	(sp)+,d1-d5
	rts	

; translates 2d vertices

; d0 - number of vertices
; d1 - x translation
; d2 - y translation

translate_coords:
	subq.w	#1,d0
.loop:
	add.w	d1,(a0)+
	add.w	d2,(a0)+
	dbra	d0,.loop	
	rts

; finds the smallest/largest 2d vertice in the list

; d0 - number of vertices
; a0 - pointer to vertice list

get_min_max_coard:
	move.w	d0,d7
	move.w	#$7fff,d0
	move.w	#$7fff,d1
	move.w	#$8000,d2
	move.w	#$8000,d3
	subq.w	#1,d7
.loop:
	movem.w	(a0)+,d4-d5
	cmp.w	d4,d0
	ble.s	.no_min1
	move.w	d4,d0
.no_min1:
	cmp.w	d5,d1
	ble.s	.no_min2
	move.w	d5,d1
.no_min2:
	cmp.w	d4,d2
	bge.s	.no_max1
	move.w	d4,d2
.no_max1:
	cmp.w	d5,d3
	bge.s	.no_max2
	move.w	d5,d3
.no_max2:
	dbra	d7,.loop
	rts

; takes a coordinate pair, and makes it into
; a list for a quadralataral
; d0 - x offset
; d1 - y offset
; a0 - list

write_out_quad:
	neg.w	d0
	neg.w	d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	neg.w	d0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	neg.w	d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	neg.w	d0	
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	rts

; rotates vertices about the origin

; d0 - number of vertices
; d1 - angle to rotate
; a0 - source list
; a1 - destination list

z_rotate_verts:
	subq.w	#1,d0
	move.w	d0,d7
	move.w	d1,d0
	bsr	get_sine_cosine

.loop:
	movem.w	(a0)+,d3-d4
	move.w	d3,d5
	move.w	d4,d6
	muls	d1,d3
	muls	d0,d4
	sub.l	d4,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a1)+
	muls	d1,d6	
	muls	d0,d5
	add.l	d6,d5
	add.l	d5,d5
	swap	d5
	move.w	d5,(a1)+	
	dbra	d7,.loop
	rts

; find out the sine/cosine values for a particular angle
; d0 - angle

get_sine_cosine:
	move.l	sine_pointer(a4),a2
	move.w	d0,d1
	add.w	#SINE_LEN/4,d1
	and.w	#SINE_LEN-1,d0
	and.w	#SINE_LEN-1,d1
	add.w	d0,d0
	add.w	d1,d1
	move.w	(a2,d0),d0	; sine
	move.w	(a2,d1),d1	; cosine
	rts
