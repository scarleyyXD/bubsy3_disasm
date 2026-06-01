
;************************************************************************
;*	TABLES FOR BUBSY/GROUND INTERACTION 				*
;************************************************************************

DYTAB	 				; Y POSITION TABLE BASED ON SLOPE
	dc.b	0,0,0,0,0,0,0,0		; FLAT
	dc.b	7,7,7,7,6,6,6,6		; 15 LL
	dc.b	5,5,5,5,4,4,4,4		; 15 ML
	dc.b	3,3,3,3,2,2,2,2		; 15 MH
	dc.b	1,1,1,1,0,0,0,0		; 15 HH
	dc.b	7,7,6,6,5,5,4,4		; 30 L
	dc.b	3,3,2,2,1,1,0,0		; 30 H
	dc.b	7,6,5,4,3,2,1,0		; 45 
	dc.b	7,5,3,1,$FF,$FD,$FB,$F9	; 60 B
	dc.b	$F,$D,$B,9,7,5,3,1	; 60 H


*	values below relate to word per square and for each velocity
*	appplied for a character running left to right. The values
*	are +ive acceleration so going downhill, odd indexes are there
*	since the slopes can be flipped

VXTAB					; VX FOR CHR BASED ON SLOPE
	dc.w	0,0			; FLAT
	dc.w	$FFFF,$1		; 15 DEG
	dc.w	$FFFF,$1		; 15 DEG
	dc.w	$FFFF,$1		; 15 DEG
	dc.w	$FFFF,$1		; 15 DEG
	dc.w	$FFF6,$A		; 30 DEG
	dc.w	$FFF6,$A		; 30 DEG
	dc.w	$FFF0,$10		; 45 DEG
	dc.w	$FFCC,$34		; 60 DEG
	dc.w	$FFCC,$34		; 60 DEG


