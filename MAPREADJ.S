CONTROL_PLANE	equ	0		; back = 2 , fore = 0
;;;ASBx: ;************************************************************************

STICKOBJECTTOPLAYFIELD:
	moveq	#OBJONOBJFLAG,d0
	and.b	OBJFLAGS(A5),d0										;be sure object is not on top another object
	beq.s	.ok
.no:	rts
.ok:	tst.w	OBJX(a5)										;if object is off end of map then no change
	bmi.s	.no
	
	moveq	#16,d7											;step size
	moveq	#$f0,d5
	move.w	OBJY(A5),d0										;ie start 16 pixels up and check 256 in depth
	and.w	d5,d0
	sub.w	d7,d0											;start 1 blocks up and check 16 below
	moveq	#(256/16)-1,d6
	
	moveq	#0,d3
	move.w	MAPWID,d3
	move.w	#ATTR_MASK,d4
	lea	MAPBASE,a0							;read the word in the map
	lea	DOUBLETAKE,a1							;get associated front:back word
	lea	ATTRTABLE,a2							;get the attribute
	lea	DYTAB,a3
	
	

.B20:
	move.w	d0,OBJY(A5)
	move.w	d0,d2
	move.w	OBJX(A5),d1

	bsr	GETATTRIB_SETUP
	
.OFFMAP:
	and.w	d4,d0										;lsb indicates slope direction !
	bne.s	.B30

	move.w	OBJY(A5),d0
	add.w	d7,d0

	DBRA	d6,.B20
	rts
.B30:
	asl.w	#4,d0
	move.w	d0,d6

	moveq	#$0f,d0
	and.w	OBJX(A5),d0

	add.w	d0,d6
	
	move.w	OBJY(A5),d1
	and.w	d5,d1
	
	moveq	#16,d0
	sub.b	0(a3,d6.W),d0
	
	cmp.b	d7,d0
	beq.s	.okno
	add.w	d1,d0
	move.w	d0,OBJY(A5)
	rts
.okno:	
	move.w	OBJY(A5),d0
	add.w	d7,d0
	
	move.w	d0,OBJY(A5)
	move.w	d0,d2
	move.w	OBJX(A5),d1

	bsr	GETATTRIB_SETUP
	
	and.w	d4,d0
	
	asl.w	#4,d0
	move.w	d0,d6

	moveq	#$0f,d0
	and.w	OBJX(A5),d0

	add.w	d0,d6
	
	move.w	OBJY(A5),d1
	and.w	d5,d1
	
	sub.b	0(a3,d6.W),d7
	
	add.w	d1,d7
	move.w	d7,OBJY(A5)
	

	rts


;;;ASBx: ;************************************************************************
GETGRAVITY:										;this routine returns the slope of the surface bubsy
	moveq	#BUBONOBJFLAG,d0
	and.b	BUBSYFLAGS,d0								;is standng on
	beq.s	.B10

	move.w	BUBOBJGRAV,d0
	move.w	d0,d1
	bra.s	.B11
.B10:
	move.w	BUBX,d1
	move.w	BUBY,d2
	bsr	GETATTRIB
	move.w	d0,d1										;save attribute
.B11:	
	and.w	#ATTR_MASK,d0
	beq.s	.B40
	
	add.w	d0,d0
	cmp.w	#($3ff*4),d0
	bcc.s	.B40

	lea	VXTAB,a0
	move.w	0(a0,d0.w),d0
	rts
.B40:
	moveq	#0,d0
	rts


GETOBJECTGRAVITY:										;this routine returns the slope of the surface 
	bsr	GETATTRIB
	move.w	d0,d1										;save attribute
.B11:	
	and.w	#ATTR_MASK,d0
	beq.s	.B40
	
	add.w	d0,d0

	lea	VXTAB,a0
	move.w	0(a0,d0.w),d0
	rts
.B40:
	moveq	#0,d0
	rts

;;;ASBx; 
;;;ASBx; ; ***********************************************************************
;;;ASBx; ; *									*
;;;ASBx; ; * BASIC GETCHR FUNCTION						*
;;;ASBx; ; *									*
;;;ASBx; ; ***********************************************************************
;;;ASBx; >GETATTRIB
;;;ASBx; ; THIS ROUTINE GIVEN PIXEL COORDINATES IN TEMP0,TEMP1
;;;ASBx; ; WILL RETURN THE ATTRIBUTE WORD OF THE MIDGROUND CHARACTER IN THE ACCUMULATOR


GETATTRIB:

; SEGA:
; D1 X
; D2 Y
; D0 RESULT
	tst.w	d2
	bmi.s	.OFFMAP
	cmp.w	MAPHTP,d2
	bcc.s	.OFFMAP

	ext.l	d1
	ext.l	d2

	lsr.w	#4,d1								;(x/16)
	lsr.w	#4,d2								;(y/16)
	mulu.w	MAPWID,d2							;times map width
	add.l	d1,d2								;add x+y

	add.l	d2,d2								;times 2 for word map
	
	lea	MAPBASE,a0							;read the word in the map
	moveq	#0,d0
	move.w	0(a0,d2.L),d0
	lsl.l	#2,d0								;*4 that word to 
	
	
	lea	DOUBLETAKE,a0							;get associated front:back word
	move.w	CONTROL_PLANE(a0,d0.l),d0
	add.w	d0,d0								;double it
	lea	ATTRTABLE,a0							;get the attribute
	move.w	0(a0,d0.w),d0
	rts
.OFFMAP:										;if off the top of the matt return 0
	moveq	#0,d0
	rts


GETATTRIB_SETUP:

;d3 = MAPWIDTH
;a0 = MAPBASE,
;a1 = DOUBLETAKE
;a2 = ATTRTABLE
	
;D1= X
;D2= Y
;D0= RESULT

	tst.w	d2
	bmi.s	.OFFMAP
	cmp.w	MAPHTP,d2
	bcc.s	.OFFMAP

	ext.l	d1
	ext.l	d2
	lsr.w	#4,d1								;(x/16)
	lsr.w	#4,d2								;(y/16)
	mulu.w	d3,d2								;times map width
	add.l	d1,d2								;add x+y
	add.l	d2,d2

	moveq	#0,d0
	move.w	0(a0,d2.L),d0
	lsl.l	#2,d0								;double that word to get 
	move.w	CONTROL_PLANE(a1,d0.l),d0
	add.w	d0,d0								;double it
	move.w	0(a2,d0.w),d0
	rts

.OFFMAP:												;if off the top of the matt return 0
	moveq	#0,d0
	rts


