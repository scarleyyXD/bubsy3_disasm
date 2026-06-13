build_pause:
	jsr	STOP_MOD
	move.w	#0,VMODE
	jsr	MAKE_OL
	move.w	#320,d0
	move.w	#230,d1
	lea	mod_load_addr,a1
	move.l	olist_view_pointer,a0

**********************************************************
Freeze:
;	move.l	Object_List_Pointer+4(a4),a0
;	move.l	Gfxblocks_Base(a4),a1
;	move.w	#Screen_Width,d0
;	move.w	#Screen_Height,d1
;	bra	Construct_Cry_Screen

**********************************************************
; Parameters
; a0 - Object list to build to screen
; a1 - Area of memory to construct to (Must be phrased!)
; d0 - X Dimension of screen area
; d1 - Y Dimension of screen area

.macro	Get_Obj
	movem.l	Object_Data_Read,d0-d3
	.endm

Construct_Cry_Screen:
	movem.l	a0-a1,Objlist_To_Build_From		; Save parameters
	movem.w	d0-d1,Width_Of_Screen			; Save width/ height
	move.l	#Backup_Freeze_Objectlist,d0
	and.l	#-16,d0
	move.l	d0,Backup_Freeze_Objectlistp			; Phrase align pointer to vbl buffer
	move.l	d0,a0
	move.w	#0,d0
	moveq	#4,d7					; Number of bits per pixel encoded
	move.w	Width_Of_Screen,d2
	lsr.w	#2,d2					; Get number of phrases !
	move.w	Height_Of_Screen,d3
	move.w	#0,d1					; Get height and y position 0
	moveq	#0,d6

	clr.l	(a0)
	move.l	#%00000000001110011000000000000000|(ntsc_n_vdb<<3),4(a0)	;432 wide
	move.l	#%00000000000000001000000000001010,8(a0)	;16bpp,230 high
	move.l	#%00000001010000001100000000000000,12(a0)

*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000001110011000000000000000,12(a0)
*	%0000000000000000000000000000101000000001010000001100000000000000,12(a0)
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000
	
	move.l	a1,d2
	lsl.l	#8,d2
	move.l	d2,(A0)
	lea	16(a0),a0		;data addr
	
	move.l	a0,d0
	lsl.l	#5,d0
	or.l	d0,-16+2(a0)		; link addr
	
	clr.l	(a0)+
	move.l	#4,(a0)+				; Stop object

	lea	Freeze_Objectlist,A0
	move.l	Backup_Freeze_Objectlistp,a1
	exg	a0,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr

	move.l	Base_Screen_Buffer,a0
	movem.w	Width_Of_Screen,d0-d1			; Base pointer to screen
	mulu	d1,d0					; Size of screen in words

.Clear:
	clr.w	(a0)+
	subq.l	#1,d0
	bne.s	.Clear					; Clear out screen
	
	pea	Construct_Vbl
	move.l	(sp)+,LEVEL2
	move.l	Backup_Freeze_Objectlistp,d0
	swap	d0
	move.l	d0,OLP			; and other bits of the OL address
	move.w	#VIEW_RESOLUTION,VMODE

Object_Type_Loop:
	move.l	Objlist_To_Build_From,a0
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,Object_Data_Read
	bsr	Get_Object_Attributes		
	cmp.w	#0,Object_Type
	bne	Not_A_Bitmap_Object
	tst.w	Object_Dwidth
	beq	.Skip_Object

	clr.w	Source_Gfx_Y
.Loop0:
	clr.w	-(sp)
.Loop1:
	clr.w	-(sp)
	clr.w	Source_Gfx_X
	tst.b	Object_Reflect
	beq.s	.Loop2
	move.w	Object_Dwidth,d2
	lsl.w	#3,d2
	subq.w	#1,d2
	asr.w	#1,d2
	move.w	d2,Source_Gfx_X
	neg.w	d2
	move.w	d2,(sp)
.Loop2:
	movem.w	(sp),d0-d1
	add.w	Object_Xpos,d0
	add.w	Object_Ypos,d1
	tst.w	d0
	bmi	.Incx
	tst.w	d1
	bmi	.Incx
	move.w	Width_Of_Screen,d4
	cmp.w	d4,d0
	bge	.Incx
	cmp.w	Height_Of_Screen,d1
	bge	.Incx
	mulu	Width_Of_Screen,d1
	add.l	d1,d1
	ext.l	d0
	add.l	d0,d1
	add.l	d0,d1
	add.l	Base_Screen_Buffer,d1
	move.l	d1,Address_Of_CRYPixel
	movem.w	Source_Gfx_X,d0-d1
	bsr	Get_A_Pixel
	tst.w	d7
	bne.s	.Not_Trans
	tst.b	Object_Trans
	bne.s	.Incx
.Not_Trans:
	move.l	Address_Of_CRYPixel,a3
	tst.b	Object_RMW
	beq.s	.Not_Rmw_Object
	tst.w	d7
	beq.s	.Ploted_Pixel
	addq.l	#1,a3
.Back1:
	tst.w	d7
	beq.s	.Ploted_Pixel
	tst.b	d7
	bpl.s	.Pos1
	neg.b	d7
	sub.b	d7,(a3)
	bcc.s	.No_Carry1
	clr.b	(a3)
.No_Carry1:
	lsr.w	#8,d7
	subq.l	#1,a3
	bra.s	.Back1
.Pos1:
	add.b	d7,(a3)
	bcc.s	.No_Carry2
	move.b	#$ff,(a3)	
.No_Carry2:
	lsr.w	#8,d7
	subq.l	#1,a3
	bra.s	.Back1
.Not_Rmw_Object:
	move.w	d7,(a3)
.Ploted_Pixel:
.Incx:
	addq.w	#1,(sp)
	tst.b	Object_Reflect
	beq.s	.Normal_Dec
	subq.w	#1,Source_Gfx_X
	bpl	.Loop2
	bra.s	.Skip
.Normal_Dec:
	addq.w	#1,Source_Gfx_X
	move.w	Source_Gfx_X,d2
	
	move.w	Object_Dwidth,d3
	lsl.w	#3,d3
	lsl.w	#3,d3
	move.w	Object_Depth,d4
	lsr.w	d4,d3	
	cmp.w	d3,d2
	bne	.Loop2
.Skip:
	addq.l	#2,sp
	addq.w	#1,(sp)
	addq.w	#1,Source_Gfx_Y
	move.w	(sp),d2
	cmp.w	Object_Height,d2
	bne	.Loop1
	addq.l	#2,sp
.Skip_Object:
	move.l	Object_Link,Objlist_To_Build_From
	bra	Object_Type_Loop

; d0-x
; d1-y
; Returns CRY in d7

Get_A_Pixel:
	mulu	Object_Dwidth,d1
	lsl.l	#3,d1
	add.l	Object_Data,d1
	move.l	d1,a3
	move.w	Object_Depth,d2
	add.w	d2,d2
	add.w	d2,d2
	lea	Dest_Bits,a6
	clr.l	(a6)
	jmp	.Jt(pc,d2)
.Jt:
	bra.w	.Pixel1
	bra.w	.Pixel2
	bra.w	.Pixel4
	bra.w	.Pixel8
	bra.w	.Pixel16
	bra.w	.Pixel32

.Pixel1:
.Pixel2:
.Pixel4:
	move.w	Object_Depth,d2
	lsl.w	d2,d0				; Which bit field to check
	moveq	#$7,d1
	and.w	d0,d1
	eor.w	#$7,d1				; First bit to check
	lsr.w	#3,d0				; Divide by bytes !
	
	moveq	#1,d3
	lsl.w	d2,d3
	subq.w	#1,d3
.Check_Loop:
	btst	d1,(a3,d0)
	sne	(a6)+
	subq.b	#1,d1
	bcc.s	.No_Carry
	moveq	#$7,d1
	addq.w	#1,d0
.No_Carry:
	dbra	d3,.Check_Loop

	moveq	#1,d3
	lsl.w	d2,d3
	subq.w	#1,d3
	moveq	#0,d4
	lea	Dest_Bits,a6
.Bit_Loop:
	tst.b	(a6)+
	sne	d5
	and.b	#1,d5
	lsl.w	#1,d4
	or.b	d5,d4
	dbra	d3,.Bit_Loop
	tst.b	d4
	bne.s	.Not_Trans	
	tst.b	Object_Trans
	beq.s	.Not_Trans
	moveq	#0,d7
	rts
.Not_Trans:
	move.w	Object_Index,d7
	lsl.w	#1,d7
	add.w	d4,d7
	bra	.Pixel_There
.Pixel8:
	moveq	#0,d7
	move.b	(a3,d0),d7
	bne.s	.Pixel_There
	tst.b	Object_Trans
	beq.s	.Pixel_There
	moveq	#0,d7
	rts
.Pixel_There:
	add.w	d7,d7
	lea	CLUT,a2
	move.w	(a2,d7),d7
	rts
.Pixel16:
	add.w	d0,d0
	move.w	(a3,d0),d7
	rts
.Pixel32:
	illegal

Not_A_Bitmap_Object:
	cmp.w	#4,Object_Type
	beq	Its_A_Stop_Object
	cmp.w	#3,Object_Type
	bne.s	.Not_Branch
	Get_Obj
	moveq	#14,d7
	lsr.w	d7,d1
	and.b	#%11,d1
	bne.s	.Conditional
	move.l	Object_Link,Objlist_To_Build_From
	bra	Object_Type_Loop
.Conditional:
	addq.l	#8,Objlist_To_Build_From
	bra	Object_Type_Loop

.Not_Branch:
	addq.l	#8,Objlist_To_Build_From
	bra	Object_Type_Loop
	illegal
	nop

Its_A_Stop_Object:
	move.l	Base_Screen_Buffer,a0
	subq.l	#4,a0
	movem.w	Width_Of_Screen,d0-d1
	movem.w	d0-d1,(a0)
	mulu	d1,d0
	add.l	d0,d0
	addq.l	#4,d0
;	movem.l	d0-d7/a0-a6,-(sp)
;	addq.l	#4,a0
;	move.w	panel_y_pos,-(sp)
;	move.w	#$00ff,d0
;.Loop0:
;	move.w	#400,-(sp)
;.Loop1:
;	tst.w	(a0)+
;	bne.s	.Pixel_There
;	move.w	d0,-2(a0)
;.Pixel_There:
;	subq.w	#1,(sp)
;	bne.s	.Loop1
;	addq.l	#2,sp
;	subq.b	#1,d0
;	subq.w	#1,(sp)
;	bne.s	.Loop0
;	addq.l	#2,sp
;	movem.l	(sp)+,d0-d7/a0-a6
	illegal

Get_Object_Attributes:
	Get_Obj
	and.l	#%111,d1
	move.w	d1,Object_Type
	Get_Obj
	and.l	#%11111111111000,d1
	cmp.w	#0,d1
	beq.s	.no_sub
	lsr.l	#4,d1
	sub.w	#(n_vdb)/2,d1
	asl.w	#6,d1
	asr.w	#6,d1
.no_sub:
	move.w	d1,Object_Ypos
	Get_Obj
	and.l	#%1111111111100000000000000,d1
	moveq	#14,d7
	lsr.l	d7,d1
	move.w	d1,Object_Height
	Get_Obj
	and.l	#%11111111<<24,d1
	moveq	#24,d7
	lsr.l	d7,d1
	and.l	#%11111111111,d0
	lsl.l	#8,d0
	add.l	d0,d1
	lsl.l	#3,d1
	move.l	d1,Object_Link
	Get_Obj
	and.l	#%11111111111111111111100000000000,d0
	moveq	#11,d7
	lsr.l	d7,d0
	lsl.l	#3,d0
	move.l	d0,Object_Data
	
	Get_Obj
	and.l	#%111111111111,d3
	asl.w	#4,d3
	asr.w	#4,d3
	move.w	d3,Object_Xpos
	Get_Obj
	moveq	#12,d7
	lsr.l	d7,d3
	and.w	#%111,d3
	move.w	d3,Object_Depth
	Get_Obj
	and.l	#%1111111111000000000000000000,d3
	moveq	#18,d7
	lsr.l	d7,d3
	move.w	d3,Object_Dwidth
	Get_Obj
	and.l	#%1111111000000,d2
	lsr.l	#38-32,d2
	move.w	d2,Object_Index
	Get_Obj
	btst	#45-32,d2
	sne	Object_Reflect
	btst	#46-32,d2
	sne	Object_RMW
	btst	#47-32,d2
	sne	Object_Trans
	rts

Construct_Vbl:
	movem.l	d0-a6,-(sp)
	lea	Freeze_Objectlist,A0
	move.l	Backup_Freeze_Objectlistp,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.l	Backup_Freeze_Objectlistp,d0
	swap	d0
	move.l	d0,OLP			; and other bits of the OL address
	move.w	INT1,d0
	lsl.w	#8,d0
	move.b	intmask,d0
	move.w	d0,INT1
	move.w	d0,INT2
	movem.l	(sp)+,d0-a6
	rte

panel_y_pos:	ds.w	0
Dest_Bits:		ds.b	4

Object_Type:	ds.w	1
Object_Ypos:	ds.w	1
Object_Height:	ds.w	1
Object_Link:	Ds.l	1
Object_Data:	Ds.l	1
	
Object_Xpos:	ds.w	1
Object_Depth:	ds.w	1
Object_Dwidth:	ds.w	1
Object_Index:	ds.w	1
Object_Reflect:	ds.b	1
Object_RMW:		ds.b	1
Object_Trans:	ds.b	1
		even
Address_Of_CRYPixel:	ds.l	1
Object_Data_Read:		ds.l	4
Source_Gfx_X:			ds.w	1
Source_Gfx_Y:			ds.w	1

Objlist_To_Build_From:	ds.l	1
Base_Screen_Buffer:		ds.l	1
Width_Of_Screen:		ds.w	1
Height_Of_Screen:		ds.w	1
						ds.b	16
Backup_Freeze_Objectlist:	ds.b	32
Backup_Freeze_Objectlistp:	ds.l	1
Freeze_Objectlist:		ds.b	32
