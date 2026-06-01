W1L1LOADINIT:
W1L2LOADINIT:
W1L3LOADINIT:
W2L1LOADINIT:
W2L2LOADINIT:
W2L3LOADINIT:
W3L1LOADINIT:
W3L2LOADINIT:
W3L3LOADINIT:
W4L1LOADINIT:
W4L2LOADINIT:
W4L3LOADINIT:
W5L1LOADINIT:
W5L2LOADINIT:
W5L3LOADINIT:
	rts

W1L2LOADCODE:
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	sf	NOT_ALI
	sf	BACK_VH
	sf	jump_through_allowed
	sf	in_alice
	sf	in_jack
	rts

W1L1LOADCODE:
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	move.w	LOADX,d0
	bmi	.MOVE
	cmpi.w	#$0090,d0
	bge.s	.NOMOVE
.MOVE:
	addq.w	#6,d0
	move.w	d0,LOADX
	bra.s	.next
.NOMOVE:
	andi.b	#~ANIMFLAG,BUBSYFLAGS
	move.b	#12,BUBSYFRAME
.next:
	sf	NOT_ALI
	sf	BACK_VH
	sf	jump_through_allowed
	sf	in_alice
	sf	in_jack
	rts

W1L3LOADCODE:
	ori.b	#BUBSYHFLIP,BUBSYFLAGS			; LOOKING UP LEFT AT THE SCORE
	bra.s	W1L1LOADCODE

W2L1LOADCODE:						; CATFIGHTING ONTO SCREEN
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	move.w	LOADX,d0
	bmi	.MOVE
	cmpi.w	#$0090,d0
	bge.s	.NOMOVE
.MOVE:
	addq.w	#6,d0
	move.w	d0,LOADX
	bra.s	W2L2LOADCODE
.NOMOVE:
	andi.b	#~ANIMFLAG,BUBSYFLAGS
	move.b	#12,BUBSYFRAME
	st	BACK_VH
	st	jump_through_allowed
	sf	in_alice
	st	in_jack
	rts

W2L2LOADCODE:
	ori.b	#BUBSYHFLIP,BUBSYFLAGS
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	subq.w	#2,LOADX
	st	BACK_VH
	st	jump_through_allowed
	sf	in_alice
	st	in_jack
	rts

W2L3LOADCODE:
	st	BACK_VH
	st	jump_through_allowed
	sf	in_alice
	st	in_jack
	rts

W3L1LOADCODE:
W3L2LOADCODE:
W3L3LOADCODE:
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	sf	BACK_VH
	sf	jump_through_allowed
	rts

W4L2LOADCODE:
W4L1LOADCODE:
W4L3LOADCODE:
	sf	BACK_VH
	sf	jump_through_allowed
	rts

W5L1LOADCODE:
	st	NOT_ALI
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0

	ori.b	#BUBSYHFLIP,BUBSYFLAGS
	move.b	BUBSYFRAME,d0
	cmpi.b	#5+1,d0
	bge	.NORUN
	subq.w	#2,LOADX
.NORUN:
	sf	BACK_VH
	sf	jump_through_allowed
	st	in_alice
	rts

W5L2LOADCODE:
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	addq.w	#2,LOADX
	st	NOT_ALI
	sf	BACK_VH
	sf	jump_through_allowed
	st	in_alice
	rts

W5L3LOADCODE:
	ori.b	#BUBSYOFFSCREEN,GAMEFLAG0
	subq.w	#3,LOADX
	st	NOT_ALI
	sf	BACK_VH
	sf	jump_through_allowed
	st	in_alice
	rts