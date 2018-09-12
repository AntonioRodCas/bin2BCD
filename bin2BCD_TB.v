 /*********************************************************
 * Description:
 * This module is test bench file for testing the binary to BCD converter
 *
 *
 *	Author:  Antonio Rodríguez    md193781   ITESO 
 *	Date:    08/09/18
 *
 **********************************************************/ 
 
 
 
module bin2BCD_TB;

parameter WORD_LENGTH = 8;


reg clk_tb = 0;
reg reset_tb;
reg enable_tb = 0;
reg start_tb = 0;

reg [WORD_LENGTH - 1 : 0] bin_tb;

wire [6 : 0] U_tb;
wire [6 : 0] T_tb;
wire [6 : 0] H_tb;
wire ready_tb;
wire sign_tb;



bin2BCD
#(
	.WORD_LENGTH(WORD_LENGTH)
)
DUV
(
	.clk(clk_tb),
	.reset(reset_tb),
	.enable(enable_tb),
	.start(start_tb),
	.bin(bin_tb),

	.U(U_tb),
	.T(T_tb),
	.H(H_tb),
	.ready(ready_tb),
	.sign(sign_tb)

);

/*********************************************************/
initial // Clock generator
  begin
    forever #2 clk_tb = !clk_tb;
  end
/*********************************************************/
initial begin // reset generator
   #0 reset_tb = 1;
   #5 reset_tb = 0;
end
/*********************************************************/
initial begin // start generator
	#8 start_tb = 1;
end
/*********************************************************/
initial begin // enable generator
	#5 enable_tb = 1;
end
/*********************************************************/
initial begin // bin generator
	#5 bin_tb = 129;
end
/*********************************************************/



endmodule