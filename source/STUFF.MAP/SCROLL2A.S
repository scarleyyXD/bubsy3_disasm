.macro	do_macro_square
	move.l	d6,A1_PIXEL-B_PATD(a5)
	move.l	a2,A1_BASE-B_PATD(a5)
	move.l	d1,B_COUNT-B_PATD(a5)
	moveq	#0,d7
	move.w	(a6)+,d7
	bne.s	.1\~
	if	DEBUG
	move.l	#$ff00ffff,BORD1
	endif
	move.l	d2,B_CMD-B_PATD(a5)				;set it going with a pattern
	if	DEBUG
	move.l	#$0000ffff,BORD1
	endif
	bra.s	.2\~
.1\~:
	add.l	d7,d7
	add.l	d7,d7
	move.w	\1(a4,d7.l),d7
	ext.l	d7
	swap	d7
	move.l	d7,A2_PIXEL-B_PATD(a5)
	if	DEBUG
	move.l	#$00ffffff,BORD1
	endif
	move.l	d0,B_CMD-B_PATD(a5)				;set it going
	if	DEBUG
	move.l	#$0000ffff,BORD1
	endif
.2\~:
	.endm

;	MAP_WORD is used to signify if the map is built of words or of bytes.. 0=byte else words.
scroll_land:
;	Set the blitter pattern to all 0's for a quick blast and all other constants in the blitter
;	speed is important
;	a1 points to a data structure of type a_map
	moveq	#1,d7			;scroll direction
	moveq	#$f0,d6
	move.w	map_y(a1),d0		;get the new y value
	and.w	d6,d0			;get rid of the shift value
	move.w	d0,d1			;copy it
	move.w	previous_y(a1),d2	;what was it before
	move.w	d1,previous_y(a1)	;save the new value
	sub.w	d2,d1			;get direction -1=up , 0=nothing , 1=down
	asr.w	#4,d1			;get block value
	add.w	d1,d7			;update direction
	lsl.w	#2,d7			;shift it up into place	
	addq.w	#1,d7			;scroll direction
	move.w	map_x(a1),d0		;get the new x value
	and.w	d6,d0			;get rid of the shift value
	move.w	d0,d4			;copy it
	move.w	previous_x(a1),d3	;what was it before
	move.w	d4,previous_x(a1)	;save the new value
	sub.w	d3,d4			;get direction -1=<<, 0=^, 1=>> 
	asr.w	#4,d4			;get block value
	add.w	d4,d7			;update direction
	move.w	d7,scroll_dir(a1)	;save it
	cmp.w	#5,d7
	bne.s	.ok1
	rts
.ok1:
	tst.w	d7
	bmi.s	.err1
	cmp.w	#$a,d7
	ble.s	.ok
.err1:
	illegal
.ok:
	lea	B_PATD,a5
	lea	DOUBLETAKE,a4
	moveq	#0,d6
	move.l	#$00010000+((-BLOCK_HEIGHT/2)&$ffff),A1_STEP-B_PATD(a5)
	move.l	#PITCH1|XADDPHR|WID128|PIXEL16,A2_FLAGS-B_PATD(a5)	;a2 (Source)
	move.l	#PITCH1|XADDPHR|WID192|PIXEL16,A1_FLAGS-B_PATD(a5)	;a1 (Dest)
	move.l	d6,(a5)				;clear the pattern data
	move.l	d6,4(a5)
	move.w	map_x(a1),d6			;get the current x position
	andi.w	#($ffff<<BLOCK_BITS)&$ffff,d6	;mask out the shift
	moveq	#0,d7				;now do the same for the y
;	move.w	map_y(a1),d7			;position and multiply
;	and.w	#($ffff<<BLOCK_BITS)&$ffff,d7	;to get absolute value down
;	mulu	#PLAYFIELD_BLITTER_WIDTH*MAP_DEPTH/MAP_DEPTH,d7
	move.l	d6,d7				;was add add both to relative position in memory
	
	move.w	d6,d5				;get the x position
	lsr.w	#BLOCK_BITS,d5			;get rid of the shift
	move.w	d5,a6				;use that for the map x position
	add.w	d5,a6
	moveq	#0,d5
	move.w	map_y(a1),d5			;now do the same for the y
	lsr.w	#BLOCK_BITS,d5
	move.l	d5,d4				;copy for use later on
	mulu	map_width(a1),d5		;but multiply to get offset down
	add.l	d5,a6				;add x and y and then add addr of the map
	add.l	map_address(a1),a6		;a6 now points to map position to top right of screen
	divu	#PLAYFIELD_HEIGHT,d4
	clr.w	d4
	swap	d4				;only interested in remainder
	add.b	d4,d4
	add.b	d4,d4				;times 4 as an index into table
	lea	map_table_offset(pc),a3
	lea	(a3,d4.w),a3			;point to offsets
	mulu	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH/4,d4
	move.l	d4,a2
	
	add.l	d7,a2				;now point to the real positions
	add.l	map_1(a1),a2			;in memory for both playfields
	move.l	blockset1(a1),A2_BASE-B_PATD(a5)	;now point to the blocksets for
	move.w	scroll_dir(a1),d0		;-1,0,1 to
	add.w	d0,d0				;double it for branch table
	add.w	d0,d0				;double it for branch table

;*********************************************************
;*							*
;*	d0	is the scroll direction			*
;*	a0	points to the blockset			*
;*	a2	points to the map screen		*
;*	a6	points to the map data			*
;*							*
;*********************************************************

	jmp	direction(pc,d0.w)

direction:				;*	x_dir	y_dir
	bra	up_left			;	*0	-1	-1
	bra	up_centre		;	*1	 0	-1
	bra	up_right		;	*2	 1	-1
	bra	centre_centre	;		*7	 illegal
	bra	centre_left		;	*4	-1	 0
	bra	centre_centre	;		*5	 0	 0
	bra	centre_right	;		*6	 1	 0
	bra	centre_centre	;		*3	 illegal
	bra	down_left		;	*8	-1	 1
	bra	down_centre		;	*9	 0	 1
	bra	down_right		;	*a	 1	 1

centre_centre:			
	rts
up_right:
	movem.l	a2/a6,-(sp)
	bsr.s	centre_right
	movem.l	(sp)+,a2/a6
	bra	blit_line_across
up_left:
	movem.l	a2/a6,-(sp)
	bsr.s	centre_left
	movem.l	(sp)+,a2/a6
up_centre:
	bra	blit_line_across
down_right:
	movem.l	a2/a3/a6,-(sp)
	bsr.s	centre_right
	movem.l	(sp)+,a2/a3/a6
	bra.s	down_centre
down_left:
	movem.l	a2/a3/a6,-(sp)
	bsr.s	centre_left
	movem.l	(sp)+,a2/a3/a6
down_centre:
	rept	(PLAYFIELD_HEIGHT-3)
	add.l	(a3)+,a2
	endr
MAP_1ALTER	equ	*+2
	lea	2*(MAP_WIDTH*((PLAYFIELD_HEIGHT-3)))(a6),a6		;add.l->lea
	bra	blit_line_across
centre_right:
	lea	BLOCK_HEIGHT*(PLAYFIELD_WIDTH-1)(a2),a2
	lea	2*PLAYFIELD_WIDTH-2(a6),a6
centre_left:
blit_line_down:
	move.l	#SRCEN|UPDA1|LFU_A|LFU_AN,d0
	move.l	#($00010001<<BLOCK_BITS)-(BLOCK_HEIGHT/2),d1
	move.l	#UPDA1|PATDSEL,d2
	moveq	#0,d6
	move.l	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH,d5
	do_macro_square	2
	moveq	#(PLAYFIELD_HEIGHT-3),d3
.lp:
	add.l	(a3)+,a2
MAP_2ALTER	equ	*+2
	lea	2*(MAP_WIDTH-1)(a6),a6
	do_macro_square	2
	dbf	d3,.lp
	rts
blit_line_across:
	move.l	#SRCEN|UPDA1|LFU_A|LFU_AN,d0
	move.l	#($00010001<<BLOCK_BITS)-(BLOCK_HEIGHT/2),d1
	move.l	#UPDA1|PATDSEL,d2
	moveq	#0,d6
	moveq	#MAP_DEPTH*BLOCK_HEIGHT,d5
	do_macro_square	2
	moveq	#PLAYFIELD_WIDTH-1,d3
.lp:
	add.l	d5,a2
	do_macro_square	2
	dbf	d3,.lp
	add.l	d5,a2
	do_macro_square	2
	rts
	
initalise_land:
	lea	B_PATD,a5
	lea	DOUBLETAKE,a4
	moveq	#0,d6
	move.l	#$00010000+((-BLOCK_HEIGHT/2)&$ffff),A1_STEP-B_PATD(a5)
	move.l	#PITCH1|XADDPHR|WID128|PIXEL16,A2_FLAGS-B_PATD(a5)	;a2 (Source)
	move.l	#PITCH1|XADDPHR|WID192|PIXEL16,A1_FLAGS-B_PATD(a5)	;a1 (Dest)
	
	move.l	d6,(a5)				;clear the pattern data
	move.l	d6,4(a5)
	
	moveq	#0,d7
	move.w	map_x(a1),d7			;get the current x position
	move.w	d7,previous_x(a1)		;save the last x value
	andi.w	#($ffff<<BLOCK_BITS)&$ffff,d7	;mask out the shift
	move.w	map_y(a1),previous_y(a1)	;save the last y position
	
	move.l	d7,d5				;get the x position
	lsr.w	#BLOCK_BITS,d5			;get rid of the shift
	move.w	d5,a6				;copy that for later
	add.w	d5,a6
	move.w	map_y(a1),d5			;now do the same for the y
	lsr.w	#BLOCK_BITS,d5
	move.l	d5,d4				;copy for use later on
	divu	#PLAYFIELD_HEIGHT,d4
	clr.w	d4
	swap	d4				;only interested in remainder
	add.b	d4,d4
	add.b	d4,d4				;times 4 as an index into table
	lea	map_table_offset(pc),a3
	lea	(a3,d4.w),a3			;point to offsets
	mulu	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH/4,d4
	move.l	d4,a2
	mulu	map_width(a1),d5		;but multiply to get offset down
	add.l	d5,a6				;add x and y and then add addr of the map
	add.l	map_address(a1),a6		;a6 now points to map position to top right of screen
	
	add.l	d7,a2				;now point to the real positions
	add.l	map_1(a1),a2			;in memory for both playfields
	move.l	blockset1(a1),A2_BASE-B_PATD(a5)		;now point to the blocksets for

	rept	PLAYFIELD_WIDTH-1		;remember that 1 more block is draw accross than ususal
	movem.l	a2/a3/a6,-(sp)
	bsr	blit_line_down			;do one line of the map
	movem.l	(sp)+,a2/a3/a6
	lea	BLOCK_HEIGHT*MAP_DEPTH(a2),a2	;point next line in the screen
	addq.l	#2,a6				;point to the map cell
	endr
	
	bsr	blit_line_down			;do one line of the map
	rts

scroll_land1:
;	Set the blitter pattern to all 0's for a quick blast and all other constants in the blitter
;	speed is important
;	a1 points to a data structure of type a_map
	moveq	#1,d7			;scroll direction
	moveq	#$f0,d6
	move.w	map_y(a1),d0		;get the new y value
	and.w	d6,d0			;get rid of the shift value
	move.w	d0,d1			;copy it
	move.w	previous_y(a1),d2	;what was it before
	move.w	d1,previous_y(a1)	;save the new value
	sub.w	d2,d1			;get direction -1=up , 0=nothing , 1=down
	asr.w	#4,d1			;get block value
	add.w	d1,d7			;update direction
	lsl.w	#2,d7			;shift it up into place	
	addq.w	#1,d7			;scroll direction
	move.w	map_x(a1),d0		;get the new x value
	and.w	d6,d0			;get rid of the shift value
	move.w	d0,d4			;copy it
	move.w	previous_x(a1),d3	;what was it before
	move.w	d4,previous_x(a1)	;save the new value
	sub.w	d3,d4			;get direction -1=<<, 0=^, 1=>> 
	asr.w	#4,d4			;get block value
	add.w	d4,d7			;update direction
	move.w	d7,scroll_dir(a1)	;save it
	cmp.w	#5,d7
	bne.s	.ok1
	rts
.ok1:
	tst.w	d7
	bmi.s	.err1
	cmp.w	#$a,d7
	ble.s	.ok
.err1:
	illegal
.ok:
	lea	B_PATD,a5
	lea	DOUBLETAKE,a4
	moveq	#0,d6
	move.l	#$00010000+((-BLOCK_HEIGHT/2)&$ffff),A1_STEP-B_PATD(a5)
	move.l	#PITCH1|XADDPHR|WID128|PIXEL16,A2_FLAGS-B_PATD(a5)	;a2 (Source)
	move.l	#PITCH1|XADDPHR|WID192|PIXEL16,A1_FLAGS-B_PATD(a5)	;a1 (Dest)
	
	move.l	d6,(a5)				;clear the pattern data
	move.l	d6,4(a5)
	move.w	map_x(a1),d6			;get the current x position
	andi.w	#($ffff<<BLOCK_BITS)&$ffff,d6	;mask out the shift
	moveq	#0,d7				;now do the same for the y
;	move.w	map_y(a1),d7			;position and multiply
;	and.w	#($ffff<<BLOCK_BITS)&$ffff,d7	;to get absolute value down
;	mulu	#PLAYFIELD_BLITTER_WIDTH*MAP_DEPTH/MAP_DEPTH,d7
	move.l	d6,d7				;was add both to relative position in memory
	
	move.w	d6,d5				;get the x position
	lsr.w	#BLOCK_BITS,d5			;get rid of the shift
	move.w	d5,a6				;use that for the map x position
	add.w	d5,a6
	moveq	#0,d5
	move.w	map_y(a1),d5			;now do the same for the y
	lsr.w	#BLOCK_BITS,d5
	move.l	d5,d4				;copy for use later on
	mulu	map_width(a1),d5		;but multiply to get offset down
	add.l	d5,a6				;add x and y and then add addr of the map
	add.l	map_address(a1),a6		;a6 now points to map position to top right of screen
	divu	#PLAYFIELD_HEIGHT,d4
	clr.w	d4
	swap	d4				;only interested in remainder
	add.b	d4,d4
	add.b	d4,d4				;times 4 as an index into table
	lea	map_table_offset(pc),a3
	lea	(a3,d4.w),a3			;point to offsets
	mulu	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH/4,d4
	move.l	d4,a2
	
	add.l	d7,a2				;now point to the real positions
	add.l	map_1(a1),a2			;in memory for both playfields
	move.l	blockset1(a1),a0		;now point to the blocksets for
	move.w	scroll_dir(a1),d0		;-1,0,1 to
	add.w	d0,d0				;double it for branch table
	add.w	d0,d0				;double it for branch table

;*********************************************************
;*							*
;*	d0	is the scroll direction			*
;*	a0	points to the blockset			*
;*	a2	points to the map screen		*
;*	a6	points to the map data			*
;*							*
;*********************************************************

	jmp	direction1(pc,d0.w)

direction1:				;*	x_dir	y_dir
	bra	up_left1		;	*0	-1	-1
	bra	up_centre1		;	*1	 0	-1
	bra	up_right1		;	*2	 1	-1
	bra	centre_centre1	;		*7	 illegal
	bra	centre_left1	;		*4	-1	 0
	bra	centre_centre1	;		*5	 0	 0
	bra	centre_right1	;		*6	 1	 0
	bra	centre_centre1	;		*3	 illegal
	bra	down_left1		;	*8	-1	 1
	bra	down_centre1	;		*9	 0	 1
	bra	down_right1		;	*a	 1	 1

centre_centre1:
	rts
up_right1:
	movem.l	a2/a6,-(sp)
	bsr.s	centre_right1
	movem.l	(sp)+,a2/a6
	bra	blit_line_across1
up_left1:
	movem.l	a2/a6,-(sp)
	bsr.s	centre_left1
	movem.l	(sp)+,a2/a6
up_centre1:
	bra	blit_line_across1
down_right1:
	movem.l	a2/a3/a6,-(sp)
	bsr.s	centre_right1
	movem.l	(sp)+,a2/a3/a6
	bra.s	down_centre1
down_left1:
	movem.l	a2/a3/a6,-(sp)
	bsr.s	centre_left1
	movem.l	(sp)+,a2/a3/a6
down_centre1:
	rept	(PLAYFIELD_HEIGHT-3)
	add.l	(a3)+,a2
	endr
MAP_3ALTER	equ	*+2
	lea	2*(MAP_WIDTH*((PLAYFIELD_HEIGHT-3)))(a6),a6		;add.l->lea
	bra	blit_line_across1
centre_right1:
	lea	BLOCK_HEIGHT*(PLAYFIELD_WIDTH-1)(a2),a2
	lea	2*PLAYFIELD_WIDTH-2(a6),a6
centre_left1:
blit_line_down1:
	move.l	#SRCEN|UPDA1|LFU_A|LFU_AN,d0
	move.l	#($00010001<<BLOCK_BITS)-(BLOCK_HEIGHT/2),d1
	move.l	#UPDA1|PATDSEL,d2
	moveq	#0,d6
	move.l	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH,d5
	do_macro_square	0
	moveq	#(PLAYFIELD_HEIGHT-3),d3
.lp:
	add.l	(a3)+,a2
MAP_4ALTER	equ	*+2
	lea	2*(MAP_WIDTH-1)(a6),a6
	do_macro_square	0
	dbf	d3,.lp
	rts
blit_line_across1:
	move.l	#SRCEN|UPDA1|LFU_A|LFU_AN,d0
	move.l	#($00010001<<BLOCK_BITS)-(BLOCK_HEIGHT/2),d1
	move.l	#UPDA1|PATDSEL,d2
	moveq	#0,d6
	moveq	#MAP_DEPTH*BLOCK_HEIGHT,d5
	do_macro_square	0
	moveq	#PLAYFIELD_WIDTH,d3
.lp:
	add.l	d5,a2
	do_macro_square	0
	dbf	d3,.lp
	rts

initalise_land1:
	lea	B_PATD,a5
	lea	DOUBLETAKE,a4
	moveq	#0,d6
	move.l	#$00010000+((-BLOCK_HEIGHT/2)&$ffff),A1_STEP-B_PATD(a5)
	move.l	#PITCH1|XADDPHR|WID128|PIXEL16,A2_FLAGS-B_PATD(a5)	;a2 (Source)
	move.l	#PITCH1|XADDPHR|WID192|PIXEL16,A1_FLAGS-B_PATD(a5)	;a1 (Dest)
	
	move.l	d6,(a5)				;clear the pattern data
	move.l	d6,4(a5)
	
	moveq	#0,d7
	move.w	map_x(a1),d7			;get the current x position
	move.w	d7,previous_x(a1)		;save the last x value
	andi.w	#($ffff<<BLOCK_BITS)&$ffff,d7	;mask out the shift
	move.w	map_y(a1),previous_y(a1)	;save the last y position
	
	move.l	d7,d5				;get the x position
	lsr.w	#BLOCK_BITS,d5			;get rid of the shift
	move.w	d5,a6				;copy that for later
	add.w	d5,a6
	move.w	map_y(a1),d5			;now do the same for the y
	lsr.w	#BLOCK_BITS,d5
	move.l	d5,d4				;copy for use later on
	divu	#PLAYFIELD_HEIGHT,d4
	clr.w	d4
	swap	d4				;only interested in remainder
	add.b	d4,d4
	add.b	d4,d4				;times 4 as an index into table
	lea	map_table_offset(pc),a3
	lea	(a3,d4.w),a3			;point to offsets
	mulu	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH/4,d4
	move.l	d4,a2
	mulu	map_width(a1),d5		;but multiply to get offset down
	add.l	d5,a6				;add x and y and then add addr of the map
	add.l	map_address(a1),a6		;a6 now points to map position to top right of screen
	
	add.l	d7,a2				;now point to the real positions
	add.l	map_1(a1),a2			;in memory for both playfields
	move.l	blockset1(a1),a0		;now point to the blocksets for

	rept	PLAYFIELD_WIDTH-1		;remember that 1 more block is draw accross than ususal
	movem.l	a2/a3/a6,-(sp)
	bsr	blit_line_down1			;do one line of the map
	movem.l	(sp)+,a2/a3/a6
	lea	BLOCK_HEIGHT*MAP_DEPTH(a2),a2	;point next line in the screen
	addq.l	#2,a6				;point to the map cell
	endr
	
	bsr	blit_line_down1			;do one line of the map
	rts
	
map_table_offset:
	rept	3
	dcb.l	(PLAYFIELD_HEIGHT-1),MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH
	dc.l	-(PLAYFIELD_HEIGHT-1)*MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH
	endr
	
center_window:
	moveq	#$10,d2
	move.w	WINDX,d0
	move.w	WINDXOLD,d1
	sub.w	d1,d0
	bpl	.moving_right
	neg.w	d0
	cmp.w	d2,d0
	ble.s	.check_vert
	sub.w	d2,d1
	move.w	d1,WINDX
	bra.s	.check_vert
.moving_right:
	cmp.w	d2,d0
	ble.s	.check_vert
	add.w	d2,d1
	move.w	d1,WINDX
.check_vert:
	move.w	WINDY,d0
	move.w	WINDYOLD,d1
;	move.b	#BOSSFLAG,d2
;	and.b	GAMEFLAGS1,d2
;	bne.s	.fix_y
	sub.w	d1,d0
	bpl	.moving_down
	neg.w	d0
	cmp.w	d2,d0
	ble.s	.check_none
	sub.w	d2,d1
	move.w	d1,WINDY
	rts
.moving_down:
	cmp.w	d2,d0
	ble.s	.check_none
	add.w	d2,d1
	move.w	d1,WINDY
.check_none:
	rts
.fix_y:
	move.w	d1,WINDY
	rts
