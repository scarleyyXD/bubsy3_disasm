	include	"c:\\bin\\blit.inc"
	include	"c:\\bin\\jaguar.inc"
	include	"mac\\equates.s"
	include	"mac\\macros.s"
	include	"mac\\variable.s"
	include	"mac\\68000.s"

	.globl	fasta_gpu_sprite_draw_prog
	.globl	fastb_gpu_sprite_draw
	.globl	fastc_gpu_sprite_drawe
	.globl	gpu_routine
	.globl	sprite_return_obytes
;	.globl	ar,um
	.globl	sprite_params
	.globl	rad_params
	.globl	builda_star_prog
	.globl	buildb_star_gpu
	.globl	buildc_star_gpue
	.globl	builda_circle_prog
	.globl	buildb_circle_gpu
	.globl	buildc_circle_gpue
	.globl	xxx
	.globl	init_gpu
	.globl	builda_wibbly_text_prog
	.globl	buildb_wibbly_text_gpu
	.globl	buildc_wibbly_text_gpue
	.globl	wibbleparams
	.globl	starparams

SCREEN_WIDTH	equ	324
PAL	equ	0
NTSC	equ	1


	.68000
	.data

	RSRESET	
	RSW	sprite_x,1
	RSW	sprite_y,1
	RSW	sprite_z,1
	RSW	sprite_number,1
	RSW	sprite_group,1
	RSW	sprite_e,0

	RSRESET
	RSL	jsprite_data,1	    ; graphic data
	RSW	jsprite_pixel_width,1   ; width in pixels
	RSW	jsprite_height,1	    ; height in pixels
	RSB	jsprite_bitsperpixel,1  ; bits per pixel
	RSB	jsprite_flaos,1         ; flags
	RSW	jsprite_yoffset,1       ; blank pixels at top
	RSW	jsprite_palindex,1	    ; palette index
	RSW	jsprite_phrase_width,1

	RSW	jsprite_e,0


***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************

.macro	GABS	reggie
	cmpq	#0,\reggie
	jr	pl,.\~1:
	nop
	neg	\reggie

.\~1:
.endm

.macro	SDIV	reggie1,reggie2
	GABS	\reggie1
	btst	#31,\reggie2
	jr	eq,.\~1
	nop
	GABS	\reggie2
	div	\reggie1,\reggie2
	neg	\reggie2
	jr	.\~2
	nop
.\~1:	div	\reggie1,\reggie2
.\~2:

.endm
	
.macro	GEXTL	reggie
	shlq	#16,\reggie
	sharq	#16,\reggie
.endm	

.macro	GEXTBL	reggie
	shlq	#24,\reggie
	sharq	#24,\reggie
.endm	

.macro	GEXW	val1,val2
	move.w	\val1,-(sp)
	clr.w	-(sp)
	move.l	(sp)+,\val2
.endm

.macro	HANGGPU
.\~1:	nop	
	movei	#$fffe,IMMID
	movei	#BG,r28
	storew	IMMID,(r28)
	jr	t,.\~1
	nop
.endm

.macro	GADDI	val,reggie
	movei	\val,IMMID
	add	IMMID,\reggie
.endm

.macro	GMULSI	val,reggie
	movei	\val,IMMID
	imult	IMMID,\reggie
.endm


.macro	GSUBI	val,reggie
	movei	\val,IMMID
	sub	IMMID,\reggie
.endm

.macro	GANDI	val,reggie
	movei	\val,IMMID
	and	IMMID,\reggie
.endm


.macro	PUSHG	reggie
	subq	#4,RA7
	store	\reggie,(RA7)
.endm

.macro	PULLG	reggie
	load	(RA7),\reggie
	addq	#4,RA7
.endm

.macro	GBSR	addr
	movei	#.\~1,IMMID
	PUSHG	IMMID
	movei	#\addr,IMMID
	jump	t,(IMMID)
	nop
.\~1:	
.endm

.macro	GCMPI	num,reggie
	movei	\num,IMMID
	cmp	IMMID,\reggie
.endm

.macro	GRTS
	load	(RA7),IMMID
	addq	#4,RA7
	jump	t,(IMMID)
	nop	
.endm

.macro	LONGJUMP	addr
	movei	#\addr,IMMID
	jump	t,(IMMID)
	nop
.endm	

.macro	STOREIMMID val,addr
	PUSHG	RA6
	movei	\val,IMMID
	movei	#\addr,RA6
	store	IMMID,(RA6)
	PULLG	RA6
.endm

.macro	STOREREG  reggie,addr
	movei	#\addr,IMMID
	store	\reggie,(IMMID)
.endm


.macro	LOADL	addr,reggie
	movei	#\addr,IMMID
	loadw	(IMMID),\reggie
	shlq	#16,\reggie
	addq	#2,IMMID
	loadw	(IMMID),\reggie
.endm
	
	


.macro	START_GPU
	move.l	#$1,G_CTRL-BASE(a5)
.endm

.macro	STOP_GPU
	move.l	#$0,G_CTRL-BASE(a5)
.endm

	.gpu
le	ccdef	$1a
gt	ccdef	$15	; these dont seem to be defined in the assembler


; ALL THESE REGISTERS CAN BE USED WHEN CONVERTING REGISTER CODE
RD0	regequ	r0
RD1	regequ	r1
RD2	regequ	r2
RD3	regequ	r3
RD4	regequ	r4
RD5	regequ	r5
RD6	regequ	r6
RD7	regequ	r7
RA0	regequ	r8
RA1	regequ	r9
RA2	regequ	r10
RA3	regequ	r11
RA4	regequ	r12
RA5	regequ	r13
RA6	regequ	r16
RA7	regequ	r17
IMMID	regequ	r18

; REGISTERS R19-R27 CAN BE USED WHEN INTERUPTS ARE RUNNING
; IF INTERUPTS ARE NOT RUNNING R19-R31 CAN BE USED

; R14/R15 CAN BE USED ANYWHERE I FEEL LIKE IT 
	.68000


;---------------------------------------------------
; THIS BIT OF CODE INITIALIZES THE GPU FOR MY STUFF

xxx:
init_gpu:
	STOP_GPU
	lea	gpu_interface_prog,a0
	lea	gpu_interface,a1
	move.l	#gpu_interfacee-gpu_interface,d0
	jsr	fast_copy_bytes
	move.l	#%0000000000000000,G_FLAGS-BASE(a5)
	move.l	#gpu_done,G_PC-BASE(a5)
	START_GPU
	rts


;---------------------------------------------------

build_map_gpu_prog:
	.gpu

; THIS IS A DIRECT PORT OF THE 68K VERSION, WITH A FEW MODIFICTIONS
; DONT BLAME ME IF YOU CANT READ IT, DOING PIPE-LINE CODE DONT LOOK NICE,
; SUPPORTS ANY SIZE BLOCKS, BUT ONLY 8 BIT/PIXEL BLOCKS
; SHOULDNT BE HARD TO CHANGE FOR OTHER BLOCK TYPES
; GPU IS REALLY GOOD FOR THIS KIND OF REPETATIVE TWAT

	.org	G_RAM+$200

BITSPERPIXEL	regequ	RA1	
LINEWIDTH	regequ	r14	

RSCREEN_WIDTH	regequ	r19
BLOCKDIM	regequ	r20

OBJPATTERN0	regequ	r21
OBJPATTERN1	regequ	r22
OBJPATTERN2	regequ	r23
OBJPATTERN3	regequ	r24
BLOCKSIZE	regequ	r25

GSCREEN_HEIGHT 	regequ	r26
GBYTES_IN_OBJECT_LIST regequ	r27



; parameters
; 0.l	x into map
; 4.l	y into map
; 8.l	map pointer
; 12.l	base address of blocks
; 16.l	current list pointer
; 20.l	pointer to a generated block of the correct size
; 24.l	screen height
; 28.l	screen width
; 32.l  block dimension

; returns

; gmap_return_obytes ; numbr of bytes added to object list

	.if	STRIP=FALSE

build_map_gpu:    	movei	#map_params,r14
	load	(r14),RD0
	load	(r14+1),RD1
	GEXTL	RD0
	GEXTL	RD1
	load	(r14+2),RA0
	load	(r14+8),BLOCKDIM
	
	move	RD0,RD3
	move	RD1,RD4
	div	BLOCKDIM,RD3
	div	BLOCKDIM,RD4	; DIVCTRL must be set for 32bit divide
	GEXTL	RD3
	GEXTL	RD4
	add	RD3,RD3
	loadw	(RA0),RD2
	add	RD2,RD2
	imult	RD2,RD4
	add	RD3,RD4
	add	RD4,RA0
	addq	#8,RA0

	move	BLOCKDIM,IMMID
	subq	#1,IMMID
	and	IMMID,RD0
	and	IMMID,RD1
	neg	RD0
	neg	RD1
	
	load	(r14+3),RA6
	load	(r14+5),r15
	load	(r14+6),GSCREEN_HEIGHT
	load	(r14+7),RSCREEN_WIDTH
	load	(r15),OBJPATTERN0
	load	(r15+1),OBJPATTERN1
	load	(r15+2),OBJPATTERN2
	load	(r15+3),OBJPATTERN3
	addq	#1,GSCREEN_HEIGHT

	move	OBJPATTERN1,RA5
	move	BLOCKDIM,BLOCKSIZE
	imult	BLOCKDIM,BLOCKSIZE
	moveq	#0,GBYTES_IN_OBJECT_LIST
	load	(r14+4),r15
	move	OBJPATTERN3,BITSPERPIXEL
	shrq	#12,BITSPERPIXEL
	GANDI	#%111,BITSPERPIXEL	

	neg	BITSPERPIXEL
	sh	BITSPERPIXEL,BLOCKSIZE
	shrq	#3,BLOCKSIZE
	move	BLOCKDIM,LINEWIDTH
	sh	BITSPERPIXEL,LINEWIDTH
	movei	#row_loop,RD6
	shrq	#3,LINEWIDTH

.gpu_no_finish_rows:
	PUSHG	RD0
	PUSHG	RD1
	PUSHG	RD2
	PUSHG	RA0
	PUSHG	RA6
	GBSR	gbuild_row
	PULLG	RA6
	PULLG	RA0
	PULLG	RD2
	PULLG	RD1
	PULLG	RD0
	add	BLOCKDIM,RD1
	cmp	GSCREEN_HEIGHT,RD1
	jr	pl,.done_rows
	add	RD2,RA0
	LONGJUMP	.gpu_no_finish_rows

.done_rows:	STOREREG	GBYTES_IN_OBJECT_LIST,gmap_return_obytes
	LONGJUMP	gpu_done
   
gbuild_row:	move	r15,RA3
	cmpq	#0,RD1
	move	RA6,RA2
	jr	pl,.pos_y
	move	RA5,OBJPATTERN1
.neg_y:	neg	RD1
	move	RD1,RD2
	shlq	#14,RD2
	sub	RD2,OBJPATTERN1
	sh	BITSPERPIXEL,RD1
	shrq	#3,RD1      
	imult	BLOCKDIM,RD1
	add	RD1,RA2	
	moveq	#0,RD1	

.pos_y:	addq	#16,r15
	add	RD1,RD1
	GADDI	#n_vdb,RD1
	movei	#%111111111111,RA6
	shlq	#3,RD1

row_loop:	cmp	RSCREEN_WIDTH,RD0
	loadw	(RA0),RD2
	jr	mi,.not_finished
	addq	#2,RA0
	LONGJUMP	.finished

.not_finished:	imult	BLOCKSIZE,RD2
	move	OBJPATTERN0,RD4
	jr	ne,.block
	add	RA2,RD2
	jump	t,(RD6)      
	add	BLOCKDIM,RD0

.block:	move	OBJPATTERN1,RD5
	shlq	#43-32-3,RD2		           
	store	OBJPATTERN2,(r15+2)
	or	RD2,RD4
	move	OBJPATTERN3,RD7
	move	RD0,RD2
	move	r15,RD3
	and	RA6,RD2
	or	RD1,RD5
	or	RD2,RD7
	addq	#16,RD3
	store	RD7,(r15+3)
	move	RD3,RD2
	addq	#16,GBYTES_IN_OBJECT_LIST
	shrq	#8+3,RD2
	shlq	#24-3,RD3
	or	RD2,RD4
	or	RD3,RD5
	store	RD4,(r15)
	store	RD5,(r15+1)
	add	BLOCKDIM,RD0
	jump	t,(RD6)      
	addq	#16,r15

.finished:	move	RA3,IMMID
	shrq	#3,RD1
	move	r15,RA3
	PUSHG	RD1
	moveq	#BRANCHGT,RD0
	move	IMMID,r15
	move	RA3,RD2	
	GBSR	make_gpu_branch
	PULLG	RD1
	subq	#2,RD1                
	add	BLOCKDIM,RD1
	add	BLOCKDIM,RD1
	moveq	#BRANCHLT,RD0
	move	RA3,RD2	
	GBSR	make_gpu_branch
	move	RA3,r15
	addq	#16,GBYTES_IN_OBJECT_LIST	
	GRTS

make_gpu_branch:	
	moveq	#3,RD5
	shlq	#3,RD1
	moveq	#0,RD4
	or	RD1,RD5
	shlq	#14,RD0
	shrq	#3,RD2
	or	RD0,RD5

	move	RD2,RD3
	shrq	#8,RD2

	or	RD2,RD4
	shlq	#24,RD3
	or	RD3,RD5
	store	RD4,(r15)
	store	RD5,(r15+1)
	addq	#8,r15
	GRTS	
	.long
build_map_gpue:
	.endif           

;---------------------------------------------------


	.68000
fasta_gpu_sprite_draw_prog:
	.gpu
	.org	G_RAM+$200

; THIS IS A DIRECT PORT OF THE 68K VERSION, WITH A FEW MODIFICTIONS
; DONT BLAME ME IF YOU CANT READ IT, DOING PIPE-LINE CODE DONT LOOK NICE,
; IT PRINTS SPRITES USING THE OBJECT PROCESSOR, THE SPRITES ARE ARRANGED
; IN Z-ORDER IN THE LIST, AND CONTAIN VARIOUS ATTRIBUTES SUCH AS
; X/Y/SPRITE/GROUP.  SOME OF THE TABLES THE CODE USES MAY HAVE TO BE GENERATED
; (SEE SOME EXAMPLE)  (NOTE, SPRITE LIST MUST BE ON PHRASE BOUNDRY ( FOR PHRASE READS)

; parameters
; 0.l	number of sprites to draw
; 4.l	address of list of sprites  (A3) 
; 8.l	pointer to start of sprite def table  (A4)
; 12.l	pointer to object list (A1)



NUMSPRITES	regequ	r19
GSPRITE_BYTES	regequ	r20
GAND1	regequ	r21
GAND2	regequ	r22
GAND3	regequ	r23
GAND4	regequ	r24

fastb_gpu_sprite_draw:
	movei	#sprite_params,r14
	load	(r14),NUMSPRITES
	load	(r14+1),RA3
	load	(r14+2),RA4
	load	(r14+3),RA1
	moveq	#0,GSPRITE_BYTES	
	movei	#%111111111111,GAND1
	movei	#%111111111000000000011111111111111,GAND2
	movei	#%11111111111,GAND3
	movei	#%11111111000000000000000000000000,GAND4
	movei	#fast_gpu_sprite_loop,RA6
	movei	#gpu_fast_sprite_link,RA7

fast_gpu_sprite_loop:
	cmpq	#0,NUMSPRITES
	loadw	(RA3),RD0	; sprite x coordinate
                  	jr	ne,.more_sprites
	addq	#2,RA3
	STOREREG	GSPRITE_BYTES,sprite_return_obytes
	LONGJUMP	gpu_done

.more_sprites:	
	loadw	(RA3),RD1	; sprite y coordinate
	move	RA4,r14
	addq	#2,RA3
	shlq	#16,RD1
	loadw	(RA3),RD2	; sprite number
	sharq	#16,RD1
	addq	#2,RA3
	shlq	#4,RD2
	loadw	(RA3),RD3	; sprite group number
	shlq	#3,RD3
	addq	#2,RA3
	add	RD3,r14
	and	GAND1,RD0
	load	(r14),RA0	; pre-genrated bitmap objects
	load	(r14+1),RA2	; normal sprite header

	add	RD2,RA0
	add	RD2,RA2
	move	RA0,r14
	subq	#1,NUMSPRITES
	load	(r14+3),RD5
	load	(r14),RD2
	or	RD0,RD5
	load	(r14+1),RD3
	cmpq	#0,RD1
	load	(r14+2),RD4
	jr	mi,.neg_sprite
	shlq	#4,RD1
	jump	t,(RA7)
	add	RD1,RD3

.neg_sprite:
	addq	#jsprite_height,RA2
	shrq	#4,RD1
	loadw	(RA2),RD0
	add	RD1,RD0
	jr	gt,.sprite_on_screen
	subq	#jsprite_height,RA2
	jump	t,(RA6)
	nop

.sprite_on_screen:	and	GAND2,RD3
	shlq	#14,RD0
	or	RD0,RD3
	neg	RD1
	load	(RA2),RD0
	addq	#jsprite_phrase_width,RA2
	loadw	(RA2),IMMID
	imult	IMMID,RD1
	subq	#jsprite_phrase_width,RA2
	shlq	#3,RD1
	and	GAND3,RD2
	add	RD1,RD0
	shlq	#43-32-3,RD0
	or	RD0,RD2

gpu_fast_sprite_link:
	move	RA1,r14
	moveq	#16,RD0
	store	RD5,(r14+3)	
	add	RA1,RD0
	store	RD4,(r14+2)	
	shrq	#3,RD0
	move	RD0,RD1

	shrq	#8,RD0
	rorq	#8,RD1
	or	RD0,RD2
	and	GAND4,RD1
	or	RD1,RD3
	store	RD2,(r14)	
	store	RD3,(r14+1)	
	addq	#16,RA1
	jump	t,(RA6)
	addq	#16,GSPRITE_BYTES
	nop
	nop
	.long
fastc_gpu_sprite_drawe:


;---------------------------------------------------

; this routine uses the gpu to run length decode images stored in public ram

	.68000
gpu_rld_prog:
	.gpu
	.org	G_RAM+$200

RLD_IMAGESP	regequ	r20
RLD_IMAGEDP	regequ	r21
RLD_LEN	regequ	r22
EIGHTY	regequ	r23
RUN_BYTE_JUMP	regequ	r24

	.if	STRIP=FALSE
gpu_rld: 	
	movei	#rld_params,r14
	load	(r14),RLD_IMAGESP	
	load	(r14+1),RLD_IMAGEDP	
	movei	#$80,EIGHTY
	moveq	#0,RLD_LEN
	movei	#.run_byte,RUN_BYTE_JUMP

.next_string:	loadb	(RLD_IMAGESP),RD0
	cmp	EIGHTY,RD0
	jump	mi,(RUN_BYTE_JUMP)
	addq	#1,RLD_IMAGESP	

	add	RD0,RLD_LEN
.copy_byte:	loadb	(RLD_IMAGESP),RD1
	subq	#1,RD0
	storeb	RD1,(RLD_IMAGEDP)
	addqt	#1,RLD_IMAGESP	
	jr	ne,.copy_byte
	addq	#1,RLD_IMAGEDP	
	LONGJUMP	.next_string

.run_byte:	cmp	EIGHTY,RD0
	jr	ne,.no_exit
	loadb	(RLD_IMAGESP),RD1
	STOREREG	RLD_LEN,rld_return_bytes
	LONGJUMP	gpu_done           

.no_exit:	GEXTBL	RD0	
	neg	RD0
	add	RD0,RLD_LEN

.loop0:	subq	#1,RD0
	storeb	RD1,(RLD_IMAGEDP)
	jr	ne,.loop0	
                 	addq	#1,RLD_IMAGEDP
	LONGJUMP	.next_string 
	.long
gpu_rlde:
	.endif

      
;---------------------------------------------------



	.68000
builda_circle_prog:
	.gpu
	.org	G_RAM+$200
	
buildb_circle_gpu:	movei	#rad_params,r14
	moveq	#0,RA6
	load	(r14),RD3
	addq	#4,r14
	GANDI	#$ff,RD3
	cmpq	#PAL,RD3
	jr	eq,.ok
	nop
	movei	#20*344,RA6

.ok:
	GBSR	.do_circ
	addq	#5*4,r14	
	GBSR	.do_circ
	LONGJUMP	gpu_done

.do_circ:	load	(r14),RA2

	load	(r14+1),RA3
	loadw	(RA3),RA0
	shlq	#16,RA0
	addq	#2,RA3
	loadw	(RA3),RA3
	or	RA3,RA0
		
	load	(r14+2),RA3
	loadw	(RA3),RA1
	shlq	#16,RA1
	addq	#2,RA3
	loadw	(RA3),RA3
	or	RA3,RA1
		
	load	(r14+3),RA3
	loadw	(RA3),RD0
		
	load	(r14+4),RA3
	loadw	(RA3),RD1
		
	movei	#ENLARGE/2,RD3
	sub	RD3,RD0
	sub	RD3,RD1
	GMULSI	#344,RD1
	add	RD0,RD1
	add	RD1,RA2

	add	RA6,RA2

	moveq	#1,RD3
	movei	#64,RD0
	move	RD0,RD5
.rloop0:	move	RD5,RD1
.rloop1:	loadw	(RA0),RD2
	move	RA2,RA3
	imult	RD3,RD2
	addqt	#2,RA0
	jr	mi,.rnext
	add	RD2,RA3
	loadb	(RA3),RD2
	storeb	RD2,(RA1)
.rnext:	subq	#1,RD1
	jr	ne,.rloop1	
	addq	#1,RA1
	subq	#1,RD0
	jr	ne,.rloop0
	nop

	GRTS

	.long

buildc_circle_gpue:

;---------------------------------------------------

	.68000
builda_star_prog:
	.gpu
	.org	G_RAM+$200

STARSCOS	regequ	r19

STARBASE_X	regequ	r20
STARBASE_Y	regequ	r21
STARBASE_BOUNDX	regequ	r22	
STARBASE_BOUNDY	regequ	r23	

STAROFFX	regequ	r24
STAROFFY	regequ	r25
STAROFFZ	regequ	r26
STARCOL	regequ	r27

STARSSIN	regequ	r28

buildb_star_gpu:	movei	#starparams,RA4
	load	(RA4),RA4	

	move	RA4,RA2
	GADDI	#star_restore_pointer,RA2
	load	(RA2),RA2

	moveq	#0,RD0

.loopx:	load	(RA2),RA3
	cmpq	#0,RA3
	jr	mi,.done_star
	addq	#4,RA2
	jr	.loopx
	storew	RD0,(RA3)
.done_star:
	movei	#SCREEN_WIDTH,STARBASE_BOUNDX
	move	RA4,RA6
	GADDI	#scree_height_fred,RA6
	loadw	(RA6),STARBASE_BOUNDY	

	move	STARBASE_BOUNDX,STARBASE_X
	move	STARBASE_BOUNDY,STARBASE_Y
	shrq	#1,STARBASE_X
	shrq	#1,STARBASE_Y

	move	RA4,RA0
	GADDI	#star_table,RA0	
	
	move	RA4,RA2
	GADDI	#star_restore_pointer,RA2
	load	(RA2),RA2

	move	RA4,RA3
	GADDI	#star_screen_pointers,RA3
	load	(RA3),RA3
	movei	#NUM_STARS,RD7
	
.star_loop0:	move	RA0,RA1
	loadw	(RA0),RD0
	GEXTL	RD0
	cmpq	#0,RD0
	jr	pl,.sine_ok
	nop
	addq	#12,RA0
	LONGJUMP	.dec

.sine_ok:	addq	#9,RD0
	move	RD0,RD1
	GADDI	#SINE_LEN/4,RD1
	GANDI	#SINE_LEN-1,RD0
	GANDI	#SINE_LEN-1,RD1
	storew	RD0,(RA0)
	shlq	#1,RD1
	shlq	#1,RD0
	move	RA4,RA6
	GADDI	#sine_pointer,RA6
	load	(RA6),RA5
	move	RA5,RA6
	add	RD0,RA5		
	add	RD1,RA6		
	loadw	(RA5),STARSSIN		   	
	loadw	(RA6),STARSCOS		   	

	addq	#2,RA0
	loadw	(RA0),STAROFFX
	addq	#2,RA0
	loadw	(RA0),STAROFFY
	addq	#2,RA0
	loadw	(RA0),STAROFFZ
	GSUBI	#20,STAROFFZ
	cmpq	#0,STAROFFZ
	jr	mi,.ok_neg_z
          	nop
	LONGJUMP	.ok_pos_z
.ok_neg_z:      	move	RA1,RA0
	GBSR	gpu_random_star
                 	LONGJUMP	.dec
.ok_pos_z:	storew	STAROFFZ,(RA0)
	addq	#2,RA0
	loadw	(RA0),RD3
	addq	#2,RA0
	loadw	(RA0),STARCOL

	moveq	#1,RD6
	imult	RD6,STAROFFX
	imult	RD6,STAROFFY
	imult	RD6,STAROFFZ

	GCMPI	#500,STAROFFZ
	jr	mi,.dec_rad
	nop
	LONGJUMP	.inc_col
.dec_rad:	subq	#2,RA0
	GADDI	#20,RD3
	storew	RD3,(RA0)
	addq	#2,RA0
	move	STARCOL,RD6
	GANDI	#$fe,RD6
	subq	#10,RD6
	jr	pl,.clr
	nop
	moveq	#0,RD6
.clr:	LONGJUMP	.col_ok

.inc_col:	move	STARCOL,RD6
	GANDI	#$fe,RD6
	addq	#2,RD6
	GCMPI	#$100,RD6
	jr	mi,.col_ok
        	nop
	subq	#2,RD6

.col_ok:	move	STARCOL,r14
	GANDI	#$ff00,r14
	or	r14,RD6
	storew	RD6,(RA0)	
	addq	#2,RA0

	GCMPI	#3000,STAROFFZ
	jr	mi,.ok_print
	nop
	subq	#2,RA0
	moveq	#0,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	LONGJUMP	.dec	
.ok_print:	move	STARCOL,r14
	GANDI	#$fe,r14
	move	r14,RD6
	shrq	#1,RD6
	bclr	#0,RD6
	GANDI	#$ff00,STARCOL
	or	STARCOL,r14
	or	STARCOL,RD6

	PUSHG	RD7
	PUSHG	RA0

	move	RA4,RA1
	GADDI	#star_ball_pointer,RA1
	load	(RA1),RA1
	movei	#NUM_STAR_COORDS,RD7
	movei	#.star_loop,RA6
	movei	#.no_star,RA5

.star_loop:	loadw	(RA1),RD0
	addq	#2,RA1
	loadw	(RA1),RD1
	imult	RD3,RD0
	addq	#2,RA1
	imult	RD3,RD1
	loadw	(RA1),RD2
	sharq	#8,RD0	
	addq	#2,RA1

	imult	RD3,RD2
	sharq	#8,RD1
	sharq	#8,RD2

	move	RD1,RD4	
	move	RD2,RD5	

	imult	STARSCOS,RD1
	imult	STARSSIN,RD2
	imult	STARSCOS,RD5
	imult	STARSSIN,RD4
	sub	RD2,RD1
	add	RD4,RD5
	sharq	#15,RD5
	sharq	#15,RD1
	move	RD5,RD2	

	add	STAROFFY,RD1
	add	STAROFFZ,RD2
	jump	mi,(RA5)
	add	STAROFFX,RD0

	movei	#PERSPECTIVE_VAL*$7fff,r15
	GADDI	#PERSPECTIVE_VAL,RD2
	div	RD2,r15
	imult	r15,RD0	
	imult	r15,RD1	
	sharq	#15,RD0	
	sharq	#15,RD1	

	add	STARBASE_X,RD0		   
	jump	mi,(RA5)
	cmp	STARBASE_BOUNDX,RD0
	jump	pl,(RA5)
	add	STARBASE_Y,RD1
	jump	mi,(RA5)
	cmp	STARBASE_BOUNDY,RD1
	jump	pl,(RA5)

	mult	STARBASE_BOUNDX,RD1
	shlq	#1,RD0
	shlq	#1,RD1
	add	RA3,RD0
	add	RD0,RD1

	cmpq	#0,RD5
	store	RD1,(RA2)
	jr	mi,.col
	addq	#4,RA2
	storew	RD6,(RD1)
	jr	.no_star
	nop
.col:	storew	r14,(RD1)

.no_star:	subq	#1,RD7
	jump	ne,(RA6)
	nop
	PULLG	RA0
	PULLG	RD7
.dec:	movei	#.star_loop0,RA6
	subq	#1,RD7
	jump	ne,(RA6)
	nop
	movei	#$80008000,RD0
	store	RD0,(RA2)
	LONGJUMP	gpu_done


gpu_random_star:	GBSR	gget_random
	GANDI	#SINE_LEN-1,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	GBSR	gget_random
	GMULSI	#500,RD0
	sharq	#16,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	GBSR	gget_random
	GMULSI	#350,RD0
	sharq	#16,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	loadw	(RA0),RD0
	GADDI	#3000,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	movei	#1<<8+$30,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	GBSR	gget_random
	GANDI	#$ff00,RD0
	storew	RD0,(RA0)
	addq	#2,RA0
	GRTS	


gget_random:	movei	#HC,IMMID
	loadw	(IMMID),RD0
	movei	#VC,IMMID
	loadw	(IMMID),RD1
	add	RD1,RD0
	shlq	#3,RD0
	move	RA4,IMMID
	GADDI	#random_number,IMMID
	loadw	(IMMID),RD1
	add	RD1,RD0
	storew	RD0,(IMMID)
	GRTS	
	nop
	nop

	.long
buildc_star_gpue:


;---------------------------------------------------

	.68000
builda_wibbly_text_prog:
	.gpu
	.org	G_RAM+$200

buildb_wibbly_text_gpu:
	movei	#wibbleparams,r14
	load	(r14),RA4
	
	move	RA4,RA0
	GADDI	#text_buffer_pointer,RA0
	load	(RA0),RA0
	move	RA4,RD0
	GADDI	#fuck_text_len,RD0
	loadw	(RD0),RD0
	shlq	#3,RD0
	move	RA0,RA1
	add	RD0,RA1
	move	RA4,RA2
	GADDI	#sine_pointer,RA2
	load	(RA2),RA2
	move	RA4,RD1
	GADDI	#intro_counter,RD1
	loadw	(RD1),RD1
	shlq	#5,RD1
	movei	#(SINE_LEN-1)*2,RD7	     
	movei	#(SINE_LEN/4)*2,RA3
	moveq	#16,RA4
	movei	#160,RA6
	movei	#.sine_text,IMMID

.sine_text:	move	RD1,RD2
	add	RA3,RD2
	and	RD7,RD1
	and	RD7,RD2
	move	RD1,RD3
	move	RD2,RD6
	add	RA2,RD3	
	add	RA2,RD6
	loadw	(RD3),RD3	
	loadw	(RD6),RD6	
	imult	RA4,RD3
	imult	RA4,RD6
	move	RD3,RD4
	move	RD6,RD5
	sub	RD3,RD6
	add	RD3,RD4
	sharq	#16,RD6	
	sharq	#16,RD4
	loadw	(RA0),RA5
	addq	#2,RA0
	add	RD6,RA5
	storew	RA5,(RA1)
	loadw	(RA0),RA5
	addq	#2,RA1
	addq	#2,RA0
	add	RD4,RA5
	storew	RA5,(RA1)
	addq	#2,RA1
	load    	(RA0),RA5
	store	RA5,(RA1)
	addq	#4,RA0
	addq	#4,RA1
	add	RA6,RD1
	subq	#8,RD0
	jump	ne,(IMMID)
	nop	
	LONGJUMP	gpu_done
	nop
	nop
	nop

	.long
buildc_wibbly_text_gpue:

	
;---------------------------------------------------
	.68000
	.if	STRIP=FALSE
color_int_prog:
	.gpu
	.org	G_RAM+(16*3)

color_int:        	movei	#OB0,r30
	movei	#gpu_bollox,r29
	load	(r30),r28
	or	r28,r28
	store	r28,(r29)

	movei	#OBF,r30
	storew	r29,(r30)	; write to object processor flag ASAP

	movei	#gpu_bollox,r30
	load	(r30),r29
	GANDI	#$ffff,r29
	addq	#12,r29
	load	(r29),r28
	addq	#1,r28
	store	r28,(r29)	

	movei	#G_FLAGS,r30
	load	(r30),r29
	load	(r31),r28
	bclr	#3,r29
	addq	#2,r28
	bset	#12,r29	; THIS IS STANDARD INTERUPT CODE FOR GPU
	addq	#4,r31
	jump	t,(r28)
	store	r29,(r30)
	nop
	nop
	.long
color_inte:
	.endif

;---------------------------------------------------
	.68000
gpu_interface_prog:
	.gpu
	.org	G_RAM+$f00
gpu_interface:

wibbleparams:
starparams:
gstack:	
rad_params:
rld_params:
sprite_params:
map_params:		dcb.l	11,0
rld_return_bytes:
sprite_return_obytes:
gmap_return_obytes: 	dc.l	0
gpu_routine:		dc.l	0

gpu_done:
	moveq	#0,r0
	movei	#gpu_routine,r1
	store	r0,(r1)
	movei	#gstack,RA7
gpu_hold:
	movei	#G_RAM+$f00,r31
	movei	#gpu_routine,r0
	load	(r0),r1
	cmpq	#0,r1
	jr	eq,gpu_hold
	nop
	jump	t,(r1)
	nop
	.long
gpu_interfacee:
	.68000


***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************
***************************************

