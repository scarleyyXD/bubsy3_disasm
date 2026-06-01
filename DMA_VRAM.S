
DOINITIALDMA
	moveq	#NEWOBJECT,D0
	and.B	OBJFLAGS(A5),D0							;check if this is a new object
	BNE.s	.NORMALAI
	move.w	d0,OBJFRAMECTR(A5)						;set counter to 0 and contine
	OR.B	#NEWOBJECT,OBJFLAGS(A5)						;new object and we always have VRAM
.NORMALAI									;its ok to continue object
	RTS



;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE RELEASES AN OBJECTS VRAM AND CLEARS THE OBJECT
;;;ABSxx:; No need to clear vram entry
;;;ASBx: ;************************************************************************
;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE SETS ALL THE FIELDS OF AN OBJECT TO 0
;;;ASBx: ; AND LOADS THE KEY WITH $FFFF
;;;ASBx: ; ON ENTRY:
;;;ASBx: ; DP NEEDS TO POINT TO THE OBJECT
;;;ASBx: ; 16 BIT MEM
;;;ASBx: ; ON EXIT:
;;;ASBx: ; A & X ARE TRASHED
;;;ASBx: ;************************************************************************

CLEAROBJWVRAM
CLEAROBJ
	lea	OBJLEN(a5),a5
	moveq	#0,d6
	rept	OBJLEN/4
	move.l	d6,-(a5)
	endr
	MOVE	#$FFFF,OBJKEY(A5)
	RTS

;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE INITIALIZES ALL THE OBJECT INTRIES IN RAM
;;;ASBx: ; IT DEACTIVATES ALL THE OBJECT BY CALLING CLEAROBJ FOR ALL OBJECTS
;;;ASBx: ; SINCE THE HIGH BIT IS USED TO SPECIFY A LOAD TYPE SCRIPT ENTRY A NEGATIVE
;;;ASBx: ; KEY WILL NEVER EXIST FOR AN OBJECT, AN EASY OFF SWITCH TO DETECT EH.!
;;;ASBx: ; BITS & DP ARE PRESERVED
;;;ASBx: ; A,X,Y ARE TRASHED
;;;ASBx: ;************************************************************************

INITOBJS
	MOVE.L	A5,-(SP)
	LEA	OBJBASE,A5
	MOVEq	#NUMOBJS-1,D7
	moveq	#0,d6
.IO00
	rept	$24/4
	move.l	d6,(a5)+
	endr
	MOVE.w	#$FFFF,OBJKEY-$24(A5)
	
	DBF	D7,.IO00
	MOVE.L (SP)+,A5
	RTS


;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE WILL EXECUTE ALL THE AI VECTORS OF OBJECTS THAT ARE "ALIVE"
;;;ASBx: ; THE OBJECT AI ROUTINES CAN COUNT ON DP POINTING TO THEIR OBJECT ENTRY
;;;ASBx: ; 16 BIT REGISTERS, A,X,Y ARE FREE, ALL TEMPS & INDS ARE AVAILABLE, BUT
;;;ASBx: ; ARE NOT POINTED TO BY THE DP REG.
;;;ASBx: ; THE OBJECT AI ROUTINES CAN'T RETURN WITH A CHANGED DP
;;;ASBx: ; ON EXIT
;;;ASBx: ; A,X,Y ARE TRASHED
;;;ASBx: ;************************************************************************

DOOBJAI
	MOVE.L	A5,-(SP)
	LEA	OBJBASE,A5
.DAI00	
	TST	OBJKEY(A5)
	BMI.s	.DAI10

	
	
	MOVE.L	OBJAI(A5),A0
	IFNE	DEBUG
	move.l	a0,bad_routine
	ENDC
	JSR	(A0)
	IFNE	DETECTMODE
	jsr	DRAW_DETECTPOINTS
	ENDC

.DAI10
	lea	OBJLEN(a5),A5
	CMP.L	#OBJBASEEND,A5
	BNE.s	.DAI00
	MOVE.L	(SP)+,A5
	RTS


;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE WILL FIND A FREE OBJECT (NEGATIVE KEY) IN THE OBJECT
;;;ASBx: ; RAM AND RETURN WITH DP POINTING TO IT IF IT ISN'T ALREADY ALIVE.
;;;ASBx: ; ON ENTRY
;;;ASBx: ; X	HAS THE KEY # OF THE OBJECT
;;;ASBx: ; ON EXIT
;;;ASBx: ; A,X,Y ARE TRASHED
;;;ASBx: ; DP POINTS TO FREE OBJECT OR AFTER LAST OBJECT
;;;ASBx: ; CARRY CLEAR SPECIFIES SUCCESS/SET MEANS THERE ARE NO FREE OBJECTS OR OBJ IS ALREADY ALIVE
;;;ASBx: ;************************************************************************

FINDFREEOBJ
	pea	(a6)
	MOVEq	#0,D7
	LEA	OBJBASE,A5
	lea	OBJBASEEND,a6
.IO00	move.w	OBJKEY(a5),d0
	BPL.s	.IO10
	MOVE.L	A5,D7
.IO10
	CMP.w	d0,D6
	Beq.s	.IO20

	lea	OBJLEN(a5),A5
	CMP.L	a6,A5
	BNE.s	.IO00

	TST.w	D7
	BEQ.s	.IO21

	MOVE.L	D7,A5
	move.l	(sp)+,a6
	AND	#~%00001,CCR
	RTS
.IO21
.IO20
	move.l	(sp)+,a6
	OR	#%00001,CCR
	RTS

FINDFIRSTFREEOBJ
	pea	(a6)
	LEA	OBJBASE,A5
	lea	OBJBASEEND,a6
.IO00
	TST.w	OBJKEY(A5)
	bmi.s	.found
.IO10
	lea	OBJLEN(a5),A5
	CMP.L	a6,A5
	BNE.s	.IO00
	move.l	(sp)+,a6
	OR	#%00001,CCR
	RTS
 
.found	move.l	(sp)+,a6
	AND	#~%00001,CCR
	RTS
 
FINDFREEOBJ_NOA6
	MOVEq	#0,D7
	LEA	OBJBASE,A5
.IO00	move.w	OBJKEY(a5),d0
	BPL.s	.IO10
	MOVE.L	A5,D7
.IO10
	CMP.w	d0,D6
	Beq.s	.IO20

	lea	OBJLEN(a5),A5
	CMP.L	a6,A5
	BNE.s	.IO00

	TST.w	D7
	BEQ.s	.IO21

	MOVE.L	D7,A5
	AND	#~%00001,CCR
	RTS
.IO21
.IO20
	OR	#%00001,CCR
	RTS



;;;ASBx: ;************************************************************************
;;;ASBx: ; THIS ROUTINE WILL START AN OBJECT FROM A SCRIPT ENTRY
;;;ASBx: ; ON ENTRY:
;;;ASBx: ; [<IND0]	POINTS TO THE OBJECT TO BE STARTED (SCRIPT ENTRY)
;;;ASBx: ; DP POINTS TO SYSDP 
;;;ASBx: ; 16 BIT REGS
;;;ASBx: ; ON EXIT:
;;;ASBx: ; A,X,Y ARE TRASHED
;;;ASBx: ;************************************************************************

STARTOBJ
	MOVE	SCRKEY(A0),D0

	bSR	CHECKOBJEN
	BCS.s	.SOFAIL

	MOVE	SCRKEY(A0),D6
	bSR.s	FINDFREEOBJ_NOA6
	BCS.s	.SOFAIL
	
	MOVE.w	SCRX(A0),OBJX(A5)
	MOVE.w	SCRY(A0),OBJY(A5)
	MOVE.w	SCRKEY(A0),d5
	move.w	d5,OBJKEY(A5)

; DECODE KEY
	sf	d5			;== and.w	#$ff00
	lsr.w	#6,d5
	move.w	d5,a2
	lsl.w	#2,d5
	add.w	d5,a2
	add.l	#OBJTABLES,A2
	MOVE.w	(A2)+,OBJOAM0(A5)
	MOVE.L	(A2)+,OBJAI(A5)
	MOVE.L	(A2)+,OBJINITDMA(A5)
	MOVE.L	(A2)+,OBJMAP(A5)
	MOVE.L	(A2)+,OBJAUX0(A5)
	MOVE.b	(A2)+,OBJFLAGS(A5)
	MOVE.b	(A2)+,OBJAUX4(A5)
	AND.w	#~1,CCR
	RTS	

.SOFAIL
	OR.w	#1,CCR
	RTS	

CHECKOBJEN
	CMP.w	#$7000,D0
	BGE.s	.START

	moveq	#7,d7
	and.w	D0,D7
	LSR.w	#3,D0
	MOVE.w	D0,d6
	moveq	#0,d0
	BSET	D7,D0

	AND.B	(A1,D6.W),D0
	BEQ.s	.START
.STOP
	OR	#1,CCR
	RTS
.START
	AND	#~1,CCR
	RTS		

;;;ASBx: ;************************************************************************
;;;ASBx: ; CALL THIS ROUTINE WITH A VALID 16 BIT KEY # IN D0
;;;ASBx: ; RIGHT NOW THE FIRST $40 KEY TYPES HAVE 256 VALID ENABLE BITS
;;;ASBx: ; ON ENTRY:
;;;ASBx: ; 16 BIT REGISTERS
;;;ASBx: ; A HAS A VALID KEY
;;;ASBx: ; IT DOES NOT NEED SYSDP!
;;;ASBx: ; ON EXIT:
;;;ASBx: ; A WILL HAVE THE NECESSARY BIT SET TO TEST OR OTHERWISE AFFECT THAT BIT
;;;ASBx: ; X WILL BE THE INDEX INTO OBJENFLAGS
;;;ASBx: ;************************************************************************

OBJENINDEX				;dont remove -- bubbop
	CMP.w	#$7000,D0
	BLT.s	.KEYINRANGE
	moveq	#0,d0
	move.w	d0,d6
	RTS
.KEYINRANGE
	moveq	#7,d6
	and.w	D0,D6
	LSR.w	#3,D0
	MOVE.w	D0,-(SP)
	moveq	#0,d0
	BSET	D6,D0
	MOVE.w	(SP)+,D6
	RTS

