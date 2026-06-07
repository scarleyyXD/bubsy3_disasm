;FIRE_A	equ	29
;PAUSE	equ	28
;FIRE_B	equ	25
RIGHT_B	equ	23
LEFT_B	equ	22
DOWN_B	equ	21
UP_B	equ	20
;KEY_1	equ	19
;KEY_4	equ	18
;KEY_7	equ	17
STAR	equ	16
;FIRE_C	equ	13
OPTIONS	equ	09
;KEY_2	equ	07
;KEY_5	equ	06
;KEY_8	equ	05
;KEY_0	equ	04
;KEY_3	equ	03
;KEY_6	equ	02
;KEY_9	equ	01
HASH	equ	00

;compatibility
JOYIN		equ	JOYSTICK
JOYOUT		equ	JOYSTICK

fire_a_pressed:
	move.l	joycur1(pc),d0
	not.l	d0
	btst	#FIRE_A,d0
	rts
fire_b_pressed:
	move.l	joycur1(pc),d0
	not.l	d0
	btst	#FIRE_B,d0
	rts
fire_c_pressed:
	move.l	joycur1(pc),d0
	not.l	d0
	btst	#FIRE_C,d0
	rts
options_pressed:
	move.l	joycur1(pc),d0
	btst	#OPTIONS,d0
	rts

check_1_and_3:
	move.l	joycur1(pc),d0
	btst	#KEY_1,d0
	beq.s	.Not_Pressed
	btst	#KEY_3,d0
	beq.s	.Not_Pressed
	sf	paused_view
.Not_Pressed:	
	rts

read_joypad:
readpad:
;scan for player 1
	move.l	#$f0fffffc,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$81fe,JOYOUT
	move.l	JOYIN,d0		; Read joypad, pause button, A button
	or.l	d1,d0			; Mask off unused bits
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81fd,JOYOUT
	move.l	JOYIN,d0		; Read *741 keys, B button
	or.l	d1,d0			; Mask off unused bits
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81fb,JOYOUT
	move.l	JOYIN,d0		; Read 2580 keys, C button
	or.l	d1,d0			; Mask off unused bits
	rol.l	#6,d0
	rol.l	#6,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81f7,JOYOUT
	move.l	JOYIN,d0		; Read 369# keys, Option button
	or.l	d1,d0			; Mask off unused bits
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

	move.l	joycur1(pc),d0		; old joycur needed for determining the new joyedge
	move.l	d1,joycur1		; Current joypad reading stored into joycur
.not:	eor.l	d1,d0
	and.l	d1,d0
	move.l	d0,joyedge1		;joypad, buttons, keys that were just pressed

;scan for player 2
	move.l	#$0ffffff3,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$817f,JOYOUT
	move.l	JOYIN,d0		; Read joypad, pause button, A button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81bf,JOYOUT
	move.l	JOYIN,d0		; Read *741 keys, B button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	ror.l	#8,d0
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81df,JOYOUT
	move.l	JOYIN,d0		; Read 2580 keys, C button
	or.l	d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81ef,JOYOUT
	move.l	JOYIN,d0		; Read 369# keys, Option button
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

	if	DAVE7
.cheating:
	move.l	#$40044,d0
	move.l	joycur1,d1
	and.l	d0,d1
	cmp.l	d0,d1
	bne.s	.no_cheat1
	move.b	#$80,LIVES
	move.w	#$7fff,INVTIMER
.no_cheat1:
	move.l	#$40044,d0
	move.l	joycur2,d1
	and.l	d0,d1
	cmp.l	d0,d1
	bne.s	.no_cheat2
	move.b	#$80,LIVES
	move.w	#$7fff,INVTIMER
.no_cheat2:
	endif
	rts

Hash_Asterisk_Pressed1:
	move.l	joycur1(pc),d0
	btst	#STAR,d0
	beq.s	.Not_Pressed
	btst	#HASH,d0
.Not_Pressed:	
	rts
Hash_Asterisk_Pressed2:
	move.l	joycur2(pc),d0
	btst	#STAR,d0
	beq.s	.Not_Pressed
	btst	#HASH,d0
.Not_Pressed:	
	rts

keys_1_2_3_down:
	move.l	joycur1(pc),d0
	btst	#KEY_1,d0
	beq.s	.Not_Pressed
	btst	#KEY_2,d0
	beq.s	.Not_Pressed
	btst	#KEY_3,d0
.Not_Pressed:	
	rts

direction_pressed:
	move.l	d1,-(sp)
	move.l	joycur1(pc),d0
	moveq	#20,d1
	lsr.l	d1,d0
	and.w	#$f,d0
	move.l	(sp)+,d1
	rts

joycur1:	dc.l	0
joyedge1:	dc.l	0
joycur2:	dc.l	0
joyedge2:	dc.l	0
PAD_TYPE:	dc.b	0
sega_pad_1:	dc.b	0
sega_pad_2:	dc.b	0
	even

;	specific to the bubsy project
pad_buttons:	;gjl0
	dc.b	FIRE_A,FIRE_B,FIRE_C,0	;0
	dc.b	FIRE_A,FIRE_C,FIRE_B,0	;1
	dc.b	FIRE_B,FIRE_A,FIRE_C,0	;2
	dc.b	FIRE_B,FIRE_C,FIRE_A,0	;3
	dc.b	FIRE_C,FIRE_A,FIRE_B,0	;4
	dc.b	FIRE_C,FIRE_B,FIRE_A,0	;5
	dc.b	FIRE_A,FIRE_B,FIRE_C,0	;6
	dc.b	FIRE_A,FIRE_C,FIRE_B,0	;7
	even

joypad_2_sega:
;	output format is a word 0000ABSS UDLR0000 and 00C00000 00LR0000 for LEFT and RIGHT buttons.

	moveq	#0,d0
	move.b	PAD_TYPE(pc),d0
	add.b	d0,d0
	add.b	d0,d0
	lea	pad_buttons(pc,d0.w),a0

	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.b	(a0)+,d3	;glide
	move.b	(a0)+,d2	;jump
	move.b	(a0)+,d4	;look
	
	move.l	joycur1,d1
	move.w	joycur1,d0			;xxAPxxBx RLDU741*
	lsr.w	#4,d0				;xxxxxxAP xxBxRLDU
	and.w	#$f,d0				;xxxxxxxx xxxxRLDU
	btst	#PAUSE,d1
	beq.s	.no_pause1
	bset	#7,d0
.no_pause1:
;	btst	#OPTIONS,d1
;	beq.s	.no_options
;	bset	#7,d0
.no_options:
	btst	d3,d1
	beq.s	.no_fire_a
	bset	#6,d0
.no_fire_a:
	btst	d4,d1
	beq.s	.no_fire_c
	bset	#5,d0
.no_fire_c:
	btst	d2,d1
	beq.s	.no_fire_b
	bset	#4,d0
.no_fire_b:
	move.b	d0,sega_pad_1

	move.l	joycur2,d1
	move.w	joycur2,d0			;xxAPxxBx RLDU741*
	lsr.w	#4,d0				;xxxxxxAP xxBxRLDU
	and.w	#$f,d0				;xxxxxxxx xxxxRLDU
	
	btst	#PAUSE,d1
	beq.s	.no_pause2
	bset	#7,d0
.no_pause2:
;	btst	#OPTIONS,d1
;	beq.s	.no_options2
;	bset	#7,d0
.no_options2:
	btst	d3,d1
	beq.s	.no_fire_a2
	bset	#6,d0
.no_fire_a2:
	btst	d4,d1
	beq.s	.no_fire_c2
	bset	#5,d0
.no_fire_c2:
	btst	d2,d1
	beq.s	.no_fire_b2
	bset	#4,d0
.no_fire_b2:
	move.b	d0,sega_pad_2
	rts

get_pad_press:
	move.l	joyedge1,d1		;get data from both pads 
	or.l	joyedge2,d1
	moveq	#0,d2
	moveq	#9-1,d0
.loop:
	move.b	.pad_bits(pc,d0.w),d2
	btst	d2,d1
	bne.s	.exit
	dbf	d0,.loop
.exit:
	rts

.pad_bits:	dc.b	KEY_1,KEY_2,KEY_3,KEY_4
			dc.b	KEY_5,KEY_6,KEY_7,KEY_8,KEY_9