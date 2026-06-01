
;---------------------------------------------------------------------
; subroutine to build objlist:
;	expects:
;	a1:	ptr to source data base (provided by user)
;	a0:	ptr to dest   master object list (provided by user)
;	d2:	number of objects to process (provided by user)
;		(destroys d0, d1, d3)
;		a2 ends with olist head

build_olist:
; Adjust ptr to 4 phrase boundary and return pointer to it.
				; (inspired by fullblt.s)
	move.l	a0,a2
	move.l	load_overlay_graphics,a6
	
*	move.l	a0,d0		; this is the given start of storage for dest, the master object list.
*	add.l	#40,d0		; which will be copied later into
*	and.l	#$ffffffe0,d0	; active obj list.
*	move.l	d0,a2		; Return ptr to phrase aligned master object list,
*
*				; which begins with the branch object header.
*	move.l	d0,a0		; Macros expect the ptr to be in a0.
; Init the object counter. 
		
; Process an object:
proc_obj:
	moveq	#32,d7
	dbf	d2,stopme
	bra	quit_obj	; been processed.

stopme:
	moveq	#0,d0
	move.b	O_TYPE(a1),d0
	add.b	d0,d0
	add.b	d0,d0
	jmp	.a_table(pc,d0.w)
	bra	d_loop
.a_table:
	bra	OBJECT_0
	bra	OBJECT_1
	bra	OBJECT_2
	bra	OBJECT_3
	bra	OBJECT_4
	bra	OBJECT_0_QUICK
	bra	OBJECT_1_QUICK
	bra	OBJECT_2_QUICK
	bra	OBJECT_3_QUICK
	bra	OBJECT_4_QUICK
	bra	JUMP_OBJECT
	bra	JUMP_OBJECT1
	bra	OBJECT_0_BIG
	bra	JUMP_OVER_OBJECT
	bra	OVERLAY_OBJECT
		
OBJECT_3_QUICK:
OBJECT_4_QUICK:
OBJECT_3:
OBJECT_2:
OBJECT_4:
; Clear 32 bytes/8 longs per SBM object

OBJECT_0:
	illegal
.t:	moveq	#0,d0
	rept	4
	move.l	d0,(a0)+
	endr
	lea	-16(a0),a0	;reset pointer

; Set link ptr field in object header.
	move.l	a0,d0
	add.l	d7,d0		; compute start of next SBM obj, 4 phrases off.
	lsr.l	#3,d0		; phrase align it
	move.l	d0,d1		; make a copy.

	lsr.l	#8,d0		; truncate the rightmost 8 bits.
	and.l	#$7ff,d0	; clear top 21 bits
	move.l	d0,(a0)		;  "						 Bit Mapped obj header.

	and.l	#$000000ff,d1	;we just want the low byte.
	ror.l	#8,d1		;low byte becomes hi byte of long.
	move.l	d1,4(a0)	;set least sig field of link ptr in SBM obj header.

	moveq	#0,d0
	moveq	#0,d1

; Invoke macros:
	Setobj_Type 	a1,a0 	
	Setobj_Xpos 	a1,a0
	move.w	O_YPOS(a1),d0
**	and.w	#$07ff,d0
	add.w	d0,d0
game11:
	add.w	#ntsc_n_vdb,d0	;in half lines
	lsl.w	#3,d0
	and.w	#$c007,6(a0)	;clear old
	or.w	d0,6(a0)	;set new

	Setobj_DataPtr	a1,a0
	Setobj_Height	a1,a0
	Setobj_Depth	a1,a0
	Setobj_Pitch	a1,a0
	Setobj_Dwidth	a1,a0
	Setobj_Iwidth	a1,a0
	Setobj_Index	a1,a0
	Setobj_Release	a1,a0
	Setobj_Trans	a1,a0
	Setobj_RMW	a1,a0
	Setobj_Reflect	a1,a0
	Setobj_Firstpix	a1,a0
*	Setobj_Hscale	a1,a0
*	Setobj_Vscale	a1,a0
*	Setobj_Remainder a1,a0


; Flag this record as processed:

; Compute adr for next object
	add.w	d7,a1			; point to next record in source data.
	add.w	d7,a0			; point to next object header in object list

d_loop:
	dbf	d2,stopme
; Finished building the object list?

quit_obj:
; We're done, so:
; Write a stop object (zero's and type).

*	tst.b	gpu_rasters
*	beq.s	.no
*	clr.l	(a0)+
*	move.l	#%10+$7ff<<3,(a0)+
.no:	
	
	clr.l	(a0)+		
	move.l	#%100,(a0)
 	rts	

OBJECT_1:
.t:	moveq	#0,d0
	rept	4
	move.l	d0,(a0)+
	endr
	lea	-16(a0),a0	;reset pointer

; Set link ptr field in object header.
	move.l	a0,d0
	add.l	d7,d0		; compute start of next SBM obj, 4 phrases off.
	lsr.l	#3,d0		; phrase align it
	move.l	d0,d1		; make a copy.

	lsr.l	#8,d0		; truncate the rightmost 8 bits.
	and.l	#$7ff,d0	; clear top 21 bits
	move.l	d0,(a0)		;  "						 Bit Mapped obj header.

	and.l	#$000000ff,d1	;we just want the low byte.
	ror.l	#8,d1		;low byte becomes hi byte of long.
	move.l	d1,4(a0)	;set least sig field of link ptr in SBM obj header.

	moveq	#0,d0
	moveq	#0,d1

; Invoke macros:
	Setobj_Type 	a1,a0 	
	Setobj_Xpos 	a1,a0
	move.w	O_YPOS(a1),d0
**	and.w	#$07ff,d0
	add.w	d0,d0
me_norm5:
	add.w	#ntsc_n_vdb,d0	;in half lines
	lsl.w	#3,d0
	and.w	#$c007,6(a0)	;clear old
	or.w	d0,6(a0)	;set new

	Setobj_DataPtr	a1,a0
	Setobj_Height	a1,a0
	Setobj_Depth	a1,a0
	Setobj_Pitch	a1,a0
	Setobj_Dwidth	a1,a0
	Setobj_Iwidth	a1,a0
	Setobj_Index	a1,a0
	Setobj_Release	a1,a0
	Setobj_Trans	a1,a0
	Setobj_RMW	a1,a0
	Setobj_Reflect	a1,a0
	Setobj_Firstpix	a1,a0
	Setobj_Hscale	a1,a0
	Setobj_Vscale	a1,a0
	Setobj_Remainder a1,a0
	bra	d_loop


; Flag this record as processed:

; Compute adr for next object
	add.w	d7,a1			; point to next record in source data.
	add.w	d7,a0			; point to next object header in object list



OBJECT_0_QUICK:
	movem.l	(a1),d0/d1/d3/d4
	movem.l	d0/d1/d3/d4,(a0)
	add.w	d7,a0
	add.w	d7,a1
	move.l	a0,d0
	lsl.l	#5,d0
	or.l	d0,-32+2(a0)
	bra	d_loop



OBJECT_0_BIG:
.t:	moveq	#0,d0
	rept	4
	move.l	d0,(a0)+
	endr
	lea	-16(a0),a0	;reset pointer

; Set link ptr field in object header.
	move.l	a0,d0
	add.l	d7,d0		; compute start of next SBM obj, 4 phrases off.
	lsr.l	#3,d0		; phrase align it
	move.l	d0,d1		; make a copy.

	lsr.l	#8,d0		; truncate the rightmost 8 bits.
	and.l	#$7ff,d0	; clear top 21 bits
	move.l	d0,(a0)		;  "						 Bit Mapped obj header.

	and.l	#$000000ff,d1	;we just want the low byte.
	ror.l	#8,d1		;low byte becomes hi byte of long.
	move.l	d1,4(a0)	;set least sig field of link ptr in SBM obj header.

	moveq	#0,d0
	moveq	#0,d1

; Invoke macros:
	Setobj_Type 	a1,a0 	
	Setobj_Xpos 	a1,a0
	move.w	O_YPOS(a1),d0
**	and.w	#$07ff,d0
	add.w	d0,d0
me_norm6:
	add.w	#ntsc_n_vdb,d0	;in half lines
	lsl.w	#3,d0
	and.w	#$c007,6(a0)	;clear old
	or.w	d0,6(a0)	;set new

	Setobj_DataPtr	a1,a0
	Setobj_Height	a1,a0
	Setobj_Depth	a1,a0
	Setobj_Pitch	a1,a0
	Setobj_Dwidth	a1,a0
	Setobj_Iwidth	a1,a0
	Setobj_Index	a1,a0
	Setobj_Release	a1,a0
	Setobj_Trans	a1,a0
	Setobj_RMW	a1,a0
	Setobj_Reflect	a1,a0
	Setobj_Firstpix	a1,a0
*	Setobj_Hscale	a1,a0
*	Setobj_Vscale	a1,a0
*	Setobj_Remainder a1,a0


; Flag this record as processed:

; Compute adr for next object
	add.w	d7,a1			; point to next record in source data.
	add.w	d7,a0			; point to next object header in object list

	bra	d_loop


OBJECT_2_QUICK:
*	YPOs=7ff
*	data???
*	type2

*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	%DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDYYYYYYYYYYYTTT

	move.l	#%00000000000000000000000000000000,(a0)
	move.l	#%00000000000000000011111111111011,4(a0)
	add.w	d7,a1
	lea	16(a0),a0
	bra	d_loop

OBJECT_1_QUICK:
	movem.l	(a1)+,d0/d1/d3/d4/d5/d6
	movem.l	d0/d1/d3/d4/d5/d6,(a0)
	
	addq.l	#8,a1
	add.w	d7,a0
	move.l	a0,d0
	lsl.l	#5,d0
	or.l	d0,-32+2(a0)
	bra	d_loop

JUMP_OBJECT:

*	%32109876543210987 6543210987654321 098765432109876 5432109876543210
*	%66665555555555444 4444444333333333 322222222221111 1111110000000000
*	%uuuuuuuuuuuuuuuuu uuuuuDDDDDDDDDDD DDDDDDDuuuuuuuu ccYYYYYYYYYYYTTT

	clr.w	(a0)
	clr.w	8(a0)
	
	move.w	(a1)+,6(a0)
	move.l	(a1)+,d0
	addq.w	#1,d0
	lsl.w	#5,d0
	add.l	a0,d0
	
	lsl.l	#5,d0
	move.l	d0,2(a0)
	
	move.w	#$7ff<<3+3,6+8(a0)
	
	move.l	d7,d0
	add.l	a0,d0
	
	lsl.l	#5,d0
	move.l	d0,2+8(a0)
	
	
	
	add.w	d7,a0
	lea	32-6(a1),a1
	bra	d_loop


JUMP_OBJECT1:

*	%32109876543210987 6543210987654321 098765432109876 5432109876543210
*	%66665555555555444 4444444333333333 322222222221111 1111110000000000
*	%uuuuuuuuuuuuuuuuu uuuuuDDDDDDDDDDD DDDDDDDuuuuuuuu ccYYYYYYYYYYYTTT

	
	
	clr.w	(a0)
	clr.w	8(a0)
	
	move.w	(a1),6(a0)
	move.w	2(a1),d0
	lsl.w	#5,d0
	add.l	a0,d0
	lsl.l	#5,d0
	move.l	d0,2(a0)
	
	move.w	6(a1),6+8(a0)
	move.l	d0,2+8(a0)
	
	move.w	#$7ff<<3+3,6+8+8(a0)
	
	move.l	d7,d0
	add.l	a0,d0
	lsl.l	#5,d0
	move.l	d0,2+8+8(a0)
	
	add.w	d7,a0
	add.w	d7,a1
	bra	d_loop


JUMP_OVER_OBJECT:

*	%32109876543210987 6543210987654321 098765432109876 5432109876543210
*	%66665555555555444 4444444333333333 322222222221111 1111110000000000
*	%uuuuuuuuuuuuuuuuu uuuuuDDDDDDDDDDD DDDDDDDuuuuuuuu ccYYYYYYYYYYYTTT

	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	move.w	(a1)+,d1
	move.l	(a1)+,d0
	addq.w	#1,d0
	lsl.w	#5,d0
	add.l	a0,d0
	lsl.l	#5,d0
	
	move.w	d1,6(a0)
	eor.w	#%1100000000000000,d1
	add.w	#32<<3,d1
	move.w	d1,6+8(a0)
	
	move.l	d0,2(a0)
	move.l	d0,2+8(a0)
	
	move.w	#$7ff<<3+3,6+8+8(a0)
	move.l	d7,d0
	add.l	a0,d0
	lsl.l	#5,d0
	move.l	d0,2+8+8(a0)
	
	add.w	d7,a0
	lea	32-6(a1),a1
	bra	d_loop

OVERLAY_OBJECT:
	movem.w	(a1),d0/d1/d3
	lsl.w	#5,d3				;index into table entry
	movem.l	0(a6,d3.w),d3/d4/d5/d6		;now pointing to entry in table
	lsl.l	#8,d3
	add.w	d1,d4				;and the y position
	or.w	d0,d6
	movem.l	d3/d4/d5/d6,(a0)
	move.l	a0,d0
	add.l	d7,d0
	lsl.l	#5,d0
	or.l	d0,2(a0)
	add.l	d7,a0
	add.l	d7,a1
	bra	d_loop
