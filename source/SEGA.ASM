WATERPAL:
*	INCLUDE MATTES\W4WPAL.s


;===========================
;
; place joysticks in JOY1L and JOY2L in snes format
;
; designed specifically for BUBSY-
;
;		A ->	A,B
;		B ->	X,Y
;		C,JL -> L
;		C,JR -> R
;		
;
; converted for the jaguar joy pads via calling joypad_2_sega
;===========================
segajoy:
	jsr	joypad_2_sega
	MOVEM.L	A0-A1/D0-D4,-(A7)	

	move.b	sega_pad_1,d0	;SACBRLDU
	move.b	sega_pad_2,d1
	
	rol.b	#3,d0		;xxxxxxxx BRLDUSAC x
	asl.w	#1,d0		;xxxxxxxB RLDUSAC0 x
	ror.b	#3,d0		;xxxxxxxB AC0RLDUS x
	asl.w	#1,d0		;xxxxxxBA C0RLDUS0 x
	ror.b	#2,d0		;xxxxxxBA S0C0RLDU x
	lsr.b	#1,d0		;xxxxxxBA 0S0C0RLD U
	roxl.w	#2,d0		;xxxxBA0S 0C0RLDUx x
	ror.b	#2,d0		;xxxxBA0S Ux0C0RLD x
	asl.w	#1,d0		;xxxBA0SU x0C0RLD0 x
	ror.b	#2,d0		;xxxBA0SU D0x0C0RL x
	asl.w	#1,d0		;xxBA0SUD 0x0C0RL0 x
	ror.b	#2,d0		;xxBA0SUD L00x0C0R x
	asl.w	#1,d0		;xBA0SUDL 00x0C0R0 x
	ror.b	#2,d0		;xBA0SUDL R000x0C0 x
	asl.w	#1,d0		;BA0SUDLR 000x0C00 x
	btst	#2,d0		;if C set
	beq.s	.no0c
	move.w	d0,d2		;move current to mask
	lsr.w	#4,d2		;0000ABSS UDLR000x x
	and.b	#$30,d2		;00000000 00LR0000 x
	or.w	#$2000,d0
	and.w	#$fcff,d0
	or.b	d2,d0
.no0c:

	rol.b	#3,d1		;xxxxxxxx BRLDUSAC x
	asl.w	#1,d1		;xxxxxxxB RLDUSAC0 x
	ror.b	#3,d1		;xxxxxxxB AC0RLDUS x
	asl.w	#1,d1		;xxxxxxBA C0RLDUS0 x
	ror.b	#2,d1		;xxxxxxBA S0C0RLDU x
	lsr.b	#1,d1		;xxxxxxBA 0S0C0RLD U
	roxl.w	#2,d1		;xxxxBA0S 0C0RLDUx x
	ror.b	#2,d1		;xxxxBA0S Ux0C0RLD x
	asl.w	#1,d1		;xxxBA0SU x0C0RLD0 x
	ror.b	#2,d1		;xxxBA0SU D0x0C0RL x
	asl.w	#1,d1		;xxBA0SUD 0x0C0RL0 x
	ror.b	#2,d1		;xxBA0SUD L00x0C0R x
	asl.w	#1,d1		;xBA0SUDL 00x0C0R0 x
	ror.b	#2,d1		;xBA0SUDL R000x0C0 x
	asl.w	#1,d1		;BA0SUDLR 000x0C00 x
	btst	#2,d1		;if C set
	beq.s	.no1c
	move.w	d1,d2		;move current to mask
	lsr.w	#4,d2		;0000ABSS UDLR000x x
	and.b	#$30,d2		;00000000 00LR0000 x
	or.w	#$2000,d1
	and.w	#$fcff,d1
	or.b	d2,d1
.no1c:

	move.w	d1,JOY2L
	move.w	d0,JOY1L

	MOVEM.L	(A7)+,A0-A1/D0-D4	
	RTS
