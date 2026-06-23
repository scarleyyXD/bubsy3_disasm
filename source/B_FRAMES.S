.macro	reset_bubsy_frame
	b_frame	set	0
	.endm
	
.macro	skip_frame
	b_frame	set	b_frame+1
	.endm

.macro	add_frame_to_bubsy
	\1	equ	b_frame
	b_frame	set	b_frame+1
	.endm

	reset_bubsy_frame
	add_frame_to_bubsy	RUN1TILES	;0
	add_frame_to_bubsy	RUN2TILES
	add_frame_to_bubsy	RUN3TILES
	add_frame_to_bubsy	RUN4TILES
	add_frame_to_bubsy	RUN5TILES
	add_frame_to_bubsy	RUN6TILES	;5
	add_frame_to_bubsy	IDLE1TILES
	add_frame_to_bubsy	IDLE2TILES
	add_frame_to_bubsy	IDLE3TILES
	add_frame_to_bubsy	IDLE4TILES
	add_frame_to_bubsy	IDLE5TILES	;10
	add_frame_to_bubsy	IDLE6TILES
	add_frame_to_bubsy	IDLE7TILES
	add_frame_to_bubsy	IDLE8TILES
	add_frame_to_bubsy	IDLE9TILES
	add_frame_to_bubsy	FIGHT1TILES	;15
	add_frame_to_bubsy	FIGHT2TILES
	add_frame_to_bubsy	FIGHT3TILES
	add_frame_to_bubsy	FIGHT4TILES
	add_frame_to_bubsy	FIGHT5TILES
	add_frame_to_bubsy	SKID1TILES 	;20
	add_frame_to_bubsy	SKID2TILES
	add_frame_to_bubsy	SKID3TILES
	add_frame_to_bubsy	SKID4TILES
	add_frame_to_bubsy	SKID5TILES
	add_frame_to_bubsy	JUMP1TILES	;25
	add_frame_to_bubsy	JUMP2TILES
	add_frame_to_bubsy	JUMP3TILES
	add_frame_to_bubsy	JUMP4TILES
	add_frame_to_bubsy	JUMP5TILES
	add_frame_to_bubsy	JUMP6TILES	;30
	add_frame_to_bubsy	JUMP7TILES
	add_frame_to_bubsy	JUMPUP1TILES
	add_frame_to_bubsy	GLIDE0TILES
	add_frame_to_bubsy	GLIDE1TILES
	add_frame_to_bubsy	GLIDE2TILES	; 35
	add_frame_to_bubsy	SHATTER0TILES
	add_frame_to_bubsy	SHATTER1TILES
	add_frame_to_bubsy	SHATTER2TILES
	add_frame_to_bubsy	SHATTER3TILES
	add_frame_to_bubsy	SHATTER4TILES	; 40
	add_frame_to_bubsy	BUBSPIN00
	add_frame_to_bubsy	BUBSPIN01
	add_frame_to_bubsy	BUBSPIN02
	add_frame_to_bubsy	BUBSPIN03
	add_frame_to_bubsy	BUBLOOKUP0
	add_frame_to_bubsy	BUBLOOKDOWN0
	add_frame_to_bubsy	BUBDUCK0
	add_frame_to_bubsy	BUBDUCK1
	add_frame_to_bubsy	WARPFRAME
	add_frame_to_bubsy	CURSOR0	; 50
	add_frame_to_bubsy	CURSOR1
	add_frame_to_bubsy	CURSOR2
	add_frame_to_bubsy	SHAKEWATER0
	add_frame_to_bubsy	SHAKEWATER1
	add_frame_to_bubsy	SHAKEWATER2
	add_frame_to_bubsy	SHAKEWATER3
	add_frame_to_bubsy	SHAKEWATER4
	add_frame_to_bubsy	SHAKEWATER5
	add_frame_to_bubsy	SHAKEWATER6
	add_frame_to_bubsy	SHAKEWATER7	; 60
	add_frame_to_bubsy	BIGSMILE0
	add_frame_to_bubsy	PUFF0
	add_frame_to_bubsy	PUFF1
	add_frame_to_bubsy	SQUISH0
	add_frame_to_bubsy	SQUISH1
	add_frame_to_bubsy	SQUISH2
	add_frame_to_bubsy	SQUISH3
	add_frame_to_bubsy	SQUISH4
	add_frame_to_bubsy	SQUISH5
	add_frame_to_bubsy	SQUISH6		; 70
	add_frame_to_bubsy	SQUISH7
	add_frame_to_bubsy	SQUISH8
	add_frame_to_bubsy	SQUISH9
	add_frame_to_bubsy	BYEBYE0
	add_frame_to_bubsy	BYEBYE1
	add_frame_to_bubsy	BYEBYE2
	add_frame_to_bubsy	BYEBYE3
	add_frame_to_bubsy	BYEBYE4
	add_frame_to_bubsy	BYEBYE5
	add_frame_to_bubsy	BYEBYE6		; 80
	add_frame_to_bubsy	SMASH0
	add_frame_to_bubsy	SMASH1
	add_frame_to_bubsy	SMASH2
	add_frame_to_bubsy	SMASH3
	add_frame_to_bubsy	UNC0
	add_frame_to_bubsy	SWIPE0
	add_frame_to_bubsy	SWIPE1
	add_frame_to_bubsy	SWIPE2
	add_frame_to_bubsy	SWIPE3
	add_frame_to_bubsy	PUSH0		; 90
	add_frame_to_bubsy	PUSH1
	add_frame_to_bubsy	PUSH2
	add_frame_to_bubsy	PUSH3
	add_frame_to_bubsy	PUSH4
	add_frame_to_bubsy	PUSH5
	add_frame_to_bubsy	BUBRUNDN0	 
	add_frame_to_bubsy	BUBRUNDN1
	add_frame_to_bubsy	BUBRUNDN2
	add_frame_to_bubsy	BUBRUNDN3
	add_frame_to_bubsy	BUBRUNDN4	; 100
	add_frame_to_bubsy	BUBRUNDN5
	add_frame_to_bubsy	BUBRUNUP0	 
	add_frame_to_bubsy	BUBRUNUP1
	add_frame_to_bubsy	BUBRUNUP2
	add_frame_to_bubsy	BUBRUNUP3
	add_frame_to_bubsy	BUBRUNUP4
	add_frame_to_bubsy	BUBRUNUP5
	add_frame_to_bubsy	READY0
	add_frame_to_bubsy	READY1
	add_frame_to_bubsy	READY2		; 110
	add_frame_to_bubsy	HHIT0
	add_frame_to_bubsy	HHIT1
	add_frame_to_bubsy	HHIT2
	add_frame_to_bubsy	HHIT3
	add_frame_to_bubsy	VHIT0
	add_frame_to_bubsy	VHIT1
	add_frame_to_bubsy	VHIT2
	add_frame_to_bubsy	VHIT3
	add_frame_to_bubsy	DROWN0
	add_frame_to_bubsy	DROWN1		; 120
	add_frame_to_bubsy	DROWN2
	add_frame_to_bubsy	DROWN3
	add_frame_to_bubsy	DROWN4
	add_frame_to_bubsy	DROWN5
	add_frame_to_bubsy	DROWN6
	add_frame_to_bubsy	DROWN7
	add_frame_to_bubsy	DROWN8
	add_frame_to_bubsy	FADE0
	add_frame_to_bubsy	FADE1
	add_frame_to_bubsy	FADE2		; 130
	add_frame_to_bubsy	FADE3
	add_frame_to_bubsy	FADE4
	add_frame_to_bubsy	FALLBACK0
	add_frame_to_bubsy	FALLBACK1
	add_frame_to_bubsy	FALLBACK2
	add_frame_to_bubsy	HITNS0
	add_frame_to_bubsy	HITNS1
	add_frame_to_bubsy	HITNS2
	add_frame_to_bubsy	HITNS3
	add_frame_to_bubsy	LAUGH0		; 140
	add_frame_to_bubsy	LAUGH1
	add_frame_to_bubsy	MELT0
	add_frame_to_bubsy	MELT1
	add_frame_to_bubsy	MELT2
	add_frame_to_bubsy	MELT3
	add_frame_to_bubsy	MELT4
	add_frame_to_bubsy	MELT5
	add_frame_to_bubsy	MELT6
	add_frame_to_bubsy	MELT7
	add_frame_to_bubsy	SPLIT0		; 150
	add_frame_to_bubsy	SPLIT1
	add_frame_to_bubsy	SPLIT2
	add_frame_to_bubsy	SPLIT3
	add_frame_to_bubsy	TAKES0
	add_frame_to_bubsy	TAKES1
	add_frame_to_bubsy	TAKES2
	add_frame_to_bubsy	TAKES3
	add_frame_to_bubsy	TAKES4
	add_frame_to_bubsy	TAKES5
	add_frame_to_bubsy	TAKES6		; 160
	add_frame_to_bubsy	TAKES7
	add_frame_to_bubsy	BAL10
	add_frame_to_bubsy	BAL11
	add_frame_to_bubsy	BAL12
	add_frame_to_bubsy	BAL13
	add_frame_to_bubsy	BAL14
	add_frame_to_bubsy	CONV0
	add_frame_to_bubsy	CONV1
	add_frame_to_bubsy	CONV2
	add_frame_to_bubsy	BUBSHELL	; 170
	skip_frame
	add_frame_to_bubsy	CAVEWKIN0
	add_frame_to_bubsy	CAVEWKIN1
	add_frame_to_bubsy	CAVEWKIN2
	add_frame_to_bubsy	CAVEWKIN3
	add_frame_to_bubsy	CAVEWKIN4
	add_frame_to_bubsy	CAVEWKIN5
	add_frame_to_bubsy	CAVWKOUT0
	add_frame_to_bubsy	CAVWKOUT1
	add_frame_to_bubsy	CAVWKOUT2	; 180
	add_frame_to_bubsy	CAVWKOUT3
	add_frame_to_bubsy	CAVWKOUT4
	add_frame_to_bubsy	CAVWKOUT5
	add_frame_to_bubsy	BANANA0
	add_frame_to_bubsy	BANANA1
	add_frame_to_bubsy	NOTIME0
	add_frame_to_bubsy	NOTIME1
	add_frame_to_bubsy	NOTIME2
	add_frame_to_bubsy	NOTIME3
	add_frame_to_bubsy	NOTIME4		;190
	add_frame_to_bubsy	NOTIME5
	add_frame_to_bubsy	NOTIME6
	add_frame_to_bubsy	NOTIME7
	add_frame_to_bubsy	NOTIME8
	add_frame_to_bubsy	NOTIME9
	add_frame_to_bubsy	NOTIMEA
	add_frame_to_bubsy	NOTIMEB
	add_frame_to_bubsy	POP0
	add_frame_to_bubsy	POP1
	add_frame_to_bubsy	POP2		; 200
	add_frame_to_bubsy	POP3
	add_frame_to_bubsy	POP4
	add_frame_to_bubsy	POP5
	add_frame_to_bubsy	POP6
	add_frame_to_bubsy	POP7
	add_frame_to_bubsy	POP8
	add_frame_to_bubsy	POP9		; 207
	skip_frame
	skip_frame
	skip_frame				; 210
	add_frame_to_bubsy	HOORAY0
	add_frame_to_bubsy	HOORAY1
	add_frame_to_bubsy	HOORAY3
	add_frame_to_bubsy	HOORAY4
	add_frame_to_bubsy	HOORAY5
	add_frame_to_bubsy	BAL15
	add_frame_to_bubsy	RIDE0
	add_frame_to_bubsy	RIDE1
	add_frame_to_bubsy	RIDE2
	add_frame_to_bubsy	RIDE3		; 220
	add_frame_to_bubsy	RUN7TILES
	add_frame_to_bubsy	RUN8TILES
	add_frame_to_bubsy	BUBRUNDN6
	add_frame_to_bubsy	BUBRUNDN7
	add_frame_to_bubsy	BUBRUNUP6	 
	add_frame_to_bubsy	BUBRUNUP7