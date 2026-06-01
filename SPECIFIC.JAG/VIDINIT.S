disp_width	equ	(320*4)		;this is in pixels/divider
disp_height	equ	(240-8)		;this is in lines
disp_change	equ	(40+4)

; Note that the horizontal timing numbers are for pal

pal_vclk		equ	376	; this for 26.6 MHz

; The following are time in units of 100 ps

pal_horiz_per		equ	317778 	; 63.5555us/2 Horizontal period
pal_sync_per		equ	46050	; 4.605us synch width
pal_eq_per		equ	23500	; 2.35us equalization
pal_front_porch		equ	17450	; 1.745us 
pal_line_blank		equ	109500	; 10.95us Total blanking




; The is the display width in video clocks



; Horizontal computations

pal_n_hp		equ	pal_horiz_per/pal_vclk
pal_n_hde		equ	((disp_width/2)-1)|$400
pal_n_hdb1		equ	((pal_n_hp)-(disp_width/2))
pal_n_hdb2		equ	pal_n_hdb1

; Vertical

pal_n_vp		equ	523
pal_n_vee		equ	6
pal_n_vbe		equ	(10*2+10*2+6)
pal_n_vdb		equ	pal_n_vbe+2
pal_n_vde		equ	pal_n_vdb+((disp_height+disp_change)*2)
pal_n_vbb		equ	pal_n_vde+40
pal_n_vs		equ	pal_n_vp-10
pal_n_veb		equ	pal_n_vs-pal_n_vee-1



; The is the display width in video clocks


; Note that the horizontal timing numbers are for ntsc

ntsc_vclk		equ	376	; this for 26.6 MHz

; The following are time in units of 100 ps

ntsc_horiz_per		equ	317778 	; 63.5555us/2 Horizontal period
ntsc_sync_per		equ	46050	; 4.605us synch width
ntsc_eq_per		equ	23500	; 2.35us equalization
ntsc_front_porch	equ	17450	; 1.745us 
ntsc_line_blank		equ	109500	; 10.95us Total blanking


; The is the display width in video clocks

; Horizontal computations

ntsc_n_hp		equ	ntsc_horiz_per/ntsc_vclk
ntsc_n_hde		equ	((disp_width/2)-1-1)|$400
ntsc_n_hdb1		equ	((ntsc_n_hp)-(disp_width/2))
ntsc_n_hdb2		equ	ntsc_n_hdb1


; Vertical

ntsc_n_vp		equ	523
ntsc_n_vee		equ	6
ntsc_n_vbe		equ	(10*2+10*2+6)
ntsc_n_vdb		equ	ntsc_n_vbe+2
ntsc_n_vde		equ	ntsc_n_vdb+(disp_height*2)
ntsc_n_vbb		equ	ntsc_n_vde+40
ntsc_n_vs		equ	ntsc_n_vp-10
ntsc_n_veb		equ	ntsc_n_vs-ntsc_n_vee-1
