#Main Idea: 3 values being written to every clock cycle. 
#first value is input (current screen (3 bits), input from controller (3 bits), current mode (3 bits))
#second value is output (select screen (3 bits), select mode(3 bits), select pads to light up (4 bits), select audio (1 bit))
#third value is touch sensors (1 bit for each sensor, total 32 sensors)

main: 
	lw $r1, input_dmem
	and $r2, GUI_code, input_dmem  #to select specific bits
	and $r3, Splash_code, input_dmem
	bne $r2, GUI_code, check_GUI_input
	bne $r3, Splash_code, check_splash_input

check_splash_input: (SPLASHSCREEN CHANGES SCREEN)
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

	lw $r1 <address in memory mapped io for save_pattern_signal>($r0) #if GUI sends signal to save pattern
	no-ops	
	bne $r0, $r1, save_patterns
	
	no-ops

	lw $r1 <address in memory mapped io for load_pattern_signal>($r0) #if GUI sends signal to load pattern
	no-op
	bne $r0, $r1, load_pattern
	
	
	lw $r1 <address in memory mapped io for end_pattern_signal>($r0) #if GUI sends signal to load pattern
	no-op
	bne $r0, $r1, end_patten
	
	

save_pattern:
	counter register
	lw $r2 <address from the sensors> 
        no-ops
	sw $r2 <memory address>(counter register)

load_pattern: 

	lw $r3 <memory address>(counter register)
	no-ops
	j check_pattern

check_pattern:

	lw $r5 <memory address>
	bne $r3,$r5 <bad_score>
	j good_score

bad_score:
	#subtract value in register saved for the score
	j load_pattern

good score: 
	#add to score
	j load_pattern
    
