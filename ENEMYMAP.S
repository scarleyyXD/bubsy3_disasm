
	even
RECYCLEMAP:
 	dc.w	0-16
 	dc.w	0-31
 	dc.l	0	;	$44
 	dc.w	0-11,0-22,0,0-26,12,0-22,12,0-7,0,0-2,0-11,0-7
 
 	dc.w	0-16
 	dc.w	0-31
 	dc.l	0	;	33
 	dc.w	0-11,0-22,0,0-26,12,0-22,12,0-7,0,0-2,0-11,0-7
 




GAMEOVERMAP:
	dc.w	0-127
	dc.w	0
	dc.l	0	;	$44
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0

	dc.w	0-127+28
	dc.w	0
	dc.l	0	;	$44
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0
LVLTXTMAP:
 	dc.w	$0000
 	dc.w	$0000
 	dc.l	0	;	6
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
EXCLMAP:
	dc.w	$FFF8-1
	dc.w	$FFC8
	dc.l	0	;	7
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

MIDPOINTMAP:
	rept	12
	dc.w	-8
	dc.w	$FFF1
	dc.l	0	;	6
	dc.w	$FFFC,$FFFA
	dc.w	$0004,$FFFA
	dc.w	$0007,$0000
	dc.w	$0004,$0006
	dc.w	$FFFC,$0006
	dc.w	$FFF9,$0000
	
	endr

BUBBLESMAP::
 ;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	rept	3
	dc.w	$FFF0
 	dc.w	$FFE8
 	dc.l	0	;	3
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
 	dc.w	$0000,$0000
	endr

SMOKEMAP::
;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	rept	3
	dc.w	$FFF0
	dc.w	$FFE0
	dc.l	0	;	$42
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	endr

BIRDSMAP::
	;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	-20
	dc.w	-13
	dc.l	0	;	$42
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	;DATA FOR FRAME 2 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	-30
	dc.w	-12
	dc.l	0	;	$42
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	;DATA FOR FRAME 3 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	-13
	dc.w	-12
	dc.l	0	;	$42
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	;DATA FOR FRAME 4 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	-13
	dc.w	-12
	dc.l	0	;	$42
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	;DATA FOR FRAME 5 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	-22
	dc.w	-12
	dc.l	0	;	$42
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000



DUCKMAP:

;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	$FFF1
	dc.w	$FFF1
	dc.l	0	;	4
	dc.w	$FFF6,$FFF1
	dc.w	$FFFE,$FFF2
	dc.w	$0005,$FFF9
	dc.w	$0006,$000E
	dc.w	$FFF6,$000E
	dc.w	$FFF6,$0001

;DATA FOR FRAME 2 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	$FFF1
	dc.w	$FFF1
	dc.l	0	;	4
	dc.w	$FFF6,$FFF6
	dc.w	$FFFC,$FFF2
	dc.w	$0005,$FFF9
	dc.w	$0001,$FFF3
	dc.w	$FFF6,$0009
	dc.w	$FFF6,$0000

;DATA FOR FRAME 3 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	$FFF1
	dc.w	$FFF1
	dc.l	0	;	4
	dc.w	$FFF6,$FFF6
	dc.w	$FFFC,$FFF2
	dc.w	$0005,$FFFA
	dc.w	$0006,$000E
	dc.w	$FFF6,$FFF3
	dc.w	$FFF6,$FFFD

EGGMAP:

;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	0-7,0-7
	dc.l	0
	dc.w	0-4+8,0-4
	dc.w	0-2+8,0-4-4
	dc.w	2+8,0-3-4
	dc.w	6+8,0-4
	dc.w	5+8,5-4
	dc.w	1+8,5-4

;DATA FOR FRAME 2 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)

	rept	2
	dc.w	0,0-7
	dc.l	0	;	2 ;N6S3x3
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	endr

ENDLEVELMAP:
 
 	rept	10
 	;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
 	dc.w	$FFF1
 	dc.w	$FFF1
 	dc.l	0	;	$44
 	dc.w	$FFF1,$0000
 	dc.w	$FFF8,$FFF3
 	dc.w	$0009,$FFF3
 	dc.w	$0010,$0000
 	dc.w	$0009,$000E
 	dc.w	$0008,$000E
 
 	endr
 	
CRATEMAP:

	rept	6
;DATA FOR FRAME 0 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	$FFF1
	dc.w	$FFE1
	dc.l	0	;	$44
	dc.w	0-15,0-31,0-9,0-31,0-3,0-31,3,0-31,9,0-31,15,0-31
	endr

	rept	5
;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	$FFF1
	dc.w	$FFE1
	dc.l	0	;	$44
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	endr

SCOREMAP:
	rept	20
;DATA FOR FRAME 100
	dc.w	0-15,0-7
	dc.l	0	;	2
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	endr

TACKMAP:
	rept	4
;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	0-31
	dc.w	0-31
	dc.l	0	;	3
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	endr

;DATA FOR FRAME 5 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	0-31
	dc.w	0-6
	dc.l	0	;	$41
	dc.w	0-26,0-5
	dc.w	0-15,0-5
	dc.w	0-5,0-5
	dc.w	6,0-5
	dc.w	16,0-5
	dc.w	27,0-5


YARNMAP:
 
 	;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
 	dc.w	$FFF9-2
 	dc.w	$FFF1-2
 	dc.l	0	;	6
 	dc.w	$FFFC,$FFF2
 	dc.w	$0004,$FFF2
 	dc.w	$0007,$FFF8
 	dc.w	$0004,$FFFE
 	dc.w	$FFFC,$FFFE
 	dc.w	$FFF9,$FFF8

	rept	3
;DATA FOR FRAME 3 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	$FFF9
	dc.w	$FFF1
	dc.l	0	;	32
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
 	endr
 	
SHIRTMAP:
	rept	5
;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	0-16,0-31
	dc.l	0	;	$44
	dc.w	0-6,0,0-15,0-17,0-7,0-29,6,0-29,13,0-17,7,0
	endr

BANANAMAP:

;FRAME 1
	dc.w	0-12,0-5
	dc.l	0	;	2
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0

;FRAME 2
	dc.w	0-4,0-12
	dc.l	0	;	N8S2x3
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0

;FRAME 3
	dc.w	0-8,0-11
	dc.l	0	;	N102
	dc.w	0,0,0-7,0,0-6,0-5,4,0-11,7,0-6,7,0

;FRAME 4
	dc.w	0-10,0-9
	dc.l	0	;	N20S2
	dc.w	0,0,0-10,0,0-9,0-5,0-4,0-8,11,0-9,8,0-1

SUPERYARNMAP:
 
 	rept	8
 	dc.w	0-14,0-28
 	dc.l	0	;	$44
 	dc.w	0-14,0-14,0-8,0-26,8,0-26,8,0-26,14,0-14,8,0-2,0-8,0-2
	endr

