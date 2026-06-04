*******************************************************************
;macros	for sprite collation
;head
.macro	ashead	o1
	if \o1=0
	dc.w	0,-25,49-SIDD+75	;h0
	endif
	if \o1=1
	dc.w	0,-24,50-SIDD+75		;h1
	endif
	if \o1=2
	dc.w	0,-25,51-SIDD+75		;h2
	endif
	if \o1=3
	dc.w	0,-26,52-SIDD+75		;h3
	endif
	if \o1=4
	dc.w	0,-26,52-SIDD+75		;h3
	endif
	.endm

;wag tail
.macro	aswag	o1
	if \o1=0
	dc.w	-20,-38,53-SIDD+75		;w0
	endif
	if \o1=1
	dc.w	-24,-37,54-SIDD+75		;w1
	endif
	if \o1=2
	dc.w	-31,-33,55-SIDD+75		;w2
	endif

	if \o1=3
	dc.w	-28,-26,56-SIDD+75		;t0
	endif
	if \o1=4
	dc.w	-27,-27,57-SIDD+75		;t1
	endif
	if \o1=5
	dc.w	-28,-36,58-SIDD+75		;t2
	endif
	if \o1=6
	dc.w	-27,-32,59-SIDD+75		;t3
	endif
	if \o1=7
	dc.w	-31,-29,60-SIDD+75		;t4
	endif
	.endm

.macro	astoss	o1
	if \o1=0
	dc.w	-24,-48,45-SIDD+75		;sw0
	endif
	if \o1=1
	dc.w	-22,-67,46-SIDD+75		;sw1
	endif
	if \o1=2
	dc.w	-24,-71,47-SIDD+75		;sw2
	endif

	if \o1=3
	dc.w	-22,-76,48-SIDD+75		;st3
	endif
	if \o1=4
	dc.w	-24,-71,45-SIDD+75		;st4
	endif
	if \o1=5
	dc.w	-22,-67,46-SIDD+75		;st5
	endif
	if \o1=6
	dc.w	-24,-48,47-SIDD+75		;st6
	endif
	.endm

;stick tongue out
.macro	ahiss	o1
	dc.w	16,-16,\o1+62-SIDD+75
	.endm

;blink close eyes
.macro	asblink
	dc.w	24-16-4,-23,61-SIDD+75
	.endm

asid_dma:
.sid_bored:
	dc.l	.sidb00			;00
	dc.l	.sidb01			;01
	dc.l	.sidb02			;02
	dc.l	.sidb01			;03
	dc.l	.sidb02			;04
	dc.l	.sidb03			;05
	dc.l	.sidb04			;06
	dc.l	.sidb05			;07
	dc.l	.sidb04			;08
	dc.l	.sidb06			;09
	dc.l	.sidb07			;10

	dc.l	.sidt01			;11
	dc.l	.sidt02			;12
	dc.l	.sidt03			;13
	dc.l	.sidt04			;14
	dc.l	.sidt05			;15
	dc.l	.sidt06			;16
	dc.l	.sidt07
	
	dc.l	.sidb08			;17
	dc.l	.sidb09			;18
	dc.l	.sidb10			;19
	dc.l	.sidb11			;20
	dc.l	.sidb09			;21
	dc.l	.sidb12			;22
	dc.l	.sidb13			;23
	dc.l	.sidb14			;24

.sid_chuck:
	dc.l	.sidc1			;25
	dc.l	.sidc2			;26
	dc.l	.sidc3			;27
	dc.l	.sidc4			;28
	dc.l	.sidc0			;29

.sidb00:
	dc.w	2,0,0,0
	ashead	0
	aswag	0
.sidb01:
	dc.w	3,0,0,0
	ashead	0
	aswag	0
	ahiss	0
.sidb02:
	dc.w	3,0,0,0
	ashead	0
	aswag	0
	ahiss	1
.sidb03:
	dc.w	4,0,0,0
	ashead	0
	aswag	0
	ahiss	2
	asblink
.sidb04:
	dc.w	2,0,0,0
	ashead	1
	aswag	0
.sidb05:
	dc.w	2,0,0,0
	ashead	2
	aswag	0
.sidb06:
	dc.w	2,0,0,0
	ashead	0
	aswag	5
.sidb07:
	dc.w	2,0,0,0
	ashead	0
	aswag	7
.sidb08:
	dc.w	2,0,0,0
	ashead	0
	aswag	4
.sidb09:
	dc.w	2,0,0,0
	ashead	0
	aswag	3
.sidb10:
	dc.w	3,0,0,0
	ashead	0
	aswag	1
	ahiss	1
.sidb11:
	dc.w	2,0,0,0
	ashead	0
	aswag	6
.sidb12:
	dc.w	2,0,0,0
	ashead	0
	aswag	2
.sidb13:
	dc.w	2,0,0,0
	ashead	3
	aswag	1
.sidb14:
	dc.w	2,0,0,0
	ashead	4
	aswag	2

.sidc0:
	dc.w	2,-18,0,$24
	dc.w	0,-24,65-SIDD+75
	dc.w	13,-37,66-SIDD+75
.sidc1:
	dc.w	3,-16,0,$20
	dc.w	10,-53,67-SIDD+75
	dc.w	0,-28,68-SIDD+75
	dc.w	34,-28,69-SIDD+75
.sidc2:
	dc.w	2,-16,0,$20
	dc.w	0,-26,70-SIDD+75
	dc.w	36,-21,71-SIDD+75
.sidc3:
	dc.w	2,-16,0,$20
	dc.w	0,-26,72-SIDD+75
	dc.w	38,-19,73-SIDD+75
.sidc4:
	dc.w	1,-17,0,$22
	dc.w	0,-34,74-SIDD+75

.sidt01:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	0
.sidt02:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	1
.sidt03:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	2
.sidt04:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	3
.sidt05:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	4
.sidt06:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	5
.sidt07:
	dc.w	3,0,0,0
	ashead	2
	aswag	6
	astoss	6