
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
    # Screen height = 32px
    # Screen width = 64px
    # Size of screen: height*width*4 = 8192
    window: .space 8192
    # Game field height = 14px
    # Game field width = 30px
    # Game field size: height*width*4 = 1680
    field: .space 1680

    # Colors
    t0: .word 0xFFFFFF # White
    t1: .word 0x000000 # Black
    bg0: .word 0x325D37 # Background color 1
    bg1: .word 0x477238 # Background color 2
    br0: .word 0xC45F75 # Border color 1
    br1: .word 0xE27285 # Border color 2
    sn0: .word 0x2789CD # Snake color 1
    sn1: .word 0x42BFE8 # Snake color 2
    apl: .word 0xF1641F # Apple color

.text
    # These registers are reserved to use as references to the window and game field
    la $t9, window
    la $t8, field
MAIN:
    la $t4, apl
    lw $s0, 0($t4)
    
    jal DRAW_BORDER
    jal DRAW_BACKGROUND

    li $v0, 10
    syscall

DRAW_BACKGROUND:
    la $t0, bg0
	lw $t0, 0($t0) # Load background color 1

	la $t1, bg1
	lw $t1, 0($t1) # Load background color 2

	move $t2, $t0 # $t2 is going to be used as a buffer to the color to be used

	li $t3, 130 # Iterator starting at first background tile
	li $t4, 2047 # Last element of the window
	sll $t5, $t4, 2

	li $t4, 190 # Last element of the first row of the background (Condition for iterator)

	li $t6, 0 # Iterator used for the change of color

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
			move $t2, $t0 # Changes color to color 1
			li $t6, 0
			j ITERATOR_DRAW_BACKGROUND

			CHANGE_BACKGROUND_COLOR_2:
			move $t2, $t1 # Changes color to color 2
			li $t6, 0
			j ITERATOR_DRAW_BACKGROUND

	ITERATOR_BACKGROUND_NEXT_ROW:
	li $t6, 958 # End of the 15th row (64*15-2)

	beq $t3, $t6, FINISHED_BACKGROUND
	addi $t3, $t3, 128 # Go to next row
	subi $t3, $t3, 60 # Go back to first pixel of the row
	addi $t4, $t4, 128 # Go to next row

	li $t6, 2 # Alternate color
	j BACKGROUND_ALTERNATE_COLOR

	FINISHED_BACKGROUND:
	jr $ra
	

DRAW_BORDER:
    la $t0, br0
    lw $t0, 0($t0) # Load border color 1

    la $t1, br1
    lw $t1, 0($t1) # Load border color 2

    move $t2, $t0 # $t2 is a buffer for the color that is going to be used

    li $t3, 0 # Iterator
    li $t4, 2048
    sll $t5, $t4, 2
    subi $t5, $t5, 4 # $t5 is used to find the end of the window

    li $t4, 64 # Condition for the iterator

    li $t6, 0 # Iterator used to change between color 1 and 2

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
        move $t2, $t0 # Changes color to color 1
        li $t6, 0
        j ITERATOR_DRAW_BORDER_HORIZONTAL

        CHANGE_BORDER_COLOR_HORIZONTAL_2:
        move $t2, $t1 # Changes color to color 2
        li $t6, 0
        j ITERATOR_DRAW_BORDER_HORIZONTAL

    FINISHED_BORDER_HORIZONTAL:
    j DRAW_BORDER_VERTICAL

DRAW_BORDER_VERTICAL:
    la $t0, br0
    lw $t0, 0($t0) # Load border color 1

    la $t1, br1
    lw $t1, 0($t1) # Load border color 2

    move $t2, $t1 # $t2 is a buffer for the color that is going to be used

    li $t3, 0 # Iterator
    li $t4, 2048
    sll $t5, $t4, 2
    subi $t5, $t5, 4 # $t5 is used to find the end of the window

    li $t4, 28 # Number of columns * 2 used as condition for the iterator

    li $t6, 0 # Iterator used to change between color 1 and 2

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
        move $t2, $t0 # Changes color to color 1
        li $t6, 0
        j ITERATOR_DRAW_BORDER_VERTICAL

        CHANGE_BORDER_COLOR_VERTICAL_2:
        move $t2, $t1 # Changes color to color 2
        li $t6, 0
        j ITERATOR_DRAW_BORDER_VERTICAL

    FINISHED_BORDER_VERTICAL:
    jr $ra
