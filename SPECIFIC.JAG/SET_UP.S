jaguar_setup:
	lea	phrase_align,a0		; align the object for phrase boundary
.lp1:	moveq	#0,d0
	move.l	(a0),d0
	beq.s	.no_more
	and.b	#$f8,d0
	move.l	d0,(a0)+
	bra.s	.lp1
.no_more:
	moveq	#128-1,d0		; Copy the palette into the chip
	lea	CLUT,a0
.cloop:
	clr.l	(a0)+
	dbf	d0,.cloop

VideoInit:
pal10:	move.w	#ntsc_n_hdb1,HDB1
pal11:	move.w	#ntsc_n_hdb2,HDB2
	move.w	#ntsc_n_hde,HDE

CHANGE4:
	move.w	#ntsc_n_vdb,VDB
	move.w	#-1,VDE
	move.w	#ntsc_n_hde,HDE

; Also lets set up some default colors

	move.w	#$0,BG

LEVEL2	equ	4*$40

; This will set up the VI (Vertical line counter Interrupt)
; Or it would if the low order bit of INT1 REALLY was the VI interrupt

CHANGE5:	move.w	#ntsc_n_vde+1,VI
IntInit:
	move.l	#hum_70_vbl,LEVEL2.w

	moveq	#0,d1
	move.b	#1,d1
	move.w	d1,INT1
	move.w	d1,INT2
	move.w	#999,PIT0
	move.w	#531,PIT1


	move.w	sr,d0
	and.w	#$f8ff,d0
	move.w	d0,sr
	
VIEW_RESOLUTION	equ	$7c1

	move.w	#VIEW_RESOLUTION,VMODE		; Turn on the display NEW
	
