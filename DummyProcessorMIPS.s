#Main Idea: 3 values being written to every clock cycle. 

#1) input (current screen (3 bits), input from controller (3 bits), current mode (4 bits), current score (8 bits))
	#screen: 0 is splash, 1 is dummy, 2 is leaderboard
	#input: 0 is left, 1 is middle, 2 is right
	#current mode: 0 is none, 1 is save, 2 is load, 3 is game


#2) output (select screen (3 bits), select mode(3 bits), select pads to light up (16 bits on GUI), select pad to light up (4 bits)
#, select audio (1 bit))
	#pads to light up GUI: 
		#for each pad: 
			#first 2 bits: red (2), green (1), none (0)
			#next 2 bits: dark (2), medium (1), light (0)
	

#3) sensor readings (1 bit for each sensor, total 32 sensors)
	#first 4 bits are smaller/central buttons, next 4 bits are bigger outside buttons
	#0-7: left, 8-15: top, 16-23:bottom, 24-31: right
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

	#Display hits
	
	lw $r1, input_dmem 
	and $r2, save_code, input_dmem #if GUI sends signal to save pattern
	bne $r2, save_code, save_pattern
	
	and $r3, load_code, input_dmem #if GUI sends signal to save pattern
	bne $r3, load_code, load_pattern	
	
	and $r4, play_code, input_dmem #if GUI sends signal to save pattern
	bne $r4, play_code, play_game
	
	j process_hits

process_hits: 
	#get each pad as an 8 bit segment
	lw $r12, sensors_dmem
	sra $r13, $r12, 8
	sra $r14, $r12, 16
	sra $r15, $r12, 24
	
	addi $r16, $r0, 255
	and $r12, $r12, $r16 #is this a hazard
	and $r13, $r13, $r16
	and $r14, $r14, $r16
	and $r15, $r15, $r16
	
	addi $r17, $r0, 0 #count for calc_hits
	j calc_hits

calc_hits: 
	addi $r18, $r0, 1
	sra $r12, $r12, $r17 $shift by count
	and $r25, $r12, $r18 $find lsb
	
add_hits_0:
	

add_hits_1: 
	
	
	

display_hits: 
	
	
	
	
	j check_GUI_input
save_pattern:
	lw $r20, sensors_dmem #sensor data in r20
	bne $r20, $r0, adjust_hit
	

	lw $r1, input_dmem 
	and $r5, end_code, $r1
	bne $r5, end_code, check_GUI_input
	
	j save_pattern

adjust_hit: #modify r20 (hit sensors) so all 8 sensors for 1 pad are 1 if one of the sensors are hit
	#if blt works
	addi $r21, $r0, 2^8
	addi $r22, $r0, 2^16
	addi $r23, $r0, 2^24

	blt $r20, $r21, left_pad
	blt $r20, $r22, top_pad
	blt $r20, $r23, bottom_pad
	j right_pad
	
	#if blt doesn't work, shift until zero while keeping the count. then you know where the largest 1 is and make that pad all 1
	#don't forget to initialize the count
	#sra $r21, $r20, $r22 #shift to right
	#addi $r22, $r22, 1 #shift to left 
	#bne $r21, $r0, fill_r20
	#j adjust_hit
	
left_pad: 
	addi $r20, $r0, <0-7 1's>
	j save_hit
top_pad:
	addi $r21, $r0, <8-15 1's>
	j save_hit
bottom_pad: 	
	addi $r22, $r0, <16-23 1's>
	j save_hit
right_pad: 	
	addi $r23, $r0, <24-31 1's>
	j save_hit

save_hit: 
	sw $r20, sensors_dmem_save($r10)
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
	#subtract value the score
	j load_pattern

good score: 
	#add to score
	j load_pattern
    
