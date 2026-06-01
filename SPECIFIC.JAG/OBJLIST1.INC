
;offsets for each object in the user object list
O_XPOS		equ	0	;word	object xpos
O_YPOS		equ	2	;word	object ypos
O_DATA		equ	4	;long	address of object data (divisible by 8)
O_HEIGHT	equ	8	;word	height of object
O_DWIDTH	equ	10	;word	bytes per line / 8
O_IWIDTH	equ	12	;word	bytes per line / 8
O_FLAGS		equ	14	;byte	flags for reflect, RMW, transparent, release
O_FIRSTPIX	equ	15	;byte	first pixel
				;pixels to skip = O_FIRSTPIX / bits per pixel
O_HSCALE	equ	16	;byte	horizontal scaling
O_VSCALE	equ	17	;byte	vertical scaling
O_REMAINDER	equ	18	;byte	remainder
O_TYPE		equ	19	;byte	object type
O_DEPTH		equ	20	;byte	pixel depth
O_PITCH		equ	21	;byte	pitch
O_INDEX		equ	22	;byte	palette index
				;4 bits per pixel objects can use 0 - 120 (multiples of 8 only)
				;2 bits per pixel objects can use 0 - 126 (multiples of 2 only)
				;1 bit  per pixel objects can use 0 - 127
				;starting color number will be index * 2
; Include additional attributes describing object processing,
; which will be transparent to the user. 
O_NUMBER	equ	23	;byte	object number (calculate for user)
O_PROCESSED	equ	24	;byte
O_DEPTH_PRI	equ	25
O_DELETE	equ	26	;byte	1 if object should not be displayed
;1 byte pad to make size even
O_ADDRESS	equ	28	;long address in work list of object header
OBJ_SIZE	equ	32	;total bytes used for one object

;settings for bits in O_FLAGS byte
HFLIP_OFF	equ	0
HFLIP_ON	equ	1	;bit 0 = horizontal flip
RMW_OFF		equ	0
RMW_ON		equ	2	;bit 1 = RMW flag
TRANS_OFF	equ	0
TRANS_ON	equ	4	;bit 2 = transparent flag
RELEASE_OFF	equ	0
RELEASE_ON	equ	8	;bit 3 = release


BMO_MAKE	macro
		moveq	#0,d1			clear these
		moveq	#0,d0
		move.b	O_FIRSTPIX(a0),d1
		add.b	d1,d1
		move.b	O_FLAGS(a0),d0
		ror.l	#3,d0
		or.l	d0,d1
		swap	d1
		moveq	#0,d0
		move.b	O_INDEX(a0),d0
		asl.w	#6,d0
		or.w	d0,d1
		move.w	O_IWIDTH(a0),d0
		ror.l	#4,d0
		or.w	d0,d1
		move.l	d1,(a1)+		save the first part
		
		clr.w	d0			d0 d1 purposes swapped
		moveq	#0,d1
		move.w	O_DWIDTH(a0),d1
		asl.w	#2,d1
		swap	d1
		or.l	d1,d0
		moveq	#0,d1
		move.b	O_PITCH(a0),d1
		ror.l	#1,d1
		swap	d1
		or.l	d1,d0
		moveq	#0,d1
		move.b	O_DEPTH(a0),d1
		ror.w	#4,d1
		or.w	O_XPOS(a0),d1
		or.w	d1,d0
		move.l	d0,(a1)+		end of the 1st phrase
		
		move.l	O_DATA(a0),d1
		moveq	#10,d0
		lsl.l	d0,d1
		move.l	O_LINK(a0),d0
		ror.l	#8,d0
		or.w	d0,d1
		move.l	d1,(a1)+		save third part
		
		swap	d0
		or.w	O_HEIGHT(a0),d0
		move.w	d0,(a1)+
		
		move.w	O_YPOS(a0),d0
		lsl.w	#3,d0
		move.w	d0,(a1)+

		endm
		
		
		
		