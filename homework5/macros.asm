# November 1st, 2020

# Yay, macros. Here to make your life so much easier :)

# ---------------------------------------------
# Macro to print a string given a string value
# ---------------------------------------------
.macro print(%string)
		.data
	string:	.asciiz	%string
		.text
	li	$v0, 4
	la	$a0, string
	syscall
.end_macro

# -----------------------------------------------------------
# Macro to print an int given an integer stored in a register
# -----------------------------------------------------------
.macro printInt(%int)
		.data
	nL:	.asciiz "\n"
		.text
	add	$a0, $0, %int
	li	$v0, 1
	syscall
.end_macro

# ------------------------------------------------------------------
# Macro to print a character given a character stored in a register
# ------------------------------------------------------------------
.macro printChar(%char)
		.data
	nL:	.asciiz "\n"
		.text
	li	$v0, 11
	add	$a0, $0, %char
	syscall
.end_macro

# --------------------------------------------------------------------------------------------------
# Macro to print a string given a string stored in a register (Different from first macro I promise)
# --------------------------------------------------------------------------------------------------
.macro printString(%str)
		.data
	nL:	.asciiz "\n"
		.text
	li	$v0, 4
	add	$a0, $0, %str
	syscall
	li	$v0, 4
	la	$a0, nL
	syscall
.end_macro

# --------------------------------------------------------------------------------
# Macro to get a string from the user, used by the main function to get a filename
# --------------------------------------------------------------------------------
.macro	getStringFromUser
		.data
	prompt:	.asciiz "Enter file name"
	nL:	.asciiz "\n"
	input:	.space	256
		.text
	li	$v0, 4
	la	$a0, prompt
	syscall
	li	$v0, 4
	la	$a0, nL
	syscall
	li	$v0, 8
	la	$a0, input
	li	$a1, 256
	syscall
.end_macro

# ----------------------------------------------------------------------------
# Macro to open a file, given a file name. Utilizes syscall 13 as you can see
# ----------------------------------------------------------------------------
.macro	openFile(%filename)
	li	$v0, 13
	add	$a0, $0, %filename
	li	$a1, 0
	li	$a2, 0
	syscall
.end_macro

# -------------------------------------
# Macro to read data from an open file
# -------------------------------------
.macro	readFromFile
		.data
	buffer:	.space	1024
		.text
	li	$v0, 14
	la	$a1, buffer
	li	$a2, 1024
	syscall
.end_macro

# ---------------------
# Macro to close a file
# ---------------------
.macro	closeFile
	li	$v0, 16
	syscall
.end_macro

# ------------------------------
# Macro to allocate heap memory
# ------------------------------
.macro	allocateHeapMem
	li	$v0, 9
	li	$a0, 1024
	syscall
.end_macro

# -------------------------------------------------
# Macro to print a newline for formatting purposes
# -------------------------------------------------
.macro printNewline
		.data
	nL:	.asciiz "\n"
		.text
	li	$v0, 4
	la	$a0, nL
	syscall
.end_macro

# ------------------------------
# Macro to terminate the program
# ------------------------------
.macro	terminateProgram
	li	$v0, 10
	syscall
.end_macro
