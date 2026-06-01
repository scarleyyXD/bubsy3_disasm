gd0		equr	r0
gd1		equr	r1
gd2		equr	r2
gd3		equr	r3
gd4		equr	r4
gd5		equr	r5
gd6		equr	r6
gd7		equr	r7

ga0		equr	r8
ga1		equr	r14
ga2		equr	r9
ga3		equr	r10
ga4		equr	r11
ga5		equr	r15
ga6		equr	r12
ga7		equr	r18

temp		equr	r13
scroll_dir	equr	r16
exit		equr	r17

scroll_land_gpu:
	movei	#exit_prog,exit
	movei	#land_def,ga1
	moveq	#1,gd7
	movei	#WINDY,temp
	load	(temp),gd0
	movei	#$fffffff0,gd6
	and	gd6,gd0
	load	(ga1+previous_y),gd2
	store	gd1,(ga1+previous_y)
	sub	gd2,gd1
	sharq	#4,gd1
	add	gd1,gd7
	shlq	#2,gd7
	addq	#1,gd7
	movei	#WINDX,temp
	load	(temp),gd0
	and	gd6,gd0
	move	gd0,gd4
	load	(ga1+previous_x),gd3
	store	gd4,(ga1+previous_x)
	sub	gd3,gd4
	sharq	#4,gd4
	add	gd4,gd7
	move	gd7,scroll_dir
	moveq	#5,temp
	cmp	temp,gd7
	jmp	eq,(exit)
	nop
.ok:
	movei	#blit_base,ga5
	movei	#DOUBLETAKE,ga4
	moveq	#0,gd6
