EEPROM_SIGNATURE	equ	$cde2

;************************************************
;						*
;	EEPROM Write & Read Primitives		*
;						*
;************************************************
;
;	Hi-Score on-board-cartridge EEPROM primitives 
;	for use by Jaguar game cartridge developers.
;
;	128 bytes (accessable as 64 words) of non-volatile
;	memory are available on Jaguar game cartridges to
;	preserve Hi-scores or other game status.
;	Data is retained for up to 10 years, and a minimum
;       of 10,000 read/write cycles is assured, according to
;	product literature. 
;
;
;
;
;
;	 Programmer: Dave Staugas
;		     Atari, Sunnyvale
;		     [408] 745-8802
;
;	Last Update: 24-Sept-93
;
;
;   Equates needed that may already be defined in the JAGUAR.INC file..
;
JOY1		equ	$f14000		;this we'll use as our I/O base address
GPIO_0		equ	$f14800		;General purpose I/O #0
GPIO_1		equ	$f15000		;General purpose I/O #1
;
;   Equates derived from the above
;    to allow indirect with 16-bit displacement addressing
;
GPIO_0of	equ	GPIO_0-JOY1	;offset to GPIO_0 (when addr reg Ax -> JOY1) 
GPIO_1of	equ	GPIO_1-JOY1	;offset to GPIO_1 (when addr reg Ax -> JOY1) 
;
;   Commands specific to the National Semiconductor NM93C14
;
;  9-bit commands..
;		 876543210
eREAD	equ	%110000000		;read from EEPROM
eEWEN	equ	%100110000		;Erase/write Enable
eWRITE	equ	%101000000		;Write selected register
eEWDS	equ	%100000000		;Erase/Write disable (default)
;
;
;  DO (data out)	- is read on bit0 of JOY1
;  DI (data in) 	- is written on bit0 of GPIO_0
;  CS (chip select)	- is pulsed low by any access to GPIO_1
;
;
;*****************************************************************
;
;  Write a word to EEPROM
;
;  entry: d0.w = data to be written
;	  d1.w = least signifigant 6 bits specify write address (0-63)  
;
;   exit: d4.w =-1 if fail
;
;
eewrite::
	movem.l	a0/d0-d3,-(sp)
	lea	JOY1,a0		;set ptr to EEPROM i/o addresses

	tst.w	GPIO_1of(a0)	;strobe ChipSelect

	move.w	#eEWEN,d2	;erase/write enable command
	bsr	out9bits	;send it to EEPROM
	
	tst.w	GPIO_1of(a0)	;strobe ChipSelect

	andi.w	#$3f,d1		;force write addr to be legit (0-63)
	ori.w	#eWRITE,d1	;form WRITE command
	move.w	d1,d2
	bsr.s	out9bits	;send it to EEPROM

	move.w	d0,d2		;get 16-bit data word to send
	bsr.s	out16bit	;  & send it

	tst.w	GPIO_1of(a0)	;strobe ChipSelect

	nop			;1 us required after CS for status valid
	nop
	move.w	#1,d2
	move.w	#32767,d4
wrwait:
	move.w	(a0),d3		;wait until write is complete
	and.w	d2,d3
	bne.s	.one
	dbra	d4,wrwait
	
.one:
	move.w	#eEWDS,d2	;get erase/write disable command
	bsr.s	out9bits	;send it

	tst.w	GPIO_1of(a0)	;strobe ChipSelect

	movem.l	(sp)+,a0/d0-d3
	tst.w	d4
	rts			;we're done
;
;
;
;******************************************************
;
;
;  Read a word from EEPROM
;
;  entry:  d1.w = least signifigant 6 bits specify read address (0-63)  
;
;   exit:  d0.w = data as read from EEPROM
;		  all other registers preserved
;
eeread::
	movem.l	a0/d1-d4,-(sp)
	lea	JOY1,a0		;set ptr to EEPROM i/o address

	tst.w	GPIO_1of(a0)	;strobe ChipSelect

	andi.w	#$3f,d1		;force legit read addr
	ori.w	#eREAD,d1
	move.w	d1,d2
	bsr.s	out9bits

	moveq	#0,d0
	moveq	#15,d3		;pick up 17 bits (1st is dummy)
inlp:	
	tst.w	GPIO_0of(a0)
	nop
	move.w	(a0),d1
	lsr.w	#1,d1
	addx.w	d0,d0
	nop
	nop
	nop
	nop
	nop
	nop
	dbra	d3,inlp

	movem.l	(sp)+,a0/d1-d4
	rts
;
;
;
;**************************************************************
;
;  Subordinate Routines needed by "eewrite"
;
;  Serial data sent to device is written to DI, bit0 of GPIO_0
;
; entry:
;  a0 -> JOY1
;  d2.w = 16-bit data word to write
;
; exit:
;  d2.w, d3.l destroyed
;
out16bit:
	rol.w	#1,d2		;align 1st serial data bit (bit15) to bit0
	moveq	#15,d3		;send 16 bits
	bra.s	out9lp
;
; entry:
;  a0 -> JOY1
;  d2.w = 9-bit command to write
;
out9bits:
	rol.w	#8,d2		;align 1st serial data bit (bit8) to bit0
	moveq	#8,d3		;send 9
out9lp:
	move.w	d2,GPIO_0of(a0)		;write next bit
	nop
	nop
	nop			;delay next write
	nop
	nop
	nop
	rol.w	#1,d2		;adjust bit0 for next datum
	dbra	d3,out9lp	;go for all 9 or all 16
	rts
;
;

******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************
******************************************************************************************

;following code is game specific written by Andrew Seed

;	returns d0 == 0 if same else error

compare_eeproms:
	movem.l	d1/d2/d3/a0/a2,-(sp)
	moveq	#0,d0
	moveq	#128/2-1,d1			;number of words in eeprom
.lp:	move.w	(a0)+,d2
	move.w	(a1)+,d3
	eor.w	d3,d2
	add.w	d2,d0
	dbf	d1,.lp
	movem.l	(sp)+,d1/d2/d3/a0/a2
	rts

;;;;;
;	a0 points to the area in memory where the eeprom is to be read/written
;	d0/d1 get corrupted
;	in write	d4 gets corrupted

read_eeprom:
	lea	128(a0),a0			;point to end of eeprom
	moveq	#128/2-1,d1
.lp:	bsr	eeread
	move.w	d0,-(a0)
	dbf	d1,.lp
	rts

;	on exit from write if an error occurs then minus flag set.

write_eeprom:
	st	writing_eeprom
	lea	128(a0),a0			;point to end of eeprom
	moveq	#128/2-1,d1
.lp:
	move.w	-(a0),d0
	bsr	eewrite
	tst.w	d4
	bmi.s	.quit
	dbf	d1,.lp
	tst.w	d4
.quit:
	sf	writing_eeprom
	rts

;	a0 points to 128 byte area of the eeprim
;	returns	d0 as check sum : word

checksum_eeprom:
	moveq	#0,d0
	movem.l	a0/d1/d2,-(sp)
	addq.l	#2,a0
	moveq	#63-1,d1
.lp:	add.w	(a0)+,d0
	ror.w	#3,d0
	dbf	d1,.lp
	movem.l	(sp)+,a0/d1/d2
	rts

*****************************************************

LAST_LEVEL_PLAYED:	dc.w	0
writing_eeprom:	dc.b	0
	even

*****************************************************

NUMBER_OF_HISCORE_NAMES	equ	10
LENGTH_OF_HISCORE_ENTRY	equ	10

;	Format of the Eeprom
;.w	0			check sum
;.w	2			Eeprom signature  $cde?
;.b	4	
;		7654		bits 0 to 3 of GAMEFLAGS2
;		3210		last level played
;	5	76543210	sfx volume
;.b	6			mod volume
;.b	7			save mod volume

;	8-127			Hiscore information		

restore_eeprom:
	movem.l	d0-a6,-(sp)
	clr.w	PLAYERS
	sf	PAD_TYPE
	clr.w	LAST_LEVEL_PLAYED
	clr.w	LEVEL
	
	lea	STEXT,a1
	lea	LVLDIGS,a2
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	
	moveq	#$c,d0
	move.b	d0,vol_sfx
	move.b	d0,vol_mod
	st	save_mod_level
	
	moveq	#0,d0
	tst.b	vol_mod
	beq.s	.off
	moveq	#1,d0
.off:
	move.b	d0,mustype
	
	lea	hi_score_table,a0
	lea	original_hi_score_table,a1
	move.l	a1,a2
.copy_highscore_data:
	move.b	(a1)+,(a0)+
	cmp.l	a0,a2
	bne.s	.copy_highscore_data
	
	lea	volume_table,a0

	moveq	#0,d1
	moveq	#$c,d0
	move.b	vol_sfx,d0
	move.b	(a0,d0.w),d0
	jsr	SET_VOLU

	moveq	#0,d2
	moveq	#1,d1
	moveq	#$c,d0
	move.b	vol_mod,d0
	bpl.s	.on
	moveq	#1,d2
	moveq	#0,d0
.on:
	move.b	d2,mustype
	
	move.b	(a0,d0.w),d0
	jsr	SET_VOLU

	jsr	START_MO
	movem.l	(sp)+,d0-a6
	rts

	even
