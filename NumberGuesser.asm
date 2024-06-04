	.data
globalArray:	.space	128
startOutput: 	.asciiz "Please choose a number from 1 to 32. \n"
displayCurrent:	.asciiz "\nHere are your current numbers: \n"
askUser: 	.asciiz "\nIs your card showing? (1 = Yes, 0 = No) \n"
invalidInput:	.asciiz "\nYou did not enter a 1 or 0. Please try again. \n"
finalNum:	.asciiz "\nThis is your card: "
repeatQ:	.asciiz "\nDo you want to restart? (1 = Yes, 0 = No) \n"

	.text
main:	
	li $v0, 4 			#system call to print string
	la $a0, startOutput 		#print output string
	syscall

firstPrint:
	addi $t6, $zero, 0		#set $t6 to 0	
	addi $t7, $zero, 32		#set $t7 to 32
	jal beforeFillArray	
	addi $s1, $zero, 0		#set $s1 to 0
	addi $s2, $zero, 32

secondPrint:
	slti $t0, $s1, 4 		#if $s1 >= 4, t0 = 0
	beq $t0, $zero, endProgram	#go to endProgram if $t0 = 0
	
	slti $t0, $v0, 1  		#if $v0 = 0(not showing), $t0 = 1
	beq $t0, 1, secNo		#if $t0 = 1, go to secNo
	
secYes: 
	sub $s2, $s2, $t7
	jal beforeFillArray	
	j thirdPrint
 
secNo:  
	sub $t6, $s2, $t7    		#set $t6 = 32 - $t7 for lower bound
	jal beforeFillArray	

thirdPrint:
	addi $s1, $s1, 1 		#increment $s1 by 1
	j secondPrint			#loop until $s1 = 4

endProgram:
	slti $t1, $v0, 1  		#if $v0 = 0 (showing), $t1 = 1 (array index)
	sll $t1, $t1, 2			#multiply by 4 for bytes
	li $v0, 4 			#set $v0 = 4: print string
	la $a0, finalNum 		#print finalNum
	syscall
	
	lw  $a0, globalArray($t1)	#set $a0 = $t1 #final number is in globalArray[0] or [1] 
	addi $v0, $zero, 1		#set $v0 to 1 : print integer
	syscall				#print integer
	
askRestart:
	li $v0, 4 			#set $v0 = 4: print string
	la $a0,repeatQ	 		#print repeatQ to ask for restart
	syscall
	
	li $v0, 5 			#store 1(yes) or 0(no) in $v0
	syscall
	
	beq $v0, 1, validRestart 	#continue only if input is 1 or 0
	beq $v0, 0, validRestart

	li $v0, 4 			#set $v0 = 4: print string
	la $a0, invalidInput 		#print invalidInput to ask for integer
	syscall
	
	j askRestart 			#loop until correct input
	
validRestart:		
	slti $t0, $v0, 1  		#if $v0 = 0, $t0 = 1
	beq $t0, 1, exit 		#if $t0 = 1, go to main
	j main

exit:
	li $v0, 10 			#service code 10: exit
	syscall				#exits
	
beforeFillArray:
	addi $s0, $zero, 0 		#set $s0 = 0 (number index)
	addi $sp, $sp, -4    
	sw $ra, 0($sp)       		# store $ra in $sp
	
fillArray:
	sltu $t0, $s0, $t7 		#if $s0 >= $t7, t0 = 0
	beq $t0, $zero, doneFillArray 	#go to doneFillArray if $t0 = 0
	
	addi $t1, $s0, 1 		#set $t1 = $s0 + 1
	addu $t1, $t1, $t6		#add lower bound
	sll $t2, $s0, 2 		#multiply $s0 by 4 and store in $t2
	sw $t1, globalArray($t2) 	#set globalArray[$t2] = $t1
	addi $s0, $s0, 1 		#increment $s0 by 1
	j fillArray			#loop until $s0 = $t7

doneFillArray:
	srl $t7, $t7, 1			#divide $t7 by 2
	addu $a1, $zero, $t7		#set $a1 = 16 (rng upper limit)
	addi $s0, $zero, 0		#set $s0 = 0

randomFillArr:
	sltu $t0, $s0, $t7		#if $s0 >= $t7, $t0 = 0
	beq $t0, $zero, doneRandomFillArr	#if $t0 = 0, go to doneRandomFillArr
	
	addi $v0, $zero, 42		#set $v0 to 42
	syscall				#$a0 = random index; $a1 = $t7
	
	sll $t2, $s0, 2 		#multiply $s0 by 4 and store in $t2
	sll $t4, $a0, 2 		#set $t4 = $a0 * 4
	lw $t3, globalArray($t2) 	#set $t3 = globalArray[$t2]
	lw $t5, globalArray($t4) 	#set $t5 = globalArray[$t4]
	
	sw $t5, globalArray($t2)	#store $t5 into globalArray[$t2]
	sw $t3, globalArray($t4) 	#store $t3 into globalArray[$t4]	
	addi $s0, $s0, 1		#increment $s0 by 1
	j randomFillArr 		#loop until elements are random
	
doneRandomFillArr:	
	li $v0, 4 			#set $v0 = 4 : print string
	la $a0, displayCurrent 		#display cards prompt
	syscall
	addi $s0, $zero, 0 		#set $s0 = 0

printArr:
	sltu $t0, $s0, $t7		#if $s0 >= $t7, $t0 = 0
	beq $t0, $zero, afterPrint	#if $t0 = 0, goto afterHalf
	
	sll $t2, $s0, 2 		#multiply $s0 by 4 and store in $t2
	lw $a0, globalArray($t2)	#set $a0 = globalArray[$t2]
	addi $v0, $zero, 1		#set $v0 to 1 : print integer
	syscall				#print integer
	
	addi $a0, $zero, 32		#set $a0 = 32 : Ascii value for space
	addi $v0, $zero, 11		#set $v0 = 11 : print character
	syscall				
	
	addi $s0, $s0, 1		#increment $s0 by 1
	j printArr			#loop until all even elements are printed

afterPrint:
	li $v0, 4 			#set $v0 = 4: print string
	la $a0, askUser 		#print askUser to ask for integer
	syscall
	
	li $v0, 5 			#store 1(showing) or 0(not showing) in $v0
	syscall
	
	beq $v0, 1, returnMain 		#continue only if input is 1 or 0
	beq $v0, 0, returnMain
	
	li $v0, 4 			#set $v0 = 4: print string
	la $a0, invalidInput 		#print invalidInput to ask for integer
	syscall
	
	j afterPrint 			#loop until correct input
	
returnMain:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra				#return from jal
