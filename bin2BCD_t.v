 /*********************************************************
 * Description:
 * This module is a binary to BCD converter
 * 	Inputs:
 *			bin: 		Binary input data
 *			clk: 		Clock input signal
 *			reset: 	Reset input signal
 *			enable:  Enable signal for the registers
 *		Outputs:
 *			H: 		Hundreds of the BCD
 *			T: 		Tens of the BCD
 *			U: 		Units of the BCD
 *			sign:	   Sign signal
 *
 *	Author:  Antonio Rodríguez    md193781   ITESO 
 *	Date:    13/09/18
 *
 **********************************************************/

module bin2BCD_t
#(
	parameter WORD_LENGTH = 8										//Input parameter definition
)

(
	input [WORD_LENGTH-1:0] bin,						
	input 						clk,
	input							reset,
	input							enable,
	
	output [6:0] H,
	output [6:0] T,
	output [6:0] U,
	output		 sign
	
	
);


wire [3:0] U_reg;								//Wire to connect BCD to register Units
wire [3:0] T_reg;								//Wire to connect BCD to register Tens
wire [3:0] H_reg;								//Wire to connect BCD to register Hundreds


wire [WORD_LENGTH-1:0] bin_wir;			//Wire to connect Two's complement decoder output to parallel to serial decod
wire  [WORD_LENGTH-1:0] regTObinint;	//Wire to connect Input resgister of Binary input to internal wire


wire [3:0] regTOunits7seg;        //Wire to connect register to 7seg decoder for units
wire [3:0] regTOtens7seg;        //Wire to connect register to 7seg decoder for tens
wire [3:0] regTOhundreds7seg;        //Wire to connect register to 7seg decoder for hundreds

wire [3:0] A1toW;   					 //Wire to connect A1 adder to World
wire [3:0] A2toW;   					 //Wire to connect A2 adder to World
wire [3:0] A3toW;   					 //Wire to connect A3 adder to World
wire [3:0] A4toW;   					 //Wire to connect A4 adder to World

wire [3:0] A5toW;   					 //Wire to connect A4 adder to World
wire [3:0] A6toW;   					 //Wire to connect A4 adder to World

//Asignations

assign sign = ~regTObinint[WORD_LENGTH-1];
assign bin_wir = (regTObinint[WORD_LENGTH-1]==0) ? regTObinint : (~regTObinint + 1'b1);

assign U_reg = {A5toW[2:0] , bin_wir[0]};
assign T_reg = {A6toW[2:0] , A5toW[3]};
assign H_reg = {3'b000 , A6toW[3]};

//----------------------Adders 3-----------------------
add3 add3_A1					     	//Adder A1 
( 
	.in({1'b0,bin_wir[7:5]}),
	
	.out(A1toW)

);

add3 add3_A2				     	//Adder A2 
( 
	.in({A1toW[2:0],bin_wir[4]}),
	
	.out(A2toW)

);

add3 add3_A3				     	//Adder A3 
( 
	.in({A2toW[2:0],bin_wir[3]}),
	
	.out(A3toW)

);
add3 add3_A4				     	//Adder A4 
( 
	.in({A3toW[2:0],bin_wir[2]}),
	
	.out(A4toW)

);

add3 add3_A5				     	//Adder A5 
(
	.in({A4toW[2:0],bin_wir[1]}),
	
	.out(A5toW[3:0])

);
add3 add3_A6				     	//Adder A6 
(
	.in({A1toW[3],A2toW[3],A3toW[3],A4toW[3]}),
	
	.out(A6toW[3:0])

);


//----------------------BCD to seven segment converter instance-----------------------
BCDto7seg units_7seg						//seven segment decoder for units
(
	.BCD(regTOunits7seg),
	
	.SSD(U)

);

BCDto7seg tens_7seg						//seven segment decoder for tens
(
	.BCD(regTOtens7seg),
	
	.SSD(T)

);

BCDto7seg hundreds_7seg						//seven segment decoder for hundreds
(
	.BCD(regTOhundreds7seg),
	
	.SSD(H)

);

//----------------------Binary input register instance-----------------------

Register
#(
	.WORD_LENGTH(WORD_LENGTH)
)
bin_register						//Binary input register
(
	.clk(clk),
	.reset(reset),
	.enable(enable),
	.Data_Input(bin),
	
	.Data_Output(regTObinint)

);

//----------------------BCD output register instance-----------------------

Register
#(
	.WORD_LENGTH(WORD_LENGTH)
)
BCD_unit_register						//BCD output register units
(
	.clk(clk),						
	.reset(reset),
	.enable(enable),
	.Data_Input(U_reg),
	
	.Data_Output(regTOunits7seg)

);

Register
#(
	.WORD_LENGTH(WORD_LENGTH)
)
BCD_ten_register						//BCD output register tens
(
	.clk(clk),						
	.reset(reset),
	.enable(enable),
	.Data_Input(T_reg),
	
	.Data_Output(regTOtens7seg)

);

Register
#(
	.WORD_LENGTH(WORD_LENGTH)
)
BCD_hundreds_register						//BCD output register hundreds
(
	.clk(clk),						
	.reset(reset),
	.enable(enable),
	.Data_Input(H_reg),
	
	.Data_Output(regTOhundreds7seg)

);

						

endmodule