# MazeGenerator.s
#
# by Christopher Combs
#
# Using skeleton code by Patrick Kelly
#
# QtSpim
#
# Last modified: 11/25/2016
#==============================================================================
# maze.s
#
# by Patrick Kelley
#
# This program produces a maze in an 80 X 24 grid by recursively pathing
# through the grid space.  It is an implementation of the following C++ code
# and is an example of equivalent coding.  As such, the complete code is given
# below and then repeated as comments in the assembly code.
#
# This code is intended to be built in the QTSPIM environment and run at a
# console command prompt with no parameters.  Each run should produce a unique
# maze.
#
# Last modified: 3/31/2014 by Patrick Kelley
#==============================================================================

# BEGIN C++ CODE
# //===========================================================================
# // maze.cpp
# //
# // C++ implementation of a recursive maze-generating program.
# //
# // History:
# // 2006.03.30 / Abe Pralle - Created
# // 2010.04.02 / Abe Pralle - Converted to C++
# //===========================================================================
# #include <iostream>
# using namespace std;
#
# //----CONSTANTS-------------------------------------------------------
# #define GRID_WIDTH 79
# #define GRID_HEIGHT 23
# #define NORTH 0
# #define EAST 1
# #define SOUTH 2
# #define WEST 3
#
# //----GLOBAL VARIABLES------------------------------------------------
# char grid[GRID_WIDTH*GRID_HEIGHT];
#
# //----FUNCTION PROTOTYPES---------------------------------------------
# void ResetGrid();
# int XYToIndex( int x, int y );
# int IsInBounds( int x, int y );
# void Visit( int x, int y );
# void PrintGrid();
#
# //----FUNCTIONS-------------------------------------------------------
# int main()
# {
#   // Starting point and top-level control.
#   srand( time(0) ); // seed random number generator.
#   ResetGrid();
#   Visit(1,1);
#   PrintGrid();
#   return 0;
# }
#
# void ResetGrid()
# {
#   // Fills the grid with walls ('#' characters).
#   for (int i=0; i<GRID_WIDTH*GRID_HEIGHT; ++i)
#   {
#     grid[i] = '#';
#   }
# }
#
# int XYToIndex( int x, int y )
# {
#   // Converts the two-dimensional index pair (x,y) into a
#   // single-dimensional index. The result is y * ROW_WIDTH + x.
#   return y * GRID_WIDTH + x;
# }
#
# int IsInBounds( int x, int y )
# {
#   // Returns "true" if x and y are both in-bounds.
#   if (x < 0 || x >= GRID_WIDTH) return false;
#   if (y < 0 || y >= GRID_HEIGHT) return false;
#   return true;
# }
#
# void Visit( int x, int y )
# {
#   // Starting at the given index, recursively visits every direction in a
#   // randomized order.
#   // Set my current location to be an empty passage.
#   grid[ XYToIndex(x,y) ] = ' ';
#
#   // Create an local array containing the 4 directions and shuffle their
#   // order.
#   int dirs[4];
#   dirs[0] = NORTH;
#   dirs[1] = EAST;
#   dirs[2] = SOUTH;
#   dirs[3] = WEST;
#
#   for (int i=0; i<4; ++i)
#   {
#     int r = rand() & 3;
#     int temp = dirs[r];
#     dirs[r] = dirs[i];
#     dirs[i] = temp;
#   }
#
#   // Loop through every direction and attempt to Visit that direction.
#   for (int i=0; i<4; ++i)
#   {
#     // dx,dy are offsets from current location. Set them based
#     // on the next direction I wish to try.
#     int dx=0, dy=0;
#     switch (dirs[i])
#     {
#       case NORTH: dy = -1; break;
#       case SOUTH: dy = 1; break;
#       case EAST: dx = 1; break;
#       case WEST: dx = -1; break;
#     }
#
#     // Find the (x,y) coordinates of the grid cell 2 spots
#     // away in the given direction.
#     int x2 = x + (dx<<1);
#     int y2 = y + (dy<<1);
#
#     if (IsInBounds(x2,y2))
#     {
#       if (grid[ XYToIndex(x2,y2) ] == '#')
#       {
#         // (x2,y2) has not been visited yet... knock down the
#         // wall between my current position and that position
#         grid[ XYToIndex(x2-dx,y2-dy) ] = ' ';
#
#         // Recursively Visit (x2,y2)
#         Visit(x2,y2);
#       }
#     }
#   }
# }
#
# void PrintGrid()
# {
#   // Displays the finished maze to the screen.
#   for (int y=0; y<GRID_HEIGHT; ++y)
#   {
#     for (int x=0; x<GRID_WIDTH; ++x)
#     {
#       cout << grid[XYToIndex(x,y)];
#     }
#     cout << endl;
#   }
# }
# END C++ CODE

#==============================================================================
# BEGIN IMPLEMENTATION
#==============================================================================

#==============================================================================
# SETUP:
#
# #include <iostream>
# using namespace std;
#==============================================================================
	# nothing to do here; standard for MIPS

#==============================================================================
# CONSTANTS:
#
# #define GRID_WIDTH 79
# #define GRID_HEIGHT 23
# #define NORTH 0
# #define EAST 1
# #define SOUTH 2
# #define WEST 3
#==============================================================================
	.data
GRID_WIDTH:	  .word	80		# need to add 1 to print as string
GRID_HEIGHT:	.word	23
GRID_SIZE:	  .word	1840		# because I can't precalculate it in
					# MIPS like I could in MASM
NORTH:		.word	0
EAST:		  .word 1
SOUTH:		.word	2
WEST:		  .word	3
RGEN:		  .word	1073807359	# a sufficiently large prime for rand
POUND:		.byte	35		# the '#' character
SPACE:		.byte	32		# the ' ' character
NEWLINE:	.byte	10		# the newline character

#==============================================================================
# STRING VARIABLES
#
# Think of them as string constants for prompts and such
#==============================================================================

rsdPrompt:	.asciiz "Enter a seed number (1073741824 - 2147483646): "
smErr1:		.asciiz "That number is too small, try again: "
bgErr:		.asciiz "That number is too large, try again: "
newLine:	.asciiz "\n"

#==============================================================================
# GLOBAL VARIABLES
#
# char grid[GRID_WIDTH*GRID_HEIGHT];
#==============================================================================

grid:	.space	1841		# ((79 + 1) * 23) + 1 bytes reserved for grid
rSeed:	.word	0		# a seed for generating a random number

#==============================================================================
# FUNCTION PROTOTYPES:
#==============================================================================
# Only listed here because it is not necessary to forward-declare in assembly
# void ResetGrid();
# int XYToIndex( int x, int y );
# int IsInBounds( int x, int y );
# void Visit( int x, int y );
# void PrintGrid();
# int srand();                  # adding function to get random seed from user
# int rand(int min, int max);	# adding function to get a random from a range

#==============================================================================
# FUNCTIONS:
#==============================================================================
	.text
	.globl main
#==============================================================================
# int main()
# {
#   // Starting point and top-level control.
#   srand( time(0) ); // seed random number generator.
#   ResetGrid();
#   Visit(1,1);
#   PrintGrid();
#   return 0;
# }
#==============================================================================
main:
	sw	$ra, 0($sp)	# save the return address
	jal	srand		# get a random seed

	li	$t9, 1
	li	$t8, 10
	sw	$t9, -8($sp)		# Set min to 1
	sw 	$t8, -12($sp)		# Set max to 10
	jal rand		        # TEST RAND

	lw	$a0, -4($sp)
	li	$v0, 1					# Print output of rand
	syscall
	la  $a0, NEWLINE
	li	$v0, 4
	syscall

	li $t9, 1
	li $t8, 5
	sw	$t9, -8($sp)		# Set x to 1
	sw 	$t8, -12($sp)		# Set y to 5
	jal XYToIndex		    # TEST XYTOINDEX

	lw	$a0, -4($sp)
	li	$v0, 1					# Print output of xytoindex
	syscall
	la  $a0, NEWLINE
	li	$v0, 4
	syscall

	jal IsInBounds		  # TEST IsInBounds

	lw	$a0, -4($sp)
	li	$v0, 1					# Print output of XYToIndex
	syscall
	la  $a0, NEWLINE
	li	$v0, 4
	syscall

	li $t9, 100
	li $t8, 500
	sw	$t9, -8($sp)		# Set x to 100
	sw 	$t8, -12($sp)		# Set y to 500
	jal IsInBounds		    # TEST XYTOINDEX

	lw	$a0, -4($sp)
	li	$v0, 1					# Print output of xytoindex
	syscall
	la  $a0, NEWLINE
	li	$v0, 4
	syscall



	jal	ResetGrid	# reset the grid to '#'s
	li	$t0, 1		# set up for start of generation at (1,1)
	sw	$t0, -4($sp)	# push first param
	sw	$t0, -8($sp) 	# push second param
	jal	Visit		# start the recursive generation
	jal	PrintGrid	# display the grid
	lw	$ra, 0($sp)	# restore the return address
	jr	$ra		# exit the program

#==============================================================================
# void ResetGrid()
# {
#   // Fills the grid with walls ('#' characters).
#   for (int i=0; i<GRID_WIDTH*GRID_HEIGHT; ++i)
#   {
#     grid[i] = '#';
#   }
# }
#==============================================================================
ResetGrid:
	# It's a waste do do a stack frame when there are no parameters or
	# return values, so I'll optimize and simply push any register I use
	# onto the stack.  I need 7, a loop counter, a place to store the
	# loop bound for comparison, the base address of the grid, a register
	# to store the character value I will write, a register to store the
	# width of the grid, a register to store the newline character, and
	# finally, a register to hold calculation results.

	# save the registers
	sw	$s0, -4($sp)	# $s0 will be the loop counter
	sw	$s1, -8($sp)	# $s1 will hold the array bound
	sw	$s2, -12($sp)	# $s2 will be the grid base address
	sw	$s3, -16($sp)	# $s3 will hold the character
	sw	$s4, -20($sp)	# $s4 will hold the grid width
	sw      $s5, -24($sp)   # $s5 will hold the newline character
	sw	$s6, -28($sp)	# $s6 used for calculations
	# NOTICE THAT I DON'T BOTHER MOVING THE STACK POINTER

	# load the working values
	li	$s0, 1		# initialize the counter
	lw	$s1, GRID_SIZE	# initialize the array bound
	la	$s2, grid	# get the base address
	lb	$s3, POUND	# store the '#' ASCII code
	lw	$s4, GRID_WIDTH # store the grid width
	lb	$s5, NEWLINE	# store the newline ASCII code

ResetLoop:
	sb	$s3, 0($s2)	# put a '#' in the grid
	addi	$s0, $s0, 1	# increment the loop counter
	addi	$s2, $s2, 1	# point at next char position
	div	$s0, $s4	# divide the counter by grid width
	mfhi	$s6		# get remainder in calculation register
	bnez	$s6, NoNewLine	# keep going

	sb	$s5, 0($s2)     # put a newline in the grid
	addi	$s0, $s0, 1	# increment the loop counter
	addi	$s2, $s2, 1	# point at next char position

NoNewLine:
	blt	$s0, $s1, ResetLoop	# if less than end, loop again

	# when we fall out of the loop, restore the registers and return
	lw	$s0, -4($sp)
	lw	$s1, -8($sp)
	lw	$s2, -12($sp)
	lw	$s3, -16($sp)
	lw	$s4, -20($sp)
	lw      $s5, -24($sp)
	lw	$s6, -28($sp)
	# IN A LANGUAGE WITH PUSH/POP, YOU WOULD HAVE TO POP THEM
	# FROM THE STACK IN THE REVERSE ORDER YOU PUSHED THEM.

	jr	$ra		# return

#==============================================================================
# srand()
#
# Unlike the C++ equivalent, this routine has to ask the user for a seed,
# because we don't have access to a time string. So I borrowed code from a
# linear congruence project to prompt for a large integer and save it as a
# seed for another function that does linear congruence.
#==============================================================================
srand:
	# For this function, we only need to preserve 3 registers.  We use
	# $a0 and $v0 for I/0, and we use $s0 as a scratch register.

	# save the registers
	sw	$v0, -4($sp)	# $v0 will be the service code
	sw	$a0, -8($sp)	# $a0 will point to the grid string
	sw	$s0, -12($sp)	# $s0 will hold the input for testing

	# prompt for a random seed and get the value
	la	$a0, rsdPrompt
	li	$v0, 4		# print_string
	syscall

input10:
	li	$v0, 5		# read_int
	syscall
	li	$s0, 1073741823		# put 2147483646 in t0 for comparison
	bgtu	$v0, $s0, input11	# input bigger than 1073741823?
	la	$a0, smErr1	# no, point to error and
	li	$v0, 4		# print_string
	syscall
	j	input10		# try again

input11:
	li	$s0, 2147483646	# upper bound in register t0 for comparison
	bleu	$v0, $s0, input12	# less than or equal 2147483646?
	la	$a0, bgErr	# no, point to error and
	li	$v0, 4		# print_string
	syscall
	j	input10		# try again

input12:
	# number is good, save and move on
	sw	$v0, rSeed

	# restore the registers
	lw	$v0, -4($sp)
	lw	$a0, -8($sp)
	lw	$s0, -12($sp)

	jr	$ra		# return

#==============================================================================
# rand(int min, int max)
#
# It uses the rSeed and RGEN values to create a new psuedo-random and a new
# seed for the next time this routine is called.  It range-fits the psuedo-
# random to the range min-max and returns it.  It does not need to formalize a
# stack frame since it doesn't call any other routines, so we simply set the
# two params and the return into the stack before calling and it begins pushing
# registers onto the stack above -12($sp).  Min is expected to be at -8($sp)
# and max is expected at -12($sp) while the return is at -4($sp).
#==============================================================================
rand:

	# TO DO:  You won't need this until you are ready to tackle the Visit
	#         routine, but you can go ahead and get it written and then
	#         test it before you actually need to use it.

	lw			$t0, -8($sp)		# load min
	lw			$t1, -12($sp)		# load max
	lw			$t2, rSeed			# load seed
	lw			$t3, RGEN				# load random generator

	multu		$t2, $t3				# multiply seed and generator
	mflo		$t4							# low becomes new seed
	mfhi		$t5							# high becomes pseudorandom
	sw			$t4, rSeed			# store the new seed

	sub			$t6, $t1, $t0		# find range (max - min)
	addiu		$t6, $t6, 1			# add one to range

	divu		$t5, $t6				# divide pseudorandom by (range + 1)
	mfhi		$t7							# get remainder
	addu		$t7, $t7, $t0		# add minimum to remainder, range fit complete

	sw			$t7, -4($sp)		# store in the stack


	jr			$ra							# return

#==============================================================================
# int XYToIndex( int x, int y )
# {
#   // Converts the two-dimensional index pair (x,y) into a
#   // single-dimensional index. The result is y * ROW_WIDTH + x.
#   return y * GRID_WIDTH + x;
# }
#
# Like rand, this uses the stack only for getting and returning values.
# -4($sp) is the return, -8($sp) is x, and -12($sp) is y.
#==============================================================================
XYToIndex:


	lw			$t0, -8($sp)			# load x
	lw			$t1, -12($sp)			# load y
	lw			$t2, GRID_WIDTH 	# load grid width

	multu		$t1, $t2					# multiply y and width
	mflo		$t3								# store prduct in t3

	addu		$t3, $t3, $t0 		# add x to product

	sw			$t3, -4($sp)			# put answer in stack

	jr			$ra								# return


#================================================================================
# int IsInBounds( int x, int y )
# {
#   // Returns "true" if x and y are both in-bounds.
#   if (x < 0 || x >= GRID_WIDTH) return false;
#   if (y < 0 || y >= GRID_HEIGHT) return false;
#   return true;
# }
#
# Like rand, this uses the stack only for getting and returning values.  -4($sp)
# is the return, -8($sp) is x, and -12($sp) is y.  Note that because we use a
# width that has an extra character, our first test is actually:
# 	if (x < 0 || x > GRID_WIDTH) return false;
#================================================================================
IsInBounds:

	# TO DO:  You won't need this until you are ready to tackle the Visit
	#         routine, but you can go ahead and get it written and then
	#         test it before you actually need to use it.

	lw			$t0, -8($sp)			# load x
	lw			$t1, -12($sp)			# load y
	lw			$t2, GRID_WIDTH 	# load grid width
	lw			$t3, GRID_HEIGHT	# load grid height

	bgt			$t0, $t2, ReturnFalse		# x > GRID_WIDTH
	blt			$t0, 0, ReturnFalse		  # x < 0

	bge			$t1, $t3, ReturnFalse		# y >= GRID_HEIGHT
	blt			$t1, 0, ReturnFalse			# y < 0

	li			$t0, 1						# if we've made it this far, return 1 for true
	sw			$t0, -4($sp)			# put it in the stack

	jr			$ra								# return

ReturnFalse:

	li			$t0, 0						# we want to return 0 for false
	sw			$t0, -4($sp)			# put it return in stack

	jr			$ra								# return

#==============================================================================
# void Visit( int x, int y )
# {
#   // Starting at the given index, recursively visits every direction in a
#   // randomized order.
#   // Set my current location to be an empty passage.
#   grid[ XYToIndex(x,y) ] = ' ';
#
#   // Create an local array containing the 4 directions and shuffle their
#   // order.
#   int dirs[4];
#   dirs[0] = NORTH;
#   dirs[1] = EAST;
#   dirs[2] = SOUTH;
#   dirs[3] = WEST;
#
#   for (int i=0; i<4; ++i)
#   {
#     int r = rand() & 3;
#     int temp = dirs[r];
#     dirs[r] = dirs[i];
#     dirs[i] = temp;
#   }
#
#   // Loop through every direction and attempt to Visit that direction.
#   for (int i=0; i<4; ++i)
#   {
#     // dx,dy are offsets from current location. Set them based
#     // on the next direction I wish to try.
#     int dx=0, dy=0;
#     switch (dirs[i])
#     {
#       case NORTH: dy = -1; break;
#       case SOUTH: dy = 1; break;
#       case EAST: dx = 1; break;
#       case WEST: dx = -1; break;
#     }
#
#     // Find the (x,y) coordinates of the grid cell 2 spots
#     // away in the given direction.
#     int x2 = x + (dx<<1);
#     int y2 = y + (dy<<1);
#
#     if (IsInBounds(x2,y2))
#     {
#       if (grid[ XYToIndex(x2,y2) ] == '#')
#       {
#         // (x2,y2) has not been visited yet... knock down the
#         // wall between my current position and that position
#         grid[ XYToIndex(x2-dx,y2-dy) ] = ' ';
#
#         // Recursively Visit (x2,y2)
#         Visit(x2,y2);
#       }
#     }
#   }
# }
#
# Visit is the tough one.  Because it is recursive, you have to use a stack-
# frame to properly handle all the levels of recursion.  There is no return
# but x is at -4($sp) and y is at -8($sp).
#==============================================================================
Visit:

	# TO DO:  You won't need this for project 9; it is just a placeholder
	#         for project 10.

	jr	$ra

#==============================================================================
# void PrintGrid()
# {
#   // Displays the finished maze to the screen.
#   for (int y=0; y<GRID_HEIGHT; ++y)
#   {
#     for (int x=0; x<GRID_WIDTH; ++x)
#     {
#       cout << grid[XYToIndex(x,y)];
#     }
#     cout << endl;
#   }
# }
#==============================================================================
PrintGrid:

	# This is even easier than the C++ code because I've set the grid up as
	# one long string so you can simply use a system service to print it to
	# the console. Doing character by character printing in MASM was more
	# complicated. We need to preserve 2 registers, $v0 and $a0 used for
	# this system service.

	move		$t0, $v0		# preserve v0
	move		$t1, $a0		# preserve a0

	la 			$a0, grid 	# load our grid to be printed
	li			$v0, 4			# we want to print a string
	syscall

	move		$v0, $t0		# put v0 back
	move		$a0, $t1		# put a0 back

	jr	$ra							# return
