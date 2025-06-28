
    ##############################################
    ###                                        ###
    ### BITMAP DISPLAY SETTINGS                ###
    ### UNIT WIDTH = 8                         ###
    ### UNIT HEIGHT = 8                        ###
    ### DISPLAY WIDTH = 512                    ###
    ### DISPLAY HEIGHT = 256                   ###
    ### BASE ADDRESS = 0x10010000(STATIC DATA) ###
    ###                                        ###
    ##############################################

.data
    # Screen height =   32px
    # Screen width =    64px
    # Size of screen: height*width*4 = 8192
    window: .space 8192
    # Game field height =   14px
    # Game field width =    30px
    # Game field size: height*width*4 = 1680
    # Bit 1:        Apple (0=False, 1=True)
    # Bit 2:        Active/Occupied by snake body (0=False, 1=True)
    # Bit 3 & 4:    Direction (Used to move the tail)
    # Total = 210 WORDS
    field: .space 1680

    # Byte 1 & 2:   Player X position
    # Byte 3:       Player Y position
    # Byte 4 & 5:   Tail X position
    # Byte 6:       Tail Y position
    # Byte 7:       Player moving direction
    # Byte 8:       Is player alive
    player: .word 0x03702731

    # Colors
    t0: .word 0xFFFFFF  # White
    t1: .word 0x000000  # Black
    bg0: .word 0x325D37 # Background color 1
    bg1: .word 0x477238 # Background color 2
    br0: .word 0xC45F75 # Border color 1
    br1: .word 0xE27285 # Border color 2
    sn0: .word 0x2789CD # Snake color 1
    sn1: .word 0x42BFE8 # Snake color 2
    apl: .word 0xF1641F # Apple color

    mainsplash0: .word 0x00000000 0x007E607E 0x667E7E60 0x7E667E60 0x7E667860 0x607E6678 0x607E667E 0x66787E66 0x7E667806 0x66666660 0x06666666 0x607E6666 0x667E7E66 0x66667E00 0x00000000 0x00000000 0x00000000 0x00000CB6 0xCDA6D00D 0x348994D0 0x09224534 0x800916CD 0x36500000 0x00000002 0x66914A80 0x0364CA6A 0x8002629A 0x40000366 0xDA6A8000 0x00000000
    mainsplash1: .word 0xFFF0FFFF 0xFF819081 0x9981819F 0x8199819F 0x8199879F 0x9F819987 0x9C819981 0x99848199 0x819984F9 0x9999999C 0xF9999999 0x9F819999 0x99818199 0x999981FF 0xFFFFFFFF 0x00000000 0x001FFFFF 0xFFF81349 0x32592812 0xCB766B28 0x16DDBACB 0x7816E932 0xC9A81FFF 0xFFFFF805 0x996EB540 0x049B3595 0x40059D65 0xBFC00499 0x25954007 0xFFFFFFC0
    oversplash0: .word 0x00000000
    oversplash1: .word 0xFFFFFFFF

.text
    # These registers are reserved to use as references to the window and game field
    la $t9, window
    la $t8, field
MAIN:
    # jal INITIAL_DRAW

    li $s0, 0
    START_LOOP:
    bgt $s0, $zero, START_GAME
    jal GET_INPUT
    jal STALL       # This stall avoids lag
    j START_LOOP

    START_GAME:
    # jal DRAW_BACKGROUND

    GAME_LOOP:
        li $s1, 0
        jal GET_INPUT

        jal MOVE_PLAYER
        jal CHECK_BOUNDARIES
        # jal CHECK_COLLISION

        # jal CHECK_APPLE (Apple eaten $s1)
        bne $s1, $zero, NO_APPLE
        # jal GENERATE_APPLE (Only if $s1 != 0, should also draw the apple)

        NO_APPLE:
        jal DRAW_BOARD_UPDATE

        # jal MOVE_TAIL

        jal STALL
        j GAME_LOOP_CONDITIONAL

    GAME_OVER:
        # jal DRAW_GAME_OVER
        li $t0, 0
        li $t1, 30
        STALL_GAME_OVER:
        beq $t0, $t1, RESTART
        jal STALL
        addi $t0, $t0, 1
        j STALL_GAME_OVER

    RESTART:
        li $s0, 0
        li $t0, 0x03702731
        sw $t0, player
        # jal DRAW_BACKGROUND
        # jal DRAW_TITLE_SCREEN
        j START_LOOP

GAME_LOOP_CONDITIONAL:
    lw $t1, player
    andi $t0, $t1, 0x00000001
    beq $t0, $zero, GAME_OVER
    j GAME_LOOP

MOVE_PLAYER:
    lw $t3, player              # Load player
    andi $t0, $t3, 0x000000F0   # Save direction
    srl $t0, $t0, 4             # Apply correct format
    andi $t1, $t3, 0xFF000000   # Save X position
    srl $t1, $t1, 24            # Apply correct format
    andi $t2, $t3, 0x00F00000   # Save Y position
    srl $t2, $t2, 20            # Apply correct format
    andi $t3, $t3, 0x000FFFFF   # Save player without X and Y values

    # Update player field
    li $t4, 30
    mult $t4, $t1
    mflo $t4
    sll $t4, $t4, 2
    sll $t5, $t2, 2
    add $t5, $t5, $t8
    lw $t6, 0($t5)
    andi $t6, 0x0FFFFFFF
    addi $t4, $t0, 4
    sll $t4, $t4, 28
    add $t4, $t4, $t6
    sw $t4, 0($t5)

    li $t4, 1
    li $t5, 2

    beq $t0, $zero, MOVE_UP
    beq $t0, $t4, MOVE_LEFT
    beq $t0, $t5, MOVE_DOWN
    bgt $t0, $t5, MOVE_RIGHT
    j MOVE_SAVE_PLAYER

    MOVE_UP:
    subi $t2, $t2, 1
    j MOVE_SAVE_PLAYER

    MOVE_LEFT:
    subi $t1, $t1, 1
    j MOVE_SAVE_PLAYER

    MOVE_DOWN:
    addi $t2, $t2, 1
    j MOVE_SAVE_PLAYER

    MOVE_RIGHT:
    addi $t1, $t1, 1
    j MOVE_SAVE_PLAYER

    MOVE_SAVE_PLAYER:
    sll $t1, $t1, 24    # Apply correct format
    sll $t2, $t2, 20    # Apply correct format
    add $t3, $t3, $t1   # Add to buffer
    add $t3, $t3, $t2   # Add to buffer
    sw $t3, player      # Save buffer to memory

    jr $ra

CHECK_BOUNDARIES:
    lw $t0, player
    andi $t1, $t0, 0xFF000000   # Save X position
    srl $t1, $t1, 24            # Apply correct format
    andi $t2, $t0, 0x00F00000   # Save Y position
    srl $t2, $t2, 20            # Apply correct format

    li $t3, 30
    li $t4, 14

    bge $t1, $t3, KILL_PLAYER
    blt $t1, $zero, KILL_PLAYER

    bge $t2, $t4, KILL_PLAYER
    blt $t2, $zero, KILL_PLAYER

    jr $ra

KILL_PLAYER:
    lw $t0, player
    andi $t0, $t0, 0xFFFFFFF0
    sw $t0, player
    jr $ra

STALL:
    # Sleep for 50ms
    li $v0, 32
    li $a0, 50
    jr $ra

GET_INPUT:
    lw $t0, 0xFFFF0004
    li $t1, 32  # Space
    li $t2, 44  # Comma
    li $t3, 97  # A
    li $t4, 111 # 0
    li $t5, 101 # E
    li $t6, 27  # Escape

    lw $t7, player # Load player
    andi $t7, $t7, 0xFFFFFF0F

    beq $t0, $t1, START_PRESSED
    beq $t0, $t2, UP_PRESSED
    beq $t0, $t3, LEFT_PRESSED
    beq $t0, $t4, DOWN_PRESSED
    beq $t0, $t5, RIGHT_PRESSED
    beq $t0, $t6, ESCAPE_PRESSED

    j FINISH

    START_PRESSED:
    li $s0, 1
    j FINISH

    UP_PRESSED:
    sw $t7, player
    j FINISH

    LEFT_PRESSED:
    addi $t7, $t7, 0x00000010
    sw $t7, player
    j FINISH

    DOWN_PRESSED:
    addi $t7, $t7, 0x00000020
    sw $t7, player
    j FINISH

    RIGHT_PRESSED:
    addi $t7, $t7, 0x00000030
    sw $t7, player
    j FINISH

    ESCAPE_PRESSED:
    li $v0, 10
    syscall
    j FINISH

    FINISH:
    sw $zero, 0xFFFF0004
    jr $ra

INITIAL_DRAW:
    move $s0, $ra
    jal DRAW_BORDER
    jal DRAW_BACKGROUND
    jal DRAW_TITLE_SCREEN
    jr $s0

DRAW_TITLE_SCREEN:
    move $s1, $ra
    la $a0, mainsplash0
    la $a1, t0
    jal SHOW_SPLASH

    la $a0, mainsplash1
    la $a1, t1
    jal SHOW_SPLASH
    jr $s1

SHOW_SPLASH:        # Shows splash stored in $a0 with color stored in $a1
    li $t0, 0
    li $t1, 30      # Splashes are 30 words long

    lw $a1, 0($a1)  # Loads color

    SPLASH_WORD_ITERATOR:
    beq $t0, $t1, EXIT

    sll $t3, $t0, 2
    add $a0, $a0, $t3
    lw $t2, 0($a0)
    sub $a0, $a0, $t3
    
    # Iterators for bitwise operations
    li $t3, 0
    li $t4, 32

    SPLASH_BIT_ITERATOR:
        beq $t3, $t4, SPLASH_NEXT_WORD
        andi $t5, $t2, 0x80000000
        sll $t2, $t2, 1
        srl $t5, $t5, 31

        beq $t5, $zero, SPLASH_NEXT_BIT

        # Go to correct direction
        sll $t5, $t0, 5
        add $t5, $t5, $t3

        li $t6, 40

        li $t7, 0

        SPLASH_ROW_ITERATOR:
            blt $t5, $t6, SPLASH_PRINT_PIXEL
            subi $t5, $t5, 40
            addi $t7, $t7, 256
            j SPLASH_ROW_ITERATOR

        SPLASH_PRINT_PIXEL:
        sll $t5, $t5, 2
        add $t6, $t5, $t7
        add $t5, $t6, $t9
        sw $a1, 1072($t5)   # Offset is 4 rows (4*4*64) + 12 Spaces (4*12

        SPLASH_NEXT_BIT:
        addi $t3, $t3, 1
        j SPLASH_BIT_ITERATOR

    SPLASH_NEXT_WORD:
    addi $t0, $t0, 1
    j SPLASH_WORD_ITERATOR

    EXIT:
    jr $ra
    

DRAW_BACKGROUND:
	lw $t0, bg0     # Load background color 1

	lw $t1, bg1     # Load background color 2

	move $t2, $t0   # $t2 is going to be used as a buffer to the color to be used

	li $t3, 130     # Iterator starting at first background tile
	li $t4, 2047    # Last element of the window
	sll $t5, $t4, 2

	li $t4, 190     # Last element of the first row of the background (Condition for iterator)

	li $t6, 0       # Iterator used for the change of color

	ITERATOR_DRAW_BACKGROUND:
		beq $t3, $t4, ITERATOR_BACKGROUND_NEXT_ROW

        sll $t7, $t3, 2

        # From the top
        add $t9, $t9, $t7
        sw $t2, 0($t9)
		addi $t9, $t9, 256
        sw $t2, 0($t9)
		subi $t9, $t9, 256
        sub $t9, $t9, $t7

        # From below
        add $t9, $t9, $t5
        sub $t9, $t9, $t7
        sw $t2, 0($t9)
		subi $t9, $t9, 256
        sw $t2, 0($t9)
		addi $t9, $t9, 256
        add $t9, $t9, $t7
        sub $t9, $t9, $t5

        # Add to counters
        addi $t3, $t3, 1
        addi $t6, $t6, 1

		BACKGROUND_ALTERNATE_COLOR:
			li $t7, 2

			beq $t6, $t7, CHANGE_BACKGROUND_COLOR
			j ITERATOR_DRAW_BACKGROUND

			CHANGE_BACKGROUND_COLOR:
			beq $t2, $t0, CHANGE_BACKGROUND_COLOR_2
			move $t2, $t0   # Changes color to color 1
			li $t6, 0
			j ITERATOR_DRAW_BACKGROUND

			CHANGE_BACKGROUND_COLOR_2:
			move $t2, $t1   # Changes color to color 2
			li $t6, 0
			j ITERATOR_DRAW_BACKGROUND

	ITERATOR_BACKGROUND_NEXT_ROW:
	li $t6, 958             # End of the 15th row (64*15-2)

	beq $t3, $t6, FINISHED_BACKGROUND
	addi $t3, $t3, 128      # Go to next row
	subi $t3, $t3, 60       # Go back to first pixel of the row
	addi $t4, $t4, 128      # Go to next row

	li $t6, 2               # Alternate color
	j BACKGROUND_ALTERNATE_COLOR

	FINISHED_BACKGROUND:
	jr $ra
	

DRAW_BORDER:
    lw $t0, br0         # Load border color 1

    lw $t1, br1         # Load border color 2

    move $t2, $t0       # $t2 is a buffer for the color that is going to be used

    li $t3, 0           # Iterator
    li $t4, 2048
    sll $t5, $t4, 2
    subi $t5, $t5, 4    # $t5 is used to find the end of the window

    li $t4, 64          # Condition for the iterator

    li $t6, 0           # Iterator used to change between color 1 and 2

    ITERATOR_DRAW_BORDER_HORIZONTAL:
        beq $t3, $t4, FINISHED_BORDER_HORIZONTAL

        sll $t7, $t3, 2

        # Top part
        add $t9, $t9, $t7
        sw $t2, 0($t9)
		addi $t9, $t9, 256
        sw $t2, 0($t9)
		subi $t9, $t9, 256
        sub $t9, $t9, $t7

        # Bottom part
        add $t9, $t9, $t5
        sub $t9, $t9, $t7
        sw $t2, 0($t9)
		subi $t9, $t9, 256
        sw $t2, 0($t9)
		addi $t9, $t9, 256
        add $t9, $t9, $t7
        sub $t9, $t9, $t5

        # Add to counters
        addi $t3, $t3, 1
        addi $t6, $t6, 1
        li $t7, 2

        beq $t6, $t7, CHANGE_BORDER_COLOR_HORIZONTAL
        j ITERATOR_DRAW_BORDER_HORIZONTAL

        CHANGE_BORDER_COLOR_HORIZONTAL:
        beq $t2, $t0, CHANGE_BORDER_COLOR_HORIZONTAL_2
        move $t2, $t0   # Changes color to color 1
        li $t6, 0
        j ITERATOR_DRAW_BORDER_HORIZONTAL

        CHANGE_BORDER_COLOR_HORIZONTAL_2:
        move $t2, $t1   # Changes color to color 2
        li $t6, 0
        j ITERATOR_DRAW_BORDER_HORIZONTAL

    FINISHED_BORDER_HORIZONTAL:
    j DRAW_BORDER_VERTICAL

DRAW_BORDER_VERTICAL:
    lw $t0, br0         # Load border color 1
    lw $t1, br1         # Load border color 2

    move $t2, $t1       # $t2 is a buffer for the color that is going to be used

    li $t3, 0           # Iterator
    li $t4, 2048
    sll $t5, $t4, 2
    subi $t5, $t5, 4    # $t5 is used to find the end of the window

    li $t4, 28          # Number of columns * 2 used as condition for the iterator

    li $t6, 0           # Iterator used to change between color 1 and 2

    ITERATOR_DRAW_BORDER_VERTICAL:
        beq $t3, $t4, FINISHED_BORDER_VERTICAL

        sll $t7, $t3, 8

        # Left side
        add $t9, $t9, $t7
        sw $t2, 512($t9)
		addi $t9, $t9, 4
        sw $t2, 512($t9)
		subi $t9, $t9, 4
        sub $t9, $t9, $t7

        # Right side
        add $t9, $t9, $t5
        sub $t9, $t9, $t7
        sw $t2, -512($t9)
		subi $t9, $t9, 4
        sw $t2, -512($t9)
		addi $t9, $t9, 4
        add $t9, $t9, $t7
        sub $t9, $t9, $t5

        # Add to counters
        addi $t3, $t3, 1
        addi $t6, $t6, 1
        li $t7, 2

        beq $t6, $t7, CHANGE_BORDER_COLOR_VERTICAL
        j ITERATOR_DRAW_BORDER_VERTICAL

        CHANGE_BORDER_COLOR_VERTICAL:
        beq $t2, $t0, CHANGE_BORDER_COLOR_VERTICAL_2
        move $t2, $t0   # Changes color to color 1
        li $t6, 0
        j ITERATOR_DRAW_BORDER_VERTICAL

        CHANGE_BORDER_COLOR_VERTICAL_2:
        move $t2, $t1   # Changes color to color 2
        li $t6, 0
        j ITERATOR_DRAW_BORDER_VERTICAL

    FINISHED_BORDER_VERTICAL:
    jr $ra

DRAW_BOARD_UPDATE:
    lw $t4, player              # Load player
    andi $t0, $t4, 0x000000F0   # Save player direction
    srl $t0, $t0, 4             # Apply correct format
    andi $t1, $t4, 0xFF000000   # Save player X position
    srl $t1, $t1, 24            # Apply correct format
    andi $t2, $t4, 0x00F00000   # Save player Y position
    srl $t2, $t2, 20            # Apply correct format
    andi $t3, $t4, 0x000FF000   # Save tail X position
    srl $t3, $t3, 12            # Apply correct format
    andi $t4, $t4, 0x00000F00   # Save tail Y position
    srl $t4, $t4, 8             # Apply correct format

    # Get tail direction
    li $t5, 30
    mult $t5, $t4
    mflo $t5
    sll $t6, $t3, 2
    sll $t5, $t5, 2
    add $t5, $t5, $t6
    add $t5, $t5, $t8
    lw $t5, 0($t5)
    andi $t5, 0x30000000
    srl $t5, $t5, 28            # Apply correct format

    CHOOSE_PLAYER_COLOR:
        add $a0, $t1, $t2
        andi $a0, $a0, 0x1
        beq $a0, $zero, PLAYER_COLOR_1
        PLAYER_COLOR_0:
        lw $a0, sn0
        j CHOOSE_BACKGROUND_COLOR
        PLAYER_COLOR_1:
        lw $a0, sn1

    CHOOSE_BACKGROUND_COLOR:
        add $a1, $t3, $t4
        andi $a1, $a1, 0x1
        beq $a1, $zero, BACKGROUND_COLOR_1
        BACKGROUND_COLOR_0:
        lw $a1, bg0
        j GET_ADDRESSES
        BACKGROUND_COLOR_1:
        lw $a1, bg1

    GET_ADDRESSES:
    # Shift left Y values by 9
    sll $t2, $t2, 9
    sll $t4, $t4, 9
    # Shift left X values by 2
    sll $t1, $t1, 3
    sll $t3, $t3, 3
    
    # Get address for player
    add $t1, $t1, $t2
    add $t1, $t1, $t9

    # Get address for tail
    add $t3, $t3, $t4
    add $t3, $t3, $t9

    # $t0 Direction player
    # $t1 Offset player
    # $t2 Direction tail
    # $t3 Offset tail
    move $t2, $t5

    FIRST_PIXEL_PLAYER:
        li $t4, 2
        bge $t0, $t4, FIRST_PIXEL_PLAYER_ELSE
        sw $a0, 260($t1)
        j FIRST_PIXEL_TAIL
        FIRST_PIXEL_PLAYER_ELSE:
        sw $a0, 0($t1)

    FIRST_PIXEL_TAIL:
        bne $s1, $zero, SECOND_PIXEL_PLAYER
        li $t4, 2
        bge $t2, $t4, FIRST_PIXEL_TAIL_ELSE
        sw $a1, 260($t3)
        j SECOND_PIXEL_PLAYER
        FIRST_PIXEL_TAIL_ELSE:
        sw $a1, 0($t3)

    SECOND_PIXEL_PLAYER:
        li $t4, 3
        blt $t0, $zero, SECOND_PIXEL_PLAYER_ELSE
        beq $t0, $t4, SECOND_PIXEL_PLAYER_ELSE
        sw $a0, 4($t1)
        j THIRD_PIXEL_PLAYER
        SECOND_PIXEL_PLAYER_ELSE:
        sw $a0, 256($t1)

    SECOND_PIXEL_TAIL:
        bne $s1, $zero, MID_PRINT_STALL
        li $t4, 3
        blt $t2, $zero, SECOND_PIXEL_TAIL_ELSE
        beq $t2, $t4, SECOND_PIXEL_TAIL_ELSE
        sw $a1, 4($t3)
        j THIRD_PIXEL_PLAYER
        SECOND_PIXEL_TAIL_ELSE:
        sw $a1, 256($t3)

    MID_PRINT_STALL:
        jal STALL

    THIRD_PIXEL_PLAYER:
        li $t4, 2
        bge $t0, $t4, THIRD_PIXEL_PLAYER_ELSE
        sw $a0, 0($t1)
        j FOURTH_PIXEL_PLAYER
        THIRD_PIXEL_PLAYER_ELSE:
        sw $a0, 260($t1)

    THIRD_PIXEL_TAIL:
        bne $s1, $zero, FOURTH_PIXEL_PLAYER
        li $t4, 2
        bge $t2, $t4, THIRD_PIXEL_TAIL_ELSE
        sw $a1, 0($t3)
        j FOURTH_PIXEL_PLAYER
        THIRD_PIXEL_TAIL_ELSE:
        sw $a1, 260($t3)

    FOURTH_PIXEL_PLAYER:
        li $t4, 3
        blt $t0, $zero, FOURTH_PIXEL_PLAYER_ELSE
        beq $t0, $t4, FOURTH_PIXEL_PLAYER_ELSE
        sw $a0, 256($t1)
        j FOURTH_PIXEL_TAIL
        FOURTH_PIXEL_PLAYER_ELSE:
        sw $a0, 4($t1)

    FOURTH_PIXEL_TAIL:
        bne $s1, $zero, FINISHED_TAIL_PLAYER_PRINTING
        li $t4, 3
        blt $t2, $zero, FOURTH_PIXEL_TAIL_ELSE
        beq $t2, $t4, FOURTH_PIXEL_TAIL_ELSE
        sw $a1, 256($t3)
        j FINISHED_TAIL_PLAYER_PRINTING
        FOURTH_PIXEL_TAIL_ELSE:
        sw $a1, 4($t3)

    FINISHED_TAIL_PLAYER_PRINTING:
    jr $ra
