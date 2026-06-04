MANHOLEAI:
	jsr	DOINITIALDMA
	jsr	OBJRANGE
	bcc.s	.INRANGE

.KILLMANHOLE:
	jmp	CLEAROBJWVRAM

.INRANGE:
	move.w	OBJY(a5),d0				;kill the manhole as it falls off the mat
	cmp.w	MAPHTP,d0
	bge.s	.KILLMANHOLE

	move.b	OBJAUX0(a5),d6			;check y range
	bmi.s	.NOCLIPY
	jsr	CLIPY

.NOCLIPY:
.CHECKSTART:					;see if it is time to launch a cover, launches at negative moment
	move.b	OBJAUX0(a5),d0
	cmpi.b	#$80,d0
	bne.s	.WAITSTATE

	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0				;check if bubsy already dead
	bne	.NOFRAME

	moveq	#BOING3,d0
	jsr	LOADNPLAYSFX
	move.w	#$fff6,OBJAUX2(a5)

	move.w	OBJY(a5),OBJAUX4(a5)			;save manhole y position
	addq.b	#1,OBJAUX0(a5)

.WAITSTATE:						;wait here a bit before launching
	move.b	OBJAUX0(a5),d0
	bmi.s	.ANIMATE
	addq.b	#2,OBJAUX0(a5)

	sf	OBJFRAME(a5)				;allow bubsy to walk on it

	andi.b	#%01111111,OBJFLAGS(a5)			;check if bubsy is standing on manhole
	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0
	ror.b	#1,d0
	or.b	d0,OBJFLAGS(a5)
	bra	.NOFRAME

.ANIMATE:
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0			;check if bubsy is dead
	bne	.NOCOLLIDE

	moveq	#BUBONMEFLAG,d0
	and.b	OBJFLAGS(a5),d0			;this is all collision,check if bubsy is on manhole when it flew up
	beq.s	.CHECKCOLLIDE

	move.b	#JUMPSTATE,BUBSTATE			;make bubsy jump to the right
	andi.b	#%11111000,BUBSYFLAGS
	move.b	#32,BUBSYFRAME

	move.w	#$f400,BUBVY			;get initial veloctiy for jump
	move.w	#$100,BUBVX

.CHECKCOLLIDE:						;check if bubsy was standing on manhole
	move.b	OBJFLAGS(a5),d0
	andi.b	#%10000000,d0
	beq.s	.WASNTSTANDING

	move.w	OBJAUX2(a5),d0			;he was, only cehck collision if OBJ VY is positive
	bmi.s	.NOCOLLIDE

.WASNTSTANDING:
	bne.s	.NOCOLLIDE
	move.w	INVTIMER,d0
	bne.s	.NOCOLLIDE

	move.w	OBJAUX6(a5),d0			;dont't bother with collsion ricocheting
	bne.s	.NOCOLLIDE

	moveq	#0,d0				;check if we collided with bubsy
	jsr	NOBOPCOLLIDE
	bcc.s	.NOCOLLIDE

	move.w	OBJAUX2(a5),d0			;we collided, bounce cover off bubsy
	neg.w	d0
	asr.w	#1,d0
	move.w	d0,OBJAUX2(a5)

	moveq	#SMASH,d0				; kill bubsy ( oops thats right, bubsy can't die ... or so say nintendo
	jsr	LOADNPLAYSFX
	moveq	#1,d0
	and.w	STIMER,d0
	bne.s	.DIEMELT
	moveq	#FALLBACKSTATE,d0
	bra.s	.KILLBUBSY

.DIEMELT:
	moveq	#MELTSTATE,d0

.KILLBUBSY:
	jsr	KILLBUBSY
	subq.w	#1,OBJAUX6(a5)			;let cover richochet

.NOCOLLIDE:
	move.w	OBJAUX6(a5),d0			;get x and y for frame
	add.w	d0,OBJX(a5)
	move.w	OBJAUX2(a5),d0
	add.w	d0,OBJY(a5)

	move.w	OBJAUX6(a5),d0			;not off to a side
	bne.s	.NOTFALLING

	move.w	OBJAUX2(a5),d0			;yes falling
	beq.s	.NOTFALLING

	move.w	OBJAUX4(a5),d0			;into place
	cmp.w	OBJY(a5),d0
	bge.s	.NOTFALLING
	move.w	d0,OBJY(a5)

	moveq	#BOTTLETOPSOUND,d0				;draw and reinitialise
	jsr	LOADNPLAYSFX
	jsr	ENEMYOAMS
	moveq	#0,d0
	move.w	d0,OBJAUX0(a5)
	move.w	d0,OBJAUX2(a5)
	move.w	d0,OBJAUX4(a5)
	move.w	d0,OBJAUX6(a5)
	sf	OBJFRAME(a5)
	sf	OBJFLAGS(a5)
	rts

.NOTFALLING:
.NOGROUND:
	moveq	#%111,d0
	and.w	STIMER,d0
	bne.s	.NOFRAME

	move.b	OBJFRAME(a5),d0
	addq	#1,d0
	and.b	#3,d0
	move.b	d0,OBJFRAME(a5)
.REQUESTDMA:
	addq.w	#2,OBJAUX2(a5)			;adjust delta y

.RESET:
.NOFRAME:
.DRAWFRAME:
	move.b	OBJFRAME(a5),d0
	beq.s	.STAYON
	ori.b	#GETOFFME,OBJFLAGS(a5)		;get collision stuff

.STAYON:
	moveq	#16,d0
	add.w	d0,OBJX(A5)
	add.w	d0,OBJY(A5)
	jsr	OBJECTISLAND
	moveq	#16,d0
	sub.w	d0,OBJX(A5)
	sub.w	d0,OBJY(A5)
	
	jmp	ENEMYOAMS

;TABLE FOR FRAME ADDRESSES
.DATATABLE:	dc.l    MANHOLE10000,MANHOLE10001,MANHOLE10002,MANHOLE10003

MANHOLEMAP:

MOFFSETX	equ	(16-2)
MOFFSETY	equ	(16-6)
X_ADD_MAX	equ	2

;DATA FOR FRAME 1 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	
	dc.w	($FFF2+MOFFSETX)&$ffff
	dc.w	($0000+MOFFSETY)&$ffff
	dc.l	0	;	1
	dc.w	20+X_ADD_MAX,44+(X_ADD_MAX*2)
	dc.w	4,4
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

;DATA FOR FRAME 2 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	($FFF5+MOFFSETX)&$ffff
	dc.w	($FFF6+MOFFSETY)&$ffff
	dc.l	0	;	3
	dc.w	($FFF0+MOFFSETX)&$ffff,($FFFA+MOFFSETY)&$ffff
	dc.w	($FFF9+MOFFSETX)&$ffff,($FFF6+MOFFSETY)&$ffff
	dc.w	($0006+MOFFSETX)&$ffff,($FFFC+MOFFSETY)&$ffff
	dc.w	($0010+MOFFSETX)&$ffff,($0006+MOFFSETY)&$ffff
	dc.w	($000C+MOFFSETX)&$ffff,($000A+MOFFSETY)&$ffff
	dc.w	($FFFD+MOFFSETX)&$ffff,($0003+MOFFSETY)&$ffff

;DATA FOR FRAME 3 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	($FFFD+MOFFSETX)&$ffff
	dc.w	($FFF1+MOFFSETY)&$ffff
	dc.l	0	;	4
	dc.w	($FFF8+MOFFSETX)&$ffff,($0000+MOFFSETY)&$ffff
	dc.w	($0000+MOFFSETX)&$ffff,($FFF2+MOFFSETY)&$ffff
	dc.w	($0006+MOFFSETX)&$ffff,($FFF2+MOFFSETY)&$ffff
	dc.w	($0008+MOFFSETX)&$ffff,($0000+MOFFSETY)&$ffff
	dc.w	($0006+MOFFSETX)&$ffff,($000D+MOFFSETY)&$ffff
	dc.w	($0000+MOFFSETX)&$ffff,($000D+MOFFSETY)&$ffff

;DATA FOR FRAME 4 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	($FFF3+MOFFSETX)&$ffff
	dc.w	($FFF8+MOFFSETY)&$ffff
	dc.l	0	;	3
	dc.w	($FFFE+MOFFSETX)&$ffff,($FFFD+MOFFSETY)&$ffff
	dc.w	($000B+MOFFSETX)&$ffff,($FFF8+MOFFSETY)&$ffff
	dc.w	($0010+MOFFSETX)&$ffff,($FFFC+MOFFSETY)&$ffff
	dc.w	($0005+MOFFSETX)&$ffff,($0005+MOFFSETY)&$ffff
	dc.w	($FFF7+MOFFSETX)&$ffff,($FFF4+MOFFSETY)&$ffff
	dc.w	($FFF0+MOFFSETX)&$ffff,($0008+MOFFSETY)&$ffff

;DATA FOR FRAME 5 (X-OFF, Y-OFF, MAP: ADDRESS, COLLISION POINTS)
	dc.w	($FFF2+MOFFSETX)&$ffff
	dc.w	($0000+MOFFSETY)&$ffff
	dc.l	0	;	1
	dc.w	20+X_ADD_MAX,44+(X_ADD_MAX*2)
	dc.w	4,4
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
