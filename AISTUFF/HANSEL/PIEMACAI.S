;PIEMACHINE - collision on this machine.



PIEMACHINE_THROW_STEPS	equ	15
PIEMACHINE_THROW_TIMER	equ	6
PIEMACHINE_RESET_TIME	equ	10

PIEMACHINE_LAST_FRAME	equ	10
PIEMACHINE_START_FRAME	equ	6

PIE_MACHINE_X_OFFSET	equ	65
PIE_MACHINE_Y_OFFSET	equ	-10

;	wait $20 cycles of animation before starting to throw the pie
;	OBJECT	%0000000000000000,PIEMACHINEAI,piemachine_dma,PIEMACHINEMAP,$20,$00,$00,$00,$00,$00				;RED YARN BOUNCE		03
;	as no collision on pie the the MAP is obselete. ( no use )

PIEMACHINEAI
	jsr	OBJRANGEBIG						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE
	jsr	CLIPY

	tst.b	OBJFLAGS(a5)
	bne.s	.stuck_to_ground
	jsr	STICKOBJECTTOPLAYFIELD
	st	OBJFLAGS(a5)
.stuck_to_ground	
	
	tst.b	OBJAUX7(a5)						;if in throw then skip start up sequence
	bne.s	.throw_now
	
	subq.b	#1,OBJAUX0(a5)						;aux0 = counter to next frame
	bpl.s	.wait_for_next_frame
	move.b	#PIEMACHINE_THROW_TIMER,OBJAUX0(a5)
	
	eor.b	#1,OBJFRAME(A5)
	
	subq.b	#1,OBJAUX1(a5)						;aux1 = number of 'steps' to next throw
	bmi.s	.throw_now
	
.wait_for_next_frame	
	JMP	DRAW_COMPLEX_SPRITE
.last_frame								;after last throw frame then reset back to the start
	
	move.b	#PIEMACHINE_THROW_TIMER,OBJAUX0(a5)
	move.b	#PIEMACHINE_THROW_STEPS,OBJAUX1(a5)
	sf	OBJAUX7(a5)
	sf	OBJFRAME(A5)
	bra.s	.wait_for_next_frame
.throw_now
	st	OBJAUX7(a5)
	subq.b	#1,OBJAUX2(a5)
	bpl.s	.wait_for_next_frame
	move.b	#PIEMACHINE_THROW_TIMER,OBJAUX2(a5)
	addq.b	#1,OBJFRAME(A5)
	cmp.b	#PIEMACHINE_LAST_FRAME,OBJFRAME(a5)
	beq.s	.last_frame
	cmp.b	#PIEMACHINE_START_FRAME,OBJFRAME(a5)
	bne.s	.wait_for_next_frame

	
	move.l	a5,a6
	
	move.w	OBJKEY(A5),d6						; if no free object then reset to start of anim
	add.w	#$0f00,d6						; use the last 2 slots of the flames - not used
	
	jsr	FINDFREEOBJ
	bcs.s	.none_free
	
	move.w	d6,OBJKEY(a5)
	
	move.l	#PIEAI,OBJAI(A5)
	move.l	#pie_dma,OBJINITDMA(a5)
	move.l	#PIEMAP,OBJMAP(A5)
	move.b	OBJOAM0(a6),OBJOAM0(a5)
	
	
	move.w	#PIE_MACHINE_X_OFFSET,d0
	move.w	#PIE_MACHINE_Y_OFFSET,d1
	tst.b	OBJOAM0(a5)
	beq.s	.facing_right
	neg.w	d0
.facing_right
	add.w	OBJX(A6),d0
	add.w	OBJY(A6),d1
	move.w	d0,OBJX(A5)
	move.w	d1,OBJY(A5)
	
.none_free	
	move.l	a6,a5
	jmp	DRAW_COMPLEX_SPRITE
	

PIEMACHINEMAP
	rept	12
	dcb.b	32,0
	endr

piemach0	macro
	dc.w	0,77-127,123
	endm
piemach1	macro
	dc.w	0,76-127,124
	endm


piemachine_dma
	dc.l	.frame0
	dc.l	.frame1
	
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4
	dc.l	.frame5
	dc.l	.frame6
	dc.l	.frame7
	dc.l	.frame8
	dc.l	.frame9
	dc.l	.frame10
	
	
	
	
	
	
.frame0	dc.w	2,-77,0,154
	piemach0
	dc.w	-1,89-127-2,134
	
.frame1	dc.w	2,-77,0,154
	piemach1
	dc.w	-1,89-127-1-2,134
	
.frame2	dc.w	2,-77,0,154
	piemach1
	dc.w	102-97,77-127-4,135

.frame3	dc.w	2,-77,0,154
	piemach0
	dc.w	121-97+1,67-127-2,136

	
.frame4	dc.w	2,-77,0,154
	piemach1
	dc.w	138-97,75-127,125

.frame5	dc.w	2,-77,0,154
	piemach0
	dc.w	168-97,60-127,128

.frame6	dc.w	2,-77,0,154
	piemach1
	dc.w	168-97,95-127,129

.frame7	dc.w	2,-77,0,154
	piemach0
	dc.w	168-97,67-127,130

.frame8	dc.w	2,-77,0,154
	piemach1
	dc.w	153-97,61-127,131

.frame9	dc.w	2,-77,0,154
	piemach0
	dc.w	123-97,71-127,132
.frame10
	dc.w	2,-77,0,154
	piemach1
	dc.w	112-97,76-127,133

