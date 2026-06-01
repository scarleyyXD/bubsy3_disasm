;;;ASBx: ;************************************************************************
;;;ASBx: ;*									 *
;;;ASBx: ;* BUBSY OBJECT HANDLER     						 *
;;;ASBx: ;*									 *
;;;ASBx: ;************************************************************************

YRANGE	equ 	100

;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE RETURNS WITH THE CARRY FLAG SET IF THE CALLING OBJECT IS OFF THE 
;;;ASBx: ; SCREEN BY YRANGE PIXELS
;;;ASBx: ;************************************************************************

CLIPY
	MOVE	D0,-(SP)
	MOVE.w	OBJY(A5),D0
	ADD.w	#YRANGE,D0
	CMP.w	WINDY,D0
	BLT.s	.CLIP
	SUB.w	#YRANGE*2+240,D0
	BMI.s	.ONSCREEN
	CMP.w	WINDY,D0
	BGE.s	.CLIP
.ONSCREEN
	MOVE	(SP)+,D0
	RTS
.CLIP
	ADDQ.L	#2+4,SP
	RTS


CLIPYSMALL
	MOVE	D0,-(SP)
	MOVE.w	OBJY(A5),D0
	ADD.w	#YRANGE,D0
	CMP.w	WINDY,D0
	BLT.s	.CLIP
	SUB.w	#YRANGE*2+240,D0
	BMI.s	.ONSCREEN
	CMP.w	WINDY,D0
	BGE.s	.CLIP
.ONSCREEN
	MOVE	(SP)+,D0
	RTS
.CLIP
	ADDQ.L	#2+4,SP
	JMP	CLEAROBJWVRAM




;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE IS TO BE CALLED ONLY FROM OBJECT AI
;;;ASBx: ; WHEN CALLED IT COMPARES THE CURRENT OBJECT'S X (DP) TO WINDX
;;;ASBx: ; AND IF IT IS FURTHER AWAY THAN SCRLA-128 THEN THE OBJECT DIES!
;;;ASBx: ; ON ENTRY:
;;;ASBx: ; 16 BIT A
;;;ASBx: ; VALID DP
;;;ASBx: ; BANK 0-1F
;;;ASBx: ; ON EXIT:
;;;ASBx: ; A CONTAINS THE POSITIVE X DISTANCE TO BUBSY
;;;ASBx: ; CARRY SET MEANS THE OBJECT SHOULD BE KILLED
;;;ASBx: 			; TO MAINTAIN COMPATABILITY WITH PREVIOUS ROUTINE
;;;ASBx: 			; RETURN POSITIVE DIST TO BUBX
;;;ASBx: ;************************************************************************

OBJRANGE
	MOVE.w	OBJX(A5),D0
	SUB.w	BUBX,D0
	BPL.s	.OR0
	NEG	D0
.OR0
	MOVE.w	D0,-(SP)
	MOVE	OBJX(A5),D0
	ADD.w	#SCRLA-160,D0
	CMP.w	WINDX,D0
	BCS.s	.CLIP
	SUB.w	#(320-16)+SCRLA+160,D0
	BMI.s	.ONSCREEN
	CMP.w	WINDX,D0
	BCC.w	.CLIP
.ONSCREEN
	MOVE.w	(SP)+,D0
	AND	#~%00001,CCR
	RTS
.CLIP
	MOVE.w	(SP)+,D0
	OR	#%00001,CCR
	RTS

;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE IS TO BE CALLED ONLY FROM OBJECT AI
;;;ASBx: ; WHEN CALLED IT COMPARES THE CURRENT OBJECT'S X (DP) TO WINDX
;;;ASBx: ; AND IF IT IS FURTHER AWAY THAN SCRLA-128 THEN THE OBJECT DIES!
;;;ASBx: ; ON ENTRY:
;;;ASBx: ; 16 BIT A
;;;ASBx: ; VALID DP
;;;ASBx: ; BANK 0-1F
;;;ASBx: ; ON EXIT:
;;;ASBx: ; A CONTAINS THE POSITIVE X DISTANCE TO BUBSY
;;;ASBx: ; CARRY SET MEANS THE OBJECT SHOULD BE KILLED
;;;ASBx: 			; TO MAINTAIN COMPATABILITY WITH PREVIOUS ROUTINE
;;;ASBx: 			; RETURN POSITIVE DIST TO BUBX
;;;ASBx: ;************************************************************************

OBJRANGEBIG
	MOVE.w	OBJX(A5),D0
	SUB.w	BUBX,D0
	BPL.s	.OR0
	NEG	D0
.OR0
	MOVE.w	D0,-(SP)
	MOVE.w	OBJX(A5),D0
	ADD.w	#SCRLA,D0
	CMP.w	WINDX,D0
	BCS.s	.CLIP
	SUB.w	#(320-16)+320+(320-16)+160,D0
	BMI.s	.ONSCREEN
	CMP.w	WINDX,D0
	BCC.s	.CLIP
.ONSCREEN
	MOVE.w	(SP)+,D0
	AND.w	#~%00001,CCR
	RTS
.CLIP
	MOVE.w	(SP)+,D0
	OR.w	#%00001,CCR
	RTS
