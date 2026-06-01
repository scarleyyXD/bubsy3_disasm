BUBSYXOFFSET:
	dc.b	$ec	; RUN	;0
	dc.b	$ee
	dc.b	$f4
	dc.b	-15
	dc.b	-21
	dc.b	-19
	dc.b	($EE+8)	; IDLE
	dc.b	($EE+8)
	dc.b	($ef+8)
	dc.b	($ef+8)
	dc.b	($ee+8)		;10
	dc.b	($F0+8)
	dc.b	($E3+8)
	dc.b	($E3+8)
	dc.b	($E3+8)
	dc.b	-30	; FIGHT
	dc.b	$e5
	dc.b	-31
	dc.b	-32
	dc.b	-32
	dc.b	$E7	; SKID	;20
	dc.b	$E6
	dc.b	$E7
	dc.b	$E4
	dc.b	$E4
	dc.b	$F6	; JUMP
	dc.b	$E9
	dc.b	$F1
	dc.b	$F6
	dc.b	$E8
	dc.b	$ED	;30 THIS IS FRAME COMING DOWN, CHANGE COULD EASE COLLISION PROBLEMS
	dc.b	$EF
	dc.b	$FA	; JUMPUP
	dc.b	$E6	; GLIDE
	dc.b	$E5
	dc.b	$E4
	dc.b 	$F0	; SHATTER
	dc.b	$f0
	dc.b	$f0
	dc.b	$f0
	dc.b	$ed	;40
	dc.b	$E7	; SPIN
	dc.b	$E5
	dc.b	$E7
	dc.b	$EC
	dc.b	$EE	; LOOKUP
	dc.b	$F1	; LOOKDOWN
	dc.b	$F1	; DUCK
	dc.b	$F1
	dc.b 	$00	; LEVEL EDIT CURSOR
	dc.b	$fc	;50
	dc.b	$fc
	dc.b	$fc
	dc.b	$EF	; SHAKEWATER
	dc.b	$F0
	dc.b	$F0
	dc.b	$EF
	dc.b	$EF
	dc.b	$E8
	dc.b	$E8
	dc.b	$E7	;60
	dc.b	$F0	; BIGSMILE
	dc.b	$F0	; PUFF
	dc.b	$F0
	dc.b 	$E8	; SQUISH
	dc.b	$e4
	dc.b	$e4
	dc.b	$ee
	dc.b 	$EE
	dc.b	$ee
	dc.b	$ee	;70
	dc.b	$ee
	dc.b 	$EE
	dc.b	$ee
	dc.b 	$F1	; BYEBYE
	dc.b	$f1
	dc.b	$f1
	dc.b	$f1
	dc.b 	$F1
	dc.b	$f1
	dc.b	$f0	;80
	dc.b	($f1+16)&$ff	; SMASH
	dc.b	($ed+16)&$ff
	dc.b	($Eb+16)&$ff
	dc.b	($f1+16)&$ff
	dc.b	($cd+16)&$ff	; UNCONCIOUS
	dc.b	($D8+16)&$ff	; SWIPE
	dc.b	($D8+16)&$ff
	dc.b	($dc+16)&$ff
	dc.b	($D9+16)&$ff
	dc.b	$d9+16	; 90 PUSH
	dc.b	$d9+16
	dc.b	$dd+16
	dc.b	$d8+16
	dc.b	$d6+16
	dc.b	$dc+16
	dc.b	-16	; RUN DOWN
	dc.b	$f4
	dc.b	-21
	dc.b	-20
	dc.b	-17	;100
	dc.b	-18
	dc.b	-12-5+2	; RUN UP
	dc.b	-16-5+2
	dc.b	-19-5+2
	dc.b	-19-5+2
	dc.b	-14-5+2
	dc.b	-17-5+2
	dc.b	$F0	; READY
	dc.b	$F3
	dc.b	$F3	;110
	dc.b	$F1	; HHIT STARS
	dc.b	$EE
	dc.b	$E8
	dc.b	$E7
	dc.b	$F1	; VHIT STARS
	dc.b	$F0
	dc.b	$EE
	dc.b	$E8
	dc.b	0-$0C 	; DROWN
	dc.b	0-$0E	;120
	dc.b	0-$0E
	dc.b	0-$13
	dc.b	0-$13
	dc.b	0-$16
	dc.b	$e7
	dc.b	$e2
	dc.b	$f0
	dc.b	0-$10	; FADE
	dc.b	0-$10
	dc.b	0-$10	;130
	dc.b	0-$10
	dc.b	0-$10
	dc.b	$f0	; FALLBACK
	dc.b	$f1
	dc.b	0-$12
	dc.b	$F1	; VHIT NO STARS
	dc.b	$EF
	dc.b	$F1
	dc.b	$ED
	dc.b 	$0	;140
	dc.b	$1	; LAUGH
	dc.b	0-$0F	; MELT
	dc.b	0-$0F
	dc.b	0-$0F
	dc.b	0-$13
	dc.b	0-$16
	dc.b	0-$19
	dc.b	0-$1C
	dc.b	0-$1D
	dc.b	0-$10	; 150 SPLIT
	dc.b	0-$12
	dc.b	0-$2E
	dc.b	0-$39
	dc.b	$E9	; TAKES
	dc.b	$E9
	dc.b	$F1
	dc.b	$F1
	dc.b	$E9
	dc.b	$E9
	dc.b	$E8	;160
	dc.b	$E7
	dc.b	$f4	; BAL1
	dc.b	$f5
	dc.b	$f6
	dc.b	$f0	; BAL2
	dc.b	$f0
	dc.b	$F5	; CONVERTABLE
	dc.b	$FC
	dc.b	$FC
	dc.b	0	;170
	dc.b	0
	dc.b	$F3	; CAVE WALK IN
	dc.b	$F3
	dc.b	$F3
	dc.b	$F3
	dc.b	$F3
	dc.b	$F3
	dc.b	$F2	; CAVE WALK OUT
	dc.b	$F2
	dc.b	$F2	;180
	dc.b	$F2
	dc.b	$F2
	dc.b	$F2
	dc.b	$EE	; BANANA
	dc.b	$E8
	dc.b	$F1	; NOTIME
	dc.b	$F1
	dc.b	$F1
	dc.b	$F1
	dc.b	$F2	;190
	dc.b	$F2
	dc.b	$F1
	dc.b	$F1
	dc.b	$F1
	dc.b	$F1
	dc.b	$F1
	dc.b	$F1
	dc.b	$E6	; POP
	dc.b	$E4
	dc.b	$ED	;200
	dc.b	$EC
	dc.b	$E1
	dc.b	$E3
	dc.b	$F1
	dc.b	$E2
	dc.b	$E1
	dc.b	$EB
	dc.b	0
	dc.b	0
	dc.b	0	;210
	dc.b	$F2	; HOORAY
	dc.b	$F2
	dc.b	$F1
	dc.b	$F1
	dc.b	$EF
	dc.b	$F6-4	; BALANCE 1 END
	dc.b	$EF	; RIDE
	dc.b	$FB
	dc.b	$F5
	dc.b	$EF	; 220 COASTER RIDE
	dc.b	-12	; RUN
	dc.b	-14
	dc.b	-22	; RUN DOWN
	dc.b	-19
	dc.b	-18	; RUN UP
	dc.b	-17

BUBSYYOFFSET:
	dc.b	$d7	;0	; RUN
	dc.b	$d7
	dc.b	$d3
	dc.b	-43
	dc.b	$d8
	dc.b	-41
	dc.b	$D2-1	; IDLE
	dc.b	$D2-1
	dc.b	$D3-1
	dc.b	$d1
	dc.b	$d1	;10
	dc.b	$D4-1
	dc.b	$D0
	dc.b	$D0
	dc.b	$D1
	dc.b	-57	; FIGHT
	dc.b	-59
	dc.b	-54
	dc.b	-58
	dc.b	-60
	dc.b	$D6	; 20 SKID
	dc.b	$D7
	dc.b	$D8
	dc.b	$D7
	dc.b	$D7
	dc.b	$df		; JUMP
	dc.b	$E1
	dc.b	$E6
	dc.b	$DD
	dc.b	$E1
	dc.b	$d4	;30
	dc.b	$de
	dc.b	$c9		; JUMP UP
	dc.b	$EB
	dc.b	$E9
	dc.b	$EA
	dc.b 	$d2
	dc.b	$d2
	dc.b	$De
	dc.b	$EC
	dc.b	$f1	;40  SHATTER
	dc.b	$EA	; SPIN
	dc.b	$E8
	dc.b	$E4
	dc.b	$E9
	dc.b	$D4	; LOOKUP
	dc.b	$de	;	$E0	; LOOKDOWN
	dc.b	$e3	;$DF	; DUCK1
	dc.b	$E4	; DUCK2
	dc.b 	$FE
	dc.b	$FC	;50
	dc.b	$FC
	dc.b	$FC	; SPIN VRAMBOX
	dc.b	$D6	; SHAKE WATER
	dc.b	$D5
	dc.b	$D9
	dc.b	$D8
	dc.b	$D5
	dc.b	$D5
	dc.b	$D5
	dc.b	$D5	;60
	dc.b	$D2	; BIGSMILE
	dc.b	$D3 	; PUFF
	dc.b	$D3 
	dc.b 	$E5
	dc.b	$F6
	dc.b	$E6
	dc.b	$D8	; SQUISH
	dc.b 	$D8
	dc.b	$D5
	dc.b	$D0	;70
	dc.b	$Cd
	dc.b 	$D0
	dc.b	$D4
	dc.b 	$D1
	dc.b	$D1
	dc.b	$D1
	dc.b	$D1	; BYEBYE
	dc.b 	$D1
	dc.b	$D1
	dc.b	$E1	;80
	dc.b	$D1	; SMASH
	dc.b	$D1
	dc.b	$Cc
	dc.b	$D1
	dc.b	$F0	; UNCONCIOUS
	dc.b	$E2	; SWIPE
	dc.b	$E2
	dc.b	$Db
	dc.b	$de
	dc.b	$D4	; 90 PUSH
	dc.b	$D4
	dc.b	$ce
	dc.b	$ce
	dc.b	$cc
	dc.b	$ca
	dc.b	$d7	; RUN DOWN
	dc.b	$d6
	dc.b	-48
	dc.b	-49
	dc.b	-43	;100
	dc.b	-47
	dc.b	-48+5	; RUN UP
	dc.b	-46+5
	dc.b	-48+5+2
	dc.b	-46+5
	dc.b	-45+5
	dc.b	-47+5
	dc.b	$DE	; READY
	dc.b	$E7
	dc.b	$E7	;110
	dc.b	$D4		; HHIT STARS
	dc.b	$CD
	dc.b	$D2
	dc.b	$D0
	dc.b	$D7		; VHIT STARS
	dc.b	$DC
	dc.b	$D6
	dc.b	$de
	dc.b	8-$1B		; DROWN
	dc.b	8-$20	;120
	dc.b	8-$20
	dc.b	8-$1B
	dc.b	8-$1B
	dc.b	8-$1B
	dc.b	$d0+8
	dc.b	$e8+8
	dc.b	($f2+16)&$ff
	dc.b	0-$2D		; FADE
	dc.b	0-$2D
	dc.b	0-$2D	;130
	dc.b	0-$2D
	dc.b	0-$2D
	dc.b	$d7		; FALLBACK
	dc.b	$E1
	dc.b	0-$0F
	dc.b	$D6 		; VHIT NO STARS
	dc.b	$DB
	dc.b	$D6
	dc.b	$DB
	dc.b 	$0	;140
	dc.b	$0		; LAUGH
	dc.b	$d4		; MELT
	dc.b	$d4
	dc.b	$D2
	dc.b	$d8
	dc.b	$dd
	dc.b	$e6
	dc.b	$f3
	dc.b	$fb
	dc.b	$d2	;150	; SPLIT
	dc.b	0-$2E
	dc.b	$de
	dc.b	0-$0E
	dc.b	$EC	; TAKES
	dc.b	$E9
	dc.b	$CF
	dc.b	$CF
	dc.b	$EC
	dc.b	$EB
	dc.b	$D5	;160
	dc.b	$D7
	dc.b	$ca	; BALANCE 0
	dc.b	$d2
	dc.b	$d0
	dc.b	$Ce	; BALAANCE 1
	dc.b	$cd
	dc.b	$C6		; CONVERTABLE
	dc.b	$DD
	dc.b	$DD
	dc.b	0	;170
	dc.b	0
	dc.b	$d2	; CAVEWALKIN
	dc.b	$D2
	dc.b	$D1
	dc.b	$D2
	dc.b	$D2
	dc.b	$D2
	dc.b	$D2	; CAVEWALKOUT
	dc.b	$D1
	dc.b	$D1	;180
	dc.b	$D3
	dc.b	$D4
	dc.b	$D1
	dc.b	$D7	; BANANA
	dc.b	$D6
	dc.b	$D2		; NOTIME
	dc.b	$D2
	dc.b	$D2
	dc.b	$D1
	dc.b	$cf	;190
	dc.b	$cf
	dc.b	$D1
	dc.b	$D1
	dc.b	$D1
	dc.b	$D1
	dc.b	$D1
	dc.b	$D1
	dc.b	$D1		; POP
	dc.b	$D2
	dc.b	$D1	;200
	dc.b	$D2
	dc.b	$E0
	dc.b	$D5
	dc.b	$CC
	dc.b	$D2
	dc.b	$DF
	dc.b	$CF
	dc.b	0
	dc.b	0
	dc.b	0	;210
	dc.b	$D0	; HOORAY
	dc.b	$D0
	dc.b	$D3
	dc.b	$CF
	dc.b	$D0
	dc.b	$D2-5	; BALANCE 1 END
	dc.b	$C7	; RIDE
	dc.b	$CA
	dc.b	$C5
	dc.b	$C5	; 220 COASTER RIDE
	dc.b	-45	; RUN
	dc.b	-43
	dc.b	-48	; RUN DOWN
	dc.b	-43
	dc.b	-48	; RUN UP
	dc.b	-47

;************************************************************************
;*								 	*
;*	BOXES								*
;*									*
;************************************************************************
 	even
BUBSYBOX1:
	dc.w	$FFFE,$FFDD,$000D,$FFEA	; RUN
	dc.w	$FFFE,$FFDC,$000C,$FFEA
	dc.w	$FFFE,$FFD8,$000D,$FFE6
	dc.w	$FFFF,$FFDE,$000D,$FFEA
	dc.w	$0000,$FFDE,$000E,$FFEA
	dc.w	$0000,$FFDA,$000D,$FFE6
	dc.w	($FFF8+8)&$ffff,$FFE6,($0001+8)&$ffff,$0000	; IDLE
	dc.w	($FFF9+8)&$ffff,$FFE6,($0002+8)&$ffff,$0000
	dc.w	($FFF7+8)&$ffff,$FFE6,($0001+8)&$ffff,$0000
	dc.w	($FFF6+8)&$ffff,$FFE6,($0001+8)&$ffff,$0000
	dc.w	($FFF6+8)&$ffff,$FFE6,($0001+8)&$ffff,$0000
	dc.w	($FFF6+8)&$ffff,$FFE6,($0001+8)&$ffff,$0000
	dc.w	($FFF8+8)&$ffff,$FFD9,($0004+8)&$ffff,$0000
	dc.w	($FFF6+8)&$ffff,$FFDA,($0006+8)&$ffff,$0000
	dc.w	($FFF9+8)&$ffff,$FFDA,($0004+8)&$ffff,$0000
	dc.w	$FFF6,$FFE4,$000D,$FFF6	;15 fight
	dc.w	$FFF6,$FFE4,$000C,$FFF7
	dc.w	$FFF9,$FFE2,$0009,$FFF7
	dc.w	$FFF9,$FFE4,$0007,$FFF9
	dc.w	$FFF7,$FFE3,$0009,$FFF8
	dc.w	$FFF0,$FFDB,$FFFB,$FFF6	;20
	dc.w	$FFF1,$FFDC,$FFFC,$FFE9
	dc.w	$FFF1,$FFDE,$0001,$FFE9
	dc.w	$FFEB,$FFDC,$FFFB,$FFEA
	dc.w	$FFF0,$FFDF,$0006,$FFE7
	dc.w	$FFFB,$FFFB,$000A,$0001	; JUMP
	dc.w	$FFEC,$FFF5,$FFFC,$FFFA
	dc.w	$FFF4,$FFE7,$FFFD,$FFF4
	dc.w	$FFFD,$FFDF,$0006,$FFE8
	dc.w	$0004,$FFE4,$0011,$FFF5
	dc.w	$FFF9,$FFDE,$0003,$FFF8
	dc.w	$FFFA,$FFE7,$0003,$FFFB
	dc.w	$FFFE,$FFF5,$0008,$0001	; JUMP UP
	dc.w	$FFF8,$FFF7,$0015,$FFFD	; GLIDE
	dc.w	$FFF6,$FFF1,$0014,$FFFA
	dc.w	$FFF5,$FFF3,$0013,$FFFC
	dc.w	$FFF7,$FFD6,$0000,$FFE6	; 36 SHATTER
	dc.w	$FFF7,$FFD6,$0000,$FFE6
	dc.w	$FFF7,$FFD6,$0000,$FFE6
	dc.w	$FFF7,$FFD6,$0000,$FFE6
	dc.w	$FFF7,$FFD6,$0000,$FFE6
	dc.w	$000A,$FFEC,$0012,$FFF7	; SPIN
	dc.w	$FFE6,$FFF1,$FFF5,$FFF7
	dc.w	$FFFF,$FFEE,$000F,$FFFB
	dc.w	$000C,$FFEE,$0012,$FFF6
	dc.w	$FFF3,$FFFC,$000D,$0001	; LOOKUP
	dc.w	$FFF8,$FFED,$000C,$FFFD	; LOOKDOWN
	dc.w	$FFF8,$FFE8,$0009,$FFFE	; DUCK
	dc.w	$FFF9,$FFEC,$000C,$FFFB
	dc.w	$0000,$0000,$0000,$0000	; 49
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$FFF7,$FFE1,$0009,$FFF2	; SHAKE WATER
	dc.w	$FFF7,$FFE2,$000A,$FFF2
	dc.w	$FFF7,$FFE2,$000A,$FFF3
	dc.w	$0002,$FFE1,$000A,$FFF3
	dc.w	$FFF8,$FFE2,$0008,$FFF4
	dc.w	$FFF2,$FFE2,$0002,$FFF4
	dc.w	$FFF5,$FFE4,$0008,$FFF4
	dc.w	$FFF7,$FFE4,$000A,$FFF0
	dc.w	$FFF3,$FFF0,$000C,$FFF3	; BIGSMILE
	dc.w	$FFF1,$FFEF,$000E,$FFF4	; PUFF
	dc.w	$FFF1,$FFEF,$000E,$FFF4
	dc.w	$FFF7,$FFD6,$0003,$0008	; 64 SQUISH
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	 ; 74 BYEBYE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFFE,$FFFA,$0007,$FFFF	; SMASH
	dc.w	$FFFE,$FFF9,$0007,$FFFF
	dc.w	$FFFE,$FFF9,$0006,$FFFF
	dc.w	$FFFF,$FFF9,$0006,$FFFF
	dc.w	$FFFE,$FFF3,$0002,$FFFA	; UNCONCIOUS
	dc.w	$FFFE,$FFF5,$0003,$FFFC	; SWIPE
	dc.w	$FFFE,$FFF5,$0003,$FFFD
	dc.w	$FFFC,$FFF2,$0004,$FFFB
	dc.w	$FFFC,$FFF8,$0005,$0001
	dc.w	$FFFD,$FFE0,$000C,$FFEB	; PUSH
	dc.w	$0000,$FFDE,$000D,$FFEA
	dc.w	$FFFD,$FFDE,$000C,$FFEB
	dc.w	$FFFC,$FFDE,$000B,$FFEB
	dc.w	$FFFD,$FFDD,$000C,$FFEB
	dc.w	$FFFF,$FFDD,$000E,$FFEB
	dc.w	$000E,$FFE0,$001E,$FFEE	; RUN DOWN
	dc.w	$000F,$FFE3,$001C,$FFF1
	dc.w	$000F,$FFE0,$001E,$FFEE
	dc.w	$000F,$FFE0,$001E,$FFEE
	dc.w	$000E,$FFE4,$001C,$FFF0
	dc.w	$000D,$FFE0,$001D,$FFED
	dc.w	$FFF0,$FFDC,$FFFD,$FFE9	; RUN UP
	dc.w	$FFF2,$FFDD,$FFFE,$FFEB
	dc.w	$FFF2,$FFDD,$FFFD,$FFEB
	dc.w	$FFF1,$FFE0,$FFFE,$FFEE
	dc.w	$FFF1,$FFDE,$FFFC,$FFEC
	dc.w	$FFEF,$FFDA,$FFFB,$FFE9
	dc.w	$FFFE,$FFEC,$0006,$FFFB	; READY
	dc.w	$0003,$FFF9,$000A,$0001
	dc.w	$0001,$FFF3,$0009,$FFFF
	dc.w	$FFF7,$FFD6,$0003,$0008	; 111 HHIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 115 VHIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 119 DROWN
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 128 FADE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 133 FALLBACK
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 136 HIT NOSTARS
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 140 LAUGH
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 142 MELT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 150 SPLIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFED,$0008,$FFF9,$0011	; TAKES
	dc.w	$FFEE,$0009,$FFF9,$0010
	dc.w	$FFF5,$FFED,$0011,$FFF5
	dc.w	$FFF5,$FFED,$0011,$FFF5
	dc.w	$FFEF,$FFF6,$FFF2,$FFFA
	dc.w	$FFEF,$FFF6,$FFF2,$FFFA
	dc.w	$FFEF,$FFE6,$000E,$FFEF
	dc.w	$FFF3,$FFE6,$000D,$FFEF
	dc.w	$FFF8,$FFD4,$0009,$FFE4	; BALANCE 0
	dc.w	$FFF5,$FFD6,$0008,$FFE5
	dc.w	$FFF8,$FFD5,$0008,$FFE6
	dc.w	$0001,$FFD2,$0011,$FFE3	; BALANCE 1
	dc.w	$0008,$FFD7,$0019,$FFE6
	dc.w	0-10,0-31,4,0-5		; 167 CONVERTABLE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFE0,$000B,$FFE5	; CAVEWALKIN
	dc.w	$FFF7,$FFDF,$000B,$FFE5
	dc.w	$FFF7,$FFDE,$000C,$FFE4
	dc.w	$FFF7,$FFDE,$000A,$FFE5
	dc.w	$FFF6,$FFDF,$000B,$FFE5
	dc.w	$FFF7,$FFDE,$000B,$FFE4
	dc.w	$FFF7,$FFDF,$0009,$FFE5	; CAVEWALKOUT
	dc.w	$FFF6,$FFDE,$000A,$FFE4
	dc.w	$FFF6,$FFDE,$000A,$FFE4
	dc.w	$FFF5,$FFDF,$000A,$FFE6
	dc.w	$FFF7,$FFDF,$000A,$FFE4
	dc.w	$FFF6,$FFDE,$000A,$FFE4
	dc.w	$0005,$FFE6,$0011,$0000	; BANANA
	dc.w	$0002,$FFF1,$0012,$FFFF
	dc.w	$FFF7,$FFD6,$0003,$0008	; NOTIME
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; POP
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; HOORAY
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$0008,$FFDA,$001A,$FFEA	; BALANCE 1 (LAST FRAME)
	dc.w	$FFF9,$FFD9,$0007,0-5	; RIDE
	dc.w	$FFF9,$FFD0,$0007,0-5
	dc.w	$FFF9,$FFC4,$0007,0-5
	dc.w	$FFF9,$FFD9,$0007,0-5	; COASTER RIDE
	dc.w	$FFFE,$FFDD,$000D,$FFEA	; RUN
	dc.w	$FFFE,$FFDC,$000C,$FFEA
	dc.w	$000E,$FFE0,$001E,$FFEE	; RUN DOWN
	dc.w	$000F,$FFE3,$001C,$FFF1
	dc.w	$FFF0,$FFDC,$FFFD,$FFE9	; RUN UP
	dc.w	$FFF2,$FFDD,$FFFE,$FFEB
	dc.w	$FFF2,$FFDD,$FFFD,$FFEB

BUBSYBOX2:
	dc.w	$FFFA,$FFE9,$0012,$FFF0	; RUN
	dc.w	$FFF8,$FFEA,$0009,$FFF2
	dc.w	$FFFC,$FFE7,$000A,$FFF2
	dc.w	$FFF7,$FFEB,$0010,$FFF2
	dc.w	$FFF8,$FFEB,$0009,$FFF2
	dc.w	$FFFC,$FFE7,$000D,$FFEF
	dc.w	($FFF4+8)&$ffff,$FFD7,($FFFF+8)&$ffff,$FFE5	; IDLE
	dc.w	($FFF3+8)&$ffff,$FFD8,($FFFE+8)&$ffff,$FFE5
	dc.w	($FFF4+8)&$ffff,$FFD8,($0002+8)&$ffff,$FFE5
	dc.w	($FFF4+8)&$ffff,$FFD8,($0001+8)&$ffff,$FFE5
	dc.w	($FFF4+8)&$ffff,$FFD8,($0001+8)&$ffff,$FFE5
	dc.w	($FFF4+8)&$ffff,$FFD9,($0002+8)&$ffff,$FFE5
	dc.w	($FFE5+8)&$ffff,$FFDF,($0016+8)&$ffff,$FFE8
	dc.w	($FFE7+8)&$ffff,$FFE0,($0010+8)&$ffff,$FFE7
	dc.w	($FFE8+8)&$ffff,$FFE0,($0010+8)&$ffff,$FFE8
	dc.w	$FFE7,$FFF3,$0019,$FFFB	;15
	dc.w	$FFE9,$FFF5,$001A,$FFFD
	dc.w	$FFE8,$FFF5,$0016,$FFFD
	dc.w	$FFEA,$FFF5,$0014,$FFFD
	dc.w	$FFE8,$FFF4,$0018,$FFFC
	dc.w	$FFF2,$FFE8,$000C,$FFF8	;20
	dc.w	$FFF6,$FFEA,$0004,$FFF7
	dc.w	$FFF5,$FFE6,$000A,$FFF7
	dc.w	$FFF6,$FFE8,$0005,$FFF6
	dc.w	$FFE9,$FFE8,$0000,$FFEE
	dc.w	$FFFB,$FFEA,$0005,$FFFA	; JUMP
	dc.w	$FFF7,$FFF0,$001F,$FFF6
	dc.w	$FFFE,$FFEA,$000D,$FFF5
	dc.w	$FFFD,$FFE9,$000D,$FFF8
	dc.w	$FFFB,$FFF3,$0008,$FFFD
	dc.w	$FFEC,$FFF4,$0015,$FFFC
	dc.w	$FFFA,$FFF7,$000D,$0001	
	dc.w	$0005,$FFD4,$000D,$FFF6	; JUMP UP
	dc.w	$0009,$FFFE,$001A,$0003	; GLIDE
	dc.w	$FFF1,$FFF7,$001B,$FFFD
	dc.w	$FFFC,$FFF7,$001C,$FFFD
	dc.w	$FFFC,$FFDC,$0003,$FFFD	; 36 SHATTER
	dc.w	$FFFC,$FFDC,$0003,$FFFD
	dc.w	$FFFC,$FFDC,$0003,$FFFD
	dc.w	$FFFC,$FFDC,$0003,$FFFD
	dc.w	$FFFC,$FFDC,$0003,$FFFD
	dc.w	$FFF0,$FFEC,$0001,$FFF8	; SPIN
	dc.w	$FFF1,$FFEE,$0011,$FFF5
	dc.w	$FFEE,$FFE7,$FFFC,$FFFA
	dc.w	$FFED,$FFF5,$000F,$FFFC
	dc.w	$FFF9,$FFE5,$0004,$FFFF	; LOOKUP
	dc.w	$FFF2,$FFFB,$0010,$0001	; LOOKDOWN
	dc.w	$FFF3,$FFFB,$0010,$0001	; DUCK
	dc.w	$FFF3,$FFF9,$0010,$0001
	dc.w	$0000,$0000,$0000,$0000	; 49
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$FFF2,$FFFC,$000D,$0001	; SHAKE WATER
	dc.w	$FFF1,$FFFD,$000F,$0001
	dc.w	$FFF1,$FFFD,$000E,$0001
	dc.w	$FFF1,$FFFD,$000E,$0001
	dc.w	$FFF1,$FFFD,$000E,$0001
	dc.w	$FFF1,$FFFD,$000E,$0001
	dc.w	$0002,$FFF3,$000C,$0001
	dc.w	$FFF1,$FFF3,$0004,$0001
	dc.w	$FFF2,$FFFD,$000D,$0001	; BIGSMILE
	dc.w	$FFF3,$FFFB,$000D,$0001	; PUFF
	dc.w	$FFF2,$FFFB,$000E,$0001
	dc.w	$FFF7,$FFD6,$0003,$0008	; 64 SQUISH
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	 ; 74 BYEBYE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF6,$FFDF,$FFFA,$FFF6	; SMASH
	dc.w	$FFF6,$FFDE,$FFFA,$FFF6
	dc.w	$FFF6,$FFE0,$FFFA,$FFF6
	dc.w	$FFF6,$FFE0,$FFFA,$FFF6
	dc.w	$FFDA,$FFF8,$FFE9,$FFFA	; UNCONCIOUS
	dc.w	$FFEF,$FFFD,$0003,$0001	; SWIPE
	dc.w	$FFEF,$FFFE,$0004,$0001
	dc.w	$FFF1,$FFFC,$0004,$0002
	dc.w	$FFF0,$FFEB,$FFFB,$0001	
	dc.w	$FFF8,$FFE8,$0003,$FFF0	; PUSH
	dc.w	$FFF6,$FFE8,$0000,$FFF0
	dc.w	$FFF6,$FFE8,$FFFF,$FFF0
	dc.w	$FFF4,$FFE7,$FFFE,$FFF0
	dc.w	$FFF5,$FFE7,$FFFF,$FFEE
	dc.w	$FFF7,$FFE6,$0001,$FFEE
	dc.w	$FFF1,$FFEC,$0012,$FFF3	; RUN DOWN
	dc.w	$FFF5,$FFEE,$0012,$FFFA
	dc.w	$0006,$FFEA,$0012,$FFF9
	dc.w	$FFFF,$FFE7,$0016,$FFFA
	dc.w	$FFF5,$FFED,$0012,$FFF9
	dc.w	$0006,$FFEB,$0016,$FFF8
	dc.w	$0000,$FFEC,$0012,$FFF3	; RUN UP
	dc.w	$FFFF,$FFEE,$0012,$FFFA
	dc.w	$FFF4,$FFEC,$0003,$FFF1
	dc.w	$0006,$FFE9,$0016,$FFFA
	dc.w	$0003,$FFED,$0012,$FFF9
	dc.w	$FFEF,$FFEA,$0002,$FFF8
	dc.w	$FFF2,$FFEE,$FFFD,$0000	; READY
	dc.w	$FFF7,$FFED,$0002,$FFFE
	dc.w	$FFF9,$FFED,$0002,$FFFE
	dc.w	$FFF7,$FFD6,$0003,$0008	; 111 HHIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 115 VHIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 119 DROWN
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 128 FADE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 133 FALLBACK
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 136 HIT NOSTARS
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 140 LAUGH
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 142 MELT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 150 SPLIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF3,$FFF9,$000A,$0007	; TAKES
	dc.w	$FFF8,$0001,$0001,$0008
	dc.w	$FFFE,$FFEA,$0006,$0001
	dc.w	$FFFE,$FFEA,$0005,$0001
	dc.w	$FFEE,$FFFB,$0008,$000E
	dc.w	$FFEE,$FFFB,$0007,$000D
	dc.w	$FFE9,$FFD8,$0001,$FFE5
	dc.w	$FFE8,$FFDA,$0000,$FFE7
	dc.w	$FFF8,$FFE5,$0007,$0001	; BALANCE 0
	dc.w	$FFF9,$FFE6,$0009,$0001
	dc.w	$FFF9,$FFE7,$0009,$0001
	dc.w	$FFF8,$FFE4,$0005,$FFF5	; BALANCE 1
	dc.w	$FFFA,$FFE1,$0009,$FFF0
	dc.w	0-8,0-49,3,0-32		; 167 CONVERTABLE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFE9,$000C,$FFF2	; CAVEWALKIN
	dc.w	$FFF7,$FFE9,$000B,$FFF2
	dc.w	$FFF6,$FFE7,$000B,$FFF1
	dc.w	$FFF6,$FFE9,$000B,$FFF1
	dc.w	$FFF6,$FFEA,$000B,$FFF2
	dc.w	$FFF6,$FFEA,$000B,$FFF2
	dc.w	$FFF6,$FFEA,$000A,$FFF2	; CAVEWALKOUT
	dc.w	$FFF5,$FFE9,$000B,$FFF2
	dc.w	$FFF5,$FFE9,$000B,$FFF2
	dc.w	$FFF5,$FFEA,$000B,$FFF2
	dc.w	$FFF5,$FFEA,$000B,$FFF2
	dc.w	$FFF5,$FFEA,$000A,$FFF2
	dc.w	$FFF6,$FFDF,$0004,$FFF7	; BANANA
	dc.w	$FFFA,$FFE9,$000D,$FFF6
	dc.w	$FFF7,$FFD6,$0003,$0008	; NOTIME
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; POP
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; HOORAY
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF8,$FFE0,$0009,$FFED	; BALANCE 1 (LAST FRAME)
	dc.w	$FFF4,$FFCB,$FFFF,$FFD8	; RIDE
	dc.w	$0006,$FFCF,$0010,$FFDC
	dc.w	$FFFA,$FFCA,$0009,$FFD5
	dc.w	$FFF4,$FFCB,$FFFF,$FFD8	; COASTER RIDE
	dc.w	$FFFA,$FFE9,$0012,$FFF0	; RUN
	dc.w	$FFF8,$FFEA,$0009,$FFF2
	dc.w	$FFF1,$FFEC,$0012,$FFF3	; RUN DOWN
	dc.w	$FFF5,$FFEE,$0012,$FFFA
	dc.w	$0000,$FFEC,$0012,$FFF3	; RUN UP
	dc.w	$FFFF,$FFEE,$0012,$FFFA

BUBSYBOX3:
	dc.w	$FFF0,$FFF1,$000C,$FFFD	; RUN
	dc.w	$FFEC,$FFF2,$0007,$FFFE
	dc.w	$FFF8,$FFF3,$0006,$0000
	dc.w	$FFF7,$FFF3,$0013,$FFFE
	dc.w	$FFEE,$FFF2,$0005,$FFFD
	dc.w	$FFFC,$FFF0,$0005,$0000
	dc.w	($FFF4+8)&$ffff,$FFFC,($0009+8)&$ffff,$0001	; IDLE
	dc.w	($FFF4+8)&$ffff,$FFFC,($0006+8)&$ffff,$0001
	dc.w	($FFF4+8)&$ffff,$FFFC,($0009+8)&$ffff,$0001
	dc.w	($FFF3+8)&$ffff,$FFFC,($0008+8)&$ffff,$0001
	dc.w	($FFF3+8)&$ffff,$FFFC,($000A+8)&$ffff,$0001
	dc.w	($FFF4+8)&$ffff,$FFFC,($0008+8)&$ffff,$0001
	dc.w	($FFF4+8)&$ffff,$FFFC,($000A+8)&$ffff,$0001
	dc.w	($FFF3+8)&$ffff,$FFFC,($000A+8)&$ffff,$0001
	dc.w	($FFF4+8)&$ffff,$FFFC,($000A+8)&$ffff,$0001
	dc.w	$FFF2,$FFE9,$0011,$FFF2	;15
	dc.w	$FFF2,$FFE9,$000F,$FFF4
	dc.w	$FFF3,$FFE7,$000D,$FFF4
	dc.w	$FFF4,$FFE8,$000B,$FFF4
	dc.w	$FFF3,$FFE8,$000D,$FFF3
	dc.w	$0001,$FFF9,$0007,$FFFE	;20
	dc.w	$0000,$FFF1,$000B,$FFFD
	dc.w	$0005,$FFF1,$000E,$FFFE
	dc.w	$0001,$FFF0,$000C,$FFFD
	dc.w	$FFFE,$FFEF,$000B,$FFFB
	dc.w	$0006,$FFE6,$000C,$FFF3	; JUMP
	dc.w	$0006,$FFE8,$0014,$FFF2
	dc.w	$0007,$FFF2,$0014,$FFFD
	dc.w	$FFF9,$FFF7,$000A,$0001
	dc.w	$FFEE,$FFED,$FFFF,$FFF8
	dc.w	$FFF5,$FFDB,$0004,$FFE8
	dc.w	$FFFF,$FFE5,$000D,$FFF2
	dc.w	$0000,$FFCD,$000A,$FFDF	; JUMP UP
	dc.w	$FFE5,$FFF1,$FFFC,$FFF8	; GLIDE
	dc.w	$FFE4,$FFF0,$FFF9,$FFF6
	dc.w	$FFE3,$FFED,$FFFC,$FFF5
	dc.w	$FFF7,$FFFD,$FFFE,$0008	;36 SHATTER 
	dc.w	$FFF7,$FFFD,$FFFE,$0008
	dc.w	$FFF7,$FFFD,$FFFE,$0008
	dc.w	$FFF7,$FFFD,$FFFE,$0008
	dc.w	$FFF7,$FFFD,$FFFE,$0008
	dc.w	$FFE8,$FFF6,$0014,$0000	; SPIN
	dc.w	$FFF1,$FFF6,$000F,$0000
	dc.w	$FFF8,$FFF7,$0006,$0000
	dc.w	$FFF4,$FFED,$0007,$0000
	dc.w	$FFF2,$FFD9,$0000,$FFE6	; LOOKUP
	dc.w	$0000,$FFEA,$0014,$FFF8	; LOOKDOWN
	dc.w	$0007,$FFE4,$0015,$FFF4	; DUCK
	dc.w	$0008,$FFE9,$0015,$FFF7
	dc.w	$0000,$0000,$0000,$0000	; 49 
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$FFFB,$FFD8,$0002,$FFFF	; SHAKE WATER
	dc.w	$FFFD,$FFDB,$0005,$FFFF
	dc.w	$FFFC,$FFDC,$0003,$FFFF
	dc.w	$FFF9,$FFDC,$0005,$FFFF
	dc.w	$FFFC,$FFDB,$0004,$FFFF
	dc.w	$FFF8,$FFDB,$0004,$FFFF
	dc.w	$FFF9,$FFDC,$0005,$FFFF
	dc.w	$FFFC,$FFDB,$0007,$FFFF
	dc.w	$FFFA,$FFD8,$0006,$FFFF	; BIGSMILE
	dc.w	$FFF8,$FFD7,$0007,$FFFF	; PUFF
	dc.w	$FFF8,$FFD6,$0008,$FFFF
	dc.w	$FFF7,$FFD6,$0003,$0008	; 64 SQUISH
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	 ; 74 BYEBYE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFFB,$FFD6,$0000,$FFF9	; SMASH
	dc.w	$FFFB,$FFD6,$0000,$FFF8
	dc.w	$FFFB,$FFD6,$0000,$FFF8
	dc.w	$FFFB,$FFD6,$0000,$FFF8
	dc.w	$FFD6,$FFFB,$0004,$0001	; UNCONCIOUS
	dc.w	$FFE2,$FFE7,$FFEE,$0001	; SWIPE
	dc.w	$FFE1,$FFE8,$FFEE,$0001
	dc.w	$FFE5,$FFE9,$FFF0,$0002
	dc.w	$FFE4,$FFE7,$FFEF,$0001
	dc.w	$FFF1,$FFF0,$FFFB,$0001	; PUSH
	dc.w	$FFF1,$FFEF,$FFFD,$0001
	dc.w	$FFF0,$FFEF,$FFFE,$0001
	dc.w	$FFEC,$FFED,$FFFE,$0001
	dc.w	$FFEB,$FFEE,$FFFD,$0001
	dc.w	$FFF2,$FFED,$FFFE,$0001
	dc.w	$0007,$FFF4,$0013,$0000	; RUN DOWN
	dc.w	$0000,$FFFB,$000B,$0006
	dc.w	$FFF9,$FFF3,$000A,$FFFE
	dc.w	$0000,$FFEE,$0014,$0002
	dc.w	$FFFF,$FFFA,$000A,$0005
	dc.w	$FFFA,$FFF2,$000D,$FFFE
	dc.w	$FFEF,$FFEB,$FFF9,$0008	; RUN UP
	dc.w	$FFEF,$FFF8,$0008,$0002
	dc.w	$FFF4,$FFF2,$0001,$0003
	dc.w	$FFF1,$FFFD,$FFFA,$000A
	dc.w	$FFF3,$FFF4,$0006,$0000
	dc.w	$FFF2,$FFF1,$FFFD,$0003
	dc.w	$0002,$FFE4,$000E,$FFF0	; READY
	dc.w	$0005,$FFEE,$0010,$FFF8
	dc.w	$0005,$FFEE,$0011,$FFF8
	dc.w	$FFF7,$FFD6,$0003,$0008	; 111 HHIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 115 VHIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 119 DROWN
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 128 FADE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 133 FALLBACK
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 136 HIT NOSTARS
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 140 LAUGH
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 142 MELT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; 150 SPLIT
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$0001,$FFEF,$000F,$0006	; TAKES
	dc.w	$FFFD,$FFF0,$0010,$0003
	dc.w	$0004,$FFD8,$0012,$FFEA
	dc.w	$0002,$FFD7,$0012,$FFEB
	dc.w	$FFFF,$FFF2,$0015,$0002
	dc.w	$FFFF,$FFF2,$0016,$0002
	dc.w	$0007,$FFE1,$0015,$FFF8
	dc.w	$0009,$FFE1,$0016,$FFF7
	dc.w	$FFEF,$FFD9,$FFF7,$FFE8	; BALANCE 0
	dc.w	$0009,$FFDC,$0015,$FFF8
	dc.w	$0009,$FFE2,$0013,$FFF5
	dc.w	$FFF4,$FFF6,$0002,$0001	; BALANCE 1
	dc.w	$FFF5,$FFF1,$0002,$0001
	dc.w	0-11,0-44,5,0-41	; 167 CONVERTABLE
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFFD,$FFD9,$0006,$FFFF	; CAVEWALKIN
	dc.w	$FFFC,$FFDA,$0005,$FFFF
	dc.w	$FFFC,$FFD9,$0008,$FFFF
	dc.w	$FFFC,$FFDA,$0006,$FFFF
	dc.w	$FFFB,$FFDA,$0005,$FFFF
	dc.w	$FFFB,$FFD8,$0005,$FFFF
	dc.w	$FFFB,$FFD9,$0005,$0001	; CAVEWALKOUT
	dc.w	$FFFB,$FFD9,$0005,$0001
	dc.w	$FFFA,$FFD9,$0006,$0001
	dc.w	$FFFA,$FFDA,$0006,$0001
	dc.w	$FFFA,$FFD9,$0006,$0001
	dc.w	$FFFA,$FFD8,$0006,$0001
	dc.w	$FFF1,$FFDE,$FFFE,$FFEC	; BANANA
	dc.w	$FFEA,$FFDE,$0000,$FFEB
	dc.w	$FFF7,$FFD6,$0003,$0008	; NOTIME
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; POP
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008	; HOORAY
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF7,$FFD6,$0003,$0008
	dc.w	$FFF6,$FFEE,$0002,$0001	; BALANCE 1 (LAST FRAME)
	dc.w	$FFF2,$FFD1,$FFF7,$FFD6	; RIDE
	dc.w	$FFFC,$FFDB,$0002,$FFE3
	dc.w	$0003,$FFDF,$0007,$FFE6
	dc.w	$FFF1,$FFD1,$0001,$FFD7	; COASTER RIDE
	dc.w	$FFF0,$FFF1,$000C,$FFFD	; RUN
	dc.w	$FFEC,$FFF2,$0007,$FFFE
	dc.w	$0007,$FFF4,$0013,$0000	; RUN DOWN
	dc.w	$0000,$FFFB,$000B,$0006
	dc.w	$FFEF,$FFEB,$FFF9,$0008	; RUN UP
	dc.w	$FFEF,$FFF8,$0008,$0002