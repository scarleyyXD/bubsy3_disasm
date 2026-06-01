	include	'c:\bin\joypad.inc'

;================================================================================================
readpad::
;scan for player 1
	move.l	#$f0fffffc,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$81fe,JOYOUT+0
	move.l	JOYIN+0,d0		; Read joypad, pause button, A button
	or.l	d1,d0			; Mask off unused bits
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81fd,JOYOUT+0
	move.l	JOYIN+0,d0		; Read *741 keys, B button
	or.l	d1,d0			; Mask off unused bits
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81fb,JOYOUT+0
	move.l	JOYIN+0,d0		; Read 2580 keys, C button
	or.l	d1,d0			; Mask off unused bits
	rol.l	#6,d0
	rol.l	#6,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81f7,JOYOUT+0
	move.l	JOYIN+0,d0		; Read 369# keys, Option button
	or.l	d1,d0			; Mask off unused bits
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

	move.l	joycur1,d0		; old joycur needed for determining the new joyedge
	move.l	d1,joycur1		; Current joypad reading stored into joycur
	eor.l	d1,d0
	and.l	d1,d0
	move.l	d0,joyedge1		;joypad, buttons, keys that were just pressed

;scan for player 2
	move.l	#$0ffffff3,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$817f,JOYOUT+0
	move.l	JOYIN+0,d0		; Read joypad, pause button, A button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81bf,JOYOUT+0
	move.l	JOYIN+0,d0		; Read *741 keys, B button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	ror.l	#8,d0
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81df,JOYOUT+0
	move.l	JOYIN+0,d0		; Read 2580 keys, C button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81ef,JOYOUT+0
	move.l	JOYIN+0,d0		; Read 369# keys, Option button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	rol.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

	move.l	joycur2,d0		; old joycur needed for determining the new joyedge
	move.l	d1,joycur2		; Current joypad reading stored into joycur
	eor.l	d1,d0
	and.l	d1,d0
	move.l	d0,joyedge2		;joypad, buttons, keys that were just pressed

	rts


joyedge1:		dc.l		0
joyedge2:		dc.l		0
joycur1:		dc.l		0
joycur2:		dc.l		0
