BRA_VCEQ	equ	%00
BRA_VCGT	equ	%01
BRA_VCLT	equ	%10
BRA_GPU		equ	%11

Setup_Initial_Branch:
	move.l	#Master_Stop_Object,d0
	and.b	#-8,d0
	move.l	d0,a1
	pea	(a1)
	move.l	#0,(a1)+
	move.l	#4,(a1)+
; a1 now points to first branch object
	move.l	a1,Dont_Know_What_This_Does_Pointer
	move.l	a1,a0				; Setup pointer to branch
	move.l	(sp),a1				; Setup destination (if branch taken!)
	moveq	#BRA_VCLT,d0			; Condition
OVER9:
	move.w	#ntsc_n_vde,d1			; Line number ( halflines !)
	bsr.s	Make_Branch_Object
	move.l	(sp)+,a1			; Setup destination (if branch taken!)
	moveq	#BRA_VCGT,d0			; Condition
	move.w	#ntsc_n_vdb,d1			; Line number ( halflines !)
	bsr.s	Make_Branch_Object
	rts

Make_Branch_Object:
	moveq	#0,d6
	moveq	#3,d7				; 64 bits ( branch object, type 3)
	lsl.w	#3,d1
	or.w	d1,d7				; Set y-pos
	moveq	#14,d5
	lsl.w	d5,d0				; Condition
	or.w	d0,d7				; Set conidition
	move.l	a1,d5
	lsr.l	#3,d5				; Branch is in phrases
	move.l	d5,d4
	and.l	#%11111111,d5
	ror.l	#8,d5
	or.l	d5,d7
	lsr.l	#8,d4
	move.l	d4,d6
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	rts

Dont_Know_What_This_Does_Pointer:
	dcb.l	1,0
	dcb.b	8,0
Master_Stop_Object:
	dcb.b	32,0
