;;;ASBx; ; ***********************************************************************
;;;ASBx; ; *									*
;;;ASBx; ; * WINDOW TRACKING ROUTINE						*
;;;ASBx; ; *									*
;;;ASBx; ; ***********************************************************************
;;;ASBx; ; INIT SYSTEM FOR THE FOLLOWING ROUTINES
	even
no_track_window:	dc.w	0

TRACKWIND:
trackwind:
	tst.b	no_track_window
	beq.s	.fair
	subq.b	#1,no_track_window
	rts
.fair:
	moveq	#SCROLLFLAG,d0
	and.b	BUBSYFLAGS1,d0
	bne.s	.S00
.S1:
	rts
.S00:
	moveq	#TAKEHOLD,d0
	and.b	GAMEFLAG1,d0
	bne.s	.S1

	move.w	BUBWX,d0
	cmp.w	BUBDWX,d0
	beq.s	.P00
	blt.s	.P01

	subq.w	#4,d0

.P01:
	addq.w	#2,d0
	move.w	d0,BUBWX

.P00:
	move.w	BUBWYTOP,d0
	cmp.w	BUBDWYTOP,d0
	beq.s	.P10
	blt.s	.P11
	
	subq.w	#8,d0

.P11:
	addq.w	#4,d0
	move.w	d0,BUBWYTOP

.P10:
	move.w	BUBWYBOT,d0
	cmp.w	BUBDWYBOT,d0
	beq.s	.P20
	blt.s	.P21

	subq.w	#8,d0

.P21:
	addq.w	#4,d0
	move.w	d0,BUBWYBOT

.P20:											;CORRELATE BUBSY TO SCREEN
	move.w	BUBX,d0
	sub.w	BUBWX,d0
	move.w	d0,WINDX

	tst.b	shake_me
	beq.s	.not_needed_eh
	subq.b	#1,shake_me
	bra.s	.do_shake
.not_needed_eh:
	cmpi.b	#14,BUBSYFRAME								;check if are on frame 14 of bubsy iddle
	bne.s	.IDLE12
.do_shake:
	moveq	#%0110,d0
	and.w	STIMER,d0								;get shake value of background
	move.w	.SHAKETABLE(pc,d0.w),d0
	add.w	d0,WINDY
	bra.s	.IDLE20

.SHAKETABLE:
	dc.w	$FFFA
	dc.w	$0006
	dc.w	$FFFA
	dc.w	$0006
.IDLE12:											;restore conditions
	move.w	BUBY,d0									; if buby-windy < bubwtop then
	sub.w	WINDY,d0								; windy = buby-bubwtop
	bmi.s	.KLUDGE
	cmp	BUBWYTOP,d0
	bge.s	.NOSCROLLY1

.KLUDGE:
	move.w	BUBY,d0
	sub.w	BUBWYTOP,d0
	move.w	d0,WINDY
	bra.s	.NOSCROLLY2

.NOSCROLLY1:										;if buby-windy >= bubwbot then
	cmp	BUBWYBOT,d0								;windy = buby - bubwbot
	blt.s	.NOSCROLLY2

	move.w	BUBY,d0
	sub.w	BUBWYBOT,d0
	move.w	d0,WINDY

.NOSCROLLY2:

.IDLE20:
	andi.b	#~BUBSYOFFSCREEN,GAMEFLAG0						;boundary check window coordinates
	move.w	WINDX,d0
	bmi.s	.B601
	cmp	WINDXMIN,d0
	bge.s	.B60

.B601:
	move.w	WINDXMIN,WINDX
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B60:											;right edge
	move.w	WINDXMAX,d0
	cmp.w	WINDX,d0
	bge.s	.B62
	move.w	d0,WINDX
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B62:											;top edge
	MOVE.W	WINDY,D0
	BMI.s	.B611
	CMP.W	WINDYMIN,D0
	BGE.s	.B61

.B611:
	move.w	WINDYMIN,WINDY
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B61:											;bottom edge
	move.w	WINDYMAX,d0
	cmp.w	WINDY,d0
	bge.s	.B63
	move.w	d0,WINDY
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B63:											;boundary for bonus rounds
	move.b	GAMEFLAG1,d0
	andi.b	#BONUSFLAG,d0
	beq.s	.NOBONUS

	move.w	BUBY,d0									;if bubsy is off the bottom fade out
	subi.w	#224,d0
	bmi.s	.NOBONUS
	cmp.w	WINDYMAX,d0
	blt.s	.NOBONUS

	move.b	FADEVAL,d0
	andi.b	#$f0,d0
	beq.s	.NOBONUS
	move.b	#$fc,FADEDIR
	move.b	#FADEOUTSOUND,d0
	jsr	STARTSOUNDALL

.NOBONUS:
	rts

;;;ASBx; ; ***********************************************************************
;;;ASBx; ; *									 *
;;;ASBx; ; * LOAD SCREEN BUFFERS (FOR LEVEL START)				 *
;;;ASBx; ; *									 *
;;;ASBx; ; ***********************************************************************

LOADSCREEN:
LOADSCREEN2:
number_to_do	equ	30
	ori.b	#SCROLLFLAG,BUBSYFLAGS1

	addi.w	#16*number_to_do,BUBX
	move.w	BUBX,d0
	sub.w	BUBWX,d0
	move.w	d0,WINDX
	move.w	d0,WINDXOLD

	move.w	BUBY,d0
	sub.w	BUBWYTOP,d0
	bpl.s	.B00
	moveq	#0,d0
.B00:
	move.w	d0,WINDY
	move.w	d0,WINDYOLD

	moveq	#number_to_do-1,d0
.B10:
	move.w	d0,-(a7)
	subi.w	#16,BUBX									;next left
	bsr	TRACKWIND
	move.w	(a7)+,d0
	
	dbf	d0,.B10
	bsr	create_2_lands
	rts

;;;ASBx; ; ***********************************************************************
;;;ASBx; ; *									*
;;;ASBx; ; * INERTIAL DAMPNERS FOR WHEN BUBSY IS STANDING ON MOVING OBJECTS	*
;;;ASBx; ; *									*
;;;ASBx; ; ***********************************************************************

DAMPENERS:
	move.w	WINDY,d7
	move.w	BUBX,d0										;engage inertial damperers!
	sub.w	BUBWX,d0
	move.w	d0,d6

	move.w	BUBY,d0										;if bubsy-windy < bubwytop then
	sub.w	d7,d0										;windy = buby -bubwytop
	cmp.w	BUBWYTOP,d0
	bge.s	.NOSCROLLY1

	move.w	BUBY,d0
	sub.w	BUBWYTOP,d0
	move.w	d0,d7
	bra.s	.NOSCROLLY2

.NOSCROLLY1:
	cmp.w	BUBWYBOT,d0									;if buby-windy >= bubwybot then
	blt.s	.NOSCROLLY2									;windy = buby-bubwybot

	move.w	BUBY,d0
	sub.w	BUBWYBOT,d0
	move.w	d0,d7

.NOSCROLLY2:
	move.w	d6,d0									;boundary check new window coordinates
	bmi.s	.B601										;left edge
	cmp.w	WINDXMIN,d0
	bge.s	.B60

.B601:
	move.w	WINDXMIN,d6
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	
.B60:												;right edge
	move.w	WINDXMAX,d0
	cmp.w	d6,d0
	bge.s	.B62

	move.w	d0,d6
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B62:
	move.w	d7,d0									;top edge
	bmi.s	.B611
	cmp.w	WINDYMIN,d0
	bge.s	.B61

.B611:
	move.w	WINDYMIN,d7
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B61:
	move.w	WINDYMAX,d0									;bottom edge
	cmp.w	d7,d0
	bge.s	.B63
	move.w	d0,d7
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

.B63:
	move.w	d6,WINDX
	move.w	d7,WINDY
	rts

	include	"mapreadj.s"
