BRA_VCEQ	Equ	%00
BRA_VCGT	Equ	%01
BRA_VCLT	Equ	%10
BRA_GPU		Equ	%11

Setup_Initial_Branch:
	Move.l	#Master_Stop_Object,d0
	And.b	#-8,d0
	Move.l	d0,a1
	Pea	(a1)
	Move.l	#0,(a1)+
	Move.l	#4,(a1)+
; a1 now points to first branch object
	Move.l	a1,Dont_Know_What_This_Does_Pointer
	Move.l	a1,a0				; Setup pointer to branch
	Move.l	(sp),a1				; Setup destination (if branch taken!)
	Moveq	#BRA_VCLT,d0			; Condition
OVER9:
	Move.w	#ntsc_n_vde,d1			; Line number ( halflines !)
	Bsr.s	Make_Branch_Object
	Move.l	(sp)+,a1			; Setup destination (if branch taken!)
	Moveq	#BRA_VCGT,d0			; Condition
	Move.w	#ntsc_n_vdb,d1			; Line number ( halflines !)
	Bsr.s	Make_Branch_Object
	Rts

Make_Branch_Object:
	Moveq	#0,d6
	Moveq	#3,d7				; 64 bits ( branch object, type 3)
	Lsl.w	#3,d1
	Or.w	d1,d7				; Set y-pos
	Moveq	#14,d5
	Lsl.w	d5,d0				; Condition
	Or.w	d0,d7				; Set conidition
	Move.l	a1,d5
	Lsr.l	#3,d5				; Branch is in phrases
	Move.l	d5,d4
	And.l	#%11111111,d5
	Ror.l	#8,d5
	Or.l	d5,d7
	Lsr.l	#8,d4
	Move.l	d4,d6
	Move.l	d6,(a0)+
	Move.l	d7,(a0)+
	Rts

Dont_Know_What_This_Does_Pointer:
	Dcb.l	1,0
	Dcb.b	8,0
Master_Stop_Object:
	Dcb.b	32,0
