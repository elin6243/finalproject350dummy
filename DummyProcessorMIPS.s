#Main Idea: 3 values being written to every clock cycle. 
#first value is input (current screen (3 bits), input from controller (3 bits), current mode (3 bits), current score (8 bits))
#second value is output (select screen (3 bits), select mode(3 bits), select pads to light up (4 bits), select audio (1 bit))
#third value is touch sensors (1 bit for each sensor, total 32 sensors)

main: 
	lw $r1, input_dmem
	and $r2, GUI_code, input_dmem  #to select specific bits
	and $r3, Splash_code, input_dmem
	bne $r2, GUI_code, check_GUI_input
	bne $r3, Splash_code, check_splash_input

check_splash_input: 
	lw $r1, input_demem
	and $r2, controller_code_left, input_dmem
	and $r3, controller_code_middle, input_dmem
	and $r4, controller_code_right, input_dmem
	or $r5, $r2, $r3
	or $r6, $r5, $r4
	bne $controller_code
	
	write to dmem for screen index (0 for splash, 1 for GUI, 2 for leaderboard)
	j main 
	
check_GUI_input: 
	addi $r10, 0 #initialize counter for save_pattern
	addi $r11, 0 #initialize counter for load_pattern

	#first display hits b/c don't need to be in a mode for a hit to be displayed
	
	lw $r1, input_dmem 
	and $r2, save_code, input_dmem #if GUI sends signal to save pattern
	bne $r2, save_code, save_pattern
	
	and $r3, load_code, input_dmem #if GUI sends signal to save pattern
	bne $r3, load_code, load_pattern	
	
	and $r4, play_code, input_dmem #if GUI sends signal to save pattern
	bne $r4, play_code, play_game
	
save_pattern:
	lw $r20, sensors_dmem #sensor data in r20
	bne $r20, $r0, save_hit
	

	lw $r1, input_dmem 
	and $r5, end_code, $r1
	bne $r5, end_code, check_GUI_input
	
	j save_pattern
	
save_hit: 
	sw $r2, sensors_dmem_save($r10)
	add $r10, $r10, 1 #increment counter
	save_pattern
		
load_pattern: 
	
	lw $r12, sensors_dmem_save($r11)

	#lw $r1, input_dmem
	
	#not sure how to save multiple indicies yet# and $r7, pattern_index_code, pattern_index #r7 has the pattern index 
	
	j check_pattern

check_pattern:
	lw $r12, 0($r7)
	add $r11, $r0, 1 #increment counter
	bne $r3,$r8
	j good_score

bad_score:
	#subtract value in register saved for the score
	j load_pattern

good score: 
	#add to score
	j load_pattern
    
