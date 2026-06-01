BITMAP_OBJECT   equ     0
SCALED_OBJECT   equ     1
GPU_OBJECT      equ     2
BRANCH_OBJECT   equ     3
STOP_OBJECT     equ     4

BRANCHEQ        equ     00
BRANCHGT        equ     1       ; If YPOS>VC
BRANCHLT        equ     2       ; If YPOS<VC

OPIXEL1 equ     0
OPIXEL2 equ     1
OPIXEL4 equ     2
OPIXEL8 equ     3
OPIXEL16        equ     4
OPIXEL24        equ     5

REFLECT equ     1
RMW     equ     2
TRANS   equ     4
RELEASE equ     8



OBJBITS macro
	moveq   #0,d0
	move.\0  \1(a0),d0
	move.l  d0,d1
	move.l  a1,-(sp)

	ifeq     (\3-2)
	addq.l  #8,a1
	endc
	ifeq    (\3-3)
	addq.l  #8,a1
	addq.l  #8,a1
	endc

	iflt     (\2-32)
	moveq   #\2,d2
	lsl.l   d2,d0
	or.l    d0,4(a1)
	sub.w   #32,d2
	Neg.w   d2
	lsr.l   d2,d1
	or.l    d1,0(a1)
	endc

	ifge     (\2-31)
	moveq   #\2-32,d2
	lsl.l   d2,d0
	or.l    d0,(a1)
	endc

	move.l  (sp)+,a1
	endm   




	RSRESET
; BITMAP OBJECT STRUCTURE
obj_type	rs.w	1
obj_ypos	rs.w	1
obj_height	rs.w	1
obj_link	rs.l	1
obj_data	rs.l	1
obj_xpos	rs.w	1
obj_depth	rs.w	1
obj_pitch	rs.w	1
obj_dwidth	rs.w	1
obj_iwidth	rs.w	1
obj_index	rs.w	1
obj_flags	rs.w	1
obj_firstpix	rs.w	1

;-SCALED BITMAP OBJECT
obj_hscale	rs.w	1 
obj_vscale	rs.w	1 
obj_remainder	rs.w	1 
	
;-BRANCH OBJECT
obj_cc	rs.w	1

		
;-DATA USED FOR STOP AND GPU
obj_gpustop_data	rs.l	2      

object_e	rs.w	1



STACKOBJ	macro
	lea     -object_e(sp),sp
	move.l  sp,a0
	endm

UNSTACKOBJ	macro
	lea     object_e(sp),sp
	endm

clip_bitmap_object: 
	move.w  obj_ypos(a0),d0
	bpl.s   .pos_y
	neg.w   d0
	mulu    obj_dwidth(a0),d0
	lsl.l   #3,d0
	add.l   d0,obj_data(a0)
	clr.w   obj_ypos(a0)
.pos_y: rts     


make_object:    move.w  obj_type(a0),d0
	lsl.w   #2,d0
	jmp     obj_jmp(pc,d0)

obj_jmp:        jmp     bitmap_type(pc)
	jmp     scaled_type(pc)
	jmp     gpu_type(pc)
	jmp     branch_type(pc)
	jmp     stop_type(pc)



bitmap_type:    bsr     make_some_of_bitmap_object
	move.l  a1,obj_link(a0)
	add.l   #16,obj_link(a0)
	OBJBITS.l       obj_link,24-3,1

	moveq   #16,d0
	add.l   d0,a1
	rts    

make_some_of_bitmap_object:
	clr.l   00(a1)
	clr.l   04(a1)
	clr.l   08(a1)
	clr.l   12(a1)
	and.w   #%111111111111,obj_xpos(a0)
	OBJBITS.w       obj_type,0,1
	OBJBITS.w       obj_ypos,3,1
	OBJBITS.w       obj_height,14,1
	OBJBITS.l       obj_data,43-3,1
	OBJBITS.w       obj_xpos,0,2
	OBJBITS.w       obj_depth,12,2
	OBJBITS.w       obj_pitch,15,2
	OBJBITS.w       obj_dwidth,18,2
	OBJBITS.w       obj_iwidth,28,2
	OBJBITS.w       obj_index,38,2
	OBJBITS.w       obj_flags,45,2
	OBJBITS.w       obj_firstpix,49,2
	rts
	
scaled_type:    subq.w  #1,obj_height(a0)
	bsr     make_some_of_bitmap_object
	clr.l   16(a1)
	clr.l   20(a1)
	OBJBITS.w       obj_hscale,0,3
	OBJBITS.w       obj_vscale,8,3
	OBJBITS.w       obj_remainder,16,3
	move.l  a1,obj_link(a0)
	add.l   #24,obj_link(a0)
	OBJBITS.l       obj_link,24-3,1
	moveq   #24,d0
	add.l   d0,a1
	rts    

gpu_type:  	clr.l   00(a1)
	clr.l   04(a1)
	OBJBITS.w       obj_type,0,1
	OBJBITS.w       obj_ypos,3,1
	OBJBITS.l       obj_data,16,1
	moveq   #8,d0
	add.l   d0,a1
	rts

branch_type:    	clr.l   00(a1)
	clr.l   04(a1)
	OBJBITS.w       obj_type,0,1
	OBJBITS.w       obj_ypos,3,1
	OBJBITS.w       obj_cc,14,1
	OBJBITS.l       obj_link,24-3,1
	moveq   #8,d0
	add.l   d0,a1
	rts

stop_type:      
	clr.l   00(a1)
	clr.l   04(a1)
	OBJBITS.w       obj_type,0,1
	moveq   #8,d0
	add.l   d0,a1
	rts



fix_object_boundry:
	move.l  a0,-(sp)
	move.l  a1,d1
	move.l  d1,d2
	add.l   d0,d1
	subq.l  #1,d0
	not.l   d0
	and.l   d0,d1
	sub.l   d1,d2
	neg.l   d2
	move.l  d2,-(sp)
	STACKOBJ        
	move.w  #BRANCH_OBJECT,obj_type(a0)
	move.l  d1,obj_link(a0)
	move.l  d1,-(sp)
	move.w  #BRANCHEQ,obj_cc(a0)
	move.w  #$7ff,obj_ypos(a0)      
	bsr     make_object
	move.l  (sp)+,a1
	UNSTACKOBJ      
	move.l  (sp)+,d0
	move.l  (sp)+,a0
	rts
