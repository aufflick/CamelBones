/* Trampoline for mips CPU in 64-bit mode */

/*
 * Copyright 1996 Bruno Haible, <bruno@clisp.org>
 *
 * This is free software distributed under the GNU General Public Licence
 * described in the file COPYING. Contact the author if you don't have this
 * or can't live with it. There is ABSOLUTELY NO WARRANTY, explicit or implied,
 * on this software.
 */

/* Available registers: $2, $3. */

	.set	nobopt
	.set	noreorder
	.text
	.globl	main
	.ent	main
main:
	.end	main
	.globl	tramp
	.ent	tramp
tramp:
#	dli	$2,0x1234567813578765
	lui	$2,0x1234
	ori	$2,$2,0x5678
	dsll	$2,$2,16
	ori	$2,$2,0x1357
	dsll	$2,$2,16
	ori	$2,$2,0x8765
#	dli	$3,0x7355471143622155
	lui	$3,0x7355
	ori	$3,$3,0x4711
	dsll	$3,$3,16
	ori	$3,$3,0x4362
	dsll	$3,$3,16
	ori	$3,$3,0x2155
	sd	$3,0($2)
#	dli	$25,0xbabebec0dea0ffab
	lui	$25,0xbabe
	ori	$25,$25,0xbec0
	dsll	$25,$25,16
	ori	$25,$25,0xdea0
	dsll	$25,$25,16
	ori	$25,$25,0xffab
	/* The called function expects to see its own address in $25. */
	j	$25
	/* Some Mips hardware running Irix-4.0.5 needs this nop. */
	nop
	.end	tramp
