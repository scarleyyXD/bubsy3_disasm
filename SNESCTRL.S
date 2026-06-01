GETINPUT:

;;;ASBx: ; RECORD FORMAT:
;;;ASBx: ; BYTE VBL COUNT 0 START FADEOUT (TRIGGERED BY SELECT)
;;;ASBx: ; BYTE CONTROLLER AX......	LOW
;;;ASBx: ;		
;;;ASBx: ;		 BY..UDLR	HIGH
;;;ASBx: ;		 ||||||||
;;;ASBx: ;		 BYAXUDLR	

	bsr	segajoy

.NORMALCTRL:
	move.w	JOY1L,d0
	move.w	d0,d1
	not.w	d0
	or.w	STICK1,d0
	not.w	d0
	move.w	d0,EDGESTICK1
	move.w	d1,STICK1

	move.w	JOY2L,d0
	move.w	d0,d1
	not.w	d0
	or.w	STICK2,d0
	not.w	d0
	move.w	d0,EDGESTICK2
	move.w	d1,STICK2

	rts
