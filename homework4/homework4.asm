# Paul Lupeituu
# October 11, 2020


# This is a program to display a square with a marquee effect. 
# There is keyboard functionality to this program when it is running,
# where you can move the box up, down, left, or right using the
# keys w, s, a, and d, respectively. 

# In order to run, build / assemble the program first, then
# open both the bitmap display and Keyboard and Display MMIO Simulator,
# adjust the settings in the bitmap display to 4x4 unit width and unit height,
# and 256x256 for display width and height.

# Then, connect botht he bitmap display and Keyboard and Display MMIO Simulator
# to MIPS, then run the program.

# Side note: this project was really fun, should do something like this again
# in the future :)


.eqv	MEM	0x10010000
.eqv	RED	0x00FF0000
.eqv	GREEN	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE	0x00FFFFFF
.eqv	YELLOW	0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF
.eqv	BLACK 	0x00000000
.eqv	WIDTH	64
.eqv	HEIGHT	64


	.data
arr:	.word	RED, GREEN, BLUE, WHITE, YELLOW, CYAN, MAGENTA


	.text
	
	# Set starting position
	addi	$a0, $0, WIDTH
	sra	$a0, $a0, 1
	addi	$a1, $0, HEIGHT
	sra	$a1, $a1, 1
	
	li	$t3, 0 	# this helps with looping
loop:
	# draw square
	jal	DrawSquare
	addi	$t3, $t3, 1 # to continue w/ marquee effect
	
	# check for input
	lw	$t5, 0xffff0000
	beq	$t5, 0, loop
	
	# process input
	lw	$s5, 0xffff0004
	beq	$s5, 32, exit 	# input space
	beq	$s5, 119, up 	# input w
	beq	$s5, 115, down	# input s
	beq	$s5, 97, left	# input a
	beq	$s5, 100, right # input d
	
	# invalid input, ignore
	j	loop
	
up:	# Black-out square and redraw it 1 unit up
	jal	DrawBlackSquare
	addi	$a1, $a1, -1
	jal	DrawSquare
	j	loop

down:
	# Black-out the square and redraw it 1 unit down
	jal	DrawBlackSquare
	addi	$a1, $a1, 1
	jal	DrawSquare
	j	loop

left:	
	# Black-out square and redraw it 1 unit left
	jal	DrawBlackSquare
	addi	$a0, $a0, -1
	jal	DrawSquare
	j	loop

right:
	# Black-out square and redraw it 1 unit right
	jal	DrawBlackSquare
	addi	$a0, $a0, 1
	jal	DrawSquare
	j	loop

	
exit:	
	# End program
	li	$v0, 10
	syscall
	
	
	
# ------------------------------------------- *	
# Function to draw square with marquee effect *
# ------------------------------------------- *
DrawSquare:
	# Save $ra onto stack because we're gonna call other functions from here
	subi	$sp, $sp, 4
	sw	$ra, ($sp)
	
	addi	$t6, $a0, 0 	# save  $a0 because syscall 32 needs $a0 too smh
	
	ble	$t3, 7, continue # these two lines are saying if(i > 7) i = 0;
	li	$t3, 0
	
	continue:	
		# Delay output by 140ms to give it the marquee effect
		li	$v0, 32
		li	$a0, 140
		syscall
		
		# Now actually draw the wonderful colored square
		addi	$a0, $t6, 0 # put a0 back where it should be
		addi	$a2, $t3, 0 # get the color to start with
		jal	DrawMarqueeSquare
		
	# Restore $ra and return to calling function	
	lw	$ra, ($sp)
	addi	$sp $sp, 4
	jr	$ra




# ------------------------------------------------- *
# Function to black-out the previously drawn square *
# ------------------------------------------------- *
DrawBlackSquare: 

	# Save $ra onto stack because we're gonna call other functions from here
	subi	$sp, $sp, 4
	sw	$ra, ($sp)
	
	li	$a2, BLACK # I mean... this is self explanatory...
	
	# Also self-explanatory...
	jal	DrawBlackTop
	jal	DrawBlackRight
	jal	DrawBlackBottom
	jal	DrawBlackLeft
	
	# Restore $ra and return to calling function
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
	


# ------------------------------------------------- *
# Function to draw the colorful sides of the square *
# ------------------------------------------------- *
DrawMarqueeSquare: 

	# Save $ra onto stack, we're calling other functions from here
	subi	$sp, $sp, 4
	sw	$ra, ($sp)
	
	# Self-explanatory...
	jal	DrawMarqueeTop
	jal	DrawMarqueeRight
	jal	DrawMarqueeBottom
	jal	DrawMarqueeLeft
	
	# Restore $ra, return to calling function
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
	
	
# ----------------------------------------- *
# Function to draw top side of black square *
# ----------------------------------------- *
DrawBlackTop:
	
	# Loop counter
	li	$t0, 0
	loopBTop:
		bge	$t0, 7, exitBTop	# Condition for continuing loop
		continueBTop:
		
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH # y * width
			add	$s1, $s1, $a0	# add x
			mul	$s1, $s1, 4	# mul by 4 to get word offset
			add	$s1, $s1, MEM	# add to base address
			
			# Store black pixel at specified address
			sw	$a2, 0($s1)
			
			# Increment counters and loop back
			addi	$a0, $a0, 1
			addi	$t0, $t0, 1
			j	loopBTop
	
	# Return to calling function
	exitBTop:
		li	$t0, 0
		jr	$ra
	
	
			
# ------------------------------------------- *
# Function to draw right side of black square *
# ------------------------------------------- *	
DrawBlackRight:

	# Loop counter
	li	$t0, 0
	
	loopBRight:
		bge	$t0, 7, exitBRight # Condition to continue loop
		
		continueBRight:
		
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1 4
			add	$s1, $s1, MEM
			
			# Store black pixel at specified location
			sw	$a2, 0($s1)
			
			# Increment counters and loop back
			addi	$a1, $a1, 1
			addi	$t0, $t0, 1
			j	loopBRight
	
	# Return to calling function
	exitBRight:
		li	$t0, 0
		jr	$ra



# --------------------------------------- *
# Function to draw bottom of black square *
# --------------------------------------- *
DrawBlackBottom:

	# Loop counter
	li	$t0, 7
	
	loopBBottom:
		ble	$t0, 0, exitBBottom # Loop continuation condition
		
		continueBBottom:
		
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1, 4
			add	$s1, $s1, MEM
			
			# Store black pixel at specified location
			sw	$a2, 0($s1)
			
			# Decrement counters and loop back
			subi	$a0, $a0, 1
			subi	$t0, $t0, 1
			j	loopBBottom
			
	# Return to calling function
	exitBBottom:
		li	$t0, 7
		jr	$ra



# --------------------------------------- *
# Function to draw bottom of black square *
# --------------------------------------- *
DrawBlackLeft:

	# Loop counter
	li	$t0, 7
	
	loopBLeft:
		ble	$t0, 0, exitBLeft # Loop continuation condition
		
		continueBLeft:
		
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1, 4
			add	$s1, $s1, MEM
			
			# Store black pixel at specified location
			sw	$a2, 0($s1)
			
			# Decrement counters and loop back
			subi	$a1, $a1, 1
			subi	$t0, $t0, 1
			j	loopBLeft
			
	# Return to calling function
	exitBLeft:
		li	$t0, 7
		jr	$ra
	
	
	
	
# --------------------------------------- *
# Function to draw the top of marquee box *
# --------------------------------------- *
DrawMarqueeTop: 
	
	# Counter and array access variables
	li	$t0, 0
	mul	$t1, $a2, 4
	
	loopTop:
		bge	$t0, 7, exitTop 	# Loop continuation condition
		ble	$t1, 28, continueTop	# Reset array access (arr[i]) variable if out of range
		li	$t1, 0 
		
		continueTop: 
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1, 4
			add	$s1, $s1, MEM
			
			# Load a color in from color array and store it at specified location
			lw	$t2, arr($t1)
			sw	$t2, 0($s1)
			
			# Increment counters and loop back
			addi	$a0, $a0, 1
			addi	$t0, $t0, 1
			addi	$t1, $t1, 4
			j	loopTop
			
	# Return to calling function
	exitTop:
		li	$t0, 0
		jr	$ra



# ------------------------------------------ *
# Function to draw right side of marquee box *
# ------------------------------------------ *
DrawMarqueeRight:
	
	# Counter and array access variable
	li	$t0, 0
	mul	$t1, $a2, 4
	
	loopRight:
		bge	$t0, 7, exitRight	# Loop continuation condition
		ble	$t1, 28, continueRight	# Reset color array accessor if out of range
		li	$t1, 0
		
		continueRight:
			 
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1, 4
			add	$s1, $s1, MEM
			
			# Get color from color array and store it at specified location
			lw	$t2, arr($t1)
			sw	$t2, 0($s1)
			
			# Increment counters and loop back
			addi	$a1, $a1, 1
			addi	$t0, $t0, 1
			addi	$t1, $t1, 4
			j	loopRight
			
	# Return to calling function
	exitRight:
		li	$t0, 0
		jr	$ra
		
		
		
# ----------------------------------------- *	
# Function to draw bottom of marquee square *
# ----------------------------------------- *
DrawMarqueeBottom:
	
	# Counter and array access variables
	li	$t0, 7
	mul	$t1, $a2, 4
	
	loopBottom:
		ble	$t0, 0, exitBottom	# Loop continuation condition
		ble	$t1, 28, continueBottom # Reset color array accessor if out of range
		li	$t1, 0
		
		continueBottom:
		
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1, 4
			add	$s1, $s1, MEM
			
			# Get color from color array and store it at specified location
			lw	$t2, arr($t1)
			sw	$t2, 0($s1)
			
			# Decrement counters and loop back
			subi	$a0, $a0, 1
			subi	$t0, $t0, 1
			addi	$t1, $t1, 4
			j	loopBottom
			
	# Return to calling function
	exitBottom:
		li	$t0, 7
		jr	$ra



# -------------------------------------------- *
# Function to draw left side of marquee square *
# -------------------------------------------- *
DrawMarqueeLeft:

	# Counter and array access variables
	li	$t0, 7
	mul	$t1, $a2, 4
	
	loopLeft:
		ble	$t0, 0, exitLeft	# Loop continuation condition
		ble	$t1, 28, continueLeft # Reset color array accessor if out of range
		li	$t1, 0
		
		continueLeft:
		
			# Get pixel to draw at
			mul	$s1, $a1, WIDTH
			add	$s1, $s1, $a0
			mul	$s1, $s1, 4
			add	$s1, $s1, MEM
			
			# Get color from color array and store it at specified location
			lw	$t2, arr($t1)
			sw	$t2, 0($s1)
			
			# Decrement counters and loop back
			subi	$a1, $a1, 1
			subi	$t0, $t0, 1
			addi	$t1, $t1, 4
			j	loopLeft
	
	# Return to calling function
	exitLeft:
		li	$t0, 7
		jr	$ra
	
	
	
	
	
	
	
