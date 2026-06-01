SegaFader:
FADER:
	rts
	move.b	FADEDIR,d0
	beq	 .NOFADE

	add.b	FADEVAL,d0
	cmpi.b	#$ef,d0
	bhi.s	 .F0
	cmpi.b	#$0f,d0
	bhi.s	 .F10

	move.b	FADEDIR,d6			;FULL DARK .. If FADEDIR is -ive then were done
	bmi.s	 .F1
	bra.s	 .F10

.F0:
	move.b	FADEDIR,d6			;FULL BRIGHTNESS ... IF FADEDIR is +ive then were done
	bmi.s	 .F10

.F1:						;end condition exists the set FADEDIR to 0
	sf	FADEDIR

.F10:
	move.b	d0,FADEVAL

.NOFADE:
	moveq	#0,d0
	move.b	FADEVAL,d0
	lsr	 #4,d0
	bsr.s	 .SegaFader

	move.b	NMIVECSEL,d0			; if in  mode demo and fully faded immediately go too big loop
	bne.s	 .NODEMO

	move.b	EDITFLAGS,d0			;in demo mode
	andi.b	#DEMOMODE,d0
	beq.s	 .NODEMO

	move.b	FADEVAL,d0			;black
	andi.b	#$f0,d0
	bne.s	 .NODEMO

	move.b	FADEDIR,d0			; be sure fading out
	bne.s	 .NODEMO
	jmp	 BIGLOOP

.NODEMO:
	rts

.SegaFader:
	moveq	#$0f,d1
	and.w	d1,d0
	eor.w	d1,d0
	lea	view_pal+256*2-4,a0		; point to
	move.b	.table1(pc,d0.w),d1
	move.b	.table2(pc,d0.w),d0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	or.w	d1,d0
	bne.s	.show_fade_stuff
	rts
	
.show_fade_stuff:
	jsr	ADD_OL
	move.l	#.no_see,d0
	lsl.l	#8,d0
	move.l	d0,(a0)+
	move.l	#%00000000010001100000000000000000,(a0)+
	move.l	#%00000000000000000101111111000000,(a0)+
	move.l	#%01010000000000000000000000000000,(a0)+
	move.b	#Q_BMO,O_TYPE-16(a0)
	jsr	ADD_OL
	move.l	#.see,d0
	lsl.l	#8,d0
	move.l	d0,(a0)+
	move.l	#%00000000010001100000000000000000,(a0)+
	move.l	#%00000000000000000101111111000000,(a0)+
	move.l	#%01010000000000000000000000000000,(a0)+
	move.b	#Q_BMO,O_TYPE-16(a0)
	rts	

.table1:	dc.b	-000,-015,-031,-047,-063,-079,-093,-127,-127,-127,-127,-127,-127,-127,-127,-127
.table2:	dc.b	-000,-000,-000,-000,-000,-000,-000,-000,-000,-015,-031,-047,-063,-079,-093,-127
	
*	%3210987654321098765432109876543210987654321098765432109876543210
*	%6666555555555544444444443333333333222222222211111111110000000000
*	 DDDDDDDDDDDDDDDDDDDDDLLLLLLLLLLLLLLLLLLLHHHHHHHHHHYYYYYYYYYYYTTT
*	%0000000000000000000000000000000000000000010001100000000000000000,4(a0)
*	%0000000000000000010111111100000001010000000000000000000000000000,12(a0)
*	 000000000FFFFFFATrRiiiiiiiIIIIIIIIIIWWWWWWWWWWPPPdddXXXXXXXXXXXX
*	%fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210
*	%3333333333333333222222222222222211111111111111110000000000000000

	cnop	0,8
.no_see:	dcb.b	8,-1
.see:		dcb.b	8,-0