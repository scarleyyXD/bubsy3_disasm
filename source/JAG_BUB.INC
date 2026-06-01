		include	"specific.jag/blitter.s"		;ok - needs some new routines
		include	"specific.jag/objlist.inc"		;ok
		
		if	DBUFF
		include	"specific.jag/jpiclist.s"		;ok
		else
		include	"specific.jag/jpiclisz.s"		;ok
		endif
		
		include	"specific.jag/obj.s"			;ok
		include	"specific.jag/keypad.s"			;ok
		include	"specific.jag/a_ints.s"			;ok
		include	"specific.jag/music.s"			;ok
		include	"specific.jag/sfx.s"			;ok
		include	"specific.jag/eeprim.s"			;ok
		include	"specific.jag/pause.s"			;ok
		include	"specific.jag/nobjlist.s"		;ok
		include	"specific.jag/rommer.s"