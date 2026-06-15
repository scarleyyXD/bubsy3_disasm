;   66 	 22
;  6	2  2
;  666 	  2	OBJECT ENTRIES MAX.
;  6  6	 2
;   66 	2222

OBJNEEDVRAM	EQU	$1A*20	; FIRST OBJ TO NEED VRAM
MIDGOT		EQU	$1D	; MIDPOINT GOT KEY

GLOBOBJ		equ	$60

; THESE TABLES HELP TO DECODE THE KEY INTO A REAL OBJECT
; THE HIGH BYTE OF THE KEY IS THE OBJECT TYPE AND THE LOW BYTE IS THE #
; THERE ARE 7 VALID BITS OF INFO IN THE HIGH BYTE CORRESPONDING TO AN 
; ENTRY IN THIS TABLE 

;Format	
;.w	oam
;.l	ai
;.l	initial dma
;.l	map
;.b	aux0
;.b	aux1
;.b	aux2
;.b	aux3
;.b	flags
;.b	aux4

.macro	OBJECT oam,ai,dma,map,aux0,aux1,aux2,aux3,flags,aux4
	dc.w	\oam
	dc.l	\ai,\dma,\map
	dc.b	\aux0,\aux1,\aux2
	dc.b	\aux3,\flags,\aux4
	.endm

;************************************************************************************************************************

	INCLUDE	"LEVELS\\W1OBJECT.S"

;************************************************************************************************************************

	INCLUDE	"LEVELS\\W2OBJECT.S"

;************************************************************************************************************************

	INCLUDE	"LEVELS\\W3OBJECT.S"
	
;************************************************************************************************************************

	INCLUDE	"LEVELS\\W4OBJECT.S"

;************************************************************************************************************************

	INCLUDE	"LEVELS\\W5OBJECT.S"

;************************************************************************************************************************