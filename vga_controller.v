module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 in1,
							 in2, 
							 in3, 
							 in4);

	
input iRST_n, in1, in2, in3, in4;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
////


reg [9:0] box_x; 
reg [9:0] box_y;
reg [19:0] counter; 


assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;
reg[23:0] color_output;
reg[3:0] box_offset; 
reg[8:0] total_x_offset; 
reg[8:0] total_y_offset; 
always@(posedge VGA_CLK_n) 
	 begin
	 box_offset<=4'd5; 
	 bgr_data <= bgr_data_raw;
	 box_x <= ADDR % 10'd640;
    box_y <= ADDR / 10'd640;
	 if(counter==0) 
		 begin
		 if(in1==0) total_x_offset<=total_x_offset+box_offset; 
		 if(in2==0) total_x_offset<=total_x_offset-box_offset; 
		 if(in3==0) total_y_offset<=total_y_offset+box_offset; 
		 if(in4==0) total_y_offset<=total_y_offset-box_offset; 
		 end
		 counter<=counter+1; 
	 if(counter==20'd1000000) counter<=0; 
//	 box_x<=box_x+total_x_offset; 
//	 box_y<=box_y+total_y_offset; 
	 
	 if((box_x>120+total_x_offset) && (box_x<280+total_x_offset) && (box_y>120+total_y_offset) &&(box_y<280+total_y_offset))
		begin
		color_output[23:16] <= 8'h9C; 
		color_output[15:8] <=8'b0; 
		color_output[7:0] <= 8'b0; 
		end
	 else 
		begin
		color_output[23:16] <= bgr_data[23:16];
		color_output[15:8] <= bgr_data[15:8];
		color_output[7:0] <= bgr_data[7:0];	
		end
	 end
assign b_data = color_output[23:16]; 
assign g_data = color_output[15:8]; 
assign r_data = color_output[7:0];
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end




endmodule
 	















