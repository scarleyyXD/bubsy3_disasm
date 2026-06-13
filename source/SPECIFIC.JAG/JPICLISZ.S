MAX_SPRITES	equ	100

NEW_OL:
	clr.l	number_of_items
	move.l	#olist_data,olist_pointer
	rts
	
ADD_OL:
	move.l	olist_pointer,a0
	add.l	#OBJ_SIZE,olist_pointer
	addq.l	#1,number_of_items
	rts	

KILL_LAST_OBJECT:
	sub.l	#OBJ_SIZE,olist_pointer
	subq.l	#1,number_of_items
	rts	

MAKE_OL:
	jsr	Setup_Initial_Branch
	move.l	Dont_Know_What_This_Does_Pointer,a0
	lea	16(a0),a0
	move.l	olist_view_pointer,a1
	move.w	#BRA_VCEQ,d0
	move.w	#$7ff,d1	
	jsr	Make_Branch_Object
	move.l	number_of_items,d2
	lea	olist_data,a1		;reset pointer

;data is set up
;so call list builder
;must build in working copy so link addresses are correct!

	move.l	olist_view_pointer,a0
	jsr	build_olist
	move.l	Dont_Know_What_This_Does_Pointer,d0
	swap	d0
	move.l	d0,OLP		;reset this pointer
	rts
	
set_start_for_ol:
	lea	olist_master,a0
	lea	40(a0),a0
	move.l	a0,d0
	and.b	#$e0,d0
	move.l	d0,olist_view_pointer
	rts

;currently being worked upon

olist_view_pointer:	dc.l	0
olist_pointer:		dc.l	0
number_of_items:	dc.l	0
