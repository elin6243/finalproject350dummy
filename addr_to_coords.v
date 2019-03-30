module addr_to_coords(address, x_coord, y_coord); 
	input[23:0] address;
	output[9:0] x_coord; 
	output[9:0] y_coord;
	
	assign x_coord = address % 10'd640;
	assign y_coord = address / 10'd640; 
endmodule