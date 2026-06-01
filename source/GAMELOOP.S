GAMELOOP:
	tst.w	STIMER
	beq.s	.no_set_pause
	st	PAUSE_ENABLED

.no_set_pause:
	sf	NMIVECSEL
	
.L10:
	move.w	GFRAMES,d1				;super slow on start, wait for specific # of VBLS for GFRAMEs
	addq.w	#1,d1

	move.w	NUMVBLS,d0
	sub.w	OLDVBLS,d0
	cmp.w	d1,d0
	Blt.s	.L10

	move.w	NUMVBLS,OLDVBLS

	bsr	GETINPUT				;read contzollers

	MOVE.l	STICK1,STICK				;get values depending upon whos in charge
	tst.w	PLAYER
	beq.s	.PL0
	cmp.w	#1,PLAYERS				;not 1 then use pad 1
	bne.s	.PL0
	MOVE.l	STICK2,STICK

.PL0:
	ADDQ.w	#1,STIMER				;increment software timer
	jsr	HANDLE_PAUSE

.GAME:	
	if	DETECTMODE
	jsr	CLS_DETECTSCREEN
	endif
	
	jsr	gravity_control

	move.w	WINDY,WINDYOLD				;load windyold ( obviously )
	move.w	WINDX,WINDXOLD				;load windxold (obviously )
	
	JSR	TRACKWIND				;have the window track bubsy
	jsr	center_window
	JSR	BUBCTRL
	
	move.l	LVLCODEVEC,a0
	jsr	(a0)					;execute
	
	jsr	NEW_OL
	
	moveq	#OVERLOFF,D0
	and.B	VBLANKFLAG,D0
	bne.s	.not_on
	if	DEBUG
	move.l	#$00008080,BORD1
	endif
	jsr	scroll_lands
	jsr	add_backdrop
	jsr	view_2_landscapes_a

.not_on:	
	andi.b	#%00111111,GAMEFLAG0
	andi.b	#~BUBSYBOUNCE,BUBSYFLAGS1		;clear flag for bubsy bopping

	moveq	#BOSSFLAG,d0
	and.b	GAMEFLAG1,d0
	bne.s	.boss_active
	if	SCRIPTMODE
	JSR	DOSCRIPT				;process the script
	endif
	
.boss_active:	
;	move.w	WINDY,WINDYOLD				;load windyold ( obviously )
;	move.w	WINDX,WINDXOLD				;load windxold (obviously )

.NORMPROC:
	cmp.l	#ENTERANIMATION,ANIMSCRPTR
	bne.s	.high_priority
	jsr	SETUPBUBSY
	
.high_priority:
	move.l	#NO_ROUTINE,ROUTINE_ADDR

	if	SCRIPTMODE
	JSR	DOOBJAI					;set up enemy objects
	endif
	
	move.b	BUBSYFLAGS1,d0				;did we bop something during object AI.
	andi.b	#BUBSYBOUNCE,d0
	beq.s	.DOSETUPBUB

	move.w	BUBVY,d0
	neg.w	d0
	beq.s	.SMALLVY
	cmpi.w	#-$800,d0
	bcc.s	.STORENEWVY
	move.w	#-$800,d0
	bra.s	.STORENEWVY

.SMALLVY:
	move.w	#-$100,d0

.STORENEWVY:
	move.w	d0,BUBVY

.DOSETUPBUB:
	if	DEBUG
	move.l	#-8,bad_routine
	endif

	cmp.l	#ENTERANIMATION,ANIMSCRPTR
	beq.s	.low_priority
	jsr	SETUPBUBSY

.low_priority:	
.ENDNOTNORM:						;w4 keep bubsys feet behind raft
.NOTONRAFT:
	if	DEBUG
	move.l	#$00ff0000,BORD1
	endif
	moveq	#OVERLOFF,D0
	and.B	VBLANKFLAG,D0
	Bne.s	.not_on1
	jsr	view_2_landscapes_b

.not_on1:
	tst.b	in_water
	beq.s	.not_in_water
	
	jsr	DO_WATER_BUBBLE

.not_in_water:
	move.l	ROUTINE_ADDR,a0
	move.l	ROUTINE_VAR,a5
	jsr	(a0)

	if	DETECTMODE
	jsr	DRAW_DETECTSCREEN
	endif
	
	if	DEBUG
	move.l	#-9,bad_routine
	endif

	JSR	SETUPOVERLAYS				;set up OAMS and VRAM for TEXT overlays
	if	DEBUG
	move.l	#$0,BORD1
	endif
	jsr	FADER					;do the fader
	
	bra	GAMELOOP

**********************************************************************************************

FIRST_WATER_BABIES_LEVEL	equ	9

gravity_control:
	sf	in_water
	move.w	LEVEL,d0
	sub.w	#FIRST_WATER_BABIES_LEVEL,d0
	bpl.s	.ok
	rts
.ok:
	cmp.w	#2,d0
	ble.s	.ok1
	rts
.ok1:
	asl.w	#2,d0
	move.l	.grav_table(pc,d0.w),a0
	move.w	BUBX,d0
	move.w	BUBY,d1
.loop:
	tst.w	(a0)
	bmi.s	.end_of_list
.box_exists:
	movem.w	(a0)+,d2/d3/d4/d5
	cmp.w	d2,d0
	blt.s	.loop		;not in x
	cmp.w	d3,d1
	blt.s	.loop		;not in y
	cmp.w	d4,d0
	bge.s	.loop		;not in x
	cmp.w	d5,d1
	bge.s	.loop		;not in y
	rts
.end_of_list:
	move.b	BUBSTATE,d0
	cmp.b	#WARP1STATE,d0
	beq.s	.exit
	cmp.b	#WARP2STATE,d0
	beq.s	.exit
	cmp.b	#WARP3STATE,d0
	beq.s	.exit
	cmp.b	#LIMBOSTATE,d0
	beq.s	.exit
	st	in_water
.exit:
	rts	
	
.grav_table:
	dc.l	.water1	
	dc.l	.water2	
	dc.l	.water3
	
;	second	x,y +1
.water1:	
	dc.w	361*16,77*16,371*16,88*16
	dc.w	302*16,82*16,501*16,141*16
	dc.w	290*16,84*16,302*16,141*16
	dc.w	284*16,92*16,290*16,141*16
	dc.w	286*16,91*16,291*16,92*16
	dc.w	289*16,90*16,291*16,92*16
	dc.w	288*16,89*16,291*16,92*16
	dc.w	287*16,90*16,290*16,95*16
	dc.w	$1200,$590,$1250,$620
	dc.w	$1210,$570,$2140,$5c0
	dc.w	-1
.water2:	
	dc.w	406*16,0*16,422*16,15*16
	dc.w	317*16,8*16,501*16,69*16
	dc.w	305*16,21*16,317*16,53*16
	dc.w	-1
.water3:
	dc.w	261*16,00*16,275*16,20*16
	dc.w	168*16,4*16,363*16,30*16
	dc.w	180*16,30*16,363*16,40*16
	dc.w	190*16,40*16,363*16,50*16
	dc.w	200*16,50*16,363*16,59*16
	dc.w	167*16,0*16,168*16,20*16
	dc.w	-1
	
B_TIME	equ	6	
	
in_water:	dc.b	0
anim_pointer:	dc.b	0
BUB_TYPE:	dc.l	0
BUB_TIMER:	dc.w	B_TIME-1
	even
	
DO_WATER_BUBBLE:
	moveq	#0,d0
	move.b	BUBSYFRAME,d0
	lea  	bubble_table,a0
	lsl.w	#2,d0
	lea	(a0,d0.w),a0
	move.w	(a0)+,d4		;this is the animation number
	move.b	(a0)+,d0		;byte offset for x + y anim
	move.b	(a0)+,d1
	ext.w	d0
	ext.w	d1
	add.w	BUBX,d0
	add.w	BUBY,d1
	sub.w	WINDX,d0
	sub.w	WINDY,d1
	
	lea	bubble_anim_table,a0
	lsl.w	#2,d4
	move.l	(a0,d4.w),a0
	cmp.l	BUB_TYPE,a0
	beq.s	.same_anim
	move.l	a0,BUB_TYPE
	sf	anim_pointer

.same_anim:
	moveq	#0,d4
	move.b	anim_pointer,d4
	move.l	BUB_TYPE,a0
	move.b	(a0,d4.w),d4
	cmp.b	#0,d4
	bne.s	.no_loop
	sf	anim_pointer
	bra.s	.same_anim

.no_loop:
	subq.w	#1,d4
	
	subq.w	#1,BUB_TIMER
	bpl.s	.no_add
	move.w	#B_TIME-1,BUB_TIMER
	addq.b	#1,anim_pointer

.no_add:
	move.l	LOAD_BUBBLE_GRAPHICS_ADDR,a0
	moveq	#BUBSYHFLIP,D7
	and.B	BUBSYFLAGS,D7							;see if bubsy is h flipped
	beq.s	.ok
	addq.w	#8,d0
.ok:
	sub.w	#44,d0
	sub.w	#44-3,d1
;d0 == sprite x
;d1 == sprite y
;d4 == sprite number
;a0 == bank addr
	jsr	print_a_sprite_normal
	rts

bubble_anim_table:
	dc.l	.stand
	dc.l	.run
	dc.l	.jump_up
	dc.l	.glide
	
.stand:		dc.b	1,2,3,4,5,6,0	;;1,2,1,6,0
.run:		dc.b	2,0
.jump_up:	dc.b	4,5,0
.glide:		dc.b	2,0

.macro	BBUB o1,o2,o3
	dc.w	\o1
	dc.b	\o2,\o3
	.endm
	even
	
bubble_table:
	rept	1+7
	BBUB	0,$1,$eb
	endr
	
	rept	1+14-8
	BBUB	0,$5,$eb
	endr
	
	rept	1+19-15
	BBUB	0,$2,$e5
	endr
	
	rept	1+24-20
	BBUB	0,$fe,$ec
	endr
	
	rept	1+31-25
	BBUB	0,$5,$ec
	endr

	BBUB	0,$2,$e7-3
	
	rept	1+35-33
	BBUB	0,$2,$f4
	endr
	
	rept	1+40-36
	BBUB	0,$ff,$ec
	endr
	
	rept	1+44-41
	BBUB	0,$fe,$ec
	endr

	BBUB	0,$ff,$e7
	
	rept	1+48-46
	BBUB	0,$5,$ec
	endr
	
	rept	1+60-49
	BBUB	0,$5,$ec
	endr
	
	rept	1+73-61
	BBUB	0,$ff,$ec
	endr
	
	rept	1+80-74
	BBUB	0,$5,$ec
	endr

	rept	1+89-81
	BBUB	0,$fb,$ec
	endr
	
	rept	1+95-90
	BBUB	0,$fb,$ec
	endr
	
	rept	1+107-96
	BBUB	0,$0,$ec
	endr
	
	rept	1+110-108
	BBUB	0,$fb,$ec
	endr
	
	rept	1+115-11
	BBUB	0,$0,$ec
	endr
	
	BBUB	0,$5,$fb
	
	BBUB	0,$5,$ec
	
	BBUB	0,$0,$0
	
	rept	1+133-119
	BBUB	0,$fb,$ec
	endr
	
	BBUB	0,$e,$ec
	
	rept	1+141-135
	BBUB	0,$fb,$ec
	endr
	
	rept	1+147-142
	BBUB	0,$0,$ec
	endr
	
	BBUB	0,$0,$ee
	BBUB	0,$1,$ee
	
	rept	1+153-105
	BBUB	0,$0,$ec
	endr
********************
	
	rept	1+161-154
	BBUB	0,$fb,$ec
	endr
	
	rept	1+166-162
	BBUB	0,$5,$ec
	endr
	
	rept	1+171-163
	BBUB	0,$fb,$ec
	endr
	
**************	
	rept	1+183-172
	BBUB	0,$0,$ec
	endr
	
	rept	1+185-184
	BBUB	0,$fb,$ec
	endr
	
	rept	1+197-186
	BBUB	0,$05,$ec
	endr
	
	rept	1+205-198
	BBUB	0,$0,$ec
	endr
	
	BBUB	0,$fb,$ec

	BBUB	0,$0,$ec
	
	rept	1+210-208
	BBUB	0,$fb,$ec
	endr
	
	rept	1+216-211
	BBUB	0,$2,$ec
	endr
	
	rept	1+220-217
	BBUB	0,$fb,$ec
	endr
	
	rept	1+226-221
	BBUB	0,$0,$ec
	endr
	
	rept	1+240
	BBUB	0,0,0
	endr

	even

NO_ROUTINE:
	rts

ROUTINE_ADDR:	dc.l	NO_ROUTINE
ROUTINE_VAR:	dc.l	NO_ROUTINE