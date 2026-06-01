SIDD	equ	45

.macro	make_current_world	O1
	rs_counter	set	\O1*$10000
	.endm
.macro	add_world_sprites label,volume
	\label	equ	rs_counter+(\volume)
	.endm

** global objects + level 1

	make_current_world	0
	
	add_world_sprites	MIDPOINT,12	;was 8
	add_world_sprites	SHIRT10000,1
	add_world_sprites	SHIRT10001,1
	add_world_sprites	BIRDS1,5
	add_world_sprites	EGG10000,4
	add_world_sprites	CRATE10000,6
	add_world_sprites	CRATE10001,1
	add_world_sprites	CRATE10002,1
	add_world_sprites	CRATE10003,1
	add_world_sprites	CRATE10004,1
	add_world_sprites	CRATE10005,1
	add_world_sprites	CRATE10006,20
	add_world_sprites	BANANA0000,4
	add_world_sprites	ENDING10000,10
	add_world_sprites	RECYCL0,8
	add_world_sprites	SUPERYRN0000,8
	add_world_sprites	TACKS10000,5
	add_world_sprites	EXCLAMATION,1
	add_world_sprites	BUBBLES0000,0
	add_world_sprites	SMOKE0,3
	add_world_sprites	SHIRT20000,0
	add_world_sprites	SHIRT20001,3

	make_current_world	1
	add_world_sprites	CAR_MISC,85

	add_world_sprites	MANHOLE10000,1
	add_world_sprites	MANHOLE10001,1
	add_world_sprites	MANHOLE10002,1
	add_world_sprites	MANHOLE10003,1

** MISC !!

	make_current_world	1
	add_world_sprites	GUARDS_MISC,45
	add_world_sprites	SIDS_EGG,1

	make_current_world	1
	add_world_sprites	GUARDS_MISC1,45-SIDD+75
	add_world_sprites	SIDS_EGG1,1