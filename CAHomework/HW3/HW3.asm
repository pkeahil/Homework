		.data
		
fileWords:	.space 	80
numArray:	.space	80
length:		.word	20
len:		.float	19.0
mean:		.float	0.0
fileName:	.asciiz "input.txt"
msg:		.asciiz "separating full string output from array output\n"
nL:		.asciiz "\n"
space:		.asciiz " "
arrBefore:	.asciiz	"The array before:\t"
arrAfter:	.asciiz "The array after:\t"
meanMsg:	.asciiz "The mean is: "
medianMsg:	.asciiz "The median is: "
stDevMsg:	.asciiz "The standard deviation is: "
errorMsg:	.asciiz "Something went wrong trying to read the file.\n"


		.text
		
	# -------------------------------------------------- *
	#                READ FROM FILE                      *
	# -------------------------------------------------- *
	la	$a0, fileName
	la	$a1, fileWords
	jal	ReadInputFile
	
	ble	$v0, 0, terminate # continue only if value in $v0 is > 0
	
	# -------------------------------------------------- *
	#          EXTRACT INTEGERS FROM INPUT BUFFER        *
	# -------------------------------------------------- *
		la	$a0, numArray	
		la	$a2, ($a1)
		li	$a1, 20
		jal	ExtractInts
	
	# -------------------------------------------------- *
	#           PRINT ARRAY BEFORE SORTING               *
	# -------------------------------------------------- *
		li	$v0, 4
		la	$a0, arrBefore
		syscall
		jal	PrintInts
		
	# -------------------------------------------------- *
	#            SORT ARRAY W/ SELECTION SORT            *
	# -------------------------------------------------- *
		jal	SelectionSort
		
	# -------------------------------------------------- *
	#            PRINT ARRAY AFTER SORTING               *
	# -------------------------------------------------- *
		li	$v0, 4
		la	$a0, arrAfter
		syscall
		jal	PrintInts
		
	# -------------------------------------------------- *
	#              CALCULATE THE MEAN                    *
	# -------------------------------------------------- *
		la	$a0, numArray
		li	$a1, 20
		jal	CalcPrintMean # calculate mean
	
		# output for "The mean is: ....."
		li	$v0, 4
		la	$a0, meanMsg  
		syscall
		li	$v0, 2		 
		syscall	
		li	$v0, 4
		la	$a0, nL
		syscall	
		
	# -------------------------------------------------- *
	#                CALCULATE THE MEDIAN                *
	# -------------------------------------------------- *	
		la	$a0, numArray
		li	$a1, 20
		jal	CalcPrintMedian # calculate median
		
		# output for "The median is: ....."
		li	$v0, 4
		la	$a0, medianMsg
		syscall
		li	$v0, 2		
		syscall		
		li	$v0, 4
		la	$a0, nL
		syscall	
		
	# -------------------------------------------------- *
	#            CALCULATE STANDARD DEVIATION            *
	# -------------------------------------------------- *
		la	$a0, numArray
		li	$a1, 20
		jal	CalcPrintStDev # calculate stdev
		
		# output for "The standard deviation is: ...."
		li	$v0, 4
		la	$a0, stDevMsg
		syscall
		li	$v0, 2		 
		syscall
		li	$v0, 4
		la	$a0, nL
		syscall
		
	# -------------------------------------------------- *
	#                 END OF PROGRAM                     *
	# -------------------------------------------------- *
		j 	programEnd			
	
terminate:
	li	$v0, 4
	la	$a0, errorMsg
	syscall
programEnd:
	li	$v0, 10
	syscall
	

ReadInputFile:
	# Put addresses of filename and buffer into temp registers for safekeeping
	la	$t0, ($a0)
	la	$t1, ($a1)
	
	# Open file in reading mode
	li	$v0, 13
	la	$a0, ($t0)
	li	$a1, 0
	syscall
	move	$s0, $v0
	
	# Read contents of file into the buffer
	li	$v0, 14
	move	$a0, $s0
	la	$a1, ($t1)
	li	$a2, 80
	syscall
	
	# Return to main
	jr	$ra
				
						
ExtractInts:
		# Counter, accumulator, and constant (for multiplication) variables
		li	$t2, 0 		
		li	$t3, 0		
		li	$t4, 10
		li	$t5, 0
	
		# Loop until end of data 	
	loop:	lbu	$t1, ($a2)
		bgt	$t1, 57, ignore		# Check between range [48, 57]
		blt	$t1, 48, NLCheck
		subi	$t1, $t1, 48		# Subtract 48 to get integer value
		mul	$t3, $t3, $t4		# Add to accumulator
		add	$t3, $t3, $t1
		addi	$t1, $t1, 48 	# so that it doesn't screw with the other parts of function
	
		# Newline check: store accumulator value in array if encountered
	NLCheck:
		bne	$t1, 10, EOFCheck	# Check if end of data
		sw	$t3, numArray($t2)	# numArray[j] = value;
		addi	$t2, $t2, 4		# j++;
		addi	$t3, $0, 0		# Reset accumulator
	
		# End of data check: exit the loop if encountered
	EOFCheck:
		bne	$t1, 0, ignore	# Check if NOT at end of data
		j 	end		# exit the loop

		# Increment i and loop back. Equivalent to i++ right before a while loop ends.
	ignore:	addi	$a2, $a2, 1
		j 	loop	

		# Return to main
	end:	jr	$ra	
	
	
	
PrintInts:
	li	$t0, 0 	# i, increments by 4 each time
	li	$t1, 0	# number of iterations, increments by 1 each time
	printLoop:
		
		bge	$t1, 20, backToMain	# while(i < 20) {
		li	$v0, 1			# 
		lw	$a0, numArray($t0)	#     print(numArray[i]);
		syscall				#
		li	$v0, 4			#
		la	$a0, space		#     print(" ");
		syscall				#
		addi	$t0, $t0, 4		#     
		addi	$t1, $t1, 1		#     i++;
		j 	printLoop		# }
	
	backToMain:
		li	$v0, 4			# 
		la	$a0, nL			# print("\n");
		syscall				#
		jr	$ra			# return;
		
		
		
SelectionSort:
	# loading addresses and temporary registers to help with sorting
	la	$s0, numArray
	li	$t0, -1		# register to represent minIndex
	li	$t1, -1		# register to represent minValue
	li	$t2, 0		# register to represent i
	li	$t3, 0		# register to represent i, but for accessing array values
	outerLoop:
		bge	$t2, 19, exitLoop		# while(i < (20 - 1)) {
		addi	$t0, $t3, 0			#     minIndex = i;
		lw	$t1, numArray($t3)		#     minValue = numArray[i];
		addi	$t4, $t2, 1			#     int j = i + 1;
		addi	$t5, $t3, 4			#     int j = i + 1 (but for accessing array elements)
		innerLoop:
			bge	$t4, 20, exitInner	#     while(j < 20) {
			lw	$s1, numArray($t5)	#         int temp1 = numArray[j];
			bge	$s1, $t1, continueInner #         if(numArray[j] < minValue) {
			lw	$t1, numArray($t5)	#             minValue = numArray[j];
			addi	$t0, $t5, 0		#             minIndex = j;
		continueInner:				#         }
			addi	$t4, $t4, 1		# 	  j++;
			addi	$t5, $t5, 4		#	  j++; (but for accessing array elements)
			j	innerLoop		#     }
	exitInner:					#
		lw	$t6, numArray($t3)		#     int temp2 = numArr[i];
		lw	$t7, numArray($t0)		#     int temp3 = numArr[minIndex];
		sw	$t7, numArray($t3)		#     numArr[i] = numArr[minIndex];
		sw	$t6, numArray($t0)		#     numArr[minIndex] = numArr[i];
		addi	$t2, $t2, 1			#     i++;
		addi	$t3, $t3, 4			#     i++; (but for accessing array elements)
		j	outerLoop			# }
	exitLoop:
		jr	$ra				# return;
	
		
		
		
CalcPrintMean:
	li	$t0, 0 # accessor for array elements
	li	$t1, 0 # counter
	li	$t2, 0 # accumulator
	meanLoop:
		bge	$t1, 20, returnMean	# while(i < 20) {
		lw	$t3, numArray($t0)	#     curr = numArray[i];
		add	$t2, $t2, $t3		#     accumulator += curr;
		addi	$t0, $t0, 4		#     
		addi	$t1, $t1, 1		#     i++;
		j 	meanLoop		# }
		
	returnMean:
		mtc1	$t2, $f0	# sum = (double)sum;
		cvt.s.w	$f0, $f0	#
		lwc1	$f2, length	# length = (double)length;
		cvt.s.w	$f2, $f2	#
		div.s	$f4, $f0, $f2	# result = sum / length;		
		mtc1	$0, $f6		# temp = 0.0;
		add.s	$f12, $f6, $f4	# f12 = result + temp;
					
		s.s	$f4, mean	# Store FP value into memory
		jr	$ra		# return;
		
CalcPrintMedian:
	li	$t2, 36			# i = 9;
	li	$t3, 40			# j = 10;
	
	
	lw	$t0, numArray($t2)	
	mtc1	$t0, $f0		# num1 = (double)numArray[i];
	lw	$t1, numArray($t3)	
	mtc1	$t1, $f2 		# num2 = (double)num2;
	
	
	add.s	$f4, $f0, $f2		# sum = num1 + num2;
	li	$t0, 2			# denom = 2.0;
	mtc1	$t0, $f6
	div.s	$f8, $f4, $f6		# result = sum / denom;
	mtc1	$0, $f10		# temp = 0.0;
	
	add.s	$f12, $f10, $f8		# F12 = result + temp;
	
	jr	$ra			# return;
	
CalcPrintStDev:
	mtc1	$0, $f0 	# double accumulator = 0.0
	li	$t0, 0  	# int i = 0;
	li	$t1, 0  	# 
	l.s	$f2, mean 	# double mean = 38.85;
	mtc1	$0, $f10	# double temp = 0.0
	
	stDevLoop:
		bge	$t0, 20, returnStDev	# while(i < 20) {
		lw	$t3, numArray($t1) 	#     int num = numArray[i]
		mtc1	$t3, $f4 		#     
		cvt.s.w $f4, $f4 		#     double value = (double)num;
		sub.s	$f6, $f4, $f2 		#     diff = value - mean;
		mul.s	$f6, $f6, $f6 		#     diff = pow(diff, 2.0);
		add.s	$f0, $f0, $f6 		#     accumulator += diff;
		addi	$t0, $t0, 1		# 
		addi	$t1, $t1, 4		#     i++;
		j	stDevLoop		# }
		
	returnStDev:
		l.s	$f6, len		# double length = 19.0;
		div.s	$f0, $f0, $f6		# value = sum / length;
		sqrt.s	$f0, $f0		# value = sqrt(value);
		add.s	$f12, $f0, $f10		# F12 = value + 0.0;
		jr	$ra			# return;
	
	
		
	
	
	
	
	
	
	
	
	
