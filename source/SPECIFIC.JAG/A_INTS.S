RESET_EEPROM_TIME	equ	60*5

	.phrase
	
null_ol:	dc.l	0,4

waitvbls:
	jsr	WVBL
	dbf	d0,waitvbls
	rts

reset_vbl:
	move.l	d0,-(sp)
	move.l	#null_ol,d0
	swap	d0
	move.l	d0,OLP
	move.l	(sp)+,d0
	move.w	d0,-(sp)
	move.w	INT1,d0
	bra.s	quick_exit_vbl
	
hum_70_vbl:
	move.w	d0,-(sp)
	move.w	INT1,d0

.no_sound:
	btst	#0,d0		; if vbl occur give it priority
	bne.s	the_vbl

quick_exit_vbl:
	lsl.w	#8,d0
	move.b	#1,d0
	move.w	d0,INT1		; allow new interrupts
	move.w	d0,INT2
	move.w	(sp)+,d0	; restore stack
	rte

the_vbl:	
	if	DEBUG
	move.l	#$ffff0000,BORD1
	endif
	movem.l	d0-a6,-(sp)		;save for later
	
	move.w	d0,-(sp)		;save the INT value
	
	move.l	#null_ol,d0
	swap	d0
	move.l	d0,OLP
	
	addq	#1,clock
	
	jsr	MAKE_OL			; make the ol
	
	tst.b	NEW_PALETTE
	beq	.no_new_palette
	sf	NEW_PALETTE
	lea	CLUT,a0			; now set up the palette quickly
	lea	view_pal,a1
	movem.l	(a1)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,(a0)

acid	set	1
	rept	8
	movem.l	(a1)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,acid*4*13(a0)
acid	set	acid+1
	endr
	movem.l	(a1)+,d0-d7/a2-a4
	movem.l	d0-d7/a2-a4,acid*4*13(a0)

.no_new_palette:
	bsr	house_work		; check star hash and 0
	
	move.w	(sp)+,d0
	lsl.w	#8,d0
	move.b	#1,d0
	move.w	d0,INT1
	move.w	d0,INT2			; allow other interrupts
	
	move.l	vbl_routine,a0
	jsr	(a0)			; call the VBL routine
	addq.l	#1,vclock		; update the clock

exit_vbl:
	if	DEBUG
	move.l	#$00ffffff,BORD1
	endif

	jsr	play_my_music

	movem.l	(sp)+,d0-a6		;restore registers
	move.w	(sp)+,d0		;restore stack and quit gracefully
	if	DEBUG
	move.l	#00000000,BORD1
	endif
	rte

play_my_music:
	tst.b	mus
	beq.s	no_sound1		; see if we have a sound interrupt
	
pal_mus_start:
	move.w	sound_me,d0
	dbf	d0,ok
	moveq	#5,d0
	bra	no_sound
pal_mus_end:

ok:
	jsr	NT_VBL			; oh yes we do
no_sound:
	move.w	d0,sound_me
no_sound1:
	rts

house_work:
	bsr	read_joypad
	bsr	star_hash
	jsr	segajoy
	bsr	sound_flip
a_vbl:
	rts

star_hash:
	jsr	Hash_Asterisk_Pressed1	;check pad 1
	bne.s	.both_down
	jsr	Hash_Asterisk_Pressed2	;and pad 2
	beq.s	.no_way
.both_down:
	tst.b	writing_eeprom
	bne.s	.no_way
	tst.b	disable_reset		;allowed to reset
	beq.s	.shit_he_is_serious
.no_reset_available:
	tst.w	reset_eeprom_timer
	bne	.no_way
	move.l	joycur1,d0
	or.l	joycur2,d0
	and.l	#1<<OPTIONS,d0
	sne	allow_eeprom_reset
	beq.s	.shit_he_is_serious			;if options is not pressed then fuck you arse wipe
	move.w	#RESET_EEPROM_TIME,reset_eeprom_timer
.no_way:
	rts
.shit_he_is_serious:
	move.l	#reset_vbl,LEVEL2.w	; null OL
	jsr	NEW_OL
	jsr	NEW_OL
	JSR	MAKE_OL			; ensure nothing is seen
	jsr	STOP_MOD
	jsr	DISABLE_
	st	disable_reset		; no more resets just yet
	addq.l	#8,sp
	move.w	(sp)+,d0
	lsl.w	#8,d0
	move.b	#1,d0
	move.w	d0,INT1
	move.w	d0,INT2			; reset the proper interrupt vectors
	lea	2+4*(8+7)(sp),sp
	move.l	#restart_program,2(sp)	; quit back to start
	rte
clear_that_eeprom:	
	sf	allow_eeprom_reset
	jsr	restore_eeprom
;	jsr	write_hi_score_to_eprom
	rts
sound_flip:
	move.l	joyedge1,d0						;see if 0 on pad 1 or pressed
	or.l	joyedge2,d0
	btst	#KEY_0,d0
	beq.s	.quit
.ok1:
	tst.b	musloaded						;have we loaded in the music yet
	beq.s	.quit
.soundonoff:
	moveq	#0,d0
	move.b	save_mod_level,d0					;get the alternative music level
	move.b	vol_mod,save_mod_level
	move.b	d0,vol_mod						;swap the 2 values over
	eor.b	#1,mustype						;change the state of the music
	cmp.b	#-1,d0							;if mustype is == -1
	beq.s	.cont							;then stop the mod
	jsr	START_MO
	moveq	#0,d1
	move.b	volume_table(pc,d0.w),d0				;with this volume setting
	jsr	SET_VOLU
	bra.s	.quit
.cont:
	jsr	STOP_MOD						;stop the mod dead in its track !!
.quit:
	tst.b	save_mod_level
	beq.s	.minus
	bpl.s	.posi
.minus:
	st	save_mod_level	
.posi:
	rts	

reset_eeprom_timer:	dc.w	0
sfxadd:				dc.l	0
vclock:				dc.l	0
vbl_routine:		dc.l	0
sound_me:			dc.w	5
volume_table:		dc.b	$00,$0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff
MAX_SLIDER_VALUE	equ	*-volume_table-1

disable_reset:		dc.b	0
paused_view:		dc.b	0
allow_eeprom_reset:	dc.b	0
save_mod_level:		dc.b	0
mustype:			dc.b	0
vol_sfx:			dc.b	0
vol_mod:			dc.b	0
NEW_PALETTE:		dc.b	0
		even
