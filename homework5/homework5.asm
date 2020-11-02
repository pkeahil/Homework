# November 1st, 2020

# This program makes use of heap allocation and macro use to
# print out original and compressed versions of a set of information
# given in a provided file. We utilize the RLE algorithm in order
# to do this. 


.include "macros.asm"

	.data
hello:		.asciiz "Hello world"
nL:		.asciiz	"\n"
heap:		.word	0
len:		.word	0
compSize:	.word	0
fileErrorMsg:	.asciiz "File not found!"
	.text
	
	# saving pointer to the heap
	allocateHeapMem
	sw	$v0, heap 
	
	mainLoop:
		getStringFromUser		# self explanatory
		
		# -----------------------------------------------------------------------------
		# Verify that the user entered a valid file name, or that they want to continue
		# -----------------------------------------------------------------------------
		lbu	$t0, ($a0)		# load the first byte, to see if user wants to exit
		beq	$t0, 10, exitMainLoop	# Exit if user only pressed enter
			
		add	$t1, $0, $a0		# User entered a file name, now we have to replace \n with \0 at end of string.
		cleanString:			# Loop through string until encountering newline char. 
			lbu	$t0, ($t1)
			beq	$t0, 10, fixNContinue
			addi	$t1, $t1, 1
			j	cleanString
		fixNContinue:
			sb	$0, ($t1)	# When we get to the newline char, replace it with a null terminator.
			
		# --------------------------------------
		# Process the file now
		# --------------------------------------
			openFile($a0) 		# $v0 has the file descriptor after this
			blt	$v0, 0, fileError
			move	$a0, $v0	# so we can use readFromFile after
	
			# pushing $a0 to the stack bc other macros use the register. 
			subi	$sp, $sp, 4
			sw	$a0, ($sp)
	
		# -------------------------------
		# Read from the file
		# --------------------------------
			readFromFile 		# $a1 has contents of the file after this
			sw	$v0, len	# $v0 has number of characters read
		
		# -------------------------------------------------------------------------
		# Append null terminator to file contents so that the heap doesn't complain
		# -------------------------------------------------------------------------
			lw	$t0, len
			add	$t1, $0, $a1
			li	$t2, 0
			appendNullTerminator:
				bge	$t2, $t0, append
				addi	$t1, $t1, 1
				addi	$t2, $t2, 1
				j	appendNullTerminator
			append:
				sb	$0, ($t1)
	
		# -----------------------------
		# Close the file
		# -----------------------------
			lw	$a0, ($sp)
			addi	$sp, $sp, 4
			closeFile
	
		# -----------------------------
		# Print original data
		# -----------------------------
			print("Original data:\n")
			printString($a1)
	
		# ---------------------------------------
		# Call the function to compress the data
		# ---------------------------------------
			print("Compressed data:\n")
			move	$a0, $a1
			lw	$a1, heap
			lw	$a2, len
			jal	CompressData	# $v0 has size of compressed data
			sw	$v0, compSize
	
		# -----------------------------------------
		# Call the function to uncompress the data
		# -----------------------------------------
			print("Uncompressed data:\n")
			lw	$a1, heap
			lw	$a2, compSize
			jal	UncompressData
			printNewline
			
		# -----------------------------------------------
		# Output statistics to console and reiterate loop
		# -----------------------------------------------
			lw	$t0, len
			lw	$t1, compSize
			print("Original file size: ")
			printInt($t0)
			printNewline
			print("Compressed file size: ")
			printInt($t1)
			printNewline
			j	mainLoop
	
	# ----------------------------------------------------------------
	# Output error and terminate if there's an issue with user's file
	# ----------------------------------------------------------------
	fileError:
		li	$v0, 4
		la	$a0, fileErrorMsg
		syscall
	# ---------------------------------------
	# Terminate normally, user wanted to exit
	# ---------------------------------------
	exitMainLoop:
		terminateProgram # self explanatory macro :)
	
# --------------------------------------------------------------------------------------------------
# Function to compress data. Utilizes RLE algorithm. Returns the length of compressed data in bytes.
# --------------------------------------------------------------------------------------------------
CompressData:
	# $a1 has heap, $a2 has length of data, $a0 has the actual data
	li	$t0, 0	# Counter to know when to exit
	li	$t6, 0	# Accumulator to keep track of how many bytes are in the compressed string.
	
	loop:
		bge	$t0, $a2, exitLoop # Loop condition: while(i < data.length())
		li	$t2, 1		# Counter to keep track of how many consecutive of one type of character there are.
		lbu	$t3, ($a0)	# Get current character
		lbu	$t4, 1($a0)	# Get next character
		subi	$t5, $a2, 1	# Subtract 1 from total length and store result in separate variable
		innerLoop:
			bge	$t0, $t5, exitInner # Loop condition: while(i < data.length() - 1 && cur == next)
			bne	$t3, $t4, exitInner
			addi	$t2, $t2, 1	# Increment counter for consecutive chars
			addi	$a0, $a0, 1	# Increment data accessor to move to next element
			addi	$t0, $t0, 1	# Increment iterator
			lbu	$t3, ($a0)	# Load the next byte
			lbu	$t4, 1($a0)	# Load the next-next byte
			j	innerLoop
		exitInner:
			subi	$sp, $sp, 4	# Push data onto stack because we need the $a0 register for printing
			sw	$a0, ($sp)
			printChar($t3)		# Print compressed data
			printInt($t2)
			lw	$a0, ($sp)	# Pop data back into $a0 now that our printing is done
			addi	$sp, $sp, 4
			
			addi	$t7, $t2, 48	# Store these values into the heap
			sb	$t3, ($a1)
			sb	$t7, 1($a1)
			
			addi	$t0, $t0, 1	# Increment iterator
			addi	$a0, $a0, 1	# increment data accessor
			addi	$a1, $a1, 2	# Increment heap accessor
			addi	$t6, $t6, 2	# Increment number of bytes in compressed version.
			j	loop
	exitLoop:
	sb	$0, ($a1) 	# Storing null at the end of the compressed version so heap doesn't complain
	sb	$0, 1($a1)
	
	li	$v0, 4		# Output newline
	la	$a0, nL
	syscall
	
	move	$v0, $t6	# Return size of compressed version in $v0 to calling function.
	jr	$ra
	

# ----------------------------------------------------------------------------------------------------
# Function to uncompress data, given compressed data. Outputs the uncompressed version to the console.
# ----------------------------------------------------------------------------------------------------
UncompressData:
	# $a1 has heap pointer
	# $a2 has size of compressed data
	
	li	$t0, 0	# Counter so we know when to exit the loop
	
	loopUncompress:
		bge	$t0, $a2, exitLoopUncompress	# Loop condition: while(i < data.length())
		lbu	$t1, ($a1)			# Load current byte, represents character to print
		lbu	$t2, 1($a1)			# Load next byte, represents amount of times to print that character
		beq	$t1, $0, exitLoopUncompress	# If either one of these is null terminator, exit the loop
		beq	$t2, $0, exitLoopUncompress
		subi	$t2, $t2, 48			# Subtract 48 from the second byte to get actual value represented.
		li	$t3, 0				# print-loop counter
		printLoopUncompress:
			bge	$t3, $t2, exitPrintLoop	
			printChar($t1)			# Print the character
			addi	$t3, $t3, 1		# Increment counter
			j	printLoopUncompress
		exitPrintLoop:
		
		addi	$t0, $t0, 2	# Increment counter
		addi	$a1, $a1, 2	# Increment heap accessor
		j	loopUncompress

	exitLoopUncompress:	# Return to calling function
		jr	$ra

