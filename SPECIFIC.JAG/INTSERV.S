LEVEL2	equ	4*$40

; This will set up the VI (Vertical line counter Interrupt)
; Or it would if the low order bit of INT1 REALLY was the VI interrupt

IntInit:
	move.l	#hum_70_vbl,LEVEL2
	move.w	#1,VI
	move.w	#$1,INT1

	move.w	sr,d0
	and.w	#$f8ff,d0
	move.w	d0,sr

	rts

