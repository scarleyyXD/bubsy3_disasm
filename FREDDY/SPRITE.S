	RSRESET	

sprite_x	rs.w	1
sprite_y	rs.w	1
sprite_z	rs.w	1
sprite_number	rs.w	1
sprite_group	rs.w	1
sprite_e	rs.w	0

	RSRESET
jsprite_data	rs.l	1	    ; graphic data
jsprite_pixel_width	rs.w	1   ; width in pixels
jsprite_height	rs.w	1	    ; height in pixels
jsprite_bitsperpixel	rs.b	1  ; bits per pixel
jsprite_flags	rs.b	1         ; flags
jsprite_yoffset	rs.w	1       ; blank pixels at top
jsprite_palindex	rs.w	1	    ; palette index
jsprite_phrase_width	rs.w	1
jsprite_e	rs.w	0

; calculates data widths in phrases for an array of sprites
; pass
; a0 - pointer to header
; a1 - pointer to graphics
; d0 - length of header file ( in total bytes)

format_jag_sprites:
	move.l	a1,d6
.loop:	add.l	d6,jsprite_data(a0)
	move.w	jsprite_pixel_width(a0),d2
	moveq	#6,d1
	sub.b	jsprite_bitsperpixel(a0),d1
	lsr.w	d1,d2
	move.w	d2,jsprite_phrase_width(a0)
	move.w	jsprite_palindex(a0),d3
	lsr.w	#1,d3
	move.w	d3,jsprite_palindex(a0)
	lea	jsprite_e(a0),a0
	sub.w	#16,d0
	bne.s	.loop
	rts

; builds sprite headers for all sprites in a list
; pass 

; a0 - pointer to header
; a1 - pointer to fast generated sprites
; d0 - length of header file ( in total bytes)

generate_fast_sprites:
	moveq	#0,d2
.loop:	movem.l	d0/d2/a0,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	bsr	draw_a_jag_sprite
	movem.l	(sp)+,d0/d2/a0
	bsr	strip_link
	addq.w	#1,d2
	sub.w	#16,d0
	bne.s	.loop
	rts


strip_link:	movem.l	-16(a1),d4-d7
	and.l	#%00000000111111111111111111111111,d5
	and.l	#%11111111111111111111100000000000,d4
	movem.l	d4-d7,-16(a1)
	rts

strip_data:	movem.l	-16(a1),d4-d7
	and.l	#%11111111111,d4
	movem.l	d4-d7,-16(a1)
	rts


; pass

; d0 - x
; d1 - y
; d2 - sprite number
; a0 - pointer to generated bitmap objects
; a1 - object list
; a2 - pointer to normal header bits

; returns
; d0 - length of object (usually 16!)
; a1 - updated object list pointer


draw_a_fast_jag_sprite:
	lsl.w	#4,d2
	move.w	d2,d6
	movem.l	(a0,d2),d2-d5
	and.w	#%111111111111,d0
	or.w	d0,d5
	tst.w	d1
	bmi.s	.negative_sprite
	lsl.w	#4,d1
	add.w	d1,d3
	bra.s	put_in_fast_link

.negative_sprite:	move.w	jsprite_height(a2,d6),d0
	add.w	d1,d0
	ble.s	.no_sprite
	and.l	#%11111111110000000000111111111111,d3
	lsl.l	#7,d0	
	lsl.l	#7,d0
	or.l	d0,d3
	move.l	jsprite_data(a2,d6),d0
	neg.w	d1
	mulu	jsprite_phrase_width(a2,d6),d1
	lsl.l	#3,d1
	add.l	d1,d0
	and.l	#%11111111111,d2
	moveq	#43-32-3,d1
	lsl.l	d1,d0
	or.l	d0,d2
	bra.s	put_in_fast_link

.no_sprite:	moveq	#0,d0
	rts

put_in_fast_link:	moveq	#16,d0
	add.l	a1,d0
	lsr.l	#3,d0
	move.l	d0,d1

	lsr.l	#8,d0
	or.l	d0,d2
	ror.l	#8,d1
	and.l	#%11111111000000000000000000000000,d1
	or.l	d1,d3
	
	movem.l	d2-d5,(a1)
	moveq	#16,d0
	add.l	d0,a1
	rts
	
; pass

; d0 - x
; d1 - y
; d2 - sprite number
; a0 - header
; a1 - object list

; returns
; d0 - length of object (usually 16!)
; a1 - updated object list pointer

draw_a_jag_sprite:
	lsl.w	#4,d2
	lea	(a0,d2),a2
	STACKOBJ
	move.w	#BITMAP_OBJECT,obj_type(a0)
	
	bsr	get_jsprite_info
	beq.s	.exit
	bsr	make_object
.exit:	UNSTACKOBJ	
	rts

; pass

; d0 - x
; d1 - y
; d2 - sprite number
; d3 - hscale/vscale
; a0 - header
; a1 - object list

; returns
; d0 - length of object (usually 24!)
; a1 - updated object list pointer

draw_a_scaled_jag_sprite:
	lsl.w	#4,d2
	lea	(a0,d2),a2
	STACKOBJ
	move.w	#SCALED_OBJECT,obj_type(a0)
	bsr	get_scaled_jsprite_info
	beq.s	.exit
	move.w	d3,obj_vscale(a0)
	swap	d3
	move.w	d3,obj_hscale(a0)
	move.w	#0,obj_remainder(a0)
	bsr	make_object
.exit:	UNSTACKOBJ	
	rts


get_scaled_jsprite_info:
	move.w	d0,obj_xpos(a0)
	add.w	jsprite_yoffset(a2),d1
	bpl.s	.positive
	move.w	#ntsc_n_vdb,obj_ypos(a0)
	ext.l	d1
	asl.l	#5,d1
	divs	d3,d1
	neg.w	d1
	move.w	jsprite_height(a2),obj_height(a0)
	sub.w	d1,obj_height(a0)
	bmi.s	.no_sprite
	move.l	jsprite_data(a2),obj_data(a0)
	mulu	jsprite_phrase_width(a2),d1
	lsl.l	#3,d1
	add.l	d1,obj_data(a0)
	bra.s	.skip_y_calc	
.positive:	add.w	d1,d1
	add.w	#ntsc_n_vdb,d1
	move.w	d1,obj_ypos(a0)
	move.w	jsprite_height(a2),obj_height(a0)
	move.l	jsprite_data(a2),obj_data(a0)
.skip_y_calc:	moveq	#0,d1
	move.b	jsprite_bitsperpixel(a2),d1
	move.w	d1,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	jsprite_phrase_width(a2),obj_iwidth(a0)	; in phrases!
	move.w	jsprite_phrase_width(a2),obj_dwidth(a0)	; in phrases!
	move.w	jsprite_palindex(a2),obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	moveq	#-1,d0
	rts
.no_sprite:	moveq	#0,d0
	rts



get_jsprite_info:	move.w	d0,obj_xpos(a0)
	add.w	jsprite_yoffset(a2),d1
	bpl.s	.positive
	move.w	#ntsc_n_vdb,obj_ypos(a0)
	neg.w	d1
	move.w	jsprite_height(a2),obj_height(a0)
	sub.w	d1,obj_height(a0)
	bmi.s	.no_sprite
	move.l	jsprite_data(a2),obj_data(a0)
	mulu	jsprite_phrase_width(a2),d1
	lsl.l	#3,d1
	add.l	d1,obj_data(a0)
	bra.s	.skip_y_calc	
.positive:	add.w	d1,d1
	add.w	#ntsc_n_vdb,d1
	move.w	d1,obj_ypos(a0)
	move.w	jsprite_height(a2),obj_height(a0)
	move.l	jsprite_data(a2),obj_data(a0)
.skip_y_calc:	moveq	#0,d1
	move.b	jsprite_bitsperpixel(a2),d1
	move.w	d1,obj_depth(a0)
	move.w	#1,obj_pitch(a0)
	move.w	jsprite_phrase_width(a2),obj_iwidth(a0)	; in phrases!
	move.w	jsprite_phrase_width(a2),obj_dwidth(a0)	; in phrases!
	move.w	jsprite_palindex(a2),obj_index(a0)
	move.w	#TRANS,obj_flags(a0)
	move.w	#0,obj_firstpix(a0)
	moveq	#-1,d0
	rts
.no_sprite:	moveq	#0,d0
	rts








