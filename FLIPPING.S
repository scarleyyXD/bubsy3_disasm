bubctrl.s 197: 	or.w	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 206: 	and.w	#~BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 390: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 842: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS									;VX is +ive
bubctrl.s 845: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 1223: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 1237: 	and.w	#~BUBSYHFLIP,d0
bubctrl.s 1245: 	and.w	#BUBSYHFLIP,d0
bubctrl.s 1638: 	and.b	#~BUBSYHFLIP,d0
bubctrl.s 1641: 	or.b	#BUBSYHFLIP,d0
bubctrl.s 1789: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 1793: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 2189: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 2221: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS						;face bubsy forward for backward landng
bubctrl.s 2224: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 2294: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 2345: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 2348: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 3062: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS						;VX is positive
bubctrl.s 3067: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 3095: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 3101: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 3111: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 3139: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 3147: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 3155: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 3276: 	moveq	#BUBSYHFLIP,d0
bubctrl.s 3292: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 3308: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS
bubctrl.s 3314: 	and.b	#~BUBSYHFLIP,BUBSYFLAGS						;face if no button pressed
bubctrl.s 3317: 	or.b	#BUBSYHFLIP,BUBSYFLAGS
bubequ.s 178: BUBSYHFLIP	EQU	%01000000
bubequ.s 185: bBUBSYHFLIP	EQU	6
loadcode.s 34: 	ori.b	#BUBSYHFLIP,BUBSYFLAGS			; LOOKING UP LEFT AT THE SCORE
loadcode.s 66: 	ori.b	#BUBSYHFLIP,BUBSYFLAGS
loadcode.s 77: 	ori.b	#BUBSYHFLIP,BUBSYFLAGS
lvlinit.s 940: 	dc.b	0,0,BUBSYHFLIP			;ali baba
lvlinit.s 941: 	dc.b	BUBSYHFLIP,0,BUBSYHFLIP		;jack & bean
lvlinit.s 944: 	dc.b	0,0,BUBSYHFLIP			;alice in wonderland
setoverl.s 11: BUBSYH_NUMBER	EQU	4
setoverl.s 27: BUBSYH_X	EQU	(SCR_OFF+256-16)
setoverl.s 37: BUBSYX_X	EQU	BUBSYH_X+16
setoverl.s 417: 	DC.W	BUBSYH_NUMBER,BUBSYH_X,BOTTOM_Y				;	BUBSY'S HEAD
setupbub.s 46: 	moveq	#BUBSYHFLIP,D3
