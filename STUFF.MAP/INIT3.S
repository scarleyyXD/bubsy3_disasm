	incdir	d:\jaguar\bubsy.dev\rom_file.pp
	include	stuff.map\constant.s

create_2_lands
	moveq	#$e0,d1
	move.w	WINDX,d0
	and.w	d1,d0
	and.w	WINDY,d1
	lea	land1,a1
	move.w	d0,map_x(a1)
	move.w	d1,map_y(a1)
	move.w	d0,previous_x(a1)
	move.w	d1,previous_y(a1)
	move.w	#MAP_WIDTH*2,map_width(a1)
	move.w	#0,scroll_dir(a1)
	move.l	LOAD_MAP_CHARACTERS_HERE,blockset1(a1)
	move.l	#MAPBASE,map_address(a1)
	move.l	map_addr,map_1(a1)
	move.l	map_addr1,map_2(a1)
	jmp	initalise_land

scroll_lands
	lea	land1,a1
	move.w	WINDX,d0
	move.w	WINDY,d1
	move.w	d0,map_x(a1)
	move.w	d1,map_y(a1)
	jmp	scroll_land
	
*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000010001100000000000000000,4(A0)
*	%0000000000000000100000000000001010000000110000001011000000000000,12(A0)
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000
	
view_2_landscapes_a
	lea	land1,a1
	move.l	map_1(a1),a4
	bra.s	add_landscape
view_2_landscapes_b
	lea	land1,a1
	move.l	map_2(a1),a4
add_landscape
	moveq	#0,d4
	moveq	#0,d1
	move.w	#(PLAYFIELD_HEIGHT*BLOCK_HEIGHT),d1	*total height of the image
	move.w	map_y(a1),d4				*interested where to start display,depth to show
	divu	d1,d4					*scan lines per image height
	clr.w	d4
	swap	d4					*I want the remainder
	sub.l	d4,d1					*find how many scan lines can be seen
	mulu	#PLAYFIELD_BLITTER_WIDTH,d4		*y*blitter width
	
	move.l	d1,d2					* number of scan lines draw
	
	moveq	#0,d6
	move.w	map_x(a1),d6
	moveq	#$f,d7
	and.w	d6,d7
	eor.w	d7,d6					*d6 = phrase align
	add.l	d6,d4					*calc abs x,y position
	add.l	a4,d4				*abs x pos
	lsl.l	#8,d4
	neg.w	d7
	and.w	#$fff,d7
	
	ror.l	#2,d1
	swap	d1
	or.w	#ntsc_n_vdb<<3,d1
	
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	move.l	d4,(A0)+
	move.l	d1,(a0)+
	move.l	#%00000000000000001000000000000010,(a0)+
	move.l	#%10100000110000001011000000000000,(A0)+
	or.w	d7,-(a0)
	
	add.l	a4,d6
	lsl.l	#8,d6
	
	move.w	d2,d3
	add.w	d3,d3
	add.w	#ntsc_n_vdb,d3
	lsl.w	#3,d3
	
	neg.w	d2
	add.w	#280,d2
	bmi.s	.no_show
	
	ror.l	#2,d2
	swap	d2
	or.w	d3,d2
	
	jsr	ADD_OL
	move.b	#Q_BMO,O_TYPE(a0)
	move.l	d6,(A0)+
	move.l	d2,(a0)+
	move.l	#%00000000000000001000000000000010,(a0)+
	move.l	#%10100000110000001011000000000000,(A0)+
	or.w	d7,-(a0)
.no_show	
	rts


	rsreset
previous_x		rs.w	1
previous_y		rs.w	1
map_y			rs.w	1
map_x			rs.w	1
scroll_dir		rs.w	1
map_width		rs.w	1
blockset1		rs.l	1
map_1			rs.l	1
map_2			rs.l	1
map_address		rs.l	1
MAP_DEF			rs.b	0
