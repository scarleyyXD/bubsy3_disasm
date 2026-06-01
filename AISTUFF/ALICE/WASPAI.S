AWASP_FRAME		equ	105

AWASPAI
	jsr	OBJRANGEBIG
	bcc.s	.inx
	jmp	CLEAROBJWVRAM
.inx	jsr	CLIPY

	WASP_KILL_BUBSY_EH
	
	sf	OBJOAM0(a5)
	move.w	OBJX(A5),d0
	cmp.w	BUBX,d0
	blt.s	.move_right
	move.b	#$08,OBJOAM0(a5)
.move_right	
	not.b	OBJAUX0(a5)
	bne.s	.ok
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.ok
	move.b	#2,OBJFRAME(A5)
.ok	

	move.l	#$00010000,d1				;if bubsy is within a specific range then go for the kill
	move.l	BUBY,d0					;else move the wasp into a striking range
	sub.l	OBJY(a5),d0
	bpl.s	.oky
	neg.l	d0
	neg.l	d1
.oky	cmp.w	#WASP_KILLY,d0
	bgt.s	.just_draw

	move.l	#AWASPATTACK_AI,OBJAI(a5)
	move.l	#WASPATTACKMAP,OBJMAP(a5)
	move.l	#awaspattack_dma,OBJINITDMA(a5)
	sf	OBJAUX0(a5)
	move.b	#1,OBJAUX1(a5)
	jmp	DRAW_COMPLEX_SPRITE
.just_draw
	cmp.l	d1,d0
	beq.s	.just_draw1
.jd	move.l	d1,TEMP5
	
	moveq	#WASP_Y_CHECK,d2
	tst.w	TEMP5
	bpl.s	.ok2
	neg.w	d2
.ok2
	add.w	OBJY(a5),d2
	move.w	OBJX(a5),d1
	jsr	GETATTRIB
	and.w	#~ATTR_MASK,d0
	bne.s	.just_draw1
	move.l	TEMP5,d0
	add.l	d0,OBJY(a5)
.just_draw1
		jmp	DRAW_COMPLEX_SPRITE
	



AWASPATTACK_AI
	jsr	OBJRANGEBIG
	bcc.s	.inx
	jmp	CLEAROBJWVRAM
.inx	jsr	CLIPY

	WASP_KILL_BUBSY_EH
	
	moveq	#0,d0
	move.b	OBJAUX1(a5),d0			;get increment in velocity
	add.b	OBJAUX0(a5),d0			;update velocity
	bmi	.change_ai
.ok	cmp.b	#MAX_W_VX,d0
	blt.s	.okvx
	moveq	#MAX_W_VX,d0
.okvx	move.b	d0,OBJAUX0(a5)
	tst.b	OBJOAM0(a5)
	beq.s	.moving_right
	neg.w	d0
.moving_right
	asr.w	#WASP_FACTOR,d0
	
	move.w	OBJX(a5),TEMP1
	add.w	d0,OBJX(a5)			;add to x position
	move.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	jsr	GETATTRIB
	and.w	#~ATTR_MASK,d0
	beq.s	.no_wall
	move.w	TEMP1,OBJX(A5)
.no_wall	

	move.l	#$00010000,d0			;fraction === 1.25
	moveq	#-48/2,d1
	add.w	BUBY,d1
	cmp.w	OBJY(a5),d1
	beq.s	.no_change
	bgt.s	.move_down			;if wasp below bubsy then move wasp up screen (-ive)
	neg.l	d0
.move_down	

	move.l	d0,TEMP5
	moveq	#WASP_Y_CHECK,d2
	tst.w	TEMP5
	bpl.s	.ok2
	neg.w	d2
.ok2
	add.w	OBJY(a5),d2
	move.w	OBJX(a5),d1
	jsr	GETATTRIB
	and.w	#~ATTR_MASK,d0
	bne.s	.just_draw1
	move.l	TEMP5,d0
	add.l	d0,OBJY(a5)
.just_draw1

.no_change					;if wasp y == bub y then no change in the wasp's y
	tst.b	OBJAUX1(a5)
	bmi.s	.same_way
	tst.b	OBJOAM0(a5)
	beq.s	.going_right
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bra.s	.cont
.change_ai
	move.l	#AWASPAI,OBJAI(a5)		;if VX = 0 then we are stationary. change AI to home in on BUBS..
	move.l	#WASPMAP,OBJMAP(a5)
	move.l	#awasp_dma,OBJINITDMA(a5)
	jmp	DRAW_COMPLEX_SPRITE
.going_right
	move.w	OBJX(a5),d0
	sub.w	BUBX,d0
.cont	bmi.s	.same_way
	neg.b	OBJAUX1(a5)			;make the wasp slow down - negate the velocity
.same_way
.animate
	not.b	OBJAUX2(a5)
	bne.s	.draw
	subq.b	#1,OBJFRAME(A5)
	bpl.s	.draw
	move.b	#2,OBJFRAME(A5)
.draw	jmp	DRAW_COMPLEX_SPRITE
	
	
awaspattack_dma
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2

.frame0	dc.w	2,-24,-23,48
	dc.w	0,0,32-32+AWASP_FRAME
	dc.w	-28,0,33-32+AWASP_FRAME

.frame1	dc.w	2,-24,-23,48
	dc.w	0,0,32-32+AWASP_FRAME
	dc.w	-24,11,34-32+AWASP_FRAME

.frame2	dc.w	2,-24,-23,48
	dc.w	0,0,32-32+AWASP_FRAME
	dc.w	-26,11,35-32+AWASP_FRAME


awasp_dma
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2


.frame0	dc.w	3,-35,-9,70
	dc.w	0,0,36-32+AWASP_FRAME
	dc.w	55,1,37-32+AWASP_FRAME
	dc.w	36,4,38-32+AWASP_FRAME

.frame1	dc.w	3,-35,-9,70
	dc.w	0,0,36-32+AWASP_FRAME
	dc.w	55,1,37-32+AWASP_FRAME
	dc.w	36,4-21,39-32+AWASP_FRAME

.frame2	dc.w	3,-35,-9,70
	dc.w	0,0,36-32+AWASP_FRAME
	dc.w	55,1,37-32+AWASP_FRAME
	dc.w	36,4,40-32+AWASP_FRAME
