DRAW_DETECT_BOX
	movem.l	d0-d7,-(sp)
	move.l	detect_screen_addr(pc),A1_BASE
	move.l	#PIXEL1|PITCH1|WID320|XADDPIX,A1_FLAGS
	move.l	#239*$10000+319,A1_CLIP
	moveq	#-1,d7
	move.l	d7,B_PATD
	move.l	d7,B_PATD+4
	move.l	#$0001ffff,A1_STEP
	
	lea	BUBBOX1,a0
	bsr.s	.draw
	lea	BUBBOX2,a0
	bsr.s	.draw
	lea	BUBBOX3,a0
	bsr.s	.draw
	movem.l	(sp)+,d0-d7
	rts

.draw	move.w	WINDX,d6
	move.w	WINDY,d7
	
	movem.w	(a0),d0-d3
	sub.w	d6,d0
	sub.w	d7,d1
	sub.w	d6,d2
	sub.w	d7,d3
	
	move.w	d0,d4
	move.w	d2,d5
	move.w	d1,d6
	bsr.s	draw_v_line
	
	move.w	d0,d4		x1
	move.w	d2,d5		x2
	move.w	d3,d6		y
	bsr.s	draw_v_line
	
	move.w	d0,d4
	move.w	d1,d5
	move.w	d3,d6
	bsr.s	draw_h_line
	
	move.w	d2,d4		x
	move.w	d1,d5		y1
	move.w	d3,d6		y2

draw_h_line
	sub.w	d5,d6
	beq.s	noTT
	swap	d6
	move.w	#1,d6
	move.l	d6,B_COUNT			;set length
	swap	d5
	move.w	d4,d5
	move.l	d5,A1_PIXEL			;set start point
draw_common
	move.l	#PATDSEL|UPDA1|DSTEN|CLIP_A1,B_CMD
noTT	rts
	

draw_v_line
	cmp.w	d4,d5
	bmi.s	.no_swap
	exg	d4,d5
.no_swap
	sub.w	d5,d4
	beq.s	.no
	swap	d4
	move.w	#1,d4
	swap	d4
	move.l	d4,B_COUNT			;set length
	swap	d6
	move.w	d5,d6
	move.l	d6,A1_PIXEL			;set start point
	move.l	#PATDSEL|UPDA1|DSTEN|CLIP_A1,B_CMD
.no	rts
	


	
DRAW_DETECTPOINTS 
	movem.l	d0/d2-d3/d7/a0-a1,-(sp)
	move.l	detect_screen_addr(pc),a1
	move.l	OBJMAP(a5),a0
	moveq	#0,d2
	move.b	OBJFRAME(a5),d2
	lsl.w	#5,d2							;quick mult by 32
	lea	8(a0,d2.w),a0
	
	moveq	#6-1,d7							;6 points to plot
.lp	
	MOVE.w	OBJX(A5),D2						;find absolute x position ( no h-flip )
	moveq	#$08,D0
	and.b	OBJOAM0(A5),D0						;begin collision check by finding out if we are h_flipped
	BNE.s	.FINDXFLIP

	ADD.w	(a0)+,D2
	BRA.s	.STOREX
.FINDXFLIP								;find x position ( h-flip)
	SUB.w	(a0)+,D2
.STOREX
	MOVE.w	OBJY(A5),D3						;find y position ( no v-flip)
	ADD.w	(a0)+,D3

	sub.w	WINDX,d2
	bmi.s	.no_plot
	cmp.w	#320,d2
	bge.s	.no_plot

	sub.w	WINDY,d3
	bmi.s	.no_plot
	cmp.w	#240,d3
	bge.s	.no_plot
	
	move.w	d3,d0
	lsl.w	#2,d0
	add.w	d0,d3
	lsl.w	#3,d3				;y*40
	moveq	#7,d0
	and.w	d2,d0				;get pixel value
	lsr.w	#3,d2				;div by 8 to get word value
	eor.b	#7,d0				;was 0->15 now 15->0
	add.w	d3,d2				;x+y
	bset	d0,(a1,d2.w)
.no_plot	
	dbf	d7,.lp							;do rest of the points
	movem.l	(sp)+,d0/d2-d3/d7/a0-a1
	rts


detect_screen_addr	dc.l	dect_scr1
			dc.l	dect_scr2
			
			

DRAW_DETECTSCREEN 
	
*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000010001100000000000000000,4(A0)
*	%0000000000000000100000000000000001010000000101001000000000000000,12(A0)
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000

	movem.l	d0-a6,-(sp)
	
	lea	view_pal+2,a0
	addq.b	#1,(a0)+
	st	(a0)
	
	move.l	view_pal,CLUT
	
	move.l	detect_screen_addr(pc),d0				;setup image
	lsl.l	#8,d0
	
	move.l	#%00000000010001100000000000000000,d1
	move.l	#%00000000000000001000000000000000,d2
	move.l	#%01010000000101001000000000000000,d3
	
	
	
	jsr	ADD_OL							;add this object to the ol
	movem.l	d0-d3,(a0)
	move.b	#Q_BMO,O_TYPE(a0)
	
	
	lea	detect_screen_addr(pc),a0
	move.l	(a0),d0							;exchange screen pointers
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	
	movem.l	(sp)+,d0-a6
	rts


CLS_DETECTSCREEN
	move.l	#$ff,BORD1
	move.l	#PITCH1|PIXEL16|WID20|XADDPHR,A1_FLAGS			;blitter cls
	move.l	detect_screen_addr(pc),A1_BASE
	move.l	#240*$10000+20,B_COUNT
	move.l	#1*$10000+(-20&$ffff),A1_STEP
	moveq	#0,d0
	move.l	d0,A1_PIXEL
	move.l	d0,B_PATD						;fill pattern
	move.l	d0,B_PATD+4
	move.l	#PATDSEL|UPDA1,B_CMD					;set it going and clip
	move.l	#0,BORD1
	rts
