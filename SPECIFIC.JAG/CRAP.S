
reset_eeprom
		
		move.b	#1,mustype
		
		move.b	#1,sfxtype
		
		move.b	#1,anitype
		
		move.b	#$c,vol_sfx
		
		move.b	#$c,vol_mod
		
		st	save_mod_level
		
		move.w	#$0,pad_def
		
		move.b	#0,levtype
		
		move.b	#1,last_level_played
		
		
		moveq	#0,d0
		move.b	volume_table+$c(pc),d0
		moveq	#1,d1
		jsr	SET_VOLU
	
		
		moveq	#0,d0
		move.b	volume_table+$c(pc),d0
		moveq	#0,d1
		jsr	SET_VOLU
	
		lea	copy_of_hiscore,a0
		lea	hiscoretab,a1
		move.w	#8*HI_NAMES-1,d0
.lp		move.w	(a0)+,(a1)+
		dbf	d0,.lp		
		
		st	kickinmusic
	

write_eeprom
		lea	temp_buffer+128,a6		place where data is stored
		moveq	#31-1,d0
.clear		clr.l	-(a6)
		dbf	d0,.clear
		clr.w	-(a6)
		move.w	#$cde0,(a6)+
		
		lea	hiscoretab,a0		start of hiscore stuff
		moveq	#HI_NAMES-1,d2		10 hiscores to write
		
.write_a_score	move.l	(a0)+,(a6)+
		lea	12(a0),a0		skip the name
		dbf	d2,.write_a_score	in total 20 words used
		
		lea	hiscoretab+4,a0	start of hiscore stuff but skip the score
		moveq	#16-1,d2		bit count
		moveq	#HI_NAMES-1,d7		number of names to do
.a_name		moveq	#12-1,d6		letters in a name
.a_letter	bsr	pack_a_letter
		dbf	d6,.a_letter
		addq.l	#4,a0			skip the score
		dbf	d7,.a_name
		bsr	end_pack_a_letter
		clr.w	(a6)
		tst.b	mustype		bit 15 mus on
		beq.s	.mus_off
		or.w	#$8000,(a6)
.mus_off	
		tst.w	pad_def			bit 14 pad type
		beq.s	.pad_off
		or.w	#$4000,(a6)
.pad_off	
		moveq	#0,d0
		move.b	vol_sfx,d0
		and.b	#%11111,d0
		add.b	d0,d0
		or.b	d0,(a6)			bits 13-9 vol sfx

		moveq	#0,d0
		move.b	levtype,d0
		and.b	#3,d0
		lsl.w	#7,d0
		or.w	d0,(a6)			bits 7-8 level of difficulty
		
		addq.l	#1,a6
		move.b	last_level_played,d0
		and.b	#%1111111,d0
		or.b	d0,(a6)+	bits 0-6 last level played
			
		move.b	vol_mod,(a6)+
		move.b	save_mod_level,(a6)+
		
		lea	temp_buffer+2,a5
		moveq	#0,d0
		moveq	#64-1-1,d1
.add		add.w	(a5)+,d0
		ror.w	#3,d0
		dbf	d1,.add
		move.w	d0,temp_buffer
		
		
		lea	temp_buffer,a5
		moveq	#0,d1
		moveq	#64-1,d2
.write_me	move.w	(a5)+,d0
		jsr	eewrite
		bmi.s	.eeprom_write_error
		addq.l	#1,d1
		dbf	d2,.write_me
.eeprom_write_error
		rts


HI_NAMES	equ	10
temp_buffer	ds.b	128

read_eeprom	
		lea	temp_buffer,a5
		moveq	#0,d1
		moveq	#64-1,d2
.read_me	jsr	eeread
		move.w	d0,(a5)+
		addq.l	#1,d1
		dbf	d2,.read_me


		lea	temp_buffer+2,a5
		moveq	#0,d0
		moveq	#64-1-1,d1
.add		add.w	(a5)+,d0
		ror.w	#3,d0
		dbf	d1,.add
		cmp.w	temp_buffer,d0
		beq.s	.ok
		bra	.use_default
.ok
		cmp.w	#$cde0,2+temp_buffer
		beq.s	.ok2
		bra	reset_eeprom
.ok2		
		lea	temp_buffer+4,a6

		moveq	#HI_NAMES-1,d2		10 hiscores to write
		lea	hiscoretab,a0	start of hiscore
		
.read_a_score	move.l	(a6)+,(a0)+
		lea	12(a0),a0		skip the name
		dbf	d2,.read_a_score	in total 2*HI_NAMES words used
		
		lea	hiscoretab+4,a0	start of hiscore stuff but skip the score
		moveq	#16-1,d2		bit count
		
		moveq	#HI_NAMES-1,d7		number of names to do
.a_name		moveq	#12-1,d6		letters in a name
.a_letter	bsr	unpack_a_letter
		dbf	d6,.a_letter
		addq.l	#4,a0			skip the score
		dbf	d7,.a_name
		addq.l	#2,a6			onto the rest of the data

		move.w	(a6)+,d0
		
		move.w	d0,d1
		and.w	#$8000,d1
		rol.w	#1,d1
		move.b	d1,mustype
		
		move.w	d0,d1
		and.w	#$4000,d1
		rol.w	#2,d1
		move.w	d1,pad_def
		
		move.w	d0,d1
		and.b	#%1111111,d1
		move.b	d1,last_level_played
		
		move.w	d0,d1
		lsr.w	#7,d1
		and.b	#%11,d1
		move.b	d1,levtype
		
		rol.w	#7,d0
		and.w	#%11111,d0
		move.b	d0,vol_sfx
		
		
		move.b	(a6)+,vol_mod
		move.b	(a6)+,save_mod_level
		
		
		moveq	#0,d0
		move.b	vol_sfx,d0
		lea	volume_table(pc),a6
		move.b	(a6,d0.w),d0
		moveq	#1,d1
		jsr	SET_VOLU
	
		moveq	#0,d0
		move.b	vol_mod,d0
		cmp.b	#-1,d0
		bne.s	.ok11
		move.b	save_mod_level,d0
		cmp.b	#-1,d0
		bne.s	.ok11
		moveq	#0,d0
.ok11		move.b	(a6,d0.w),d0
		moveq	#0,d1
		jsr	SET_VOLU
		rts

.use_default
		
		move.b	#1,mustype
		
		move.b	#1,sfxtype
		
		move.b	#1,anitype
		
		move.b	#$c,vol_sfx
		
		move.b	#$c,vol_mod
		
		st	save_mod_level
		
		move.w	#$0,pad_def
		
		sf	levtype
		
		move.b	#1,last_level_played
		
		
		moveq	#0,d0
		move.b	volume_table+$c(pc),d0
		moveq	#1,d1
		jsr	SET_VOLU
	
		
		moveq	#0,d0
		move.b	volume_table+$c(pc),d0
		moveq	#0,d1
		jsr	SET_VOLU
	
		lea	copy_of_hiscore,a0
		lea	hiscoretab,a1
		move.w	#8*HI_NAMES-1,d0
.lp		move.w	(a0)+,(a1)+
		dbf	d0,.lp		
		bra	write_eeprom
		
		
end_pack_a_letter
.still_same_word
		roxr.w	(a6)
		dbf	d2,.still_same_word
		addq.w	#2,a6			jump over the last word
		rts		
pack_a_letter	move.b	(a0)+,d1
		moveq	#-1,d0
.next_letter	addq.w	#1,d0
		cmp.b	index(pc,d0.w),d1
		bne.s	.next_letter
		moveq	#5-1,d1
.a_bit		roxr.w	d0			shift lsb out
		roxr.w	(a6)
		dbf	d2,.still_same_word
		addq.l	#2,a6			next word
		moveq.w	#16-1,d2		for next 16 bits
.still_same_word
		dbf	d1,.a_bit
		rts

unpack_a_letter	moveq	#0,d0
		moveq	#5-1,d1			no of bits to find
.a_bit		roxr.w	(a6)
		roxr.w	d0
		dbf	d2,.still_same_word
		addq.l	#2,a6			next word
		moveq.w	#16-1,d2		for next 16 bits
.still_same_word
		dbf	d1,.a_bit
		rol.w	#5,d0
		move.b	index(pc,d0.w),(a0)+
		rts
index		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ .",0
