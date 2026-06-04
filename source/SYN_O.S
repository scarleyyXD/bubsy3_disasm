;; SYN.O - 7/25/1994
;; Decompiled object file by Scarlett<3 (5/20-5/23)

	.data

.text0:	dc.l	'Copyright (1993) Imagitec Design, Inc '

sub_298EE:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#0,D_CTRL
	move.l	#0,D_FLAGS
	movea.l	#D_RAM,a1
	movea.l	#dword_2B618,a0
	move.l	a0,d0
	move.l	#SETUPGPU,d1
	sub.l	d0,d1
	lsr.l	#2,d1

loc_2991E:
	move.l	(a0)+,(a1)+
	dbf	d1,loc_2991E

	movea.l	#(D_RAM+$800),a0
	jsr	sub_2997C
	jsr	sub_2997C
	jsr	sub_2997C
	jsr	sub_2997C
	jsr	sub_2997C
	jsr	sub_2997C

	move.l	#27,($00F1A150).l		; 0xF1A150
	move.l	#21,($00F1A154).l		; 0xF1A154
	move.l	#D_RAM,D_PC
	move.l	#1,D_CTRL
	movem.l	(sp)+,d0-d7/a0-a6
	rts

sub_2997C:
	move.l  #-4,(a0)+
	move.l  #$4000,(a0)+
	clr.l   d0
	move.l  d0,(a0)+
	move.l  d0,(a0)+
	move.l  d0,(a0)+
	move.l  d0,(a0)+
	move.l  d0,(a0)+
	move.l  d0,(a0)+
	rts

.text1:	dc.l	'Imagitec Design,Inc ½ 1993 written by Trev'

INIT_SOUND:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	sub_298EE
	bsr.w	sub_29A28
	movem.l (sp)+,d0-d7/a0-a6
	rts

PT_MOD_INIT:
	movem.l d1-d7/a0-a6,-(sp)
	bsr.w	init_mod
	lea	(dword_2B5DE).l,a6
	move.l	#2,dword_2B5EE-dword_2B5DE(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	rts

loc_299F0:
	move.l	#$1AC,d0
	lsl.l	#8,d0
	move.l	#$321,d1
	moveq	#$6C,d2
	lea	(dword_2AF90).l,a0

loc_29A06:
	move.l	d0,d3
	divu.w	d2,d3
	andi.l	#$FFFF,d3
	mulu.w	#$1C,d3
	divu.w	#$2B,d3
	andi.l	#$FFFF,d3
	move.w	d3,(a0)+
	addq.l	#1,d2
	dbf	d1,loc_29A06
	rts

sub_29A28:
	move.l	#61300,d0
	move.l	#801,d1
	moveq	#108,d2
	move.l	#32768,d4
	lea	(dword_2AF90).l,a0

loc_29A42:
	move.l	d0,d3
	divu.w	d2,d3
	swap	d3
	add.l	d4,d3
	swap	d3
	andi.l	#$FFFF,d3
	move.w	d3,(a0)+
	addq.l	#1,d2
	dbf	d1,loc_29A42
	rts

NT_VBL:
	movem.l	d0-d1/d7-a4,-(sp)
	bsr.w	do_your_main_tick

	lea	byte_2A7F6(pc),a3
	pea	(a3)
	lea	$210(a3),a3
	lea	dword_2AF90(pc),a1
	lea	word_2A7D6(pc),a0
	movea.l	#(D_RAM+$800),a4
	moveq	#3,d7
	lea	dword_2B5DE(pc),a2
	pea	(a2)
loc_29A84:
	moveq	#0,d0
	move.w	$18(a3),d0
	beq.s	loc_29A9A

	subi.w	#$6C,d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),d0
	move.l	d0,12(a4)
loc_29A9A:
	clr.l	d0
	move.w	$1A(a3),d0
	lsr.w	#1,d0
	move.w	d0,2(a2)
	move.l	(a2),4(a4)
	move.l	0(a0),d1
	blt.s	loc_29B04

	move.l	d1,$10(a4)
	move.l	#-1,0(a0)
	move.l	#-4,(a4)
	move.w	#0,(a2)
	move.l	(a2),4(a4)
	tst.l	d1
	beq.s	loc_29B04

	move.l	4(a0),d0
	lsr.l	#8,d0
	move.l	d0,8(a4)
	moveq	#0,d0
	move.w	$10(a3),d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,$14(a4)
	move.l	$C(a3),d0
	cmp.l	d1,d0
	beq.s	loc_29AF6
	move.w	#$8000,(a2)
	move.l	(a2),4(a4)
loc_29AF6:
	move.l	#0,$18(a4)
	move.l	#$1C,(a4)
loc_29B04:
	lea	$20(a4),a4
	addq.l	#8,a0
	lea	$34(a3),a3
	addq.l	#4,a2
	dbf	d7,loc_29A84

	movea.l	(sp)+,a2
	movea.l	(sp)+,a3
	tst.w	$14(a2)
	beq.s	loc_29B52
	moveq	#0,d1
	move.w	$20E(a3),d1
	move.l	$1E(a2),d0
	add.l	$10(a2),d1
	cmp.l	d0,d1
	ble.s	loc_29B3A
	move.l  d0,d1
	move.w  #0,$14(a2)
	bra.s   loc_29B4E
loc_29B3A:
	cmp.l	#0,d1
	bge.s	loc_29B4E
	move.l	#0,d1
	move.w	#0,$14(a2)
loc_29B4E:
	move.w	d1,$20E(a3)
loc_29B52:
	movem.l	(sp)+,d0-d1/d7-a4
	rts

do_sound:		; pseudo-label
sub_29B58:
	movem.l d0-d7/a2-a6,-(sp)
	lea	dword_2B5DE(pc),a2
	tst.b	byte_2B604-dword_2B5DE(a2)
	beq.w	loc_29C1C
	tst.b	$27(a2)
	beq.s	loc_29B7C
	moveq	#1,d6
	movea.l	#(D_RAM+$880),a4
	lea	$30(a2),a2
	bra.s	loc_29B88
loc_29B7C:
	moveq	#5,d6
	movea.l	#(D_RAM+$800),a4
	lea	$28(a2),a2
loc_29B88:
	pea	(a4)
	pea	(a2)
	move.w	d6,d7
loc_29B8E:
	cmpi.l	#-4,(a4)
	bne.s	loc_29B9A
	move.w	#$FFFF,(a2)
loc_29B9A:
	lea	$20(a4),a4
	addq.l	#2,a2
	dbf	d7,loc_29B8E
	lea	dword_2B5DE(pc),a6
	movea.l (sp)+,a5
	movea.l (sp)+,a2
	movea.l #0,a3
	movea.l a3,a4
	move.w  d1,d4
	move.w  d6,d7
loc_29BB8:
	cmp.w	(a5),d4
	blt.s	loc_29BC2
	movea.l a2,a4
	movea.l a5,a3
	move.w  (a5),d4
loc_29BC2:
	addq.l	#2,a5
	lea	$20(a2),a2
	dbf	d7,loc_29BB8
	cmpa.l	#0,a4
	beq.s	loc_29C1C
	move.w	d1,(a3)
	move.l	#-4,(a4)
	move.l	a0,$10(a4)
	lsl.l	#8,d0
	move.l	d0,8(a4)
	move.l	d0,$14(a4)
	move.l	#0,$18(a4)
	move.l	$1A(a6),d0
	lsl.l	#6,d0
	move.l	d0,4(a4)
	tst.l	d3
	bne.s	loc_29C04
	move.l	$22(a6),d3
loc_29C04:
	mulu.w	#$1C,d3
	divu.w	#$2B,d3
	andi.l	#$FFFF,d3
	move.l	d3,$C(a4)
	move.l	#$1C,(a4)
loc_29C1C:
	movem.l	(sp)+,d0-d7/a2-a6
	rts

loc_29C22:
	movem.l	d1-d2/a0-a1,-(sp)
	lea	dword_2B5DE(pc),a0
	tst.w	d1
	beq.s	loc_29C34
	lea	$1A(a0),a1
	bra.s	loc_29C38

loc_29C34:
	lea	$1E(a0),a1
loc_29C38:
	move.l	(a1),d2
	ext.l	d0
	tst.l	d0
	bpl.s	loc_29C52
	add.l	d0,d2
	cmp.l	#0,d2
	bge.s	loc_29C62
	move.l	#0,d2
	bra.s	loc_29C62
loc_29C52:
	add.l   d0,d2
	cmp.l   #256-1,d2
	ble.s   loc_29C62
	move.l  #256-1,d2
loc_29C62:
	move.w  #1,$14(a0)
	move.l  d2,(a1)
	tst.w	d1
	bne.s	loc_29C76
	lea	byte_2A7F6(pc),a0
	move.w  d2,word_2AA04-byte_2A7F6(a0)
loc_29C76:
	move.l  d2,d0
	movem.l (sp)+,d1-d2/a0-a1
	rts

SET_VOLU:
	movem.l	d1-d2/a0-a1,-(sp)
	lea	dword_2B5DE(pc),a0
	tst.w	d1
	beq.s	loc_29C90
	lea	$1A(a0),a1
	bra.s	loc_29C94
loc_29C90:
	lea	$1E(a0),a1
loc_29C94:
	move.l	d0,d2
	cmp.l	#0,d2
	bge.s	loc_29CA6
	move.l	#0,d2
	bra.s	loc_29CB4
loc_29CA6:
	cmp.l	#256-1,d2
	ble.s	loc_29CB4
	move.l  #256-1,d2
loc_29CB4:
	move.w  #1,$14(a0)
	move.l  d2,(a1)
	tst.w   d1
	bne.s   loc_29CC8
	lea	byte_2A7F6(pc),a0
	move.w	d2,word_2AA04-byte_2A7F6(a0)
loc_29CC8:
	move.l  d2,d0
	movem.l (sp)+,d1-d2/a0-a1
	rts

NOFADE:		; might be this?
	movem.l d0/a0,-(sp)
	lea	dword_2B5DE(pc),a0
	move.l  dword_2B5FC-dword_2B5DE(a0),d0
	lea	byte_2A7F6(pc),a0
	move.w  d0,word_2AA04-byte_2A7F6(a0)
	movem.l (sp)+,d0/a0
	rts

FADEUP:
	move.l	a0,-(sp)
	lea	dword_2B5DE(pc),a0
	move.l	#2,$10(a0)
	move.w	#1,$14(a0)
	movea.l	(sp)+,a0
	rts

FADEDOWN:
	move.l	a0,-(sp)
	lea	dword_2B5DE(pc),a0
	move.l	#-2,$10(a0)
	move.w	#1,$14(a0)
	movea.l	(sp)+,a0
	rts

START_MOD:
	move.l	a4,-(sp)
	move.l	#0,(D_RAM+$350)
	jsr	ENABLETIMER

	lea	dword_2B5DE(pc),a4
	st	byte_2B605-dword_2B5DE(a4)
	move.w	#1,$14(a4)
	movea.l	(sp)+,a4
	rts

STOP_MOD:
	movem.l	d7/a3-a4,-(sp)
	jsr	DISABLETIMER

	lea	dword_2B5DE(pc),a4
	sf	byte_2B605-dword_2B5DE(a4)
	lea	$28(a4),a3
	movea.l	#(D_RAM+$800),a4
	moveq	#3,d7

PLAYFX:
	move.l	#-4,(a4)
	move.l	#0,4(a4)
	move.w	#-1,(a3)+
	lea	32(a4),a4
	dbf	d7,PLAYFX

	move.l	#-1,(D_RAM+$350)
	movem.l	(sp)+,d7/a3-a4
	rts

ENABLE_FX:
	movem.l	a6,-(sp)
	lea	dword_2B5DE(pc),a6
	st	$26(a6)
	movem.l	(sp)+,a6
	rts

DISABLE_FX:
	movem.l	d7/a6,-(sp)
	lea	dword_2B5DE(pc),a6
	sf	$26(a6)
	tst.b	$27(a6)
	beq.s	loc_29DAE
	moveq	#5,d7
	bra.s	loc_29DB0
loc_29DAE:
	moveq	#1,d7
loc_29DB0:
	movea.l	#(D_RAM+$800),a6
	lea	$A0(a6),a6
loc_29DBA:
	move.l  #-4,(a6)
	move.l  #0,4(a6)
	lea	-$20(a6),a6
	dbf	d7,loc_29DBA
	movem.l	(sp)+,d7/a6
	rts

GETSAMNO:
	movem.l d1/a0-a2,-(sp)
	lea	dword_2B5DA(pc),a1
	lea	(a1,d0.w),a1
	move.b	(a1),d1
	lea	byte_2A7F6(pc),a0
	lea	word_2AA06-byte_2A7F6(a0),a0
	mulu.w  #52,d0		; multiply by 52 bytes (length)
	lea	SAMP_NUMBER(a0,d0.w),a2
	move.b  (a2),d0
	move.b  d0,(a1)
	move.b  1(a2),d1
	bne.s   .no
	moveq   #-1,d0
.no:
	clr.b   1(a2)
	movem.l (sp)+,d1/a0-a2
	rts

HALTDSP:
	movem.l d0/d7/a1/a4,-(sp)
	lea	dword_2B5DE(pc),a1
	move.w	d0,d7
	andi.w	#15,d7
	cmp.w	#15,d7
	bne.s	loc_29E24
	jsr	DISABLETIMER
loc_29E24:
	not.l	d0
	move.l	d0,(D_RAM+$34C).l
	movem.l	(sp)+,d0/d7/a1/a4
	rts

RESUMEDSP:
	movem.l	d7/a1/a4,-(sp)
	lea	dword_2B5DE(pc),a1
	moveq	#0,d7
	not.l	d7
	move.l	d7,(D_RAM+$34C).l
	tst.b	$27(a1)
	beq.s	loc_29E50
	jsr	ENABLETIMER
loc_29E50:
	movem.l (sp)+,d7/a1/a4
	rts
	
.text2:	dc.l	'Copyright (1993) Imagitec Design, Inc '

init_mod:
	bsr.s   init_mod_setting
	bsr.w   sub_29F50
	rts

; a0 = mod file ?
init_mod_setting:
	lea	byte_2A7F6(pc),a5
	move.l	a0,off_2A806-byte_2A7F6(a5)	; store the MOD address at $35FC0 !!

	; initially default to 15-channel
	move.w	#472,d0			; song position(s)	-> 472	($01D8)
	move.w	#600,d1			; pattern data		-> 600	($0258)

	cmpi.l	#'M.K.',$438(a0)	; is the signature 'M.K.'?
	bne.s	loc_29EA6			; if not, keep the 15-channel setting

	; 31-channel song, re-set the positions
	move.w	#952,d0			; song position(s)	-> 952	($03B8)
	move.w	#1084,d1		; pattern data		-> 1084	($043C)

loc_29EA6:
	lea	(a0,d0.w),a1		; find pattern position(s) in song
	lea	(a0,d1.w),a2		; find individual pattern data
	move.l	a1,$14(a5)
	move.l	a2,$18(a5)
	moveq	#0,d0
	move.b	(a1),d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	a2,d0
	move.l	d0,8(a5)
	clr.l	12(a5)
	adda.w	#$14,a0
	move.b	-2(a1),0(a5)	; set song length
	moveq	#$7F,d0
	moveq	#0,d1

loc_29ED6:
	cmp.b	(a1)+,d1
	bge.s	loc_29EDE
	move.b	-1(a1),d1

loc_29EDE:
	dbf	d0,loc_29ED6
	move.b	#6,2(a5)		; set TPR (ticks-per-row) to 6
	move.b	#0,1(a5)		; set current tick to 0
	move.b	#0,3(a5)		; set song position to 0
	moveq	#7,d0
	lea	word_2A7D6(pc),a6

loc_29EFA:
	clr.l	(a6)+
	dbf	d0,loc_29EFA

	moveq	#$33,d0
	lea	$210(a5),a6

loc_29F06:
	clr.l	(a6)+
	dbf	d0,loc_29F06

	lea	$244(a5),a6
	move.w  #8,$20(a6)
	lea	$278(a5),a6
	move.w  #$10,$20(a6)
	lea	$2AC(a5),a6
	move.w  #$18,$20(a6)
	lea	$1C(a5),a5
	lea	dword_2A00C(pc),a6
	moveq	#$1E,d0

loc_29F34:
	move.l	a6,(a5)+
	move.w	#1,(a5)+
	move.l	a6,(a5)+
	move.w  #2,(a5)+
	clr.l	(a5)+
	dbf	d0,loc_29F34

	lea	dword_29FD8(pc),a5
	movem.l	d0-d7/a0-a4,(a5)
	rts

sub_29F50:
	lea	dword_29FD8(pc),a5
	movem.l (a5),d0-d7/a0-a4
	lea	byte_2A7F6(pc),a5
	addq.w	#1,d1
	lsl.l	#8,d1
	lsl.l	#2,d1
	lea	(a2,d1.l),a2
	lea	$1C(a5),a3
	move.l	$14(a5),d0
	sub.l	a0,d0
	subq.l	#2,d0
	divu.w	#$1E,d0
	subq.w	#1,d0

loc_29F78:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	$16(a0),d1
	move.w	$1C(a0),d3
	move.w	$1A(a0),d2
	bne.s	loc_29F94
	add.l	d1,d1
	add.l	d3,d3
	move.l	d1,d4
	bra.s	loc_29FB0

loc_29F94:
	move.l	d2,d4
	add.l	d3,d4
	cmp.l	d1,d4
	bgt.s	loc_29F9E
	add.l	d2,d2

loc_29F9E:
	add.l	d1,d1
	add.l	d3,d3
	move.l	d2,d4
	add.l	d3,d4
	cmp.l	d1,d4
	ble.s   loc_29FB0
	move.l	d1,d3
	sub.l	d2,d3
	move.l	d1,d4

loc_29FB0:
	move.l	a2,(a3)+
	lsr.l	#1,d3
	lsr.l	#1,d4
	move.w	d4,(a3)+
	move.l	a2,(a3)
	add.l	d2,(a3)+
	move.w	d3,(a3)+
	moveq	#0,d2
	move.b	$18(a0),d2
	move.w	d2,(a3)+
	move.b	$19(a0),d2
	move.w	d2,(a3)+
	adda.l	d1,a2
	lea	$1E(a0),a0
	dbf	d0,loc_29F78
	rts

;; will document these later...
dword_29FD8:	dcb.l 13,0
dword_2A00C:	dcb.l 4,0

do_your_main_tick:		; called after NT_VBL
sub_2A01C:
	movem.l d0-d7/a0-a6,-(sp)
	lea	byte_2A7F6(pc),a5	; load player data
	lea	1(a5),a0		; grab our current tick
	lea	loc_2A31E(pc),a1	; load effect data
	move.b	(a0)+,d0	; add to the tick
	addq.b	#1,d0
	cmp.b	(a0),d0
	blt.s	loc_2A05A
	clr.b	-(a0)		; clear tick counter
	bsr.w	sub_2A0E6
	lea	dword_2AF90,a0
	tst.b	(a0)+
	beq.s	loc_2A048
	move.b	-(a0),1(a0)
	clr.b	(a0)+
loc_2A048:
	tst.b	(a0)
	beq.s	loc_2A058
	subq.b	#1,(a0)
	beq.s	loc_2A058
	subi.l  #$10,12(a5)	; subtract from row???
loc_2A058:
	bra.s   loc_2A05C
loc_2A05A:
	move.b  d0,-(a0)
loc_2A05C:
	lea	$210(a5),a0		; grab channel 1's effect
	bsr.w	do_effects		; do effect loop
	lea	$244(a5),a0		; grab channel 2's effect
	bsr.w	do_effects		; do effect loop
	lea	$278(a5),a0		; grab channel 3's effect
	bsr.w	do_effects		; do effect loop
	lea	$2AC(a5),a0		; grab channel 4's effect
	bsr.w	do_effects		; do effect loop

	tst.b	5(a5)
	beq.s	loc_2A096
	sf	5(a5)
	moveq	#0,d0
	move.b	6(a5),d0
	lsl.w	#4,d0
	move.l	d0,12(a5)
	clr.w	6(a5)
loc_2A096:
	cmpi.l  #64*16,12(a5)	; reached 64 rows?
	blt.s   loc_2A0DA
loc_2A0A0:
	moveq   #0,d0
	move.b  6(a5),d0	; take current address ($35FC0 + row)
	lsl.w   #4,d0
	move.l  d0,12(a5)	; reset row positon
	move.b  3(a5),d0	; take song position from A5
	addq.b  #1,d0		; add to song position
	cmp.b   0(a5),d0	; song position > pattern(s) in song?
	blt.s   loc_2A0BA		; if not, continue
	clr.b	d0			; reset and re-play the song
loc_2A0BA:
	move.b  d0,3(a5)
	movea.l $14(a5),a0
	move.b	(a0,d0.w),d0
	lsl.l	#8,d0
	lsl.l	#2,d0
	add.l	$18(a5),d0
	move.l  d0,8(a5)
	sf	6(a5)
	sf	7(a5)
loc_2A0DA:
	tst.b	7(a5)
	bne.s	loc_2A0A0
	movem.l (sp)+,d0-d7/a0-a6
	rts
sub_2A0E6:
	tst.b   $791(a5)
	beq.s   loc_2A0F6
	addi.l  #$10,12(a5)	; add to current row
	rts
loc_2A0F6:
	movea.l 8(a5),a0
	adda.l	12(a5),a0
	addi.l	#$10,12(a5)	; add to current row

	lea	$210(a5),a1
	lea	word_2A7D6(pc),a2
	bsr.s	sub_2A134
	lea	$244(a5),a1
	lea	word_2A7DE(pc),a2
	bsr.s	sub_2A134
	lea	$278(a5),a1
	lea	word_2A7E6(pc),a2
	bsr.s	sub_2A134
	lea	$2AC(a5),a1
	lea	word_2A7EE(pc),a2
	bsr.s	sub_2A134
	lea	word_2A2FE(pc),a1
	rts
sub_2A134:
	move.l	(a0)+,d0
	move.l	d0,0(a1)
	move.w	d0,d1
	swap	d0
	move.w  d0,d2
	andi.w	#$F000,d1
	andi.w	#$F000,d2
	lsr.w	#4,d1
	or.w	d2,d1
	beq.s	loc_2A180
	subq.w	#1,d1
	lsr.w	#4,d1
	andi.w	#$1F0,d1
	st	$33(a1)
	lsr.w	#4,d1
	move.b	d1,$32(a1)
	lsl.w	#4,d1
	lea	6(a1),a3
	lea	$1C(a5),a4
	adda.w	d1,a4
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.w	(a4)+,(a3)+
	move.w	(a4),2(a3)
	movea.l	$C(a1),a3
	move.l	a3,$2A(a1)
loc_2A180:
	andi.w	#$FFF,d0
	beq.w	locret_2A28C
	move.b	2(a1),d1
	andi.w	#$F,d1
	cmp.b	#3,d1		; effect == 3?
	beq.w	loc_2A242
	cmp.b	#5,d1		; effect == 5?
	beq.w	loc_2A242
	cmp.b	#9,d1		; effect == 9?
	bne.s	loc_2A1D0
	moveq	#0,d1	; restart the sample??
	move.b	3(a1),d1
	beq.s	loc_2A1B2
	move.b	d1,$23(a1)
loc_2A1B2:
	move.b	$23(a1),d1
	lsl.w	#7,d1
	cmp.w	10(a1),d1
	bge.s	loc_2A1CA
	sub.w	d1,10(a1)
	add.w	d1,d1
	add.l	d1,6(a1)
	bra.s	loc_2A1D0
loc_2A1CA:
	move.w  #1,10(a1)
loc_2A1D0:
	move.l	d0,d1
	swap	d1
	andi.w  #$FF0,d1
	cmp.w   #$E50,d1
	bne.s   loc_2A1EC
	moveq   #0,d2
	move.b  3(a1),d2
	andi.w  #$F,d2
	move.w  d2,$12(a1)
loc_2A1EC:
	move.w	$12(a1),d2
	beq.s	loc_2A20C
	lea	dword_2AB06,a3
	moveq	#$24,d2
loc_2A1F8:
	cmp.w	(a3)+,d0
	bcc.s	loc_2A200
	dbf	d2,loc_2A1F8
loc_2A200:
	move.w  $12(a1),d2
	mulu.w  #$48,d2
	move.w  -2(a3,d2.w),d0
loc_2A20C:
	move.w	d0,$14(a1)
	cmp.w	#$ED0,d1
	beq.w	locret_2A28C
	btst	#2,$22(a1)
	bne.s	loc_2A224
	clr.b	$25(a1)
loc_2A224:
	btst	#6,$22(a1)
	bne.s	loc_2A230
	clr.b	$25(a1)
loc_2A230:
	move.l	6(a1),0(a2)
	move.w	$A(a1),4(a2)
	asl	4(a2)
	rts
loc_2A242:
	move.w  $12(a1),d1
	mulu.w  #$48,d1
	lea	dword_2AB06,a3
	adda.l  d1,a3
	moveq   #0,d1
loc_2A252:
	cmp.w   (a3,d1.w),d0
	bcc.s   loc_2A262
	addq.w  #2,d1
	cmp.w   #$48,d1
	bcs.s   loc_2A252
	moveq   #$46,d1
loc_2A262:
	move.w	$12(a1),d0
	andi.b	#8,d0
	beq.s	loc_2A272
	tst.w	d1
	beq.s	loc_2A272
	subq.w	#2,d1
loc_2A272:
	move.w	(a3,d1.w),d0
	move.w	d0,$1C(a1)
	clr.b	$1E(a1)
	cmp.w	$14(a1),d0
	beq.s	loc_2A28E
	bgt.s	locret_2A28C
	move.b  #1,$1E(a1)
locret_2A28C:
	rts
loc_2A28E:
	clr.w   $1C(a1)
	rts

do_effects:
sub_2A294:
	move.l  a1,-(sp)
	movem.l a0-a1,-(sp)
	bsr.w	sub_2A77C
	movem.l (sp)+,a0-a1
	lea	$14(a0),a2
	move.l	(a2)+,(a2)
	moveq	#0,d0
	move.w	2(a0),d0
	andi.w	#$FFF,d0
	beq.s	loc_2A2CE
	move.l	d0,d1
	andi.w	#$FF,d1
	lsr.w	#8,d0
	tst.b	(a1,d0.w)
	beq.s	loc_2A2CE
	add.w	d0,d0
	lea	word_2A2DE(pc),a1
	adda.w	(a1,d0.w),a1
	jsr	(a1)
loc_2A2CE:
	move.w	$20E(a5),d0
	mulu.w	$1A(a0),d0
	move.w	d0,$1A(a0)
	movea.l (sp)+,a1
	rts

word_2A2DE:			; effect functions done after tick>0
	dc.w	loc_2A31E-word_2A2DE		; effect 0 - arpeggio!
	dc.w	loc_2A376-word_2A2DE		; effect 1 - pitch up!
	dc.w	loc_2A392-word_2A2DE		; effect 2 - pitch down!
	dc.w	loc_2A3AE-word_2A2DE		; effect 3 - slide to note
	dc.w	loc_2A42C-word_2A2DE		; effect 4 - vibrato
	dc.w	loc_2A4C2-word_2A2DE		; effect 5 (effects $3 + $A)
	dc.w	loc_2A4D2-word_2A2DE		; effect 6 (effects $4 + $A)
	dc.w	loc_2A4E2-word_2A2DE		; effect 7 - tremolo (this works??)
	dc.w	locret_2A586-word_2A2DE		; effect 8 - unused (FT2 pan)
	dc.w	loc_2A588-word_2A2DE		; effect 9 - sample offset
	dc.w	sub_2A5B0-word_2A2DE		; effect $A - volume slide
	dc.w	loc_2A5DE-word_2A2DE		; effect $B - pattern jump
	dc.w	loc_2A5EE-word_2A2DE		; effect $C - set volume
	dc.w	loc_2A600-word_2A2DE		; effect $D - break pattern
	dc.w	loc_2A622-word_2A2DE		; effect $E - multiple effects!
	dc.w	loc_2A7C6-word_2A2DE		; effect $F - set TPR (no tempo)

word_2A2FE:	;something something flags???
	dc.w $0000	;0
	dc.w $0000	;1
	dc.w $0000	;2
	dc.w $0000	;3
	dc.w $0001	;4
	dc.w $0005	;5
	dc.w $0101	;6
	dc.w $0101	;7
	dc.w $0101	;8
	dc.w $0101	;9
	dc.w $0101	;A
	dc.w $0101	;B
	dc.w $0000	;C
	dc.w $0100	;D
	dc.w $0000	;E
	dc.w $0100	;F

loc_2A31E:		; effect 0 - arpeggio!
	moveq	#0,d0
	move.b	1(a5),d0	; get current tick
	divs.w	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	loc_2A344
	cmp.w	#2,d0
	beq.s	loc_2A33C
	move.l	d1,d0
	lsr.b	#4,d0
	bra.s	loc_2A34A
loc_2A33C:
	move.l	d1,d0
	andi.b	#15,d0
	bra.s	loc_2A34A
loc_2A344:
	move.w	$14(a0),d2
	bra.s	loc_2A370
loc_2A34A:
	add.w   d0,d0
	move.w  $12(a0),d1
	mulu.w  #$48,d1
	lea	dword_2AB06,a1
	adda.l	d1,a1
	move.w	$14(a0),d1
	moveq	#$24,d7
loc_2A360:
	move.w	(a1,d0.w),d2
	cmp.w	(a1),d1
	bcc.s	loc_2A370
	addq.l	#2,a1
	dbf	d7,loc_2A360
	rts
loc_2A370:
	move.w  d2,$18(a0)
	rts

loc_2A376:		; effect 1 - pitch up!
	sub.w   d1,$14(a0)
	cmpi.w  #113,$14(a0)
	bge.s   loc_2A388
	move.w  #113,$14(a0)
loc_2A388:
	move.w  $14(a0),d0
	move.w  d0,$18(a0)
	rts

loc_2A392:		; effect 2 - pitch down!
	add.w   d1,$14(a0)
	cmpi.w  #856,$14(a0)
	ble.s   loc_2A3A4
	move.w  #856,$14(a0)
loc_2A3A4:
	move.w  $14(a0),d0
	move.w  d0,$18(a0)
	rts

loc_2A3AE:		; effect 3 - slide to note
	tst.w	d1
	beq.s	sub_2A3BA
	move.b	d1,$1F(a0)
	clr.b	3(a0)
sub_2A3BA:
	move.w	$1C(a0),d2
	bne.s	loc_2A3C2
	rts
loc_2A3C2:
	moveq	#0,d0
	move.b	$1F(a0),d0
	tst.b	$1E(a0)
	beq.s	loc_2A3E2
	sub.w	d0,$14(a0)
	cmp.w	$14(a0),d2
	blt.s	loc_2A3F4
	move.w	d2,$14(a0)
	clr.w	$1C(a0)
	bra.s	loc_2A3F4
loc_2A3E2:
	add.w	d0,$14(a0)
	cmp.w	$14(a0),d2
	bgt.s	loc_2A3F4
	move.w	d2,$14(a0)
	clr.w	$1C(a0)
loc_2A3F4:
	move.w	$14(a0),d0
	move.b	$28(a0),d1
	andi.b	#15,d1
	beq.s	loc_2A426
	move.w	$12(a0),d1
	mulu.w	#$48,d1
	lea	dword_2AB06,a1
	adda.l	d1,a1
	moveq	#0,d1
loc_2A412:
	cmp.w	(a1,d1.w),d0
	bcc.s	loc_2A422
	addq.w	#2,d1
	cmp.w	#$48,d1
	bcs.s	loc_2A412
	moveq	#$46,d1
loc_2A422:
	move.w	(a1,d1.w),d0
loc_2A426:
	move.w	d0,$18(a0)
	rts

loc_2A42C:		; effect 4 - vibrato
	tst.w	d1
	beq.s	sub_2A454
	move.b	$24(a0),d2
	andi.b	#$F,d1
	beq.s	loc_2A440
	andi.b	#$F0,d2
	or.b	d1,d2
loc_2A440:
	move.b	3(a0),d1
	andi.b	#$F0,d1
	beq.s	loc_2A450
	andi.b	#$F,d2
	or.w	d1,d2
loc_2A450:
	move.b	d2,$24(a0)
sub_2A454:
	lea	byte_2AAE6,a1		; load up vibrato table
	move.b	$25(a0),d0
	lsr.w	#2,d0
	andi.w	#31,d0
	moveq	#0,d1
	move.b	$22(a0),d1
	andi.b	#3,d1
	beq.s	loc_2A48E
	lsl.b	#3,d0
	cmp.b	#1,d1
	beq.s	loc_2A47C
	move.b	#$FF,d1
	bra.s	loc_2A492
loc_2A47C:
	tst.b	$25(a0)
	bpl.s	loc_2A48A
	move.b	#$FF,d1
	sub.b	d0,d1
	bra.s	loc_2A492
loc_2A48A:
	move.b	d0,d1
	bra.s	loc_2A492
loc_2A48E:
	move.b	(a1,d0.w),d1
loc_2A492:
	move.b	$24(a0),d0
	andi.w	#$F,d0
	mulu.w	d0,d1
	lsr.w	#7,d1
	move.w	$14(a0),d0
	tst.b	$25(a0)
	bmi.s	loc_2A4AC
	add.w	d1,d0
	bra.s	loc_2A4AE
loc_2A4AC:
	sub.w	d1,d0
loc_2A4AE:
	move.w	d0,$18(a0)
	move.b	$24(a0),d0
	lsr.w	#2,d0
	andi.w	#$3C,d0
	add.b	d0,$25(a0)
	rts

loc_2A4C2:		; effect 5 (effects $3 + $A)
	bsr.w	sub_2A3BA
	moveq	#0,d1
	move.b	3(a0),d1
	bsr.w	sub_2A5B0
	rts

loc_2A4D2:		; effect 6 (effects $4 + $A)
	bsr.w	sub_2A454
	moveq	#0,d1
	move.b	3(a0),d1
	bsr.w	sub_2A5B0
	rts

loc_2A4E2:		; effect 7 - tremolo (this works??)
	tst.w	d1
	beq.s	loc_2A50A
	move.b	$24(a0),d2
	andi.b	#$F,d1
	beq.s	loc_2A4F6
	andi.b	#$F0,d2
	or.b	d1,d2
loc_2A4F6:
	move.b  3(a0),d1
	andi.b  #$F0,d1
	beq.s   loc_2A506
	andi.b  #$F,d2
	or.w    d1,d2
loc_2A506:
	move.b  d2,$24(a0)
loc_2A50A:
	lea	byte_2AAE6,a1		; load up vibrato table
	move.b	37(a0),d0
	lsr.w	#2,d0
	andi.w	#31,d0
	moveq	#0,d1
	move.b	$22(a0),d1
	lsr.b	#4,d1
	andi.b	#3,d1
	beq.s	loc_2A546
	lsl.b   #3,d0
	cmp.b   #1,d1
	beq.s   loc_2A534
	move.b  #255,d1
	bra.s   loc_2A54A
loc_2A534:
	tst.b   37(a0)
	bpl.s   loc_2A542
	move.b  #255,d1
	sub.b   d0,d1
	bra.s   loc_2A54A
loc_2A542:
	move.b  d0,d1
	bra.s   loc_2A54A
loc_2A546:
	move.b  (a1,d0.w),d1
loc_2A54A:
	move.b  $24(a0),d0
	andi.w  #15,d0
	mulu.w  d0,d1
	lsr.w   #6,d1
	move.w  $16(a0),d0
	tst.b   $25(a0)
	bmi.s   loc_2A564
	add.w   d1,d0
	bra.s   loc_2A566
loc_2A564:
	sub.w   d1,d0
loc_2A566:
	bpl.s   loc_2A56A
	moveq   #0,d0
loc_2A56A:
	cmp.w   #64,d0
	ble.s   loc_2A572
	moveq   #64,d0
loc_2A572:
	move.w  d0,$1A(a0)
	move.b  $24(a0),d0
	lsr.w   #2,d0
	andi.w  #$3C,d0
	add.b   d0,$25(a0)
	rts

locret_2A586:	; effect 8 - unused (FT2 pan)
	rts

loc_2A588:		; effect 9 - sample offset
	tst.w	d1
	beq.s	loc_2A590
	move.b	d1,$23(a0)
loc_2A590:
	move.b	$23(a0),d1
	lsl.w	#7,d1
	cmp.w	$A(a0),d1
	bge.s	loc_2A5A8
	sub.w	d0,$A(a0)
	add.w	d0,d0
	add.l	d0,6(a0)
	rts
loc_2A5A8:
	move.w	#1,$A(a0)
	rts

sub_2A5B0:		; effect $A - volume slide
	move.w	$16(a0),d3
	move.w	d1,d2
	lsr.w	#4,d1
	andi.w	#$F,d1
	beq.s	loc_2A5CA
	add.w	d1,d3
	cmp.w	#64,d3
	ble.s	loc_2A5D4
	moveq	#64,d3
	bra.s	loc_2A5D4
loc_2A5CA:
	andi.w	#$F,d2
	sub.w	d2,d3
	bpl.s	loc_2A5D4
	moveq	#0,d3
loc_2A5D4:
	move.w	d3,$16(a0)
	move.w	d3,$1A(a0)
	rts

loc_2A5DE:		; effect $B - pattern jump
	subq.w	#1,d1
	move.b	d1,3(a5)
	clr.b	6(a5)
	st	7(a5)
	rts

loc_2A5EE:		; effect $C - set volume
	cmp.w	#64,d1	; volume > 64 ??
	ble.s	loc_2A5F6
	moveq	#64,d1	; truncate to 64
loc_2A5F6:
	move.w	d1,$16(a0)
	move.w	d1,$1A(a0)
	rts

loc_2A600:		; effect $D - break pattern
	clr.b	6(a5)
	st	7(a5)
	move.l	d1,d2
	lsr.b	#4,d1
	mulu.w	#10,d1
	andi.b	#$F,d2
	add.b	d2,d1
	cmp.b	#63,d1	; pattern > 63 ??
	bhi.s	locret_2A620
	move.b  d1,6(a5)
locret_2A620:
	rts

loc_2A622:	; effect $E - multiple effects!
	move.w	d1,d2
	andi.w	#$F,d1
	lsr.w	#4,d2
	add.w	d2,d2
	lea	dword_2A638(pc),a1
	adda.w	(a1,d2.w),a1
	jsr	(a1)
	rts

dword_2A638:		; Exy effect list
	dc.w	locret_2A658-dword_2A638	; effect 0 - enable filter (does nothing)
	dc.w	loc_2A65A-dword_2A638		; effect 1 - pitch up by X
	dc.w	loc_2A666-dword_2A638		; effect 2 - pitch down by X
	dc.w	loc_2A672-dword_2A638		; effect 3 - portamento control
	dc.w	loc_2A67E-dword_2A638		; effect 4 - vibrato control
	dc.w	loc_2A68A-dword_2A638		; effect 5 - set finetune
	dc.w	loc_2A690-dword_2A638		; effect 6 - pattern loop
	dc.w	loc_2A6C8-dword_2A638		; effect 7 - tremolo control
	dc.w	locret_2A6D6-dword_2A638	; effect 8 - unused
	dc.w	loc_2A6D8-dword_2A638		; effect 9 - retrigger note
	dc.w	loc_2A716-dword_2A638		; effect $A - fine vol. slide up
	dc.w	loc_2A724-dword_2A638		; effect $B - fine vol. slide down
	dc.w	loc_2A730-dword_2A638		; effect $C - note cut at X tick
	dc.w	loc_2A740-dword_2A638		; effect $D - note delay until X tick
	dc.w	loc_2A752-dword_2A638		; effect $E - pattern delay
	dc.w	loc_2A766-dword_2A638		; effect $F - invert loop

locret_2A658:	; effect 0 - enable filter (does nothing)
	rts

loc_2A65A:		; effect 1 - pitch up by X
	tst.b	1(a5)	; is tick 0?
	bne.s	locret_2A664
	bsr.w	loc_2A376
locret_2A664:
	rts

loc_2A666:		; effect 2 - pitch down by X
	tst.b	1(a5)	; is tick 0?
	bne.s	locret_2A670
	bsr.w	loc_2A392
locret_2A670:
	rts

loc_2A672:		; effect 3 - portamento control
	andi.b	#$F0,$28(a0)
	or.b	d1,$28(a0)
	rts

loc_2A67E:		; effect 4 - vibrato control
	andi.b	#$F0,$22(a0)
	or.b	d1,$22(a0)
	rts

loc_2A68A:		; effect 5 - set finetune
	move.b	d1,$12(a0)
	rts

loc_2A690:		; effect 6 - pattern loop
	tst.b	1(a5)	; is tick 0?
	bne.s	locret_2A6C6
	tst.w	d1
	beq.s	loc_2A6BA
	tst.b	$26(a0)
	beq.s	loc_2A6B4
	subq.b	#1,$26(a0)
	beq.s	locret_2A6C6
loc_2A6A6:
	move.b	$27(a0),d0
	move.b	d0,6(a5)
	st	5(a5)
	rts
loc_2A6B4:
	move.b	d1,$26(a0)
	bra.s	loc_2A6A6
loc_2A6BA:
	move.l	$C(a5),d1
	lsr.w	#4,d1
	subq.b	#1,d1
	move.b	d1,$27(a0)
locret_2A6C6:
	rts

loc_2A6C8:		; effect 7 - tremolo control
	lsl.b	#4,d1
	andi.b	#$F,$22(a0)
	or.b	d1,$22(a0)
	rts

locret_2A6D6:	; effect 8 - unused
	rts

loc_2A6D8:		; effect 9 - retrigger note
	tst.w	d1
	beq.s	locret_2A714

	moveq	#0,d2
	move.b	1(a5),d2
	bne.s	loc_2A6F4
	move.w	0(a0),d2
	andi.w	#$FFF,d2
	bne.s	locret_2A714
	moveq	#0,d2
	move.b	1(a5),d2
loc_2A6F4:
	divu.w	d1,d2
	swap	d2
	tst.w	d2
	bne.s	locret_2A714
sub_2A6FC:
	move.w	$20(a0),d1
	lea	word_2A7D6(pc),a6
	move.l	6(a0),0(a6,d1.w)
	move.w	10(a0),4(a6,d1.w)
	asl	4(a6,d1.w)
locret_2A714:
	rts

loc_2A716:		; effect $A - fine vol. slide up
	tst.b	1(a5)		; is current tick 0?
	bne.s	locret_2A722

	lsl.b	#4,d1
	bsr.w	sub_2A5B0
locret_2A722:
	rts

loc_2A724:		; effect $B - fine vol. slide down
	tst.b   1(a5)		; is current tick 0?
	bne.s   locret_2A72E

	bsr.w   sub_2A5B0
locret_2A72E:
	rts

loc_2A730:		; effect $C - note cut at X tick
	cmp.b	1(a5),d1	; is current tick at intended value?
	bne.s	locret_2A73E

	clr.w	$16(a0)
	clr.w	$1A(a0)
locret_2A73E:
	rts

loc_2A740:		; effect $D - note delay until X tick
	cmp.b	1(a5),d1	; is current tick at intended value?
	bne.s	locret_2A750
	tst.w	0(a0)
	beq.s	locret_2A750

	bsr.w	sub_2A6FC
locret_2A750:
	rts

loc_2A752:		; effect $E - pattern delay
	tst.b	1(a5)		; is current tick 0?
	bne.s	locret_2A764
	tst.b	$791(a5)
	bne.s	locret_2A764

	addq.b	#1,d1
	move.b	d1,dword_2AF90
locret_2A764:
	rts

loc_2A766:		; effect $F - invert loop
	tst.b	1(a5)		; is current tick 0?
	bne.s	locret_2A7C4

	lsl.b	#4,d1
	andi.b	#$F,$28(a0)
	or.b	d1,$28(a0)
	tst.b	d1
	beq.s	locret_2A7C4
sub_2A77C:
	moveq	#0,d1
	move.b	40(a0),d1
	lsr.b	#4,d1
	beq.s	locret_2A7C4
	lea	byte_2AAD6,a1		; load up inverse loop table
	move.b	(a1,d1.w),d1
	add.b	d1,$29(a0)
	btst	#7,$29(a0)
	beq.s	locret_2A7C4
	clr.b	$29(a0)
	move.l	12(a0),d0
	moveq	#0,d1
	move.w	16(a0),d1
	add.l	d1,d0
	add.l	d1,d0
	movea.l	42(a0),a1
	addq.l	#1,a1
	cmpa.l	d0,a1
	bcs.s	loc_2A7BA
	movea.l	12(a0),a1
loc_2A7BA:
	move.l	a1,$2A(a0)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
locret_2A7C4:
	rts
loc_2A7C6:
	andi.w	#31,d1
	beq.s	locret_2A7D4
	move.b	d1,2(a5)
	clr.b	1(a5)
locret_2A7D4:
	rts

word_2A7D6:	dc.w -1,-1,0,0
word_2A7DE:	dc.w -1,-1,0,0
word_2A7E6:	dc.w -1,-1,0,0
word_2A7EE:	dc.w -1,-1,0,0

byte_2A7F6:	dc.b 0	;; song length
byte_2A7F7:	dc.b 0	;; current tick (sub_2A01C)
byte_2A7F8:	dc.b 0	;; ticks per row
byte_2A7F9:	dc.b 0	;; song position
.padding0:	dc.l 0
word_2A7FE:	dc.l 0	;; pattern address ($35FC0+addr)
word_2A802:	dc.l 0	;; current row
off_2A806:	dc.l 0	;; MOD address location

;TODO!!! (sample offset/data??)
off_2A80A:	dc.l 0	;; pattern data begin address
off_2A80E:	dc.l 0	;; pattern data address

.macro	add_sample				;	(+16)
	dc.l 0	;; sample begin addr.	(+0)
	dc.w 0	;; sample length??		(+4)
	dc.l 0	;; sample loop addr.	(+6)
	dc.w 0	;; unknown???			(+10)
	dc.w 0	;; unknown???			(+12)
	dc.w 0	;; default volume		(+14)
	.endm

off_2A812:	;; sample data/pointers	(+496)
	rept 31
	add_sample
	endr

word_2AA04:	dc.w 0	;; global volume ?? (SET_VOLU)

;; channel struct info (len:52)
NOTE			equ 0	; $00
EFFECT			equ 2	; $02
EFFECT_PARAM	equ 3	; $03
SAMP_START		equ 6	; $06
SAMP_LENGTH		equ 10	; $0A
SAMP_START2		equ 12	; $0C
FINETUNE		equ 18	; $12
LAST_PERIOD		equ 20	; $14
VOLUME			equ 22	; $16
PERIOD			equ 24	; $18
VOLUME_EX		equ 26	; $1A
PORTA_TARGET	equ 28	; $1C
PORTA_SPEED		equ 31	; $1F
NUM_34			equ 34	; $22
SAMP_OFFSET		equ 35	; $23
VIBRATO_NUM		equ 36	; $24
VIBRATO_TICK	equ 37	; $25
REPEAT_NUMBER	equ 38	; $26
REPEAT_PATTERN	equ 39	; $27
SAMP_NUMBER		equ 50	; $32

.macro	add_channel							;	(+52)
	dc.w 0		; note							(+0)
	dc.b 0,0	; effect,effect_param			(+2)
	dc.w 0		; loop start ??					(+4)
	dc.l 0		; start	($35FC0+off)			(+6)
	dc.w 0		; length / period				(+10)
	dc.l 0		; sample start	($35FC0+off)	(+12)
	dc.w 0,0	; loop start ??					(+16)
	dc.w 0		; last period					(+20)
	dc.w 0		; volume						(+22)
	dc.w 0		; last period 2					(+24)
	dc.w 0		; volume^10						(+28)
	dc.w 0		; something??					(+30)
	dc.w 0		; portamento speed				(+32)
	dc.w 0		; something??					(+34)
	dc.w 0		; sample offset					(+36)
	dc.b 0		; vibrato depth					(+38)
	dc.b 0		; vibrato tick					(+39)
	dc.w 0,0	; something??					(+40)
	dc.l 0		; sample start 2($35FC0+off)	(+42)
	dc.w 0,0	; something??					(+46)
	dc.b 0		; sample number					(+50)
	dc.b 0		; global volume ??				(+51)
	.endm

word_2AA06:	add_channel	;; channel 1 info ($02AA06-$02AA39)
word_2AA3A:	add_channel	;; channel 2 info ($02AA3A-$02AA6D)
word_2AA6E:	add_channel	;; channel 3 info ($02AA6E-$02AAA1)
word_2AAA2:	add_channel	;; channel 4 info ($02AAA2-$02AAD5)
	
byte_2AAD6:				;; inverse loop table
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

byte_2AAE6:				;; vibrato table
	dc.b	  0, 24, 49, 74, 97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120, 97, 74, 49, 24

dword_2AB06:			;; period/finetune tables
	dc.l	.ftune0,.ftune1,.ftune2,.ftune3
	dc.l	.ftune4,.ftune5,.ftune6,.ftune7
	dc.l	.ftune8,.ftune9,.ftuneA,.ftuneB
	dc.l	.ftuneC,.ftuneD,.ftuneE,.ftuneF
.ftune0:
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
.ftune1:
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
.ftune2:
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
.ftune3:
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
.ftune4:
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
.ftune5:
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
.ftune6:
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
.ftune7:
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
.ftune8:
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
.ftune9:
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
.ftuneA:
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
.ftuneB:
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
.ftuneC:
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
.ftuneD:
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
.ftuneE:
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
.ftuneF:
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	
.padding1:	dc.w	0,0,0,0,0	; padding found here...

dword_2AF90:			;; not sure what this is ?
	dc.w	$0237,$0232,$022D,$0228,$0223,$021E,$0219,$0215
    dc.w	$0210,$020B,$0207,$0203,$01FE,$01FA,$01F6,$01F2
    dc.w	$01EE,$01EA,$01E6,$01E2,$01DE,$01DB,$01D7,$01D3
    dc.w	$01D0,$01CC,$01C9,$01C6,$01C2,$01BF,$01BC,$01B9
    dc.w	$01B5,$01B2,$01AF,$01AC,$01A9,$01A6,$01A3,$01A1
    dc.w	$019E,$019B,$0198,$0195,$0193,$0190,$018E,$018B
    dc.w	$0188,$0186,$0183,$0181,$017F,$017C,$017A,$0178
    dc.w	$0175,$0173,$0171,$016F,$016C,$016A,$0168,$0166
    dc.w	$0164,$0162,$0160,$015E,$015C,$015A,$0158,$0156
    dc.w	$0154,$0152,$0150,$014E,$014D,$014B,$0149,$0147
    dc.w	$0146,$0144,$0142,$0140,$013F,$013D,$013B,$013A
    dc.w	$0138,$0137,$0135,$0134,$0132,$0130,$012F,$012D
    dc.w	$012C,$012B,$0129,$0128,$0126,$0125,$0123,$0122
    dc.w	$0121,$011F,$011E,$011D,$011B,$011A,$0119,$0117
    dc.w	$0116,$0115,$0114,$0112,$0111,$0110,$010F,$010E
    dc.w	$010C,$010B,$010A,$0109,$0108,$0107,$0105,$0104
    dc.w	$0103,$0102,$0101,$0100,$00FF,$00FE,$00FD,$00FC
    dc.w	$00FB,$00FA,$00F9,$00F8,$00F7,$00F6,$00F5,$00F4
    dc.w	$00F3,$00F2,$00F1,$00F0,$00EF,$00EE,$00ED,$00EC
    dc.w	$00EB,$00EA,$00E9,$00E9,$00E8,$00E7,$00E6,$00E5
    dc.w	$00E4,$00E3,$00E3,$00E2,$00E1,$00E0,$00DF,$00DE
    dc.w	$00DE,$00DD,$00DC,$00DB,$00DA,$00DA,$00D9,$00D8
    dc.w	$00D7,$00D7,$00D6,$00D5,$00D4,$00D4,$00D3,$00D2
    dc.w	$00D1,$00D1,$00D0,$00CF,$00CF,$00CE,$00CD,$00CD
    dc.w	$00CC,$00CB,$00CA,$00CA,$00C9,$00C8,$00C8,$00C7
    dc.w	$00C7,$00C6,$00C5,$00C5,$00C4,$00C3,$00C3,$00C2
    dc.w	$00C1,$00C1,$00C0,$00C0,$00BF,$00BE,$00BE,$00BD
    dc.w	$00BD,$00BC,$00BC,$00BB,$00BA,$00BA,$00B9,$00B9
    dc.w	$00B8,$00B8,$00B7,$00B6,$00B6,$00B5,$00B5,$00B4
    dc.w	$00B4,$00B3,$00B3,$00B2,$00B2,$00B1,$00B1,$00B0
    dc.w	$00B0,$00AF,$00AF,$00AE,$00AE,$00AD,$00AD,$00AC
    dc.w	$00AC,$00AB,$00AB,$00AA,$00AA,$00A9,$00A9,$00A8
    dc.w	$00A8,$00A7,$00A7,$00A7,$00A6,$00A6,$00A5,$00A5
    dc.w	$00A4,$00A4,$00A3,$00A3,$00A3,$00A2,$00A2,$00A1
    dc.w	$00A1,$00A0,$00A0,$00A0,$009F,$009F,$009E,$009E
    dc.w	$009D,$009D,$009D,$009C,$009C,$009B,$009B,$009B
    dc.w	$009A,$009A,$009A,$0099,$0099,$0098,$0098,$0098
    dc.w	$0097,$0097,$0096,$0096,$0096,$0095,$0095,$0095
    dc.w	$0094,$0094,$0094,$0093,$0093,$0093,$0092,$0092
    dc.w	$0091,$0091,$0091,$0090,$0090,$0090,$008F,$008F
    dc.w	$008F,$008E,$008E,$008E,$008D,$008D,$008D,$008C
    dc.w	$008C,$008C,$008B,$008B,$008B,$008B,$008A,$008A
    dc.w	$008A,$0089,$0089,$0089,$0088,$0088,$0088,$0087
    dc.w	$0087,$0087,$0087,$0086,$0086,$0086,$0085,$0085
    dc.w	$0085,$0084,$0084,$0084,$0084,$0083,$0083,$0083
    dc.w	$0082,$0082,$0082,$0082,$0081,$0081,$0081,$0081
    dc.w	$0080,$0080,$0080,$007F,$007F,$007F,$007F,$007E
    dc.w	$007E,$007E,$007E,$007D,$007D,$007D,$007D,$007C
    dc.w	$007C,$007C,$007C,$007B,$007B,$007B,$007B,$007A
    dc.w	$007A,$007A,$007A,$0079,$0079,$0079,$0079,$0078
    dc.w	$0078,$0078,$0078,$0077,$0077,$0077,$0077,$0077
    dc.w	$0076,$0076,$0076,$0076,$0075,$0075,$0075,$0075
    dc.w	$0074,$0074,$0074,$0074,$0074,$0073,$0073,$0073
    dc.w	$0073,$0073,$0072,$0072,$0072,$0072,$0071,$0071
    dc.w	$0071,$0071,$0071,$0070,$0070,$0070,$0070,$0070
    dc.w	$006F,$006F,$006F,$006F,$006F,$006E,$006E,$006E
    dc.w	$006E,$006E,$006D,$006D,$006D,$006D,$006D,$006C
    dc.w	$006C,$006C,$006C,$006C,$006B,$006B,$006B,$006B
    dc.w	$006B,$006A,$006A,$006A,$006A,$006A,$006A,$0069
    dc.w	$0069,$0069,$0069,$0069,$0068,$0068,$0068,$0068
    dc.w	$0068,$0068,$0067,$0067,$0067,$0067,$0067,$0067
    dc.w	$0066,$0066,$0066,$0066,$0066,$0065,$0065,$0065
    dc.w	$0065,$0065,$0065,$0064,$0064,$0064,$0064,$0064
    dc.w	$0064,$0064,$0063,$0063,$0063,$0063,$0063,$0063
    dc.w	$0062,$0062,$0062,$0062,$0062,$0062,$0061,$0061
    dc.w	$0061,$0061,$0061,$0061,$0060,$0060,$0060,$0060
    dc.w	$0060,$0060,$0060,$005F,$005F,$005F,$005F,$005F
    dc.w	$005F,$005F,$005E,$005E,$005E,$005E,$005E,$005E
    dc.w	$005E,$005D,$005D,$005D,$005D,$005D,$005D,$005D
    dc.w	$005C,$005C,$005C,$005C,$005C,$005C,$005C,$005B
    dc.w	$005B,$005B,$005B,$005B,$005B,$005B,$005A,$005A
    dc.w	$005A,$005A,$005A,$005A,$005A,$005A,$0059,$0059
    dc.w	$0059,$0059,$0059,$0059,$0059,$0058,$0058,$0058
    dc.w	$0058,$0058,$0058,$0058,$0058,$0057,$0057,$0057
    dc.w	$0057,$0057,$0057,$0057,$0057,$0056,$0056,$0056
    dc.w	$0056,$0056,$0056,$0056,$0056,$0055,$0055,$0055
    dc.w	$0055,$0055,$0055,$0055,$0055,$0055,$0054,$0054
    dc.w	$0054,$0054,$0054,$0054,$0054,$0054,$0053,$0053
    dc.w	$0053,$0053,$0053,$0053,$0053,$0053,$0053,$0052
    dc.w	$0052,$0052,$0052,$0052,$0052,$0052,$0052,$0052
    dc.w	$0051,$0051,$0051,$0051,$0051,$0051,$0051,$0051
    dc.w	$0051,$0050,$0050,$0050,$0050,$0050,$0050,$0050
    dc.w	$0050,$0050,$0050,$004F,$004F,$004F,$004F,$004F
    dc.w	$004F,$004F,$004F,$004F,$004E,$004E,$004E,$004E
    dc.w	$004E,$004E,$004E,$004E,$004E,$004E,$004D,$004D
    dc.w	$004D,$004D,$004D,$004D,$004D,$004D,$004D,$004D
    dc.w	$004D,$004C,$004C,$004C,$004C,$004C,$004C,$004C
    dc.w	$004C,$004C,$004C,$004B,$004B,$004B,$004B,$004B
    dc.w	$004B,$004B,$004B,$004B,$004B,$004B,$004A,$004A
    dc.w	$004A,$004A,$004A,$004A,$004A,$004A,$004A,$004A
    dc.w	$004A,$0049,$0049,$0049,$0049,$0049,$0049,$0049
    dc.w	$0049,$0049,$0049,$0049,$0048,$0048,$0048,$0048
    dc.w	$0048,$0048,$0048,$0048,$0048,$0048,$0048,$0048
    dc.w	$0047,$0047,$0047,$0047,$0047,$0047,$0047,$0047
    dc.w	$0047,$0047,$0047,$0047,$0046,$0046,$0046,$0046
    dc.w	$0046,$0046,$0046,$0046,$0046,$0046,$0046,$0046
    dc.w	$0045,$0045,$0045,$0045,$0045,$0045,$0045,$0045
    dc.w	$0045,$0045,$0045,$0045,$0045,$0044,$0044,$0044
    dc.w	$0044,$0044,$0044,$0044,$0044,$0044,$0044,$0044
    dc.w	$0044,$0044,$0043,$0043,$0043,$0043,$0043,$0043
    dc.w	$0043,$0043,$0000,$0000,$0000

dword_2B5DA:	dc.b $FF,$FF,$FF,$FF	;; unused??? (if this is used, tell me what for...)
dword_2B5DE:	dc.b $00,$00,$00,$00	;; channel 1 row info
dword_2B5E2:	dc.b $00,$00,$00,$00	;; channel 2 row info
dword_2B5E6:	dc.b $00,$00,$00,$00	;; channel 3 row info
dword_2B5EA:	dc.b $00,$00,$00,$00	;; channel 4 row info
dword_2B5EE:	dc.l 0					;; volume fade dir

				dc.w 0,0,0
				dc.l $FF

dword_2B5FC:	dc.l $FF		; (NOFADE)

				dc.l $100

byte_2B604:		dc.b 0			; (sub_29B58, ENABLE_FX, DISABLE_FX)
byte_2B605:		dc.b 0			; (START_MOD, STOP_MOD)

				dcb.l 4,-1
				dc.w 0

dword_2B618:
	rts

	.68000