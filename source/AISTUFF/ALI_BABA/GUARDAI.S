
; The guard can be either looking out for Bubsy else he is asleep
;	 if asleep he wakes up and his eyes pop out
; then he charges at BUBSY
; and tries to cut him in two

; if the guard reaches a slope of wall then he will change direction..


;different types of objects for wake and asleep
;format for object is
;	0				.w	oam - not bothered about flip - its done
;	AI_ROUTINE			.l	ai
;	DMA				.l	initial dma
;	map for sprite structure	.l	map
;	last frame in animation		.b	aux0
;	0				.b	aux1
;	0				.b	aux2 - not used set to 0 
;	0				.b	aux3 - set to 0 for 1st frame counter
;	0				.b	flags - not used set to 0
;	first sprite in animation	.b	aux4

;	OBJECT	%0000000000000000,GUARDSLEEPAI,guard_dma,GUARD_MAP,$01,$00,$00,$00,$03,$00			;guard sleep
;	OBJECT	%0000000000000000,GUARDPEERAI,guard_dma,GUARD_MAP,$07,$00,$00,$00,$03,$15			;guard peer

*****************************************************************************************

GUARD_RANGE		equ	160			;look ahead distance for guard detect Bubsy
GUARD_RANGE_KILLX	equ	80			;distance guard must be for him to kill Bubsy
GUARD_RANGE_KILLY	equ	16

GUARD_CHARGE_ME		equ	2			;first frame of guard charging
GUARD_LOOK_FRAMES	equ	$11

GUARDKIILLFRAME		equ	$a			;first frame of guard killing bubsy

GUARD_CHARGE_FRAMES	equ	7
GUARD_KILL_FRAMES	equ	6

GUARD_SHAKEGROUND_FRAME	equ	2

GUARD_DX		equ	8			;speed at which guard charges
LAND_FLAT_DX_GUARD	equ	40			

GUARD_RUN_SPEED		equ	3			;frame rates for moves
GUARD_LOOK_SPEED	equ	12
GUARD_SLEEP_SPEED	equ	20
GUARD_PEER_SPEED	equ	30
GUARD_PEER_START1	equ	23
GUARD_PEER_START2	equ	0

GUARD_SWIPE_SPEED	equ	7

*****************************************************************************************

.macro	GUARD_KILL_BUBSY_EH
	move.w	#$0901,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#SPLITSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	endm

.macro	GUARD_KILL_BUBSY_EH_POP
	move.w	#$0901,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP_BIG
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	endm

.macro	Grun o1
	if \o1=-1
	;	01,02,03,04,05,06,07,08,09,10,11,12,13,14
	Soff	00,00,00,00,00,00,00,00,00,00,00,00,00,00
	endif
	if \o1=2
	Soff	50+22-4,00,27,50,48,49,55,33,46,19,41,04,06,44
	endif
	if \o1=3
	Soff	50+20-6,04,27,50,48,49,55,33,46,19,50,06,06,48
	endif
	if \o1=4
	Soff	50+20-4,04,27,50,48,49,55,33,46,19,47,09,06,48
	endif
	if \o1=5
	Soff	50+18-3,04,27,50,48,49,55,33,46,19,48,-1,06,48
	endif
	if \o1=6
	Soff	50+22-4,00,27,50,48,49,55,33,46,19,41,04,06,44
	endif
	if \o1=7
	Soff	50+20-5,04,27,50,48,49,55,33,46,19,50,06,06,48
	endif
	if \o1=0
	Soff	50+18,04,27,50,48,49,55,33,46,19,47,08,06,48
	endif
	if \o1=1
	Soff	50+20-4,04,27,50,48,49,55,33,46,19,48,-1,06,48
	endif
	.endm

.macro	Gframe o1
	if \o1=-1
	;	01,02,03,04,05,06,07,08,09,10,11,12,13,14
	Soff	00,00,00,00,00,00,00,00,00,00,00,00,00,00
	endif
	if \o1=0
	Soff	25,00,09,06,46,05,46,23,06,29,33,36,06,50
	endif
	if \o1=1
	Soff	00,00,07,08,48,07,48,21,07,30,37,37,07,50
	endif
	if \o1=2
	Soff	-1,00,50,01,67,04,58,29,27,30,38,36,52,41
	endif
	if \o1=3
	Soff	00,-4,50,06,33,21,04,23,39,30,21,36,35,42
	endif
	if \o1=4
	Soff	01,00,29,03,40,19,40,30,17,34,39,45,26,61
	endif
	if \o1=5
	Soff	00,04,46,08,02,29,56,35,05,43,14,48,45,52
	endif
	if \o1=6
	Soff	01,00,38,03,48,21,20,30,48,32,47,49,37,61
	endif
	if \o1=7
	Soff	00,00,69,02,77,16,80,32,41,38,21,51,69,58
	endif
	if \o1=8
	Soff	01,00,70,06,77,23,62,33,12,35,40,38,53,40 
	endif
	if \o1=9
	Soff	01,00,07,08,48,07,48,21,07,30,30,37,07,50
	endif
	if \o1=10
	Soff	10,01,00,02,38,00,08,25,18,40,36,26,25,57
	endif
	.endm

*****************************************************************************************
GUARDPEERAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y

	GUARD_KILL_BUBSY_EH_POP

	jsr	STICKOBJECTTOPLAYFIELD
	
	moveq	#DEADFLAG,d0
	and.b	BUBSYFLAGS,d0
	bne.s	.animate
	
	moveq	#ANCHORFLAG,d0			;guard only detects if bubsy is on the ground
	and.b	BUBSYFLAGS,d0
	beq.s	.animate
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below:
	cmp.w	#GUARD_RANGE_KILLY,d0		;allow bubsy to creep up on guard
	bgt.s	.animate			;dy too great
	
	move.w	OBJX(a5),d0			;and within area
	sub.w	BUBX,d0
	bpl.s	.ive
	neg.w	d0
.ive:
	cmp.w	#GUARD_RANGE,d0
	ble	GUARDCHARGEINITAI		;go and kill bubsy..
.animate:
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#GUARD_PEER_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw
.increment:
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	OBJAUX0(a5),d0
	ble.s	.no_wrap
	moveq	#0,d0
.no_wrap:
	moveq	#GUARD_PEER_START1,d3
	cmp.b	#0,d0
	beq.s	.head1
	cmp.b	#4,d0
	bne.s	.ok
.head1:
	moveq	#GUARD_PEER_START2,d3
.ok:
	move.b	d3,OBJAUX3(a5)
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bra	DRAW_COMPLEX_SPRITE
	
*****************************************************************************************

GUARDSLEEPAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	GUARD_KILL_BUBSY_EH_POP
	
	jsr	STICKOBJECTTOPLAYFIELD
	
	moveq	#ANCHORFLAG,d0			;guard only detects if bubsy is on the ground
	and.b	BUBSYFLAGS,d0
	beq.s	.animate
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below:
	cmp.w	#GUARD_RANGE_KILLY,d0		;allow bubsy to creep up on guard
	bgt.s	.animate
	
	moveq	#0,d1
	move.w	OBJX(a5),d0			;and within area
	sub.w	BUBX,d0
	bpl.s	.ive
	neg.w	d0
	moveq	#2,d1				; d1 indicates which side bubsy is on  0<- ->2
.ive:
	cmp.w	#GUARD_RANGE,d0
	ble.s	make_guard_look
.animate:
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#GUARD_SLEEP_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	cmp.b	OBJAUX0(a5),d0
	ble.s	.no_wrap
	moveq	#0,d0
.no_wrap:
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bra	DRAW_COMPLEX_SPRITE
	
make_guard_look:
	move.l	#GUARDLOOKAI,OBJAI(a5)		;set up pointer for next sequence
	sf	OBJAUX1(a5)			;reset animation
	sf	OBJAUX3(a5)			;reset timer
	add.b	#GUARD_LOOK_FRAMES,d1
	move.b	d1,OBJAUX4(a5)			;indicate which way bubsy appears

*****************************************************************************************

GUARDLOOKAI:
	jsr	OBJRANGE			;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	jsr	CLIPY				; in range y
	
	GUARD_KILL_BUBSY_EH_POP
	
	jsr	STICKOBJECTTOPLAYFIELD
	
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#GUARD_LOOK_SPEED,d0
	bne.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw
.increment:
	sf	OBJAUX3(a5)

	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	
	cmp.b	OBJAUX0(a5),d0
	ble.s	.no_wrap
	moveq	#0,d0
	subq.b	#1,OBJFLAGS(a5)
	beq.s	GUARDCHARGEINITAI
.no_wrap:
	move.b	d0,OBJAUX1(a5)
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
.just_draw:
	bsr	DRAW_COMPLEX_SPRITE
	rts
*****************************************************************************************

GUARDCHARGEINITAI:
	move.l	#GUARDCHARGEAI,OBJAI(a5)
	move.b	#GUARD_CHARGE_FRAMES,OBJAUX0(a5)		;number of frames
	st	OBJAUX1(a5)					;first frame
	move.b	#GUARD_RUN_SPEED-1,OBJAUX3(a5)			;ensure get frame and that the 1st one will be 0 not 1
	move.b	#GUARD_CHARGE_ME,OBJAUX4(a5)
	move.w	BUBX,d2						;get distance
	sub.w	OBJX(a5),d2
	bpl.s	.WALKON
	neg.w	d2
	ori.b	#%00001000,OBJOAM0(a5)				;make guard walk to left
	bra.s	.WALKON
.WALKRIGHT:
	andi.b	#%11110111,OBJOAM0(a5)				;make guard walk to the right
.WALKON:

*****************************************************************************************

GUARDCHARGEAI:
	jsr	OBJRANGEBIG						;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:

	GUARD_KILL_BUBSY_EH_POP

	moveq	#0,d0							;move the guard first of all
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#GUARD_RUN_SPEED,d0
	beq.s	.INCREMENT
	move.b	d0,OBJAUX3(a5)
	bra	.dontkillbubsy

.INCREMENT:
	move.w	OBJY(a5),d0						;set up y to check if we will walk over the dege
	add.w	#5,d0
	move.w	d0,d2
	sub.w	#10,d0
	move.w	d0,TEMP5						;set up for checking for floor

	moveq	#-GUARD_DX,d1
	moveq	#-GUARD_DX,d6
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	bne.s	.WALKLEFT
	moveq	#GUARD_DX,d6
	moveq	#GUARD_DX,d1
.WALKLEFT:
	add.w	OBJX(a5),d1						;check if we will walk over edge
	move.w	d1,TEMP6
	jsr	GETATTRIB						;x+dx,y+5
	move.w	d0,TEMP7
	move.w	TEMP5,d2
	move.w	TEMP6,d1
	jsr	GETATTRIB						;x+dx,y-5
	or.w	d0,d0
	bne.s	.use_this_one
	or.w	TEMP7,d0
.use_this_one:
	move.w	d0,d7
	and.w	#ATTR_MASK,d0
	bne.s	.CHECKWALL
	and	d0,d0							;0 then it must be nothing
	beq.s	.change_direction
	bra.s	.all_ok

.CHECKWALL:								;check if we will hit a wall
	and.w	#WALL_CTRL,d7
	beq.s	.all_ok
.change_direction:
	bchg.b	#3,OBJOAM0(a5)						;change direction
	bra.s	.no_move
.all_ok:
	add.w	d6,OBJX(a5)						;move the guard by d6
.no_move:
.DONETHIS:
	moveq	#0,d0
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	and.b	#7,d0
	
	move.b	d0,OBJAUX1(a5)						;pointer to frame number
	add.b	OBJAUX4(a5),d0						;offset in complex sprite table
	move.b	d0,OBJFRAME(a5)
	sf	OBJAUX3(a5)
	jsr	STICKOBJECTTOPLAYFIELD

.NOINCREMENT:
	moveq	#DEADFLAG,d0						;then try to kill bubsy -- the axe-man cometh
	and.b	BUBSYFLAGS,d0
	bne.s	.dontkillbubsy						;if bubsy is dead then dont kill kill kill
	
	move.w	BUBY,d0
	sub.w	OBJY(a5),d0
	bpl.s	.below
	neg.w	d0
.below:
	cmp.w	#GUARD_RANGE_KILLY,d0					;allow bubsy to creep up on guard
	bgt.s	.dontkillbubsy
	
	move.w	BUBX,d0
	sub.w	OBJX(a5),d0
	bpl.s	.FACINGLEFT
	neg.w	d0
.FACINGLEFT:
	cmp.w	#GUARD_RANGE_KILLX,d0					;allow bubsy to creep up on guard
	bge.s	.dontkillbubsy
	
	moveq	#LAND_FLAT_DX_GUARD,d1
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	bne.s	.facingleft
	neg	d1
.facingleft:
	add.w	OBJX(a5),d1
	move.w	OBJY(a5),d2
	addq	#1,d2
	jsr	GETOBJECTGRAVITY
	tst.w	d1
	bpl.s	.posgravity
	neg.w	d1
.posgravity:
	cmp.w	#1,d1
	beq.s	GUARDTRYKILLBUBSYINIT
.dontkillbubsy:
	bra	DRAW_COMPLEX_SPRITE

*****************************************************************************************

GUARDTRYKILLBUBSYINIT:
	move.l	#GUARDSWIPESWORDAI,OBJAI(a5)
	move.b	#GUARDKIILLFRAME,OBJAUX4(a5)				;base for the animation
	move.b	#GUARD_KILL_FRAMES,OBJAUX0(a5)
	
	sf	OBJAUX1(a5)						;reset anim pointer

*****************************************************************************************

GUARDSWIPESWORDAI:
	jsr	OBJRANGE							;and in range x
	bcc.s	.INRANGE
	jmp	CLEAROBJWVRAM
.INRANGE:
	GUARD_KILL_BUBSY_EH
	
	moveq	#0,d0
	move.b	OBJAUX3(a5),d0
	addq	#1,d0
	cmp.b	#GUARD_SWIPE_SPEED,d0
	beq.s	.increment
	move.b	d0,OBJAUX3(a5)
	bra	.just_draw
.increment:
	sf	OBJAUX3(a5)
	
	move.b	OBJAUX1(a5),d0
	addq	#1,d0
	move.b	d0,OBJAUX1(a5)
	
	cmp.b	#GUARD_SHAKEGROUND_FRAME,d0
	bne.s	.no_shake
	move.b	#16,shake_me

.no_shake:
	cmp.b	OBJAUX0(a5),d0
	bgt	GUARDCHARGEINITAI					;if done animation then charge- hopefully bubsy will be dead !! AH
	add.b	OBJAUX4(a5),d0
	move.b	d0,OBJFRAME(a5)
	
.just_draw:
	bsr	DRAW_COMPLEX_SPRITE
	rts

*****************************************************************************************
*
*	To draw a complex sprite all the characters must be in the same sprite bank..
*
*****************************************************************************************

DRAW_COMPLEX_SPRITE:
	move.l	OBJINITDMA(a5),a1					;point to table for sprite definitions
	move.l	LOAD_LEVEL_SPRITES_HERE,a0				;point to sprite table 
									;I know its says ali baba but this is the first level we are doing
	moveq	#0,d0
	move.b	OBJFRAME(a5),d0						;get frame number
	lsl.w	#2,d0
	move.l	(a1,d0.w),a1						;point to data structure
	
	move.w	(a1)+,d2						;get number of points
	move.w	(a1)+,d3						;x offset
	move.w	(a1)+,d5						;y offset
	move.w	(a1)+,d6						;width of the big sprite
	bmi.s	.just_draw_right_only					;if minus then draw right only
		
	btst.b	#3,OBJOAM0(a5)						;check if we should walk left ??
	bne.s	.left
.just_draw_right_only:
	lea	print_a_sprite_normal,a2
	move.l	a0,usp
	dbf	d2,.loop
	rts
.loop:
	move.w	(a1)+,d0						;x
	add.w	OBJX(a5),d0						;all sprites are relative to origin
	add.w	d3,d0							;add sprite offsets
	sub.w	WINDX,d0						;position within window
	
	move.w	(a1)+,d1						;y
	add.w	OBJY(a5),d1
	add.w	d5,d1
	sub.w	WINDY,d1
	
	move.w	(a1)+,d4						;sprite number
	
	move.l	usp,a0
	jsr	(a2)
	dbf	d2,.loop						;print all the sprites
	rts

.left:
	move.l	a0,usp
	lea	print_a_sprite_flipped_minus,a2
	dbf	d2,.loop1
	rts
.loop1:
	move.w	d6,d0							;w
	sub.w	(a1)+,d0						;w-x
	add.w	OBJX(a5),d0						;w-x-l 
	add.w	d3,d0							;add sprite offsets
	sub.w	WINDX,d0						;position within window
	
	move.w	(a1)+,d1						;y
	add.w	OBJY(a5),d1
	add.w	d5,d1
	sub.w	WINDY,d1
	
	move.w	(a1)+,d4						;sprite number

	move.l	usp,a0
	jsr	(a2)
	dbf	d2,.loop1						;print all the sprites
	rts

************************************************************************************************
************************************************************************************************
************************************************************************************************

guard_dma:
;sleep frames
	dc.l	.rguard1	;00			;pointer to stuctures
	dc.l	.rguard2	;01

;run frames
	dc.l	.rguarr0	;02
	dc.l	.rguarr1	;03
	dc.l	.rguarr2	;04
	dc.l	.rguarr3	;05
	dc.l	.rguarr4	;06
	dc.l	.rguarr5	;07
	dc.l	.rguarr6	;08
	dc.l	.rguarr7	;09

.kill_frames:	
	dc.l	.rguark0	;0a
	dc.l	.rguark2	;0b
	dc.l	.rguark3	;0c
	dc.l	.rguark6	;0d
	dc.l	.rguark5	;0e
	dc.l	.rguark4	;0f
	dc.l	.rguark1	;10

.look_frames:
	dc.l	.rguardl1	;11
	dc.l	.rguardl2	;12

	dc.l	.rguardl3	;13
	dc.l	.rguardl4	;14

.peering_frames:
	dc.l	.rguardp0	;15
	dc.l	.rguardp1	;16
	dc.l	.rguardp3	;17
	dc.l	.rguardp4	;18
	dc.l	.rguardp2	;19
	dc.l	.rguardp4	;1a
	dc.l	.rguardp3	;1b
	dc.l	.rguardp1	;1c
	
************************************************************************************************


********		guard sleeping 2 frames
**			offset to top left of character
********

.rguard1:
	dc.w	3				;number of sprites per character
	dc.w	0,0,-1
	dc.w	$18-24,$10-56+5,0
	dc.w	0-24,-56+5,2			;x,y,frame number
	dc.w	24-24,-29+5,3			;x and y are relative to OBJX and OBJY
.rguard2:
	dc.w	3				;number of sprites per character
	dc.w	0,0,-1
	dc.w	$18-24,$0f-56+5,1
	dc.w	0-24,-56+5,2			;x,y,frame number
	dc.w	24-24,-29+5,3			;x and y are relative to OBJX and OBJY

************************************************************************************************

********		guard running 8 frames			OK
**			offset at feet of character		OK
********							OK
.rguarr0:
	dc.w	3,0,0,0
	dc.w	-15,-19,35
	dc.w	-16+3-20,-35-19+2,43
	dc.w	-12+3,-19-35,44
.rguarr1:
	dc.w	3,0,0,0
	dc.w	-14,-19,36
	dc.w	-16+2-20,-35-19+2,43
	dc.w	-12+2,-19-35,44
.rguarr2:
	dc.w	3,0,0,0
	dc.w	-10,-15,37
	dc.w	-16+4-20,-35-15+2,43
	dc.w	-12+4,-35-15,44
.rguarr3:
	dc.w	3,0,0,0
	dc.w	-16,-21,38
	dc.w	-16-20,-35-21+2+2,43
	dc.w	-12,-35-21+2,44
.rguarr4:
	dc.w	3,0,0,0
	dc.w	-15,-19,39
	dc.w	-16+2-20,-35-19+2,43
	dc.w	-12+2,-35-19,44
.rguarr5:
	dc.w	3,0,0,0
	dc.w	-15,-19,40
	dc.w	-16+1-20,-35-19+2,43
	dc.w	-12+1,-35-19,44
.rguarr6:
	dc.w	3,0,0,0
	dc.w	-10,-15,41
	dc.w	-16+5-20,-35-15+2,43
	dc.w	-12+5,-35-15,44
.rguarr7:
	dc.w	3,0,0,0
	dc.w	-16,-21,42
	dc.w	-16+1-20,-35-21+2+2,43
	dc.w	-12+1,-35-21+2,44

************************************************************************************************

********
***		Frames for killing bubsy
********

.rguark0:
	dc.w	3
	dc.w	0,0,0
	dc.w	19,-18-4,13
	dc.w	0,-49-4,14
	dc.w	24,-52-4,15
.rguark1:
	dc.w	3
	dc.w	0,0,0
	dc.w	0,-14,16
	dc.w	28,-61,17
	dc.w	15,-35,18
.rguark2:
	dc.w	4
	dc.w	0,0,0
	dc.w	16,-51,19
	dc.w	0,-41,20
	dc.w	26,-12,21
	dc.w	64,-58,22
.rguark3:
	dc.w	3
	dc.w	0,0,0
	dc.w	0,-36,23
	dc.w	20,-41,24
	dc.w	62,-23,25
.rguark4:
	dc.w	3
	dc.w	0,0,0
	dc.w	20,-61,26
	dc.w	0,-14,27
	dc.w	7,-43,28
.rguark5:
	dc.w	3
	dc.w	0,0,0
	dc.w	0,-10,29
	dc.w	0,-32,30
	dc.w	26,-38,31
.rguark6:
	dc.w	3
	dc.w	0,0,0
	dc.w	0,-21,32
	dc.w	17,-13,33
	dc.w	18,-41,34

************************************************************************************************

********							OK
***		Look at bubsy frames				OK
********							OK

.rguardl1:
	dc.w	3
	dc.w	0,0,-1
	dc.w	0,-56+5,5
	dc.w	5,-15+5,6
	dc.w	15,-42+5,9
.rguardl2:
	dc.w	3
	dc.w	0,0,-1
	dc.w	0,-56+5,5
	dc.w	5,-15+5,6
	dc.w	15,-42+5,10
.rguardl3:
	dc.w	3
	dc.w	0,0,-1
	dc.w	0,-56+5,5
	dc.w	5,-15+5,6
	dc.w	15,-42+5,11
.rguardl4:
	dc.w	3
	dc.w	0,0,-1
	dc.w	0,-56+5,5
	dc.w	5,-15+5,6
	dc.w	15,-42+5,12

************************************************************************************************

********
***		Look at bubsy frames
********

.rguardp0:
	dc.w	3
	dc.w	0,0,-1
	dc.w	-10,-20,171
	dc.w	6,-20-65+27,170
	dc.w	-4,-43,165
.rguardp1:
	dc.w	3
	dc.w	0,0,-1
	dc.w	-10,-20,171
	dc.w	6,-20-65+27,170
	dc.w	-3,-43,166
.rguardp2:
	dc.w	3
	dc.w	0,0,-1
	dc.w	-10,-20,171
	dc.w	6,-20-65+27,170
	dc.w	-3,-43,167
.rguardp3:
	dc.w	3
	dc.w	0,0,-1
	dc.w	-10,-20,171
	dc.w	6,-20-65+27,170
	dc.w	-3,-43,168
.rguardp4:
	dc.w	3
	dc.w	0,0,-1
	dc.w	-10,-20,171
	dc.w	6,-20-65+27,170
	dc.w	-3,-43,169

GUARD_MAP:
	Gframe	0		;asleep
	Gframe	0

	Grun	0		;running
	Grun	1
	Grun	2
	Grun	3
	Grun	4
	Grun	5
	Grun	6
	Grun	7

	Gframe	5		;2	0
	Gframe	7		;4	1
	Gframe	8		;5	2
	Gframe	2		;6	3
	Gframe	3		;7	4
	Gframe	4		;8	5
	Gframe	6		;3	6

	Gframe	9		;awaking
	Gframe	9
	Gframe	9
	Gframe	9

	Gframe	10		;peer
	Gframe	10
	Gframe	10
	Gframe	10
	Gframe	10
	Gframe	10
	Gframe	10
	Gframe	10
	Gframe	10
