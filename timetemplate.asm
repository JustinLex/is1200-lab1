  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"

	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,1000
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
hexasc:
	andi	$a0,$a0,0xf
	li	$t0,9
	ble	$a0,$t0,hop
	nop
	addi	$v0,$a0,55
	jr 	$ra
	nop
hop:
	addi	$v0,$a0,48
	jr	$ra
	nop

delay:
	blez $a0 nomoredelay
	nop
	addi $t0,$0,800
delayloop:
	addiu $t0,$t0,-1
	bne 	$t0,$0,delayloop
	nop
	addiu $a0,$a0,-1
	bne		$a0, $0,delay
	nop
nomoredelay:
	jr $ra
	nop

time2string:
	PUSH	($ra)
	PUSH 	($s0) #preserve $s0
	PUSH	($s1) #preserve $s1
	PUSH	($s2) #preserve $s2
	move	$s0,$a0 #save output address

	sb		$0,5($s0) #write NUL at byte 5

	addi	$t0,$0,0x3A #write the ASCII colon char to temp register
	sb  	$t0,2($s0)#write colon at byte 3

	addi 	$s1,$0,4 #byte offset for writing
	addi 	$s2,$0,2 #hardcode loop to skip offset 2

	loop:
	beq		$s1,$s2,decrementshift #see if offset is 2 (don't overwrite colon)
	nop
	move	$a0,$a1 #prepare hexasc input
	jal 	hexasc #convert first digit to ASCII
	nop
	add 	$t0,$s0,$s1 #calculate memory with offset
	sb		$v0,0,($t0) #write $v0 into memory
	srl		$a1,$a1,4 #delete last number from input
	decrementshift:
	addiu	$s1,$s1,-1
	bgez	$s1,loop
	nop

	lb	$t0,4($s0)
	addi	$t7,$0,57
	bne	$t0,$t7,notnine
	nop
	addi	$t6,$0,0x454e494e
	sw	$t6,4($s0)
	sb	$0,8($s0)
	notnine:

	POP		($s2)
	POP		($s1)
	POP 	($s0)
	POP 	($ra)
	jr	$ra
	nop
