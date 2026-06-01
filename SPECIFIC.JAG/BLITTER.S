***		ALL GRAPHIC DATA MUST LIE ON A PHRASE BOUNDARY
***		FOR LAMERS USE THE INSTRUCTION CNOP 0,8 BEFORE
***		THE INCLUSION OF GRAPHIC DATA...AND ENSURE ALL
***		SECTIONS PRECEEDING ARE THUS ALIGNED..........



***		ACCORDING TO THE GOLDEN RULE OF ATARI..

***		THALL SHALT NOT USE A BLITTER WHILST WITHIN
***		AN INTERRUPT.. TAKE HEED.

***		THIS IS VERY EXCITING TO TYPE IN AS I AM NOT
***		BORED AT THIS MOMENT IN TIME BUT WHO CARES..


************************************************************************************************


*d0=x
*d1=y
*a0=index to bank number,sprite number hi-word:low-word
*a1 points to offset for negative flipped	


DRAW_JAGUAR_SPRITE_1:
	move.l	a0,d2
	move.w	d2,d4
	swap	d2
	lsl.w	#2,d2
	lea	bank_of_sprites,a6
	move.l	(a6,d2.w),a0
	moveq	#%1000,d2
	and.b	OBJOAM0(a5),d2
	beq.s	print_a_sprite_normal
	sub.w	(a1),d0
	bra	print_a_sprite_flipped

DRAW_JAGUAR_SPRITE:
	move.l	a0,d2
	move.w	d2,d4
	swap	d2
	lsl.w	#2,d2
	lea	bank_of_sprites,a6
	move.l	(a6,d2.w),a0
	moveq	#%1000,d2
	and.b	OBJOAM0(a5),d2
	beq.s	print_a_sprite_normal
	sub.w	(a1),d0
	bra	print_a_sprite_flipped_minus





print_a_sprite_normal:

**	d0=x
**	d1=y
**	d4=sprite_number
**	a0=sprite header address

**	also this routine is for non flipped-horizontal sprites
**	above registers are not preserved - all the rest are

**	Clipping is performed to reduce the size of the OL - releasing time for 680000
**	sprite header table must have been converted before running this routine

	cmp.w	#320,d0
	blt.s	.ok
	rts
.ok:	movem.l	d3-d7,-(sp)
	lsl.w	#5,d4				;index into table entry
	add.w	d4,a0				;now pointing to entry in table
	tst.w	d1
	bpl.s	.top_y_ok			;if at top then
	moveq	#0,d3
	move.w	20(a0),d3			;height
	add.w	d1,d3
	bmi.s	no_print1
	beq.s	no_print1
	movem.l	(a0)+,d4-d7
	muls	(a0),d1				;times by width per scan line
	sub.l	d1,d4
	moveq	#0,d1				;top of the screen
	ror.l	#2,d3
	swap	d3
	and.l	#%11111111000000000011111111111111,d5
	or.l	d3,d5
	bra.s	.cont_me
.top_y_ok:
	cmp.w	screen_height,d1
	bge.s	no_print1
	movem.l	(a0),d4-d7
.cont_me:

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
	
no_print1:
	movem.l	(sp)+,d3-d7
	rts


print_a_sprite_flipped:
	tst.w	d0
	bpl.s	.ok
	rts
.ok:	movem.l	d3-d7,-(sp)
	lsl.w	#5,d4				;index into table entry
	add.w	d4,a0				;now pointing to entry in table
	tst.w	d1
	bpl.s	.top_y_ok			;if at top then
	moveq	#0,d3
	move.w	20(a0),d3			;height
	add.w	d1,d3
	bmi.s	no_print2
	beq.s	no_print2
	movem.l	(a0)+,d4-d7
	muls	(a0)+,d1				;times by width per scan line
	add.w	(a0)+,d0			;width in pixels
	sub.l	d1,d4
	moveq	#0,d1				;top of the screen
	ror.l	#2,d3
	swap	d3
	and.l	#%11111111000000000011111111111111,d5
	or.l	d3,d5
	bra.s	.cont_me
.top_y_ok:
	cmp.w	screen_height,d1
	bge.s	no_print2
	add.w	18(a0),d0			;width in pixels
	movem.l	(a0),d4-d7
.cont_me:
	or.w	#$2000,d6
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
	
no_print2:
	movem.l	(sp)+,d3-d7
	rts

print_a_sprite_flipped_minus:
	tst.w	d0
	bpl.s	.ok
	rts
.ok:	movem.l	d3-d7,-(sp)
	lsl.w	#5,d4				;index into table entry
	add.w	d4,a0				;now pointing to entry in table
	tst.w	d1
	bpl.s	.top_y_ok			;if at top then
	moveq	#0,d3
	move.w	20(a0),d3			;height
	add.w	d1,d3
	bmi.s	no_print3
	beq.s	no_print3
	movem.l	(a0)+,d4-d7
	muls	(a0)+,d1			;times by width per scan line
	sub.l	d1,d4
	moveq	#0,d1				;top of the screen
	ror.l	#2,d3
	swap	d3
	and.l	#%11111111000000000011111111111111,d5
	or.l	d3,d5
	bra.s	.cont_me
.top_y_ok:
	cmp.w	screen_height,d1
	bge.s	no_print3
	movem.l	(a0),d4-d7
.cont_me:
	or.w	#$2000,d6
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
	
no_print3:
	movem.l	(sp)+,d3-d7
	rts


;converts the sprite header so that the relative address in the header is now absolute
;a1 point to the data
relocate_sprites:
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	move.l	a1,d0
	move.l	(a1),d1
	lsr.l	#5,d1
	subq.w	#1,d1
.loop:	add.l	d0,(a1)
	lea	32(a1),a1
	dbf	d1,.loop
	move.l	(sp)+,d1
	move.l	(sp)+,d0
	rts
	

print_a_sprite_normal_no_clip:

	lsl.w	#5,d4				;index into table entry
	movem.l	0(a0,d4.w),d4-d7
	lsl.l	#8,d4
	add.w	d1,d5				;and the y position
	or.w	d0,d7
	jsr	ADD_OL				;a0 returns with address to make an object at
	movem.l	d4/d5/d6/d7,(a0)
	move.b	#Q_BMO,O_TYPE(a0)		;indicate type of object
	rts

add_backdrop:
	tst.b	BACK_VH
	bne.s	.vert
	lea	land1,a1
	moveq	#0,d0
	move.w	map_x(a1),d0
	lsr.w	#2,d0
	divu	#399,d0
	clr.w	d0
	swap	d0
	neg.w	d0
	add.w	#400,d0
	
	move.l	#%00000000010001100000000000000000,d2
	moveq	#%00000000000000000000000000000011,d3
	move.l	#%00100000110010001011000000000000,d4

	moveq	#0,d1
	move.w	map_y(a1),d1
	lsr.w	#4,d1
	mulu	#400,d1
	add.l	#LOAD_BACKGROUND_MAP_HERE,d1
	lsl.l	#8,d1

	cmp.w	#320,d0
	bgt.s	.only_one
	
	
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	d1-d4,(a0)
	or.w	d0,14(a0)

.only_one:
	sub.w	#400,d0
		
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	d1-d4,(a0)
	and.w	#$fff,d0
	or.w	d0,14(a0)
	rts

.vert:	

	lea	land1,a1
	
	moveq	#0,d0
	move.w	map_y(a1),d0
	asr.w	#2,d0
	divu	#500-1,d0
	clr.w	d0
	swap	d0				;0>>499
	
	
	move.w	d0,d1
	mulu	#320,d1
	add.l	#LOAD_BACKGROUND_MAP_HERE,d1
	asl.l	#8,D1				;BACK ADDR
	
	move.l	#%00000000000000000000000000000010,d3
	move.l	#%10000000101000001011000000000000,d4
	
	
	moveq	#0,d2
	move.w	#500,d2
	sub.w	d0,d2
	move.w	d2,d7
	ror.l	#2,d2
	swap	d2
	or.w	#ntsc_n_vdb<<3,d2
	
	
	cmp.w	#280,d7
	bge.s	.one_high
	
	
	
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	d1-d4,(a0)
	
	
	move.l	#LOAD_BACKGROUND_MAP_HERE,d1
	asl.l	#8,D1				;BACK ADDR
	
	moveq	#0,d2				;get height
	move.w	#280,d2
	ror.l	#2,d2
	swap	d2
	
	asl.w	#4,d7				;get y  == old_height
	add.w	#ntsc_n_vdb<<3,d7
	or.w	d7,d2
	bra.s	.cont
	
	
	
.one_high:	
	moveq	#0,d2
	move.w	#280,d2
	ror.l	#2,d2
	swap	d2
	or.w	#ntsc_n_vdb<<3,d2
	
	
	
.cont:	
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	movem.l	d1-d4,(a0)
	rts

*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000010001100000000000000000,4(A0)
*	%0000000000000000000000000000001010000000101000001011000000000000,d4
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000
	

print_a_sprite_scaled_display:

**	d0=x
**	d1=y
**	d2=sx
**	d3=sx
**	d4=sprite_number
**	a0=sprite header address

**	Clipping is performed to reduce the size of the OL - releasing time for 680000
**	sprite header table must have been converted before running this routine

.ok:	
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
	bset	#0,d5				;indicate sprite is scaled
	sub.l	#%100000000000000,d5		;take 1 off the y else I get an exta line  <<<<<<<<<
	jsr	ADD_OL_DISPLAY				;a0 returns with address to make an object at
	move.b	#Q_SBMO,O_TYPE(a0)		;indicate type of object
	movem.l	d4/d5/d6/d7,(a0)
	move.b	d2,21(a0)
	move.b	d2,22(a0)
	move.b	d2,23(a0)
	rts



add_title_screen:
	
*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000010001100000000000000000,4(A0)
*	%0000000000000000000000000000001010110000101011001011000000000000,12(A0)
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000


	jsr	ADD_OL
	move.l	load_title_pic_here,d0
	cmp.w	#240,screen_height
	bge.s	.pal
	add.l	#344*40,d0
.pal:
	asl.l	#8,d0
	move.l	d0,(a0)+
	move.l	#%00000000010001100000000000000000,(a0)+
	move.l	#%00000000000000000000000000000010,(a0)+
	move.l	#%10110000101011001011000000000000,(A0)+
	move.b	#Q_BMO,O_TYPE-16(a0)
	rts


print_a_sprite_normal_display:

**	d0=x
**	d1=y
**	d4=sprite_number
**	a0=sprite header address

**	also this routine is for non flipped-horizontal sprites
**	above registers are not preserved - all the rest are

**	Clipping is performed to reduce the size of the OL - releasing time for 680000
**	sprite header table must have been converted before running this routine

	cmp.w	#320,d0
	blt.s	.ok
	rts
.ok:	movem.l	d3-d7,-(sp)
	lsl.w	#5,d4				;index into table entry
	add.w	d4,a0				;now pointing to entry in table
	tst.w	d1
	bpl.s	.top_y_ok			;if at top then
	moveq	#0,d3
	move.w	20(a0),d3			;height
	add.w	d1,d3
	bmi.s	.no_print1
	beq.s	.no_print1
	movem.l	(a0)+,d4-d7
	muls	(a0),d1				;times by width per scan line
	sub.l	d1,d4
	moveq	#0,d1				;top of the screen
	ror.l	#2,d3
	swap	d3
	and.l	#%11111111000000000011111111111111,d5
	or.l	d3,d5
	bra.s	.cont_me
.top_y_ok:
	cmp.w	screen_height,d1
	bge.s	.no_print1
	movem.l	(a0),d4-d7
.cont_me:

	lsl.l	#8,d4

	add.w	d1,d1				;convert the scanline to jaguar y
	add.w	#ntsc_n_vdb,d1
	lsl.w	#3,d1
	add.w	d1,d5				;and the y position
	
	and.w	#$fff,d0			;mask the sprite
	or.w	d0,d7
	
	jsr	ADD_OL_DISPLAY			;a0 returns with address to make an object at
	movem.l	d4/d5/d6/d7,(a0)
	move.b	#Q_BMO,O_TYPE(a0)		;indicate type of object
	
.no_print1:
	movem.l	(sp)+,d3-d7
	rts



BACK_VH:		dc.b	0
		even
