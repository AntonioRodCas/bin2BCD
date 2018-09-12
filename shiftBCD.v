 /*********************************************************
 * Description:
 * This module is a shifter BCD module to double the input 
 * and take out the carry in case the BCD value is bigger than 5
 * 	Inputs:
 *			clk: 		Clock input signal
 * 		init:	   Start input signal
 *			reset: 	Reset input signal
 *			in:		Input serialized data
 *		Outputs:
 *			cout: 	Carry to a BCD significant bit
 *			BCD: 		BCD output [3:0]
 *
 *
 *	Author:  Antonio Rodríguez    md193781   ITESO 
 *	Date:    08/09/18
 *
 **********************************************************/

module shiftBCD 

(						
	input clk,
	input init,
	input	reset,
	input	in,						
	
	output Cout,
	output [3:0] BCD
	
);

reg [3:0] BCD_reg;
reg [2:0] BCD_dou;
reg Cout_reg;

// Shifter module
always @(posedge clk, posedge reset) 
begin
	if (reset)
	begin
		BCD_reg <= 0;
	end
	else if (init)
		begin
			BCD_reg [3:1] <= 3'b000;
			BCD_reg [0]   <= in; 
		end
		else
		begin
			BCD_reg <= {BCD_dou, in};  //Shifter
		end
end

// Doubler module
always @(BCD_reg) 
begin
	case (BCD_reg) 
		4'b0000: BCD_dou = 3'b000;  //After shifter -> 0
		4'b0001: BCD_dou = 3'b001;  //After shifter -> 2
		4'b0010: BCD_dou = 3'b010;  //After shifter -> 4
		4'b0011: BCD_dou = 3'b011;  //After shifter -> 6
		4'b0100: BCD_dou = 3'b100;  //After shifter -> 8
		4'b0101: BCD_dou = 3'b000;  //After shifter -> 10 (carry)
		4'b0110: BCD_dou = 3'b001;  //After shifter -> 12 (carry)
		4'b0111: BCD_dou = 3'b010;  //After shifter -> 14 (carry)
		4'b1000: BCD_dou = 3'b011;  //After shifter -> 16 (carry)
		4'b1001: BCD_dou = 3'b100;  //After shifter -> 18 (carry)
		default: BCD_dou = 3'b000;
	endcase
end

// Carry detector
always @(BCD_reg) 
begin
	if (BCD_reg == 4'b0101 || BCD_reg == 4'b0110 || BCD_reg == 4'b0111 || BCD_reg == 4'b1000 || BCD_reg==4'b1001)
	begin
		Cout_reg <= (1'b1 & !init);  //Set output to 0 at init state
	end
	else
	begin
		Cout_reg <= 1'b0;
	end
end


//Assign outputs
assign Cout = Cout_reg;
assign BCD = BCD_reg;



endmodule