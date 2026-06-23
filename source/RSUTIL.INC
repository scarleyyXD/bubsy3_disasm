.macro	_rsset
	rs_counter	set	\1
	.endm

.macro	_rsreset
	_rsset	0
	.endm
	
.macro	_rsb	label,volume
	\label		set	rs_counter
	rs_counter	set	rs_counter+(\volume)
	.endm

.macro	_rsw	label,volume
	\label		set	rs_counter
	rs_counter	set	rs_counter+((\volume)*2)
	.endm
	
.macro	_rsl	label,volume
	\label		set	rs_counter
	rs_counter	set	rs_counter+((\volume)*4)
	.endm