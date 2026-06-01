DUM_SWITCH_MASK	equ	%10		;== switch 2 to activate the weight

.macro	DUMWEIGHT_KILL_BUBSY
	move.w	#$0701,d6
	moveq	#SMASH,d7
	jsr	EZNOBOPCOLLIDE
	bcc.s	.not_dead
	moveq	#SMASH,d0
	jsr	STARTSOUND
	moveq	#ACCORDIANSTATE,d0
	jsr	KILLBUBSY
.not_dead:
	.endm

DUMWEIGHTAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	DUMWEIGHT_KILL_BUBSY			;not able to kill this object

	moveq	#DUM_SWITCH_MASK,d0		;check if the switch has been tripped
	and.b	SWITCHES,d0			;if not then just draw the weight
	beq.s	.in_air
	
	move.w	OBJVY(a5),d0			;else drop that puppy from a great height
	addq.w	#1,d0				;and watch it drop on BUBSY's head
	and.w	#$f,d0
	bne.s	.ok
	moveq	#$1f,d0
.ok:
	move.w	d0,OBJVY(a5)
	asr.w	#2,d0
	add.w	d0,OBJY(a5)			;increase falling speed 1 in 4 frames
	
	moveq	#29,d0
	add.w	OBJY(a5),d0
	move.w	OBJX(a5),d1
	move.w	d0,d2
	jsr	GETATTRIB
	and.w	#ATTR_MASK,d0
	beq.s	.in_air
	move.b	#16,shake_me
	move.l	#CRATEEXPLODE,a0
	move.l	#CRATE10002,OBJINITDMA(a5)
	move.l	#CRATEMAP,OBJMAP(a5)
	move.l	a0,OBJAI(a5)
	add.w	#32,OBJY(a5)
	sf	OBJAUX1(a5)
	sf	OBJAUX0(a5)
	rts
.in_air:
	move.w	OBJX(a5),d0
	sub.w	WINDX,d0
	move.w	OBJY(a5),d1
	sub.w	WINDY,d1
	move.l	LOAD_LEVEL_SPRITES_HERE,a0	;point to sprite table 
	move.w	#TON_SPRITE_FREE,d4
	jmp	print_a_sprite_normal
