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
O_DEPTH		equ	19	;byte	pixel depth
O_PITCH		equ	20	;byte	pitch
O_INDEX		equ	21	;byte	palette index
O_DEPTH_PRI	equ	22
O_NUMBER	equ	23	;byte	object number (calculate for user)
O_PROCESSED	equ	24	;byte
O_TYPE		equ	25	;byte	object type
				;4 bits per pixel objects can use 0 - 120 (multiples of 8 only)
				;2 bits per pixel objects can use 0 - 126 (multiples of 2 only)
				;1 bit  per pixel objects can use 0 - 127
				;starting color number will be index * 2
O_DELETE	equ	26	;byte	1 if object should not be displayed
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

;object processing macros

;---------------------------------------------------------------------
;
;	MACROS  to:  set bit packed fields in master object header list
;	WARNING: these are not yet suitable for modifying the list once setup
;		 except for XPOS and YPOS
;
;	Given:
;		\1	ptr to pseudo_object data base, source	
;		\2	ptr to master object list, dest 	
;
;	Returns:
;		Object list updated
;		D0 and D1 destroyed
;		
;---------------------------------------------------------------------

; Macro to set an object's Xpos
.macro Setobj_Xpos	RecordPtrRegister, ObjectPtrRegister
	move.w	(\1),d0
	and.w	#$0fff,d0
	and.w	#$f000,14(\2)		;clear old value
	or.w	d0,14(\2)		;set new value
	.endm

; Macro to set an object's Data Ptr
.macro Setobj_DataPtr	 RecordPtrRegister, ObjectPtrRegister
	move.l	O_DATA(\1),d0
	and.b	#$f8,d0	;lose bottom 3 bits
	lsl.l	#8,d0		;shift left 9
	and.l	#$7ff,(\2)	;clear old value
	or.l	d0,(\2)		;* update
 	.endm

; Macro to set an object's Height
.macro Setobj_Height	RecordPtrRegister, ObjectPtrRegister
	move.w	O_HEIGHT(\1),d0
	and.l	#$000003ff,d0
	swap	d0		; = lsl.l #16,d0
	lsr.l	#2,d0
	and.l	#$ff003fff,4(\2);clear old value
	or.l	d0,4(\2)	;* update
	.endm

; Macro to set an object's Dwidth
.macro Setobj_Dwidth	 RecordPtrRegister, ObjectPtrRegister
	move.w	O_DWIDTH(\1),d0			
**	and.w	#$03ff,d0
	lsl.w	#2,d0		
	or.w	d0,12(\2)		;* update
	.endm

; Macro to set an object's Iwidth
.macro Setobj_Iwidth	RecordPtrRegister, ObjectPtrRegister
	move.w	O_IWIDTH(\1),d0			
**	and.w	#$03ff,d0
	move.w	d0,d1
	lsl.w	#4,d0
	or.b	d0,12(\2)		;* update with low 4 bits
	lsr.w	#4,d1		
	or.b	d1,11(\2)		;* update with hi 6 bits  
	.endm

; Macro to set an object's Release
.macro Setobj_Release 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_FLAGS(\1),d0			
	and.b	#$08,d0		; Release flag is in bit 3 of source.
	lsr.b	#3,d0		;			 0 of dest.
	or.b	d0,9(\2)		;* update
	.endm

; Macro to set an object's Transparent
.macro Setobj_Trans 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_FLAGS(\1),d0			
	and.b	#$04,d0		; Trans flag is in bit 2 of source.
	lsl.b	#5,d0		;		       7 of dest.	
	or.b	d0,10(\2)	;* update
	.endm

; Macro to set an object's RMW
.macro Setobj_Reflect 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_FLAGS(\1),d0			
	and.b	#$02,d0		; RMW flag is in bit 1 of source.		
	lsl.b	#5,d0		;		     6 of dest.
	or.b	d0,10(\2)	;* update
	.endm

; Macro to set an object's Reflect
.macro Setobj_RMW 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_FLAGS(\1),d0			
	and.b	#$01,d0		; Reflect flag is in bit 0 of source.
	lsl.b	#5,d0		;		     5 of dest.			
	or.b	d0,10(\2)	;* update
	.endm

; Macro to set an object's Firstpix
.macro Setobj_Firstpix 		RecordPtrRegister, ObjectPtrRegister
	move.b	O_FIRSTPIX(\1),d0			
**	and.b	#$3f,d0
	lsl.b	#1,d0		
	or.b	d0,9(\2)	;* update
	.endm

; Macro to set an object's Hscale
.macro Setobj_Hscale 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_HSCALE(\1),23(\2)	;* update
	.endm

; Macro to set an object's Vscale
.macro Setobj_Vscale	RecordPtrRegister, ObjectPtrRegister
	move.b	O_VSCALE(\1),22(\2)	;* update
	.endm

; Macro to set an object's Remainder
.macro Setobj_Remainder 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_REMAINDER(\1),21(\2)	;* update
	.endm

; Macro to set an object's Type 
.macro Setobj_Type 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_TYPE(\1),d0	
**	and.b	#$07,d0
	or.b	d0,7(\2)		;* update
	.endm

; Macro to set an object's Depth
.macro Setobj_Depth 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_DEPTH(\1),d0			
**	and.b	#$07,d0
	lsl.b	#4,d0
	or.b	d0,14(\2)		;* update	
	.endm

; Macro to set an object's Pitch
.macro Setobj_Pitch 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_PITCH(\1),d0		; Pitch field destination crosses a word boundary,
	and.l	#$00000007,d0		; so treat it as part of a long.
	swap	d0
	lsr.l	#1,d0		
	or.l	d0,12(\2)		;* update		
	.endm

; Macro to set an object's index attribute 
.macro Setobj_Index 	RecordPtrRegister, ObjectPtrRegister
	move.b	O_INDEX(\1),d0	; Index field destination crosses a word boundary,
	and.l	#$7f,d0		; so treat it as part of a long.
	lsl.l	#6,d0		; shift left 6
	or.l	d0,8(\2)	;* update
	.endm

;end_Macros