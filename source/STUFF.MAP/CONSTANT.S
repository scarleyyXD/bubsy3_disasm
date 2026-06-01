MAP_WORD			equ	1
MOVE_STEP			equ	4
MOVE_STEP1			equ	(MOVE_STEP/2)
MOVE_STEP2			equ	(MOVE_STEP1/2)
BLOCK_BITS			equ	4				;4=16 pixels,5=32 pixels
BLOCK_HEIGHT		equ	(1<<BLOCK_BITS)			;square blocks
MAP_DEPTH			equ	1				;1=8bpp 2=16bpp  bpp= bits per pixel
MAP_WIDTH			equ	($15e*2)			;general figures needed for a map space
MAP_HEIGHT			equ	$40				;in the bss section.. figures in blocks
VIEW_HEIGHT			equ	(280)
VIEW_WIDTH			equ	336
PLAYFIELD_WIDTH		equ	((VIEW_WIDTH/BLOCK_HEIGHT)+1)	;need at least 1 for mid block .. 2 needed
PLAYFIELD_BLITTER_WIDTH	equ	384	;(VIEW_WIDTH+BLOCK_HEIGHT)	;this is used for playfield calculations
PLAYFIELD_HEIGHT	equ	((VIEW_HEIGHT)/BLOCK_HEIGHT)+2+1	;240 or 280 not a full character and need 1 extra
PLAY_SCREEN			equ	((BLOCK_HEIGHT*PLAYFIELD_HEIGHT)*(PLAYFIELD_BLITTER_WIDTH)*MAP_DEPTH)
ANDY				equ	PLAY_SCREEN
PLAYFIELD_BLITTER_STEP	equ	(PLAYFIELD_BLITTER_WIDTH-384)&$ffff