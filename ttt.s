# File: main.s
# Author: Adam Petty

#=====================================================================

# REGISTER ASSOCIATION:
#	s0 = n
#	s1 = n * n
#	s2 = &board
#   s3 = turn counter
#=====================================================================

######################################################################
#
## text segment
#
######################################################################
        .text
        .globl main

main:   jal WELCOME
        jal PRINT_NEWLINE
        
        li  $v0, 4
        la  $a0, ENTER_N
        syscall 
        
        jal     READ_INT
        move    $s0, $v0 
        mul     $s1, $s0, $s0
        la      $s2, BOARD
        li      $t1, ' '
        li      $t3, 0


INIT_BOARD:
        add     $t2, $s2, $t3
        sb      $t1, 0($t2)
        addiu   $t3, $t3, 1
        bne     $s1, $t3 INIT_BOARD

        li  $v0, 4
        la  $a0, FIRST
        syscall

        jal OPP_START
        jal PRINT_NEWLINE
        jal DRAW_BOARD
       
        jal PLAYER_TURN
        jal EXIT
#----------------------------------------------------------------
# Function: WELCOME
#
# Displays the welcome/game start screen
# Assigns the n value to s0
#----------------------------------------------------------------

WELCOME:    la  $a0, START_MSG
            li  $v0, 4
            syscall

            jr  $ra 

#----------------------------------------------------------------
# Function: PRINT_INT
#
# std::cout << x << std::endl;
#----------------------------------------------------------------
PRINT_INT:	li	$v0, 1
			syscall
			jr	$ra


#---------------------------------------------------------------
# Function: PRINT_NEWLINE
#
# std::cout << "\n";
#---------------------------------------------------------------
PRINT_NEWLINE:	
            la	$a0, NEWLINE 
			li	$v0, 4	
			syscall
			jr	$ra


#----------------------------------------------------------------
# Function: READ_INT
#
# std::cin >> x;
#----------------------------------------------------------------
READ_INT:	li	$v0, 5
			syscall
			jr	$ra


#---------------------------------------------------------------
# Function: EXIT
#
# Ends the program
#---------------------------------------------------------------
EXIT:		li	$v0, 10
            syscall


#---------------------------------------------------------------
# Function: PRINT_BAR
#
# Prints "-"
#---------------------------------------------------------------
PRINT_BAR:  la  $a0, BAR
            li  $v0, 4
            syscall
            
            jr  $ra


#---------------------------------------------------------------
# Function: PRINT_CROSS
#
# Prints "+"
#---------------------------------------------------------------
PRINT_CROSS:
            la  $a0, CROSS
            li  $v0, 4
            syscall

            jr  $ra


#---------------------------------------------------------------
# Function: PRINT_PIPE
#
# cout << "|";
#---------------------------------------------------------------
PRINT_PIPE: la  $a0, PIPE
            li  $v0, 4
            syscall

            jr  $ra


            
#---------------------------------------------------------------
# Function: OPP_START
#
# Starts the game, opponent places an 'O' in the center
#---------------------------------------------------------------
OPP_START:  li      $t0, 2
            divu    $s0, $t0
            mflo    $t0
            mul     $t1, $s0, $t0
            add     $t1, $t1, $t0
            
            add     $t0, $s2, $t1
            li      $t1, 'O'
            sb      $t1, 0($t0)
            
            jr      $ra


#---------------------------------------------------------------
# Function: PLAYER_TURN
#
# Draws the grid for the game board
#---------------------------------------------------------------
PLAYER_TURN:
            la  $a0, ENTER_R
            li  $v0, 4
            syscall
            jal     READ_INT
            move    $t0, $v0
            
            la  $a0, ENTER_C
            li  $v0, 4
            syscall
            jal     READ_INT
            move    $t1, $v0
            
            mul $t0, $t0, $s0
            add $t0, $t0, $t1
            add $t1, $s2, $t0
            li  $t0, 'X'
            sb  $t0, 0($t1)

            jal DRAW_BOARD
            


            # WIN CHECK GOES HERE

ROW_WIN_CHECK:
            li      $t0, 0
            li      $t3, 'X'
            
ROW_WIN_CHECK_OUTER:
            beq     $t0, $s0, COL_WIN_CHECK
            li      $t1, 0
            mul     $t2, $t0, $s0
            add     $t2, $t2, $s2

ROW_WIN_CHECK_INNER:      
            beq     $t1, $s0, VICTORY
            
            lb      $t4, 0($t2)
            bne     $t3, $t4, ROW_WIN_OUTER_EXIT
            
            addiu   $t1, $t1, 1
            addiu   $t2, $t2, 1            
            j       ROW_WIN_CHECK_INNER

ROW_WIN_OUTER_EXIT:
            addiu   $t0, $t0, 1
            j       ROW_WIN_CHECK_OUTER




COL_WIN_CHECK:
            li      $t0, 0
            li      $t3, 'X'
             
COL_WIN_CHECK_OUTER:
            beq     $t0, $s0, DIAG_WIN_CHECK
            li      $t1, 0
            move    $t2, $s2
            add     $t2, $t2, $t0

COL_WIN_CHECK_INNER:      
            beq     $t1, $s0, VICTORY
            
            lb      $t4, 0($t2)
            bne     $t3, $t4, COL_WIN_OUTER_EXIT
            
            addiu   $t1, $t1, 1
            add     $t2, $t2, $s0
            j       COL_WIN_CHECK_INNER

COL_WIN_OUTER_EXIT:
            addiu   $t0, $t0, 1
            j       COL_WIN_CHECK_OUTER




DIAG_WIN_CHECK:
            li      $t0, 0
            move    $t2, $s2
            li      $t3, 'X'

DIAG_WIN_LOOP:
            beq     $t0, $s0, VICTORY            
            
            lb      $t4, 0($t2)
            bne     $t3, $t4, DIAG2_WIN_CHECK
            
            addiu   $t0, $t0, 1
            add     $t2, $t2, $s0
            addiu   $t2, $t2, 1
            j       DIAG_WIN_LOOP

DIAG2_WIN_CHECK:
            li      $t0, 0
            move    $t2, $s2
            add     $t2, $t2, $s0
            addiu   $t2, $t2, -1
            li      $t3, 'X'

DIAG2_WIN_LOOP:
            beq     $t0, $s0, VICTORY

            lb      $t4, 0($t2)
            bne     $t3, $t4, AI_ROW_CHECK      # start of opponents turn
            
            addiu   $t0, $t0, 1
            add     $t2, $t2, $s0
            addiu   $t2, $t2, -1
            j       DIAG2_WIN_LOOP

#---------------------------------------------------------------
# OPPONENT TURN (OPP_TURN)
#
# for (int i = 0, i < n, ++i)
# {
# 
#
#
#
#
#
# Draws the grid for the game board
#---------------------------------------------------------------


#####################

# ROW-WIN CHECK

#####################


AI_ROW_CHECK:
            li      $t0, 0
            
AI_ROW_CHECK_OUTER:
            beq     $t0, $s0, AI_COL_CHECK
            li      $t1, 0
            mul     $t2, $t0, $s0
            add     $t2, $t2, $s2
            li      $t5, 0

AI_ROW_CHECK_INNER:      
            beq     $t1, $s0, ROW_INNER_EXIT
            
            li      $t3, 'X'
            lb      $t4, 0($t2)
            beq     $t3, $t4, ROW_OUTER_EXIT
            
            li      $t3, ' ' 
            bne     $t3, $t4, ROW_NO_SPACE
            move    $t9, $t2
            addiu   $t5, $t5, 1

ROW_NO_SPACE: 
            addiu   $t1, $t1, 1
            addiu   $t2, $t2, 1            
            j       AI_ROW_CHECK_INNER

ROW_INNER_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_WIN

ROW_OUTER_EXIT:
            addiu   $t0, $t0, 1
            j       AI_ROW_CHECK_OUTER


#####################

# COLUMN-WIN CHECK

#####################


AI_COL_CHECK:
           li       $t0, 0

AI_COL_CHECK_OUTER:
            beq     $t0, $s0, AI_DIAG_CHECK
            li      $t1, 0 
            li      $t5, 0
AI_COL_CHECK_INNER:
            beq     $t1, $s0, COL_INNER_EXIT
            add     $t2, $t0, $s2
            mul     $t3, $t1, $s0
            add     $t2, $t2, $t3
            
            li      $t3, 'X'
            lb      $t4, 0($t2)
            beq     $t3, $t4, COL_OUTER_EXIT

            li      $t3, ' '
            bne     $t3, $t4, COL_NO_SPACE
            move    $t9, $t2
            addiu   $t5, $t5, 1
COL_NO_SPACE:
            addiu   $t1, $t1, 1
            j       AI_COL_CHECK_INNER

COL_INNER_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_WIN

COL_OUTER_EXIT:
            addiu   $t0, $t0, 1
            j       AI_COL_CHECK_OUTER

            
#####################

# DIAG-WIN CHECK

#####################
            
            
AI_DIAG_CHECK:
            li      $t0, 0
            move    $t2, $s2
            li      $t5, 0

AI_DIAG_LOOP:
            beq     $t0, $s0, AI_DIAG_LOOP_EXIT
            li      $t3, 'X'
            lb      $t4, 0($t2)
            beq     $t3, $t4, AI_DIAG_CHECK2

            li      $t3, ' '
            bne     $t3, $t4, DIAG_NO_SPACE
            addiu   $t5, $t5, 1
            move    $t9, $t2

DIAG_NO_SPACE:
            addiu   $t0, $t0, 1
            add     $t2, $t2, $s0
            addiu   $t2, $t2, 1
            j       AI_DIAG_LOOP

AI_DIAG_LOOP_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_WIN

AI_DIAG_CHECK2:
            li      $t0, 0
            move    $t2, $s2
            addiu   $t1, $s0, -1
            add     $t2, $t2, $t1
            li      $t5, 0

AI_DIAG_LOOP2:
            beq     $t0, $s0, AI_DIAG_LOOP2_EXIT
            li      $t3, 'X'
            lb      $t4, 0($t2)
            beq     $t3, $t4, AI_ROW_BLOCK 

            li      $t3, ' '
            bne     $t3, $t4, DIAG2_NO_SPACE
            addiu   $t5, $t5, 1
            move    $t9, $t2

DIAG2_NO_SPACE:
            addiu   $t0, $t0, 1
            add     $t2, $t2, $s0
            addiu   $t2, $t2, -1
            j       AI_DIAG_LOOP2

AI_DIAG_LOOP2_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_WIN


#####################

# ROW-BLOCK CHECK

#####################


AI_ROW_BLOCK:
            li      $t0, 0
            
AI_ROW_BLOCK_OUTER:
            beq     $t0, $s0, AI_COL_BLOCK
            li      $t1, 0
            mul     $t2, $t0, $s0
            add     $t2, $t2, $s2
            li      $t5, 0

AI_ROW_BLOCK_INNER:      
            beq     $t1, $s0, ROW_BLOCK_INNER_EXIT
            
            li      $t3, 'O'
            lb      $t4, 0($t2)
            beq     $t3, $t4, ROW_BLOCK_OUTER_EXIT
            
            li      $t3, ' ' 
            bne     $t3, $t4, ROW_BLOCK_NO_SPACE
            move    $t9, $t2
            addiu   $t5, $t5, 1

ROW_BLOCK_NO_SPACE: 
            addiu   $t1, $t1, 1
            addiu   $t2, $t2, 1            
            j       AI_ROW_BLOCK_INNER

ROW_BLOCK_INNER_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_BLOCK

ROW_BLOCK_OUTER_EXIT:
            addiu   $t0, $t0, 1
            j       AI_ROW_BLOCK_OUTER


#####################

# COLUMN-BLOCK CHECK

#####################


AI_COL_BLOCK:
           li       $t0, 0

AI_COL_BLOCK_OUTER:
            beq     $t0, $s0, OPP_CHOOSE
            li      $t1, 0 
            li      $t5, 0
AI_COL_BLOCK_INNER:
            beq     $t1, $s0, COL_BLOCK_INNER_EXIT
            add     $t2, $t0, $s2
            mul     $t3, $t1, $s0
            add     $t2, $t2, $t3
            
            li      $t3, 'O'
            lb      $t4, 0($t2)
            beq     $t3, $t4, COL_BLOCK_OUTER_EXIT

            li      $t3, ' '
            bne     $t3, $t4, COL_BLOCK_NO_SPACE
            move    $t9, $t2
            addiu   $t5, $t5, 1
COL_BLOCK_NO_SPACE:
            addiu   $t1, $t1, 1
            j       AI_COL_BLOCK_INNER

COL_BLOCK_INNER_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_BLOCK

COL_BLOCK_OUTER_EXIT:
            addiu   $t0, $t0, 1
            j       AI_COL_BLOCK_OUTER
            
            
#####################

# DIAGONAL-BLOCK CHECK

#####################


AI_DIAG_BLOCK:
            li      $t0, 0
            move    $t2, $s2
            li      $t5, 0

AI_DIAG_BLOCK_LOOP:
            beq     $t0, $s0, AI_DIAG_BLOCK_LOOP_EXIT
            li      $t3, 'O'
            lb      $t4, 0($t2)
            beq     $t3, $t4, AI_DIAG_BLOCK2

            li      $t3, ' '
            bne     $t3, $t4, DIAG_BLOCK_NO_SPACE
            addiu   $t5, $t5, 1
            move    $t9, $t2

DIAG_BLOCK_NO_SPACE:
            addiu   $t0, $t0, 1
            add     $t2, $t2, $s0
            addiu   $t2, $t2, 1
            j       AI_DIAG_BLOCK_LOOP

AI_DIAG_BLOCK_LOOP_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_BLOCK

AI_DIAG_BLOCK2:
            li      $t0, 0
            move    $t2, $s2
            addiu   $t1, $s0, -1
            add     $t2, $t2, $t1
            li      $t5, 0

AI_DIAG_BLOCK_LOOP2:
            beq     $t0, $s0, AI_DIAG_BLOCK_LOOP2_EXIT
            li      $t3, 'O'
            lb      $t4, 0($t2)
            beq     $t3, $t4, OPP_CHOOSE

            li      $t3, ' '
            bne     $t3, $t4, DIAG_BLOCK2_NO_SPACE
            addiu   $t5, $t5, 1
            move    $t9, $t2

DIAG_BLOCK2_NO_SPACE:
            addiu   $t0, $t0, 1
            add     $t2, $t2, $s0
            addiu   $t2, $t2, -1
            j       AI_DIAG_BLOCK_LOOP2

AI_DIAG_BLOCK_LOOP2_EXIT:
            li      $t3, 1
            beq     $t3, $t5, OPP_BLOCK


#####################

# OPPONENT FREE CHOICE

#####################


OPP_CHOOSE:
            addiu   $t0, $s2, 0
            li      $t1, ' '
            lb      $t2 0($t0)

OPP_LOOP1:  beq     $t1, $t2, OPP_LOOP1_EXIT
            addiu   $t0, $t0, 1
            lb      $t2, 0($t0)
            j       OPP_LOOP1

OPP_LOOP1_EXIT:
            li  $t1, 'O'
            sb  $t1, 0($t0)
           
            jal DRAW_BOARD 
            j   PLAYER_TURN 


OPP_BLOCK:  li  $t0, 'O'
            sb  $t0, 0($t9)
            jal DRAW_BOARD
            j   PLAYER_TURN


OPP_WIN:    li  $t0, 'O'
            sb  $t0, 0($t9)
            jal DRAW_BOARD
            la  $a0, LOSS_MSG
            li  $v0, 4
            syscall

            jal PRINT_NEWLINE
            jal EXIT

VICTORY:    la  $a0, WIN_MSG
            li  $v0, 4
            syscall 

            jal PRINT_NEWLINE
            jal EXIT

#---------------------------------------------------------------
# Function: DRAW_BOARD (DB)
#
# Draws the grid for the game board
#
# t0 = outer loop counter, exits at end of DB2
# t1 = inner loop counter
# t2 = BOARD iterator i.e board[t2]
#
#---------------------------------------------------------------
DRAW_BOARD: addiu   $sp, $sp, -4
            sw      $ra, 4($sp)
            li      $t0, 0
            li      $t1, 0
            li      $t2, 0

DB_LOOP1:   beq     $t1, $s0, DB1_EXIT

            jal     PRINT_CROSS
            jal     PRINT_BAR
            addiu   $t1, $t1, 1
            j       DB_LOOP1

DB1_EXIT:   jal     PRINT_CROSS
            jal     PRINT_NEWLINE
            li      $t1, 0

DB_LOOP2:   beq     $t1, $s0, DB2_EXIT
            jal     PRINT_PIPE
            
            la      $a0, BOARD
            add     $a0, $a0, $t2
            lb      $a0, 0($a0)
            li      $v0, 11
            syscall

            addiu   $t2, $t2, 1
            addiu   $t1, $t1, 1
            j       DB_LOOP2

DB2_EXIT:   jal     PRINT_PIPE
            jal     PRINT_NEWLINE
            addiu   $t0, $t0, 1
            li      $t1, 0 
            bne     $t0, $s0, DB_LOOP1
            
DRAW_BOARD_EXIT:
            jal     PRINT_CROSS
            jal     PRINT_BAR
            addiu   $t1, $t1, 1
            bne     $t1, $s0, DRAW_BOARD_EXIT
            jal     PRINT_CROSS
            jal     PRINT_NEWLINE

            lw      $ra, 4($sp)
            addiu   $sp, $sp, 4
            jr      $ra            


######################################################################
#
# data segment
#
######################################################################
        
        .data
# Game messages
NEWLINE:	.asciiz "\n"
START_MSG:  .asciiz "Let's play a game of tic-tac-toe."
ENTER_N:	.asciiz "Enter n: "
FIRST:		.asciiz "I'll go first"
CROSS:		.asciiz "+"
PIPE:		.asciiz "|"
BAR:		.asciiz "-"
ENTER_R:	.asciiz "Enter row: "
ENTER_C:	.asciiz "Enter column: "

# Game over messages
DRAW:		.asciiz "We have a draw!"
LOSS_MSG:	.asciiz "I'm the winner!"
WIN_MSG:    .asciiz "You are the winner!"

# Game board
BOARD:		.byte 0


#EOF
