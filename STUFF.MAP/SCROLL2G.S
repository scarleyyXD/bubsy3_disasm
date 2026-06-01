	include	 "c:\\bin\\jaguar.inc"
	include	 "c:\\bin\\blit.inc"
	include	"constant.s"
	.68000
	.data
	
scroller_definition::
	dc.l	scroll_start,scroll_end-scroll_start
	
scroll_start:
	.gpu


macro	JUMPTO	whereto
	movei	#\whereto,gtemp
	jump	t,(gtemp)
	nop
	
endm



macro	WAIT_FOR_BLITTER
.lp12:	load	(blit_control),gtemp
	btst	#0,gtemp
	jr	eq,.lp12
	nop
	
endm


macro	GBSR	whereto
	movei	#.\~,long_routine
	movei	#\whereto,gtemp
	jump	t,(gtemp)
	nop
.\~:
endm

macro	GRTS
	jump	t,(long_routine)
	nop
endm

macro	GBSRS	whereto
	movei	#.\~,short_routine
	movei	#\whereto,gtemp
	jump	t,(gtemp)
	nop
.\~:
endm

macro	GRTSS
	jump	t,(short_routine)
	nop
endm


	org	G_RAM
pointer_to_map::	dc.l	0

gd0	equr	r0
gd1	equr	r1
gd2	equr	r2
gd3	equr	r3
gd4	equr	r4
gd5	equr	r5
gd6	equr	r6
gd7	equr	r7

ga0	equr	r8
ga1	equr	r9
ga2	equr	r10
ga3	equr	r11
ga4	equr	r12
ga5	equr	r13
ga6	equr	r16
ga7	equr	r17


map_pointer		equr	r14
blit_pointer		equr	r15
gtemp			equr	r18
scroll_direction	equr	r19
map_wide		equr	r20
short_routine		equr	r21
long_routine		equr	r22

aa1_pixel		equr	r23
aa2_pixel		equr	r24
block_size		equr	r25
aa1_base		equr	r26
aa2_base		equr	r27
blit_control		equr	r28

map_y		equ	0
map_x		equ	1
previous_y	equ	2
previous_x	equ	3
map_width	equ	4
blockset1	equ	5
map_1		equ	6




scroll_land::
	movei	#pointer_to_map,ga1
	moveq	#1,gd7
	load	(ga1),map_pointer

	load	(map_pointer+map_y),gd0
	load	(map_pointer+previous_y),gd2
	and	gd6,gd0
	move	gd0,gd1
	store	gd1,(map_pointer+previous_y)
	sub	gd2,gd1
	sharq	#4,gd1
	add	gd1,gd7
	shlq	#2,gd7
	addq	#1,gd7
	load	(map_pointer+map_x),gd0
	load	(map_pointer+previous_x),gd2
	and	gd6,gd0
	move	gd0,gd1
	store	gd1,(map_pointer+previous_x)
	sub	gd2,gd1
	sharq	#4,gd1
	add	gd1,gd7
	move	gd7,scroll_direction
	
	movei	#A1_BASE,blit_pointer
	
	movei	#$10000+(-BLOCK_HEIGHT)&$ffff,gd5
	moveq	#0,gd6
	store	gd5,(blit_pointer+A01_STEP)
	store	gd5,(blit_pointer+A02_STEP)
	movei	#PITCH1|XADDPIX|WID384|PIXEL8,gd5
	store	gd6,(blit_pointer+B00_PATD)
	store	gd6,(blit_pointer+B01_PATD)
	store	gd5,(blit_pointer+A02_FLAGS)
	store	gd5,(blit_pointer+A01_FLAGS)
	
	movei	#A1_PIXEL,aa1_pixel
	movei	#A2_PIXEL,aa2_pixel
	movei	#B_COUNT,block_size
	movei	#A1_BASE,aa1_base
	movei	#A2_BASE,aa2_base
	movei	#B_CMD,blit_control

	
	movei	#($ffff<<BLOCK_BITS)&$ffff,gtemp
	load	(map_pointer+map_x),gd6
	and	gtemp,gd6
	
	move	gd6,gd5
	shrq	#BLOCK_BITS,gd5
	move	gd5,ga6
	shlq	#1,ga6
	load	(map_pointer+map_y),gd5
	load	(map_pointer+map_width),gtemp
	shrq	#BLOCK_BITS,gd5
	move	gtemp,map_wide
	mult	gtemp,gd5
	add	gd5,ga6
	movei	#G_REMAIN,ga7
	movei	#PLAYFIELD_HEIGHT,gtemp
	div	gtemp,gd4
	load	(ga7),gd4
	or	gd4,gd4
	jr	cc,.pos
	nop
	neg	gd4
.pos:	shlq	#2,gd4
	movei	#map_table_offset,ga3
	add	gd4,ga3
	movei	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH/4,gtemp
	mult	gtemp,gd4
	load	(map_pointer+map_1),ga2
	add	gd4,ga2
	add	gd7,ga2
	load	(map_pointer+blockset1),ga0
	
	movei	#direction,gtemp
	shlq	#2,scroll_direction
	add	scroll_direction,gtemp
	load	(gtemp),scroll_direction
	jump	T,(scroll_direction)
	nop
up_right:
	moveta	ga2,ga2
	moveta	ga6,ga6
	GBSR	centre_right
	movefa	ga2,ga2
	movefa	ga6,ga6
	JUMPTO	blit_line_accross
	
up_left:
	moveta	ga2,ga2	
	moveta	ga6,ga6
	GBSR	centre_left
	movefa	ga2,ga2
	movefa	ga6,ga6
	JUMPTO	blit_line_accross
	
down_right:
	moveta	ga2,ga2	
	moveta	ga6,ga6
	GBSR	centre_right
	movefa	ga2,ga2
	movefa	ga6,ga6
	JUMPTO	down_centre
	
down_left:
	moveta	ga2,ga2	
	moveta	ga6,ga6
	GBSR	centre_left
	movefa	ga2,ga2
	movefa	ga6,ga6

down_centre:
	rept	PLAYFIELD_HEIGHT-2
	load	(ga3),gtemp
	addq	#4,ga3
	add	gtemp,ga2
	endr
	movei	#PLAYFIELD_HEIGHT-2,gtemp
	mult	map_wide,gtemp
	add	gtemp,ga6
up_centre:
	JUMPTO	blit_line_accross

centre_right:
	movei	#BLOCK_HEIGHT*(PLAYFIELD_WIDTH-1),gtemp
	add	gtemp,ga2
	movei	#2*(PLAYFIELD_WIDTH-1),gtemp
	add	gtemp,ga6
centre_left:
	movei	#SRCEN|UPDA1|LFU_A|LFU_AN,gd0
	movei	#$00010001<<BLOCK_BITS,gd1
	movei	#UPDA1|PATDSEL,gd2
	moveq	#0,gd6
	movei	#MAP_DEPTH*BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH,gd5
	move	map_wide,ga4
	GBSRS	do_a_map_square
	moveq	#PLAYFIELD_HEIGHT-1,gd3
.lp:	load	(ga3),gtemp
	add	gtemp,ga2
	addq	#4,ga3
	add	ga4,ga6
	GBSRS	do_a_map_square
	subq	#1,ga3
	jr	ne,.lp
	nop
	GRTS

blit_line_accross:
	movei	#SRCEN|UPDA1|LFU_A|LFU_AN,gd0
	movei	#$00010001<<BLOCK_BITS,gd1
	movei	#UPDA1|PATDSEL,gd2
	moveq	#0,gd6
	moveq	#MAP_DEPTH*BLOCK_HEIGHT,gd5
	GBSRS	do_a_map_square
	moveq	#PLAYFIELD_WIDTH-1,gd3
.lp:	add	gd5,ga2
	addq	#2,ga6
	GBSRS	do_a_map_square
	subq	#1,gd3
	jr	ne,.lp
	
	add	gd5,ga2
	GBSRS	do_a_map_square
	GRTS
	
do_a_map_square:
	WAIT_FOR_BLITTER
	store	gd6,(aa2_pixel)
	store	gd6,(aa1_pixel)
	store	gd1,(block_size)
	store	ga2,(aa1_base)
	loadw	(ga6),gd7
	or	gd7,gd7
	jr	eq,.clear
	store	gd2,(blit_control)					;set it going with a pattern
	GRTSS
.clear:
	shlq	#8,gd7
	add	ga0,gd7
	store	gd7,(aa2_base)						;set screen window bases
	store	gd0,(blit_control)					;set it going
	GRTSS

direction:
	dc.l	up_left,up_centre,up_right,centre_centre
	dc.l	centre_left,centre_centre,centre_right,centre_centre
	dc.l	down_left,down_centre,down_right

map_table_offset:
	rept	3
	dcb.l	(PLAYFIELD_HEIGHT-1),MAP_DEPTH-BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH
	dc.l	-(PLAYFIELD_HEIGHT-1)*MAP_DEPTH-BLOCK_HEIGHT*PLAYFIELD_BLITTER_WIDTH
	endr

centre_centre:

	.phrase
	.68000
scroll_end:
