STARTSOUNDALL:
LOADNPLAYSFX:
STARTSOUND:

; d0 = effect

sfxplay:
	tst.b	vol_sfx
	bne.s	.play		;whether or not to play the samples - quiet mode
	rts
.play:
	movem.l	d0-a6,-(sp)		;save registers

	move.l	sfxadd,a2		;address of sample data
	move.w	(a2)+,d1		;read number of effects
	moveq	#0,d3
	move.b	d0,d3
	add.b	d3,d3
	lea	voc_tab(pc),a6
	move.w	(a6,d3.w),d0		;get voice number
	move.w	sfx_tab(pc,d3.w),d3	;get pitch number
	cmp.w	d1,d0			;effect ok?
	bgt.s	.sfxplay6		;no, illegal number!
	lsl.w	#2,d1
	lea.l	(a2,d1.w),a0		;find address of first effect
	subq.w	#1,d0			;decrement effect
	bmi.s	.sfxplay5		;first effect
.sfxplay4:
	add.l	(a2)+,a0		;add length of effect
	dbra	d0,.sfxplay4		;find address of effect
.sfxplay5:
	move.l	(a2)+,d0		;read length of effect
	moveq	#1,d1			;priority
	move.w	#$3fff,d2		;pan value
	jsr	PLAYFX
.sfxplay6:
	movem.l	(sp)+,d0-a6		;restore registers
	rts

;**	  00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  20,  31,  32,  33,  34,
;35,  36,  37,  38,  39,  4
sfx_tab:
	dc.w	$180,$180,$000,$000,$000,$000,$000,0246,$000,$000,$000,$000,$000,$000,$000,0186,0206,0226,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,0512
	dc.w	$000,$000,$000,$000,$000,$000,$000
voc_tab:
	dc.w	$000,$000,$100,$001,$002,$002,$002,$005,$003,$100,$004,$100,$100,$100,$005,$005,$005,$005,$00A,$006,$006,$007,$008,$009,$100,$00A,$00A,$00B,$100,$100,$00C,$00C
	dc.w	$00D,$00F,$010,$011,$100,$012,$013

LEVELSPEECH:
	movem.l	d0-a6,-(sp)
	
	move.w	LEVEL,d0
	lsl.w	#2,d0
	lea	SPEECHTABLE,a0
	move.l	0(a0,d0.w),a0
	lea	level_speech,a1
	jsr	file_load
	
	move.w	LEVEL,d0
	lsl.w	#2,d0
	lea	SPEECH_LENGTH,a0
	move.l	0(a0,d0.w),d0
	moveq	#1,d1
	move	#$3fff,d2
	move	#$1a0,d3
	lea	level_speech,a0
	jsr	PLAYFX
	movem.l	(sp)+,d0-a6
	rts
