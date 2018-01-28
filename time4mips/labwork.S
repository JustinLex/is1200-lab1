  # labwork.S
  # Written 2015-2017 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1.
  # The macros PUSH and POP are in the public domain.
  # Please add your own code at the end of the file.

  #
  # Please keep the two macros PUSH and POP unchanged
  #
.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm
  #
  # Please add your own code below this line
  #

	hexasc:
		andi	$a0,$a0,0xf
		addi	$t0,$0,9
		ble	$a0,$t0,hop
		nop #[delay-slot]
		jr 	$ra
		addi	$v0,$a0,55 #[delay-slot]
	hop:
		jr	$ra
		addi	$v0,$a0,48 #[delay-slot]

.global	delay
delay:
			blez $a0 nomoredelay
			addi $t0,$0,800 #[delay-slot]
		delayloop:
			addiu $t0,$t0,-1
			bne 	$t0,$0,delayloop
			nop #[delay-slot]
			addiu $a0,$a0,-1
			bne		$a0, $0,delay
			nop #[delay-slot]
		nomoredelay:
			jr $ra
			nop #[delay-slot]

.global	time2string
			time2string:
				PUSH	$ra
				PUSH 	$s0 #preserve $s0
				PUSH	$s1 #preserve $s1
				PUSH	$s2 #preserve $s2
				move	$s0,$a0 #save output address

				sb		$0,5($s0) #write NUL at byte 5

				addi	$t0,$0,0x3A #write the ASCII colon char to temp register
				sb  	$t0,2($s0)#write colon at byte 3

				addi 	$s1,$0,4 #byte offset for writing
				addi 	$s2,$0,2 #hardcode loop to skip offset 2

				loop:
				beq		$s1,$s2,decrementoffset #skip if offset is 2 (don't overwrite colon)
				move	$a0,$a1 #prepare hexasc input [delay-slot]
				jal 	hexasc #convert first digit to ASCII
				nop #[delay-slot]
				add 	$t0,$s0,$s1 #calculate memory with offset
				sb		$v0,0($t0) #write $v0 into memory
				srl		$a1,$a1,4 #delete last number from input
				decrementoffset:
				addiu	$s1,$s1,-1
				bgez	$s1,loop
				nop #[delay-slot]


				POP		$s2
				POP		$s1
				POP 	$s0
				lw	$ra,0($sp)
				jr	$ra
				addi	$sp,$sp,4 #[delay-slot]
