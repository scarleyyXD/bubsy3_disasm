
; takes a word and flips its bits
; d0 - word to flip

flip_word       movem.w d1-d2,-(sp)     ; same some work regs
	moveq   #0,d1   ; result cleared
	moveq   #16-1,d2        ; works on 16 bits
.loop   add.w   d1,d1   ; double up result
	lsr.w   #1,d0   ; shift out lower bit
	bcc.s   .double ; no bit out, dont append 1 to end
	addq.w  #1,d1
.double dbra    d2,.loop        ; all bits
	move.w  d1,d0   ; returns in d0
	movem.w (sp)+,d1-d2
	rts

; takes a 4byte BCD and converts it into a long
; d0 - BCD number


bcd_to_long     movem.l d1-d4/d7,-(sp)  ; save work registers
	moveq   #0,d1   ; result
	moveq   #1,d2   ; unit to add
	moveq   #8-1,d7 ; 8 digits

.loop   moveq   #0,d3
	move.b  d0,d3   ; store lower byte in d3
	lsr.l   #4,d0   ; next BCD digit shifted
	and.w   #$f,d3  ; mask BCD digit
	subq.w  #1,d3   ; make DBRA counter ( -1 its a zero)
	bmi.s   .zero
.loop0  add.l   d2,d1   ; else add the current shift unit
	dbra    d3,.loop0
.zero   move.l  d2,d4
	lsl.l   #3,d2
	add.l   d4,d2   ; multiply result by 10
	add.l   d4,d2
	dbra    d7,.loop        ; all digits
	move.l  d1,d0   ; result in d0
	movem.l (sp)+,d1-d4/d7
	rts

; Sets the zero flag for error returns ,etc

setzero macro
	or.b    #$4,CCR
	endm

; clears the zero flag for error returns ,etc

clrzero macro
	and.b   #$b,CCR
	endm

; Sets vectorbase (68020+) to zero

VBR0    Macro
	Move.l  4.w,a6  ; execbase
	Lea     .\@2(pc),a5     ; super routine in a5
	Clr.l   d0
	Jsr     -150(a6)        ; super mode
	Jsr     -156(a6)        ; user move
	Bra.s   .\@1    ; skip super routine

.\@2    Moveq   #0,d7
	Movec   d7,VBR  ; set VBR=0
	Rte
.\@1
	Endm

; gets absolute value of a word

abs     macro
	tst.w   \1
	bpl.s   .\@2
	neg.w   \1
.\@2    
	endm

; all registers onto stack

Push    Macro
	Movem.l d0-a6,-(sp)
	Endm

; all registers off stack

Pull    Macro
	Movem.l (sp)+,d0-a6
	Endm

; simple copy bytes
; a0 - start
; a1 - dest
; d0 - number of bytes

Copy_Bytes      Move.b  (a0)+,(a1)+
	Subq.l  #1,d0
	Bne.s   Copy_Bytes
	Rts

; simple clear bytes
; a0 - source
; d0 - number of bytes

Clear_Bytes     Clr.b   (a0)+
	Subq.l  #1,d0
	Bne.s   Clear_Bytes
	Rts

; simple set bytes
; a0 - source
; d0 - number of bytes

Set_Bytes       St      (a0)+
	Subq.l  #1,d0
	Bne.s   Set_Bytes
	Rts

; optomized method of copying huge data regions

; a0 - source
; a1 - source
; d0 - number of bytes

Fast_Copy_68000 Push            ; all registers onto stack
.Loop   Sub.l   #48,d0  ; we can do 48 bytes at once
		    Blt.s       .Done_Fast      ; check like in a DO..WHILE loop
	Movem.l (a0)+,d1-d7/a2-a6       ; collect 48 bytes in all our registers
	Movem.l d1-d7/a2-a6,(a1)        ; save out 48 bytes in our registers
		    Lea 48(a1),a1       ; next lot of 48 bytes
	Bra.s   .Loop   ; until donw

.Done_Fast      Add.l   #48,d0  ; left over bytes positive
	Beq.s   .Done   ; 0 - no more bytes
	Bsr     Copy_Bytes      ; else just a standard copy of 1-47 bytes
.Done   Pull            ; all registers off of stack
	Rts

; searches for zero in a string
; a0 - string

Search_Zero     Tst.b   (a0)+
	Bne.s   Search_Zero
	Rts

BCDDIVIDE       Macro
	Divu    #\1,d0
		    Not.b       d1
		    Beq.s       .\@1
		    Lsl.b       #4,d0
	Or.b    d0,(a1)
	Bra.s   .\@2
.\@1    Or.b    d0,(a1)+
.\@2    Clr.w   d0
	Swap    d0
	Endm

Long_to_BCD     Clr.l   (a1)
	Sf      d1
	Move.l  (a0),d0
	Divu    #10000,d0
	Swap    d0
	Clr.w   d0
	Swap    d0
	BCDDIVIDE 1000
	BCDDIVIDE 100
	BCDDIVIDE 10
	Or.b    d0,(a1)+
	Move.l  (a0),d0
	Divu    #10000,d0
	Clr.w   d0
	Swap    d0
	Sf      d1
	BCDDIVIDE 1000
	BCDDIVIDE 100
	BCDDIVIDE 10
	Or.b    d0,(a1)+
	Rts

BCD_Ascii       Moveq   #4-1,d7
.Loop   Move.b  (a0)+,d0
	Move.b  d0,d1
	Lsr.b   #4,d0
	And.b   #$f,d0
	And.b   #$f,d1
	Add.b   #"0",d0
	Add.b   #"0",d1
	Move.b  d0,(a1)+
	Move.b  d1,(a1)+
	Dbra    d7,.Loop
	Rts

; swaps 2 words via any combination of addressing

Swap_Words          Macro
	Move.w  \1,-(sp)
	Move.w  \2,\1
	Move.w  (sp)+,\2
	Endm

; divides \2 by \1 and saves the result in \2, as a 16bit int:16bit fraction

frac_div        macro
	tst.w   \1
	bne.s   .not_zero
	moveq   #1,\1
.not_zero       divu    \1,\2
	move.l  d7,-(sp)
	move.l  #$10000,d7
	swap    \2
	divu    \1,d7
	mulu    \2,d7
	move.w  d7,\2
	move.l  (sp)+,d7
	endm
