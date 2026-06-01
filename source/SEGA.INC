;************************************************************************
;*
;* 68000 EQUATES 
;* 
;************************************************************************

FlagX       equ     %10000
FlagN       equ     %01000
FlagZ       equ     %00100
FlagV       equ     %00010
FlagC       equ     %00001

;---------------------------------------------------------------------------
;SNES named controller bits, but in format for genesis bubsy

JOY_B	   	equ	%1000000000000000
JOY_Y	    	equ	%0100000000000000
JOY_SELECT	equ	%0010000000000000
JOY_C		equ	%0010000000000000
JOY_START 	equ	%0001000000000000
CTRL_UP		equ	%0000100000000000	; CONTROLLER BITS	; JOY_UP    -> CTRL_UP
CTRL_DOWN	equ	%0000010000000000						; JOY_DOWN  -> CTRL_DOWN
CTRL_LEFT	equ	%0000001000000000						; JOY_LEFT  -> CTRL_LEFT
CTRL_RIGHT	equ	%0000000100000000						; JOY_RIGHT -> CTRL_RIGHT
JOY_A	    	equ	%0000000010000000
JOY_X	    	equ	%0000000001000000
JOY_L	    	equ	%0000000000100000
JOY_R	    	equ	%0000000000010000
JOY_HOR     equ   CTRL_LEFT^CTRL_RIGHT
JOY_VER     equ   CTRL_UP^CTRL_DOWN
JOY_ANY     equ   JOY_HOR^JOY_VER
;---------------------------------------------------------------------------

bJOY_UP		=	11
bJOY_DOWN	=	10
bJOY_LEFT	=	9
bJOY_RIGHT	=	8
	