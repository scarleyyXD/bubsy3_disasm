WETSUIT_MOVE_SPEED	equ	6
WETSUIT_FRAMES		equ	11

.macro	WETSUIT_KILL_BUBSY
	move.w	#$0601,d6				;see if BUBSY has bopped the guard
	move.w	#SMASH,d7
	jsr	ENEMYBOP
	bcc.s	.no_collide
	moveq	#MELTSTATE,d0
	jsr	KILLBUBSY
.no_collide:
	.endm

WETSUITAI:
	JSR	OBJRANGE
	BCC.s	.NORANGE
	JMP	CLEAROBJ
.NORANGE:
	JSR	CLIPYSMALL					;do not do a small one
	
	WETSUIT_KILL_BUBSY

	tst.b	OBJFLAGS(a5)
	bne.s	.stuck_to_ground
	jsr	STICKOBJECTTOPLAYFIELD
	move.w	OBJY(a5),OBJY+2(a5)
	st	OBJFLAGS(A5)
.stuck_to_ground:
	subq.b	#1,OBJAUX0(a5)
	bpl.s	.just_draw
.move_eel:
	move.b	#WETSUIT_MOVE_SPEED-1,OBJAUX0(a5)

	subq.b	#1,OBJAUX1(a5)
	bpl.s	.no_wrap
	move.b	#WETSUIT_FRAMES-1,OBJAUX1(a5)
.no_wrap:
	moveq	#0,d0
	move.b	OBJAUX1(A5),d0
	move.b	.wet_frames(pc,d0.w),OBJFRAME(A5)
	asl.w	#1,d0
	move.w	.wet_tables(pc,d0.w),d1
	add.w	OBJY+2(a5),d1
	move.w	d1,OBJY(a5)
.just_draw:
	jmp	DRAW_COMPLEX_SPRITE

.wet_tables:
	dc.w	085-116
	dc.w	071-116
	dc.w	071-116
	dc.w	068-116
	dc.w	070-116
	dc.w	082-116
	dc.w	100-116
	dc.w	116-116
	dc.w	116-116
	dc.w	116-116
	dc.w	116-116

.wet_frames:
;	frame number	a,9,8,7,6,5,4,3,2,1,0
	dc.b		6,6,5,4,3,3,3,2,2,1,0
	even

wetsuit_dma:
	dc.l	.frame0
	dc.l	.frame1
	dc.l	.frame2
	dc.l	.frame3
	dc.l	.frame4
	dc.l	.frame5
	dc.l	.frame6

.frame0:	dc.w	1,0,0,0
	dc.w	-13,-53,11

.frame1:	dc.w	1,0,0,0
	dc.w	-13,-46,12

.frame2:	dc.w	1,0,0,0
	dc.w	-12,-44,13

.frame3:	dc.w	1,0,0,0
	dc.w	-11,-58,27

.frame4:	dc.w	1,0,0,0
	dc.w	-24,-54,28

.frame5:	dc.w	1,0,0,0
	dc.w	-28,-48,29

.frame6:	dc.w	1,0,0,0
	dc.w	-28,-41,87

WETSUITMAP:
	Soff	11,1,0,0,1,23,2,45,21,0,21,23,20,45
	Soff	11,0,0,0,21,0,3,23,19,23,2,38,20,38
	Soff	12,0,0,0,21,0,4,18,18,18,2,37,20,37
	Soff	10,3,0,0,19,1,2,21,20,21,1,48,19,48
	Soff	12,3,0,0,23,1,-13,21,35,21,3,44,21,44
	Soff	20,1,0,0,39,0,-9,30,47,30,11,41,29,41
	Soff	22,1,0,0,47,0,22,10,22,41,-7,26,49,26