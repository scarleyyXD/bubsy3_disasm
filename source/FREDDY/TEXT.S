MAX_CHARS       	equ	100
CR					equ	$a
NULL				equ	$0
SETX				equ	$1
SETXB				equ	$6
SETY				equ	$2
SPACE				equ	$20
FIXEDLEN			equ	$3
CENTERX				equ	$4
FONT_SPACER_FRED	equ	0

; a0 - pointer to text
; a1 - pointer to buffer for converted text

; text codes :-
; NULL - Termination
; CR   - Carraige return
; SETX - X pixel positioning
; SETY - Y pixel positioning

convert_text_to_sprites:
	move.l  a1,-(sp)
	moveq   #0,d5
	moveq   #0,d7   ; set x/y cursor position
	move.w  d5,d6     
	moveq   #0,d0
	lea     ascii_table(pc),a2
	move.l  font1_hed_pointer(a4),a3
	moveq   #0,d4

.text_loop:
	move.b  (a0)+,d0
	moveq   #0,d1
	move.b  (a2,d0),d1
	bne.s   .no_special
	cmp.b   #NULL,d0
	beq.s   .done
	cmp.b   #SPACE,d0
	bne.s   .no_space
	add.w   #12,d6
	bra.s   .text_loop
	
.no_space:
	cmp.b   #CR,d0
	bne.s   .not_cr
	move.w  d5,d6
	add.w   #17,d7
	bra.s   .text_loop
	
.not_cr:
	cmp.b   #SETX,d0
	bne.s   .no_setx
	move.b  (a0)+,d5
	lsl.w   #8,d5
	move.b  (a0)+,d5
	move.w  d5,d6
	bra.s   .text_loop
	
.no_setx:
	cmp.b   #SETY,d0
	bne.s   .no_sety
	move.b  (a0)+,d7
	lsl.w   #8,d7
	move.b  (a0)+,d7
	bra.s   .text_loop
	
.no_sety:
	cmp.b   #FIXEDLEN,d0
	bne.s   .no_fixed_len
	st      d4
	bra.s   .text_loop
	
.no_fixed_len:
	illegal

.no_special:
	subq.w  #1,d1
	move.w  d6,(a1)+                         
	move.w  d7,(a1)+                         
	move.w  d1,(a1)+                         
	move.w  #1,(a1)+        
	
	tst.b   d4
	beq.s   .no_fixed
	add.w   #22,d6
	bra     .text_loop
	
.no_fixed:
	pea	(a1)
	lea	font_width_table,a1
	move.b	(a1,d1),d1
	move.l	(sp)+,a1
	add.w	d1,d6
	bra     .text_loop

.done:
	move.l  (sp)+,a3       
	sub.l   a3,a1
	move.l  a1,d0
	lsr.l   #3,d0
	rts

draw_text:	
	WAIT_GPU
	move.l  a0,a3
	lea     sprite_params,a0
	ext.l   d0              
	move.l  d0,(a0)+
	move.l  a3,(a0)+
	lea     intro_fst_pointer(a4),a1
	move.l  a1,(a0)+
	move.l  current_list_pointer(a4),(a0)+

	lea     fasta_gpu_sprite_draw_prog,a0
	lea     fastb_gpu_sprite_draw,a1
	move.l  #fastc_gpu_sprite_drawe,d0
	sub.l	#fastb_gpu_sprite_draw,d0 
	bsr     fast_copy_bytes

	move.l  #fastb_gpu_sprite_draw,gpu_routine
	rts

wait_text:
	WAIT_GPU
	move.l  sprite_return_obytes,d0
	add.w   d0,bytes_in_object_list(a4)
	add.l   d0,current_list_pointer(a4)
	rts

ascii_table:
	dcb.b   $21,0
	dc.b    39
	dcb.b   $24-$22,0
	dc.b	81,82
	dcb.b   $2e-$26,0
	dc.b    38
	dcb.b   $30-$2f,0
	dc.b    15,27,28,29,30,31,32,33,34,35,36
	dc.b    36,37
	dcb.b   $3f-$3d,0
	dc.b    40
	dcb.b   $41-$40,0
	dc.b    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26

font_width_table:
	dc.b    12+FONT_SPACER_FRED,13+FONT_SPACER_FRED,11+FONT_SPACER_FRED,13+FONT_SPACER_FRED,12+FONT_SPACER_FRED
	dc.b    12+FONT_SPACER_FRED,16+FONT_SPACER_FRED,13+FONT_SPACER_FRED,6+FONT_SPACER_FRED,10+FONT_SPACER_FRED
	dc.b    13+FONT_SPACER_FRED,10+FONT_SPACER_FRED,19+FONT_SPACER_FRED
	dc.b    14+FONT_SPACER_FRED,18+FONT_SPACER_FRED,12+FONT_SPACER_FRED,17+FONT_SPACER_FRED,13+FONT_SPACER_FRED
	dc.b    12+FONT_SPACER_FRED,12+FONT_SPACER_FRED,12+FONT_SPACER_FRED,14+FONT_SPACER_FRED,18+FONT_SPACER_FRED
	dc.b    14+FONT_SPACER_FRED,12+FONT_SPACER_FRED,13+FONT_SPACER_FRED
	dc.b    8+FONT_SPACER_FRED,14+FONT_SPACER_FRED,12+FONT_SPACER_FRED,13+FONT_SPACER_FRED,11+FONT_SPACER_FRED
	dc.b    13+FONT_SPACER_FRED,13+FONT_SPACER_FRED,13+FONT_SPACER_FRED,13+FONT_SPACER_FRED
	dc.b    7+FONT_SPACER_FRED,8+FONT_SPACER_FRED,5+FONT_SPACER_FRED,7+FONT_SPACER_FRED,13+FONT_SPACER_FRED
	dcb.b	40,0
	dc.b    10+FONT_SPACER_FRED,18+FONT_SPACER_FRED	

fuck_text:
;;	dc.b    SETX,0,50
	dc.b    SETX,0,40
	dc.b    SETY,0,30
	dc.b	"HIGH SCORE "
	dc.b    "PLAYER "
;;	dc.b    "COOL STUFF "
;;	dc.b    "DUDE "
player_hi_number:
	dc.b    "1"     
	dc.b    "!",CR,CR
	DC.B    "ENTER YOUR NAME"
	dc.b    SETX,0,64
	dc.b    SETY,0,140
	dc.b    FIXEDLEN
hi_name:
	dc.b    "MMMMMMMMM"
	dc.b    NULL

start_text:	
	dc.b	SETX,0,50,SETY,0,10,"PRESS FIRE TO START"
	dc.b	SETX,0,4,SETY,0,40,"PRESS OPTION FOR OPTIONS",NULL

hi_score_table_text:
	dc.b	SETY,0,8,SETX,0,70,"HI SCORE TABLE"
	dc.b	$10
hi_score_table:	
	dc.b    FIXEDLEN
	dc.b    SETY,0,030-10+00+10,SETX,0,05,"ANDY.SEED",SETXB,0,175,"00250732"
	dc.b    SETY,0,050-10-02+10,SETX,0,05,"SLICK!!!!",SETXB,0,175,"00225000"
	dc.b    SETY,0,070-10-04+10,SETX,0,05,"DAVE!!!!!",SETXB,0,175,"00200000"
	dc.b    SETY,0,090-10-06+10,SETX,0,05,"MAD.FRED!",SETXB,0,175,"00175000"
	dc.b    SETY,0,110-10-08+10,SETX,0,05,"RICK.....",SETXB,0,175,"00150000"
	dc.b    SETY,0,130-10-10+10,SETX,0,05,"KEVEROONY",SETXB,0,175,"00125000"
	dc.b    SETY,0,150-10-12+10,SETX,0,05,"JODEZOOM!",SETXB,0,175,"00100000"
	dc.b    SETY,0,170-10-14+10,SETX,0,05,"FARAN.T.!",SETXB,0,175,"00075000"
	dc.b    SETY,0,190-10-16+10,SETX,0,05,"RODNEY!..",SETXB,0,175,"00050000"
	dc.b    SETY,0,210-10-18+10,SETX,0,05,"KARL.BOSS",SETXB,0,175,"00025000"
	dc.b    NULL

original_hi_score_table:
	dc.b    FIXEDLEN
	dc.b    SETY,0,030-10+00+10,SETX,0,05,"ANDY.SEED",SETXB,0,175,"00250732"
	dc.b    SETY,0,050-10-02+10,SETX,0,05,"SLICK!!!!",SETXB,0,175,"00225000"
	dc.b    SETY,0,070-10-04+10,SETX,0,05,"DAVE!!!!!",SETXB,0,175,"00200000"
	dc.b    SETY,0,090-10-06+10,SETX,0,05,"MAD.FRED!",SETXB,0,175,"00175000"
	dc.b    SETY,0,110-10-08+10,SETX,0,05,"RICK.....",SETXB,0,175,"00150000"
	dc.b    SETY,0,130-10-10+10,SETX,0,05,"KEVEROONY",SETXB,0,175,"00125000"
	dc.b    SETY,0,150-10-12+10,SETX,0,05,"JODEZOOM!",SETXB,0,175,"00100000"
	dc.b    SETY,0,170-10-14+10,SETX,0,05,"FARAN.T.!",SETXB,0,175,"00075000"
	dc.b    SETY,0,190-10-16+10,SETX,0,05,"RODNEY!..",SETXB,0,175,"00050000"
	dc.b    SETY,0,210-10-18+10,SETX,0,05,"KARL.BOSS",SETXB,0,175,"00025000"
	dc.b    NULL

credit_text:
    dcb.b   6,CR

	dc.b	CENTERX,"BUBSY",CR
	dc.b	CENTERX,"IN FRACTURED FURRY TALES",CR,CR,CR
exot:
	dc.b	CENTERX,"BUBSY II$ BUBSY$",CR
	dc.b	CENTERX,"AND THE BUBSY CHARACTER",CR
	dc.b	CENTERX,"ARE TRADEMARKS OF",CR
	dc.b	CENTERX,"ACCOLADE$ INC.",CR
	dc.b	CENTERX,"%1991$ 1994 ACCOLADE$ INC.",CR
	dc.b	CENTERX,"ALL RIGHTS RESERVED.",CR,CR,CR,CR,CR,CR

	dc.b	CR,CR,CENTERX,"LICENSED TO ATARI CORP",CR,CR,CR,CR,CR

	dc.b    CENTERX,"CREDITS",CR,CR,CR,CR
	dc.b    CENTERX,"PROGRAMMING",CR,CR
	dc.b    CENTERX,"ANDREW SEED",CR,CR,CR,CR
	
	dc.b    CENTERX,"ARTWORK",CR,CR
	dc.b    CENTERX,"DAVID SEVERN",CR
	dc.b    CENTERX,"STEVE SLICK NOAKE",CR
	dc.b    CENTERX,"COLIN JACKSON",CR
	dc.b    CENTERX,"RICK LODGE",CR,CR,CR,CR
	
	dc.b    CENTERX,"GAME DESIGN",CR,CR
	dc.b    CENTERX,"JODY COBB",CR,CR,CR,CR

	dc.b    CENTERX,"ADDITIONAL GAME DESIGN",CR,CR
	dc.b    CENTERX,"STEVE SLICK NOAKE",CR
	dc.b    CENTERX,"DAVID SEVERN",CR
	dc.b    CENTERX,"ANDREW SEED",CR,CR,CR

	dc.b    CENTERX,"MUSIC AND SOUNDFX",CR,CR
	dc.b    CENTERX,"ALASTAIR LINDSEY",CR
	dc.b    CENTERX,"KEVIN SAVILLE",CR,CR,CR,CR

	dc.b    CENTERX,"MAP DESIGN",CR,CR
	dc.b    CENTERX,"MARK HOOLEY",CR
	dc.b	CENTERX,"JODY COBB",CR,CR,CR,CR

	dc.b    CENTERX,"SUPPORT PROGRAMMING",CR,CR
	dc.b    CENTERX,"KARL WEST",CR  
	dc.b    CENTERX,"NIGEL CONROY",CR
	dc.b    CENTERX,"MARTIN RANDELL",CR
	dc.b    CENTERX,"TREVOR RAYNSFORD",CR,CR,CR,CR
	
	dc.b    CENTERX,"LEAD TESTERS",CR,CR
	dc.b    CENTERX,"JODY COBB",CR
	dc.b    CENTERX,"SCOTT HUNTER",CR,CR,CR

	dc.b    CENTERX,"GAME TESTERS",CR,CR
	dc.b    CENTERX,"MARK HOOLEY",CR
	dc.b    CENTERX,"ROGER COE",CR
	dc.b    CENTERX,"FARAN THOMASON",CR
	dc.b    CENTERX,"ANDREW KEIM",CR
	dc.b    CENTERX,"HANK CAPPA",CR
	dc.b    CENTERX,"JOE SOUSA",CR
	dc.b    CENTERX,"MARTIN MUELLER",CR,CR,CR,CR

	dc.b	CENTERX,"PRODUCER",CR,CR
	dc.b	CENTERX,"FARAN THOMASON",CR,CR,CR,CR
	
	dc.b    CENTERX,"PRODUCT SUPPORT",CR,CR
	dc.b    CENTERX,"RICK SCOTT",CR
	dc.b    CENTERX,"TINA SCHONICS",CR

	dcb.b   20,CR
	dc.b    NULL

game_done_text:
    dcb.b   6,CR
	dc.b	CENTERX,"NICE ONE DUDE!",CR,CR
	dc.b	CENTERX,"WITH YOUR HELP$ BUBSY",CR
	dc.b	CENTERX,"HAS SAVED ALL THE",CR
	dc.b	CENTERX,"FAIRY TALES FROM",CR
	dc.b	CENTERX,"CERTAIN DESTRUCTION.",CR,CR,CR
	dc.b	CENTERX,"WITH MOTHER GOOSE",CR
	dc.b	CENTERX,"FREED FROM HER CAGE$",CR
	dc.b	CENTERX,"AND ALL THE BAD",CR
	dc.b	CENTERX,"DUDES BANISHED",CR
	dc.b	CENTERX,"FOREVER$",CR,CR
	dc.b	CENTERX,"SO WHAT NOW",CR
	dc.b	CENTERX,"FOR BUBSY ???",CR,CR,CR
	dc.b	CENTERX,"DOES HE TAKE UP",CR
	dc.b	CENTERX,"STAMP COLLECTING ???",CR,CR
	dc.b	CENTERX,"PERHAPS BUY A NEW",CR
	dc.b	CENTERX,"TSHIRT ???",CR,CR,CR
	dc.b	CENTERX,"TAKEOVER",CR
	dc.b	CENTERX,"HOLLYWOOD WITH HIS",CR
	dc.b	CENTERX,"PUURRRRSONALITY",CR,CR
	dc.b	CENTERX,"OR MAYBE NOW TAKE A",CR
	dc.b	CENTERX,"GOOD LONG REST ???",CR,CR,CR,CR,CR
	dc.b	CENTERX,"WHAT COULD POSSIBLY",CR
	dc.b	CENTERX,"GO WRONG ???",CR
	dcb.b   20,CR
	dc.b    NULL
	even
