build_pause:
	JSR	STOP_MOD
	move.w	#0,VMODE
	jsr	MAKE_OL
	move.w	#320,d0
	move.w	#230,d1
	lea	mod_load_addr,a1
	move.l	olist_view_pointer,a0

**********************************************************
Freeze:
	;Move.l	Object_List_Pointer+4(a4),a0
	;Move.l	Gfxblocks_Base(a4),a1
	;Move.w	#Screen_Width,d0
	;Move.w	#Screen_Height,d1
	;Bra	Construct_Cry_Screen

**********************************************************
; Parameters
; A0 - Object list to build to screen
; A1 - Area of memory to construct to (Must be phrased!)
; D0 - X Dimension of screen area
; D1 - Y Dimension of screen area

Get_Obj	Macro	
	Movem.l	Object_Data_Read,d0-d3
	Endm

Construct_Cry_Screen:
	Movem.l	a0-a1,Objlist_To_Build_From		; Save parameters
	Movem.w	d0-d1,Width_Of_Screen			; Save width/ height
	Move.l	#Backup_Freeze_Objectlist,d0
	And.l	#-16,d0
	Move.l	d0,Backup_Freeze_Objectlistp			; Phrase align pointer to vbl buffer
	Move.l	d0,a0
	Move.w	#0,d0
	Moveq	#4,d7					; Number of bits per pixel encoded
	Move.w	Width_Of_Screen,d2
	Lsr.w	#2,d2					; Get number of phrases !
	Move.w	Height_Of_Screen,d3
	Move.w	#0,d1					; Get height and y position 0
	Moveq	#0,d6

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
	
	Clr.l	(a0)+
	Move.l	#4,(a0)+				; Stop object

	Lea	Freeze_Objectlist,A0
	Move.l	Backup_Freeze_Objectlistp,a1
	Exg	a0,a1
	Rept	8
	Move.l	(a0)+,(a1)+
	Endr

	Move.l	Base_Screen_Buffer,a0
	Movem.w	Width_Of_Screen,d0-d1			; Base pointer to screen
	Mulu	d1,d0					; Size of screen in words

.Clear:
	Clr.w	(a0)+
	Subq.l	#1,d0
	Bne.s	.Clear					; Clear out screen
	
	Pea	Construct_Vbl
	MOve.l	(sp)+,LEVEL2
	Move.l	Backup_Freeze_Objectlistp,d0
	swap	d0
	move.l	d0,OLP			; and other bits of the OL address
	move.w	#VIEW_RESOLUTION,VMODE

Object_Type_Loop:
	Move.l	Objlist_To_Build_From,a0
	Movem.l	(a0)+,d0-d3
	Movem.l	d0-d3,Object_Data_Read
	Bsr	Get_Object_Attributes		
	Cmp.w	#0,Object_Type
	Bne	Not_A_Bitmap_Object
	Tst.w	Object_Dwidth
	Beq	.Skip_Object

	Clr.w	Source_Gfx_Y
.Loop0:
	Clr.w	-(sp)
.Loop1:
	Clr.w	-(sp)
	Clr.w	Source_Gfx_X
	Tst.b	Object_Reflect
	Beq.s	.Loop2
	Move.w	Object_Dwidth,d2
	Lsl.w	#3,d2
	Subq.w	#1,d2
	Asr.w	#1,d2
	Move.w	d2,Source_Gfx_X
	Neg.w	d2
	Move.w	d2,(sp)
.Loop2:
	Movem.w	(sp),d0-d1
	Add.w	Object_Xpos,d0
	Add.w	Object_Ypos,d1
	Tst.w	d0
	Bmi	.Incx
	Tst.w	d1
	Bmi	.Incx
	Move.w	Width_Of_Screen,d4
	Cmp.w	d4,d0
	Bge	.Incx
	Cmp.w	Height_Of_Screen,d1
	Bge	.Incx
	Mulu	Width_Of_Screen,d1
	Add.l	d1,d1
	Ext.l	d0
	Add.l	d0,d1
	Add.l	d0,d1
	Add.l	Base_Screen_Buffer,d1
	Move.l	d1,Address_Of_CRYPixel
	Movem.w	Source_Gfx_X,d0-d1
	Bsr	Get_A_Pixel
	Tst.w	d7
	Bne.s	.Not_Trans
	Tst.b	Object_Trans
	Bne.s	.Incx
.Not_Trans:
	Move.l	Address_Of_CRYPixel,a3
	Tst.b	Object_RMW
	Beq.s	.Not_Rmw_Object
	Tst.w	d7
	Beq.s	.Ploted_Pixel
	Addq.l	#1,a3
.Back1:
	Tst.w	d7
	Beq.s	.Ploted_Pixel
	Tst.b	d7
	Bpl.s	.Pos1
	Neg.b	d7
	Sub.b	d7,(a3)
	Bcc.s	.No_Carry1
	Clr.b	(a3)
.No_Carry1:
	Lsr.w	#8,d7
	Subq.l	#1,a3
	Bra.s	.Back1
.Pos1:
	Add.b	d7,(a3)
	Bcc.s	.No_Carry2
	Move.b	#$ff,(a3)	
.No_Carry2:
	Lsr.w	#8,d7
	Subq.l	#1,a3
	Bra.s	.Back1
.Not_Rmw_Object:
	Move.w	d7,(a3)
.Ploted_Pixel:
.Incx:
	Addq.w	#1,(sp)
	Tst.b	Object_Reflect
	Beq.s	.Normal_Dec
	Subq.w	#1,Source_Gfx_X
	Bpl	.Loop2
	Bra.s	.Skip
.Normal_Dec:
	Addq.w	#1,Source_Gfx_X
	Move.w	Source_Gfx_X,d2
	
	Move.w	Object_Dwidth,d3
	Lsl.w	#3,d3
	Lsl.w	#3,d3
	Move.w	Object_Depth,d4
	Lsr.w	d4,d3	
	Cmp.w	d3,d2
	Bne	.Loop2
.Skip:
	Addq.l	#2,sp
	Addq.w	#1,(sp)
	Addq.w	#1,Source_Gfx_Y
	Move.w	(sp),d2
	Cmp.w	Object_Height,d2
	Bne	.Loop1
	Addq.l	#2,sp
.Skip_Object:
	MOve.l	Object_Link,Objlist_To_Build_From
	Bra	Object_Type_Loop

; d0-x
; d1-y
; Returns CRY in d7

Get_A_Pixel:
	Mulu	Object_Dwidth,d1
	Lsl.l	#3,d1
	Add.l	Object_Data,d1
	Move.l	d1,a3
	Move.w	Object_Depth,d2
	Add.w	d2,d2
	Add.w	d2,d2
	Lea	Dest_Bits,a6
	Clr.l	(a6)
	Jmp	.Jt(pc,d2)
.Jt:
	Bra.w	.Pixel1
	Bra.w	.Pixel2
	Bra.w	.Pixel4
	Bra.w	.Pixel8
	Bra.w	.Pixel16
	Bra.w	.Pixel32

.Pixel1:
.Pixel2:
.Pixel4:
	Move.w	Object_Depth,d2
	Lsl.w	d2,d0				; Which bit field to check
	Moveq	#$7,d1
	And.w	d0,d1
	Eor.w	#$7,d1				; First bit to check
	Lsr.w	#3,d0				; Divide by bytes !
	
	Moveq	#1,d3
	Lsl.w	d2,d3
	Subq.w	#1,d3
.Check_Loop:
	btst	d1,(a3,d0)
	Sne	(a6)+
	Subq.b	#1,d1
	Bcc.s	.No_Carry
	Moveq	#$7,d1
	Addq.w	#1,d0
.No_Carry:
	Dbra	d3,.Check_Loop

	Moveq	#1,d3
	Lsl.w	d2,d3
	Subq.w	#1,d3
	Moveq	#0,d4
	Lea	Dest_Bits,a6
.Bit_Loop:
	Tst.b	(a6)+
	Sne	d5
	And.b	#1,d5
	Lsl.w	#1,d4
	Or.b	d5,d4
	Dbra	d3,.Bit_Loop
	Tst.b	d4
	Bne.s	.Not_Trans	
	Tst.b	Object_Trans
	Beq.s	.Not_Trans
	Moveq	#0,d7
	Rts
.Not_Trans:
	Move.w	Object_Index,d7
	Lsl.w	#1,d7
	Add.w	d4,d7
	Bra	.Pixel_There
.Pixel8:
	Moveq	#0,d7
	Move.b	(a3,d0),d7
	Bne.s	.Pixel_There
	Tst.b	Object_Trans
	Beq.s	.Pixel_There
	Moveq	#0,d7
	Rts
.Pixel_There:
	Add.w	d7,d7
	Lea	CLUT,a2
	Move.w	(a2,d7),d7
	Rts
.Pixel16:
	Add.w	d0,d0
	Move.w	(a3,d0),d7
	Rts
.Pixel32:
	Illegal

Not_A_Bitmap_Object:
	Cmp.w	#4,Object_Type
	Beq	Its_A_Stop_Object
	Cmp.w	#3,Object_Type
	Bne.s	.Not_Branch
	Get_Obj
	MOveq	#14,d7
	Lsr.w	d7,d1
	And.b	#%11,d1
	Bne.s	.Conditional
	MOve.l	Object_Link,Objlist_To_Build_From
	Bra	Object_Type_Loop
.Conditional:
	Addq.l	#8,Objlist_To_Build_From
	Bra	Object_Type_Loop

.Not_Branch:
	Addq.l	#8,Objlist_To_Build_From
	Bra	Object_Type_Loop
	Illegal
	Nop

Its_A_Stop_Object:
	Move.l	Base_Screen_Buffer,a0
	Subq.l	#4,a0
	Movem.w	Width_Of_Screen,d0-d1
	Movem.w	d0-d1,(a0)
	Mulu	d1,d0
	Add.l	d0,d0
	Addq.l	#4,d0
;	Movem.l	d0-d7/a0-a6,-(sp)
;	Addq.l	#4,a0
;	Move.w	panel_y_pos,-(sp)
;	Move.w	#$00ff,d0
;.Loop0	Move.w	#400,-(sp)
;.Loop1	Tst.w	(a0)+
;	Bne.s	.Pixel_There
;	Move.w	d0,-2(a0)
;.Pixel_There
;	Subq.w	#1,(sp)
;	Bne.s	.Loop1
;	Addq.l	#2,sp
;	Subq.b	#1,d0
;	Subq.w	#1,(sp)
;	Bne.s	.Loop0
;	Addq.l	#2,sp
;	Movem.l	(sp)+,d0-d7/a0-a6
	Illegal

Get_Object_Attributes:
	Get_Obj
	And.l	#%111,d1
	Move.w	d1,Object_Type
	Get_Obj
	And.l	#%11111111111000,d1
	cmp.w	#0,d1
	beq.s	.no_sub
	Lsr.l	#4,d1
	Sub.w	#(n_vdb)/2,d1
	Asl.w	#6,d1
	Asr.w	#6,d1
.no_sub:
	Move.w	d1,Object_Ypos
	Get_Obj
	And.l	#%1111111111100000000000000,d1
	Moveq	#14,d7
	Lsr.l	d7,d1
	Move.w	d1,Object_Height
	Get_Obj
	And.l	#%11111111<<24,d1
	Moveq	#24,d7
	Lsr.l	d7,d1
	And.l	#%11111111111,d0
	Lsl.l	#8,d0
	Add.l	d0,d1
	Lsl.l	#3,d1
	Move.l	d1,Object_Link
	Get_Obj
	And.l	#%11111111111111111111100000000000,d0
	Moveq	#11,d7
	Lsr.l	d7,d0
	Lsl.l	#3,d0
	Move.l	d0,Object_Data
	
	Get_Obj
	And.l	#%111111111111,d3
	Asl.w	#4,d3
	Asr.w	#4,d3
	Move.w	d3,Object_Xpos
	Get_Obj
	Moveq	#12,d7
	Lsr.l	d7,d3
	And.w	#%111,d3
	Move.w	d3,Object_Depth
	Get_Obj
	And.l	#%1111111111000000000000000000,d3
	Moveq	#18,d7
	Lsr.l	d7,d3
	Move.w	d3,Object_Dwidth
	Get_Obj
	And.l	#%1111111000000,d2
	Lsr.l	#38-32,d2
	Move.w	d2,Object_Index
	Get_Obj
	Btst	#45-32,d2
	Sne	Object_Reflect
	Btst	#46-32,d2
	Sne	Object_RMW
	Btst	#47-32,d2
	Sne	Object_Trans
	Rts

Construct_Vbl:
	movem.l	d0-a6,-(sp)
	Lea	Freeze_Objectlist,A0
	Move.l	Backup_Freeze_Objectlistp,a1
	Rept	8
	Move.l	(a0)+,(a1)+
	Endr
	Move.l	Backup_Freeze_Objectlistp,d0
	swap	d0
	move.l	d0,OLP			; and other bits of the OL address
	Move.w	INT1,d0
	lsl.w	#8,d0
	move.b	intmask,d0
	move.w	d0,INT1
	move.w	d0,INT2
	movem.l	(sp)+,d0-a6
	Rte

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
Address_Of_CRYPixel:	Ds.l	1
Object_Data_Read:		Ds.l	4
Source_Gfx_X:			Ds.w	1
Source_Gfx_Y:			Ds.w	1

Objlist_To_Build_From:	Ds.l	1
Base_Screen_Buffer:		Ds.l	1
Width_Of_Screen:		Ds.w	1
Height_Of_Screen:		Ds.w	1
						Ds.b	16
Backup_Freeze_Objectlist:	Ds.b	32
Backup_Freeze_Objectlistp:	Ds.l	1
Freeze_Objectlist:		Ds.b	32
