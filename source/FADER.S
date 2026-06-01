FADE_DONE	equ	256

SegaFader:
	move.w	BUBX,d0
	move.w	BUBY,d1
	sub.w	WINDX,d0
	sub.w	WINDY,d1			;screen x and y
	moveq	#0,d2
	moveq	#0,d3
	move.w	screen_height,d4
	lsr.w	#1,d4
	cmp.w	#160,d0
	bgt.s	.no_mx
	move.w	#320,d2

.no_mx:
	lsr.w	#1,d4
	cmp.w	d4,d1
	bgt.s	.no_my
	move.w	screen_height,d1
.no_my:
	muls	d4,d4
	muls	d5,d5
	add.l	d4,d5			radius
	move.w	d5,fade_radius_squared
	move.w	d0,fade_x
	move.w	d1,fade_y
	move.w	d5,d6
	move.w	#-8,fade_direction
	move.w	#256,fade_scale
	st	fade_installed
	rts

FADER:	rts
	tst.b	fade_installed
	bne.s	.ok
	rts
.ok:
	moveq	#0,d5
	moveq	#0,d1
	move.w	fade_radius_squared,d5
	move.w	fade_y,d1
	bsr	fill_window
	move.w	d1,d3
	moveq	#0,d4
.lp:
	bsr	draw_line_of_circle
	addq	#1,d4
	dbf	d3,.lp
	bsr	draw_window
	move.w	fade_scale,d2
	add.w	fade_direction,d2
	move.w	d2,fade_scale
	not.b	fade_toggle
	beq.s	.fade_1
	move.l	#CIRCLE_VIEW1,d0
	bra.s	.fade_00
.fade_1:
	move.l	#CIRCLE_VIEW2,d0
.fade_00:
	move.l	d0,view_circle
	cmp.w	#0,d2
	beq.s	.done
	cmp.w	#FADE_DONE,d2
	bne.s	.ok1
.done:
	sf	fade_installed
.ok1:
	rts

draw_line_of_circle:
	move.w	d1,d0
	sub.w	d4,d0
	beq	.zero
	mulu	d0,d0
	neg.w	d0
	add.w	d5,d0
	ext.l	d0
	moveq	#32-1,d7
.sqrt1:
	btst	d7,d0
	dbne	d7,.sqrt1
	lsr.w	#1,d7
	bset	d7,d7
	move.l	d0,d2
	divs	d7,d2
	add	d2,d7
	lsr.w	#1,d7
	move.l	d0,d2
	divs	d7,d2
	add	d2,d7
	lsr.w	#1,d7
	move.l	d0,d2
	divs	d7,d2
	add	d2,d7
	lsr.w	#1,d7
	mulu	fade_scale,d7
	lsr.l	#8,d7
	cmp.w	#0,d7
	beq.s	.zero
;;draw_top_line	
	move.w	d4,d2
	swap	d2
	move.w	fade_x,d2
	sub.w	d7,d2
	move.l	d2,A1_PIXEL		;set x start
	
	moveq	#1,d2
	swap	d2
	move.w	d7,d2
	add.w	d2,d2
	move.l	d2,B_COUNT
	
	move.l	#PATDSEL|CLIP_A1,B_CMD

;;draw_bottom_line	
	move.l	d2,B_COUNT		;length of the line
	
	move.w	fade_y,d2
	add.w	d2,d2
	sub.w	d4,d2
	swap	d2
	move.w	d7,d2
	sub.w	fade_x,d2
	move.l	d2,A1_PIXEL		;set x start
	
	move.l	#PATDSEL|CLIP_A1,B_CMD

.zero:
	rts
	
fill_window:
	move.l	#PITCH1|PIXEL8|WID40|XADDPHR,A1_FLAGS
	move.l	view_circle,A1_BASE
	moveq	#0,d0
	move.l	d0,A1_PIXEL
	moveq	#-1,d0
	move.l	d0,B_PATD
	move.l	d0,B_PATD+4
	move.l	#280*$10000+320,B_COUNT
	move.l	#1*$10000+$ffff&(-320),A1_STEP
;	move.l	#PATDSEL|UPDA1,B_CMD	
	
	move.l	#280*$10000+320,A1_CLIP
	moveq	#0,d0
	move.l	d0,B_PATD
	move.l	d0,B_PATD+4
	rts
	
draw_window:
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	move.l	view_circle,d0
	lsl	#8,d0
	move.l	d0,(a0)+
	move.l	#%00000000010001100000000000000000|(ntsc_n_vdb<<3),(a0)+
	move.l	#%00000000000000001000000001000010,(a0)+
	move.l	#%10000000101000001000000000000000,12(a0)
	rts

*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000010001100000000000000000,4(a0)
*	%0000000000000000110000000000001010000000101000001000000000000000,12(a0)
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000

view_circle:	dc.l	CIRCLE_VIEW1
fade_scale:		dc.w	0
fade_x:			dc.w	0
fade_y:			dc.w	0
fade_direction:		dc.w	0
fade_radius_squared:	dc.w	0
fade_installed:		dc.b	0
fade_toggle:		dc.b	0
	even