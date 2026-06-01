edit_complex_sprite
	bsr.s	is_456_pressed
	lea	sprite_table_start,a0
.pressed
	bsr	select_sprite_to_edit
	bsr	edit_sprite
	bsr.s	is_456_pressed
	bra.s	.pressed

is_456_pressed					;if 456 not pressed then quit altogether
	Move.l	joycur1(pc),d0
	Btst	#KEY_4,d0
	Beq.s	.Not_Pressed
	Btst	#KEY_5,d0
	Beq.s	.Not_Pressed
	Btst	#KEY_6,d0
	Beq.s	.Not_Pressed
	rts
.Not_Pressed	
	addq	#4,sp
	Rts

is_789_pressed
	Move.l	joycur1(pc),d0
	Btst	#KEY_7,d0
	Beq.s	.Not_Pressed
	Btst	#KEY_8,d0
	Beq.s	.Not_Pressed
	Btst	#KEY_9,d0
	Beq.s	.Not_Pressed
	addq	#4,sp
.Not_Pressed	
	Rts

up_just_pressed
	Move.l	joyedge1,d0
	not.l	d0
	Btst	#UP_B,d0
	bcc.s	.no
	cmp.l	#sprite_table_start,a0
	beq.s	.no
	subq.l	#4,a0
.no	Rts

fire_pressed
	Move.l	joycur1,d0
	Btst	#FIRE_A,d0
	Beq.s	.Not_Pressed
	Btst	#FIRE_B,d0
	Beq.s	.Not_Pressed
	Btst	#FIRE_C,d0
	Beq.s	.Not_Pressed
	addq	#4,sp
.Not_Pressed	
	Rts


down_just_pressed
	Move.l	joyedge1,d0
	not.l	d0
	Btst	#DOWN_B,d0
	bcc.s	.no
	cmp.l	#sprite_table_end-4,a0
	beq.s	.no
	addq.l	#4,a0
.no	Rts

select_sprite_to_edit
	bsr.s	up_just_pressed
	bsr.s	down_just_pressed
	bsr.s	fire_pressed
	move.l	a0,current_pointer
	clr.l	current_frame
	clr.w	current_flip
	jsr	NEW_OL
	bsr.s	print_this_sprite
	jsr	WVBL
	bsr	is_456_pressed
	bsr	is_789_pressed
	move.l	current_pointer,a0
	bra.s	select_sprite_to_edit
	





print_this_sprite
	move.l	current_pointer,a1					;get addr of pointer
	move.l	(a1),a1							;dma pointer
	addq	#2,a1
	move.w	current_frame,d0
	lsl.w	#3,d0
	add.w	d0,a1
	tst.w	current_flip
	beq.s	.cont
	addq.l	#4,a1
	bra.s	.cont
	move.w	(a1)+,d2
.loop	move.w	(a1)+,d0						;x
	move.w	(a1)+,d1						;y
	move.w	(a1)+,d4						;sprite number

	add.w	#320/2,d0						;centre on screen
	add.w	#24/2,d1
	move.l	LOAD_ALI_BABA_SPRITES_HERE,a0				;point to sprite table
	jsr	print_a_sprite_normal
.cont	dbf	d2,.loop						;print all the sprites
	bsr	print_sprite_info
	rts




print_sprite_info
	move.l	current_pointer,d0
	sub.l	#sprite_table_start,d0
	lsr	#2,d0
	divu	#10,d0
	add.l	#"0000",d0
	move.b	d0,sprite_number
	swap	d0
	move.b	d0,sprite_number+1

	moveq	#0,d0
	move.w	current_frame,d0
	divu	#10,d0
	add.l	#"0000",d0
	move.b	d0,sprite_frame
	swap	d0
	move.b	d0,sprite_frame+1
	
	
	moveq	#0,d0
	move.l	current_point,d0
	divu	#10,d0
	add.l	#"0000",d0
	move.b	d0,sprite_point
	swap	d0
	move.b	d0,sprite_point+1
	
	
	move.l	current_pointer,a1					;get addr of pointer
	move.l	(a1),a1							;get the value pointing to
	moveq	#0,d0							;get number of points
	move.w	(a1),d0
	move.w	d0,-(sp)
	pea	(a1)
	divu	#10,d0
	add.l	#"0000",d0
	move.b	d0,sprite_points
	swap	d0
	move.b	d0,sprite_points+1
	
	lea	sprite_number_text,a1
	bsr	print_text_message
	
	lea	sprite_frame_text,a1
	bsr	print_text_message
	
	lea	sprite_points_text,a1
	bsr	print_text_message
	
	lea	sprite_current_text,a1
	bsr	print_text_message
	

	move.b	#4,format_of_print_text
.loop	
	move.l	(sp)+,a0
	addq	#2,a0
	
	subq.w	#1,(sp)
	bmi.s	.exit
	
	lea	num_x,a1
	bsr	convert_to_decimal
	
	lea	num_y,a1
	bsr	convert_to_decimal
	
	lea	num_f,a1
	bsr	convert_to_decimal
	
	lea	format_of_print_text,a1
	bsr	print_text_message
	
	addq.b	#1,format_of_print_text
	bra.s	.loop
	
	
	
.exit	addq	#2,sp
	rts


convert_to_decimal
	moveq	#0,d0
	moveq	#" ",d1
	move.w	(a0)+,d0
	beq.s	.ok
	bpl.s	.ok
	neg.w	d0
	moveq	#"-",d1
.ok	move.b	d1,(a1)+
	
	divu	#10,d0
	add.l	#"0000",d0
	move.b	d0,(a1)
	swap	d0
	move.b	d0,1(a1)
	rts
	
print_text_message
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a1)+,d0
	move.b	(a1)+,d1
	lsl	#3,d0
	lsl	#3,d1
	
.loop	moveq	#0,d4
	move.b	(a1)+,d4
	bne.s	.ok
	rts
.ok	cmp.b	#" ",d4
	bne.s	.not_sp
	addq	#8,d0
	bra.s	.loop
.not_sp
	lea	my_spr,a0
	move.b	.char_tab-32(pc,d4.w),d4
	lsl.w	#5,d4				;index into table entry
	add.w	d4,a0				;now pointing to entry in table
	movem.l	(a0),d4-d7
	lsl.l	#8,d4
	add.w	d1,d1				;convert the scanline to jaguar y
	add.w	#ntsc_n_vdb,d1
	lsl.w	#3,d1
	add.w	d1,d5				;and the y position
	and.w	#$fff,d0			;mask the sprite
	or.w	d0,d7
	jsr	ADD_OL				;a0 returns with address to make an object at
	movem.l	d4/d5/d6/d7,(a0)
	move.b	#Q_BMO,O_TYPE(a0)		;indicate type of object
	addq	#8,d0
	bra.s	.loop
	
	


.char_tab
	DC.B	$00,$25,$00,$00,$00,$00,$00,$00	;  !"#$%&'
	DC.B	$00,$00,$00,$00,$1a,$00,$27,$00	; ()*+,-./
	DC.B	$0e,$1b,$1c,$1d,$1e,$1f,$20,$21 ; 0-7
	DC.B	$22,$23,$24,$00,$00,$00,$00,$26	; 89:;<=>?
	DC.B	$00,$00,$01,$02,$03,$04,$05,$06	; @A-G
	DC.B	$07,$08,$09,$0a,$0b,$0c,$0d,$0e	; H-O
	DC.B	$0f,$10,$11,$12,$13,$14,$15,$16	; P-W
	DC.B	$17,$18,$19			; XYZ



	even

edit_sprite
	bsr	is_456_pressed
	bsr	is_789_pressed
	bsr	fire_1a_pressed	;alter frame number
	bsr	fire_1b_pressed	;alter point number
	bsr	fire_1c_pressed	;change position
	bsr	fire_1o_pressed	;options flip sprite
	jsr	NEW_OL
	bsr	print_this_sprite
	jsr	WVBL
	bra.s	edit_sprite

fire_1a_pressed
	bsr	fire_a_pressed
	bcc.s	.pressed
	rts
.pressed
	bsr	fire_a_up_just_pressed
	bsr	fire_a_down_just_pressed
	rts

fire_a_down_just_pressed
	Move.l	joyedge1,d0
	not.l	d0
	Btst	#DOWN_B,d0
	bcc.s	.no
	tst.w	current_point
	beq.s	.no
	subq	#1,current_point
.no	Rts

fire_a_up_just_pressed
	Move.l	joyedge1,d0
	not.l	d0
	Btst	#DOWN_B,d0
	bcc.s	.no
	bsr	get_frames_in_this_sprite
	cmp	current_point,d0
	blt.s	.no
	addq	#1,current_point
.no	Rts





sprite_number_text
	dc.b	0,0,"sprite number "
sprite_number
	dc.b	"00",0

sprite_frame_text
	dc.b	1,0,"sprite frame "
sprite_frame
	dc.b	"00",0

sprite_points_text
	dc.b	2,0,"sprite points "
sprite_points
	dc.b	"00",0

sprite_current_text
	dc.b	2,0,"current point "
sprite_point
	dc.b	"00",0

format_of_print_text
	dc.b	4,0
num_x	dc.b	"000,"
num_y	dc.b	"000 "
num_f	dc.b	"000",0
	even

current_pointer
	dc.l	0
current_frame
	dc.l	0
current_point
	dc.l	0
current_flip
	dc.w	0

sprite_table_start
	dc.l	guard_dma
sprite_table_end

	cnop	0,8
my_spr	incbin	specific.jag\font.bbx
	