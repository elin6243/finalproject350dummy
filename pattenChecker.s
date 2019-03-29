main:

check_GUI_input: 

	lw $r1 <address in memory mapped io for save_pattern_signal>($r0) #if GUI sends signal to save pattern
	no-ops	
	bne $r0, $r1, save_pattern
	
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
    
