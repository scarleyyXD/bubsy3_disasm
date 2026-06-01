	cmp.w	#(disp_height+disp_change),screen_height
	beq	.done
	move.w	#(disp_height+disp_change),screen_height
	lea	pal_mus_start,a0
	lea	pal_mus_end-pal_mus_start(a0),a1
.clp:	move.w	#$4e71,(a0)+
	cmp.l	a0,a1
	bne.s	.clp
	move.w	#pal_n_vde+1,CHANGE5+2			;set new line for the interrupt

	move.w	#((disp_height-32+disp_change)*2+ntsc_n_vdb)*8-((disp_height-32)*2+ntsc_n_vdb)*8,d0
	
;;	add.w	d0,OVER1+2
	add.w	d0,OVER2+2
	add.w	d0,OVER3+2
	add.w	d0,OVER4+2
	add.w	d0,OVER5+2
	
	
	
	move	#pal_n_vde,OVER9+2

	lea	OVER_TABLE_START+4,a0
	lea	OVER_TABLE_END-OVER_TABLE_START(a0),a1
.clp1:	add.w	d0,(a0)
	addq	#6,a0
	cmp.l	a0,a1
	bne.s	.clp1
	move.w	#50,FrameRate

	move.w	#$e8,d0
	move.w	d0,OVER2A+2
	move.w	d0,OVER2B+2
	
	moveq	#10,d0
	add.b	d0,PLRTXT1+2
	add.b	d0,PLRTXT2+2
	add.b	d0,PLRTXT3+2

	moveq	#10,d0
	add.b	d0,JMPTXT1+2
	add.b	d0,JMPTXT2+2
	add.b	d0,JMPTXT3+2
	add.b	d0,JMPTXT4+2
	add.b	d0,JMPTXT5+2
	add.b	d0,JMPTXT6+2

	moveq	#10,d0
	add.b	d0,JMPTXT12+2
	add.b	d0,JMPTXT22+2
	add.b	d0,JMPTXT32+2
	add.b	d0,JMPTXT42+2
	add.b	d0,JMPTXT52+2
	add.b	d0,JMPTXT62+2

	moveq	#40,d0
	add.b	d0,STARTTEXT+2

	moveq	#40,d0
	add.b	d0,CREDITTXT+2
	
	moveq	#40,d0
	add.b	d0,ENTPASTXT+2
	add.b	d0,PASTXT+2
	add.b	d0,PASTXT1+2
	add.b	d0,PASTXT2+2

.done:

