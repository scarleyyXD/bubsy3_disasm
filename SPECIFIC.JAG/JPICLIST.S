
MAX_SPRITES	equ	100


NEW_OL:
	bsr	change_ol_lists
	clr.l	number_of_items
	move.l	working_ol_base,olist_pointer
	rts
	
ADD_OL:
	move.l	olist_pointer,a0
	add.l	#OBJ_SIZE,olist_pointer
	addq.l	#1,number_of_items
	rts	

ADD_OL_DISPLAY:
	move.l	display_olist_pointer,a0
	add.l	#OBJ_SIZE,display_olist_pointer
	addq.l	#1,display_number_of_items
	rts	

KILL_LAST_OBJECT:
	sub.l	#OBJ_SIZE,olist_pointer
	subq.l	#1,number_of_items
	rts	

change_ol_lists:
	lea	olist_pointer,a0
	movem.l	(a0),d0-d5
	exg.l	d0,d3
	exg.l	d1,d4
	exg.l	d2,d5
	movem.l	d0-d5,(a0)
	rts


MAKE_OL:	
	jsr	Setup_Initial_Branch
	Move.l	Dont_Know_What_This_Does_Pointer,a0
	Lea	16(a0),a0
	move.l	olist_view_pointer,a1
	Move.w	#BRA_VCEQ,d0
	Move.w	#$7ff,d1	
	Jsr	Make_Branch_Object
	move.l	display_number_of_items,d2
	move.l	display_ol_base,a1

;data is set up
;so call list builder
;must build in working copy so link addresses are correct!

	move.l	olist_view_pointer,a0
	jsr	build_olist
	Move.l	Dont_Know_What_This_Does_Pointer,d0
	swap	d0
	move.l	d0,OLP		;reset this pointer
	rts
	
set_start_for_ol:
	lea	olist_data,a0
	lea	40(a0),a0
	move.l	a0,d0
	and.b	#$e0,d0
	move.l	d0,olist_view_pointer

	move.l	#olist_master,working_ol_base
	move.l	#olist_master1,display_ol_base

	rts

olist_view_pointer:	dc.l	0

;currently being worked upon

olist_pointer:			dc.l	0
number_of_items:		dc.l	0
working_ol_base:		dc.l	0

;one i'm seeing

display_olist_pointer:		dc.l	0
display_number_of_items:	dc.l	0
display_ol_base:		dc.l	0
