.text
	j main
	j interrupt
	j exception

main:
	# clean PC[31]
	la $ra, userMain
	jr $ra

userMain:
	# load SysTick
	lui $s7, 0x00004000		# $s7 = 0x40000000
	lw $s6, 20($s7)
	
	li $sp, 1024			# prevent $sp grow out of range
	
	# call quickSort
	li $a0, 0			# $a0 = 0x00000000 as start address
	li $a1, 0			# $a1 = 0
	li $a2, 127			# $a2 = 127
	jal quickSort
	
	# load SysTick again, $s7 = 0x40000000
	lw $s5, 20($s7)
	sub $s4, $s5, $s6
	
	# put lower 16 bits of $s4 in $s0, $s1, $s2, $s3
	li $t0, 0xf
	and $s0, $t0, $s4
	srl	$s4, $s4, 4
	and $s1, $t0, $s4
	srl	$s4, $s4, 4
	and $s2, $t0, $s4
	srl	$s4, $s4, 4
	and $s3, $t0, $s4
	
	# use led[0] to show finish
	li $t0, 1
	sw $t0, 12($s7)

	li $s6, 0
	
	# Timer interrupt
	subi $t0, $zero, 0x000f
	sw $t0, 0($s7)			# TH = 0xffffff01
	subi $t0, $zero, 1
	sw $t0, 4($s7)			# TL = 0xffffffff
	li $t0, 3
	sw $t0, 8($s7)			# TCon = 3
	
loop:
	j loop

quickSort:
	# save registers, no need to save $s3, see comments below
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0		# store arr in $s0
	move $s1, $a1		# store left in $s1
	move $s2, $a2		# store right in $s2
	move $t0, $s1		# $t0 stores i
	move $t1, $s2		# $t1 stores j
	sll $t2, $s1, 2
	add $t2, $s0, $t2	# $t2 = array + 4 * left
	lw $s3, 0($t2)		# store key in $s3, key only used before calling quickSort, so no need to save register
	
	outerloop:
		innerloop1:
			sll $t2, $t1, 2
			add $t2, $s0, $t2
			lw $t3, 0($t2)				# $t3 = arr[j]
			bltu $t3, $s3, innerloop2	# exit if arr[j] < key
			bge $t0, $t1, innerloop2	# exit if i >= j
			addi $t1, $t1, -1			# j--
			j innerloop1
		innerloop2:
			sll $t2, $t0, 2
			add $t2, $s0, $t2
			lw $t3, 0($t2)				# $t3 = arr[i]
			bgtu $t3, $s3, innerexit		# exit if arr[i] > key
			bge $t0, $t1, innerexit		# exit if i >= j
			addi $t0, $t0, 1			# i++
			j innerloop2
		innerexit:
		bge $t0, $t1, exit				# break if i >= j
		sll $t2, $t0, 2
		add $t2, $s0, $t2				# $t2 = arr + 4 * i
		sll $t3, $t1, 2
		add $t3, $s0, $t3				# $t3 = arr + 4 * j
		lw $t4, 0($t2)					# $t4 = arr[i]
		lw $t5, 0($t3)					# $t5 = arr[j]
		sw $t4, 0($t3)					# arr[j] = $t4
		sw $t5, 0($t2)					# arr[i] = $t5
		j outerloop
	
	exit:
	sll $t2, $s1, 2
	add $t2, $s0, $t2					# $t2 = arr + 4 * left
	sll $t3, $t0, 2
	add $t3, $s0, $t3					# $t3 = arr + 4 * i
	lw $t4, 0($t3)						# $t4 = arr[i]
	sw $t4, 0($t2)						# arr[left] = $t4
	sw $s3, 0($t3)						# arr[i] = key
	
	addi $t2, $t0, -1					# $t2 = i - 1
	bge $s1, $t2, exit1					# exit if left >= i - 1
	move $a0, $s0						# $a0 = arr
	move $a1, $s1						# $a1 = left
	move $a2, $t2						# $a2 = i - 1
	jal quickSort
	
	exit1:
	addi $t2, $t0, 1					# $t2 = i + 1
	bge $t2, $s2, exit2					# exit if i + 1 >= right
	move $a0, $s0						# $a0 = arr
	move $a1, $t2						# $a1 = i + 1
	move $a2, $s2						# $a2 = right
	jal quickSort
	
	exit2:
	# restore registers and return
	lw $ra, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16
	jr $ra

interrupt:
	# Ignore saving registers since showing digits is the last part of program
	
	# $s7 = 0x40000000
	li $t0, 1
	sw $t0, 8($s7)			# TCon = 1
	
	beqz $s6, show0
	subi $t0, $s6, 1
	beqz $t0, show1
	subi $t0, $t0, 1
	beqz $t0, show2
	subi $t0, $t0, 1
	beqz $t0, show3

show0:
	li $t0, 0x00000100
	move $t1, $s0
	j digits
	
show1:
	li $t0, 0x00000200
	move $t1, $s1
	j digits

show2:
	li $t0, 0x00000400
	move $t1, $s2
	j digits

show3:
	li $t0, 0x00000800
	move $t1, $s3
	j digits

digits:
	# show digits with num in $t1 and en in $t0
	andi $t1, $t1, 0xf
	addi $t2, $zero, 0x00c0
	beq  $t1, 0, interruptExit
	addi $t2, $zero, 0x00f9
	beq  $t1, 1, interruptExit
	addi $t2, $zero, 0x00a4
	beq  $t1, 2, interruptExit
	addi $t2, $zero, 0x00b0
	beq  $t1, 3, interruptExit
	addi $t2, $zero, 0x0099
	beq  $t1, 4, interruptExit
	addi $t2, $zero, 0x0092
	beq  $t1, 5, interruptExit
	addi $t2, $zero, 0x0082
	beq  $t1, 6, interruptExit
	addi $t2, $zero, 0x00f8
	beq  $t1, 7, interruptExit
	addi $t2, $zero, 0x0080
	beq  $t1, 8, interruptExit
	addi $t2, $zero, 0x0090
	beq  $t1, 9, interruptExit
	addi $t2, $zero, 0x0088
	beq  $t1, 10, interruptExit
	addi $t2, $zero, 0x0083
	beq  $t1, 11, interruptExit
	addi $t2, $zero, 0x00c6
	beq  $t1, 12, interruptExit
	addi $t2, $zero, 0x00a1
	beq  $t1, 13, interruptExit
	addi $t2, $zero, 0x0086
	beq  $t1, 14, interruptExit
	addi $t2, $zero, 0x008e
	beq  $t1, 15, interruptExit
	addi $t2, $zero, 0x00ff
	
interruptExit:
	addi $s6, $s6, 1
	andi $s6, $s6, 3
	
	add $t0, $t0, $t2
	sw $t0, 16($s7)
	li $t0, 3
	sw $t0, 8($s7)			# TCon = 3
	jr $k0

exception:
	j exception
