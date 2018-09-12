 /*********************************************************
 * Description:
 * This module is a binary to BCD converter
 * 	Inputs:
 *			bin: 		Binary input data
 *			clk: 		Clock input signal
 * 		start:	Start input signal
 *			reset: 	Reset input signal
 *		Outputs:
 *			H: 		Hundreds of the BCD
 *			T: 		Tens of the BCD
 *			U: 		Units of the BCD
 *			ready:	Ready signal
 *
 *	Author:  Antonio Rodríguez    md193781   ITESO 
 *	Date:    08/09/18
 *
 **********************************************************/

module bin2BCD
#(
	parameter WORD_LENGTH = 8										//Input parameter definition
)

(
	input [WORD_LENGTH-1:0] bin,						
	input 						clk,
	input 						start,
	input							reset,
	input							enable,
	
	output [6:0] H,
	output [6:0] T,
	output [6:0] U,
	output  		 ready,
	output		 sign
	
	
);

reg  start_reg;
reg  ready_reg;
wire [3:0] U_reg;
wire [3:0] T_reg;
wire [3:0] H_reg;
reg [7:0] counter;

wire [WORD_LENGTH-1:0] bin_wir;			//Wire to connect Two's complement decoder output to parallel to serial decod
wire  [WORD_LENGTH-1:0] regTObinint;	//Wire to connect Input resgister of Binary input to internal wire

wire  serTOUBCD;						//Wire to connect serial to Units BCD
wire  UBCDTOTBCD;						//Wire to connect Units BCD to Tens BCD
wire  TBCDTOHBCD;						//Wire to connect Tens BCD to Hundreds BCD
wire  dummy;						   //Wire to connect Hundreds BCD to dummy line

wire [3:0] regTOunits7seg;        //Wire to connect register to 7seg decoder for units
wire [3:0] regTOtens7seg;        //Wire to connect register to 7seg decoder for tens
wire [3:0] regTOhundreds7seg;        //Wire to connect register to 7seg decoder for hundreds

//----------------------Parallel to serial converter instance-----------------------
par2ser
#(
	.WORD_LENGTH(WORD_LENGTH)
)
par2ser_1								
(
	.clk(clk),
	.reset(reset),
	.load(start_reg),
	.par(bin_wir),
	
	.ser(serTOUBCD)

);

//----------------------BCD shifter converter instances-----------------------
shiftBCD units_BCD					     	//BCD shifter for Units
( 
	.clk(clk),
	.init(start_reg),
	.reset(reset),
	.in(serTOUBCD),
	
	.Cout(UBCDTOTBCD),
	.BCD(U_reg)

);

shiftBCD tens_BCD						       //BCD shifter for Tens
(
	.clk(clk),
	.init(start_reg),
	.reset(reset),
	.in(UBCDTOTBCD),
	
	.Cout(TBCDTOHBCD),
	.BCD(T_reg)

);

shiftBCD hundreds_BCD						//BCD shifter for hundreds
(
	.clk(clk),
	.init(start_reg),
	.reset(reset),
	.in(TBCDTOHBCD),
	
	.Cout(dummy),
	.BCD(H_reg)

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
	.clk(ready),						//Ready signal will hold the value at the 7seg display
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
	.clk(ready),						//Ready signal will hold the value at the 7seg display
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
	.clk(ready),						//Ready signal will hold the value at the 7seg display
	.reset(reset),
	.enable(enable),
	.Data_Input(H_reg),
	
	.Data_Output(regTOhundreds7seg)

);


//Start 
always @(posedge clk, posedge reset) 
begin
	if (reset)
	begin
		start_reg <= 1;
	end
	else if(start)
		begin
			if(ready_reg)
			begin
				start_reg <= 1;
			end
			else
			begin
				start_reg <= 0;
			end
		end
		else
		begin
			start_reg <= 1;
		end
end

//Counter
always @(posedge clk, posedge reset) 
begin
	if (reset)
	begin
		counter <= 0;
	end
	else if (!start_reg)
		begin
			counter <= counter + 1'b1;
		end
		else
		begin
			counter <= 0;
		end
end

//ready
always @(posedge clk, posedge reset) 
begin
	if (reset)
	begin
		ready_reg <= 0;
	end
	else if(!start_reg)
		begin
			if(counter==WORD_LENGTH)
			begin
				ready_reg <= 1;
			end
			else
			begin
				ready_reg <= 0;
			end
		end
		else
		begin
			
		end
end

//Assignations 
assign ready = ready_reg;
assign sign = ~regTObinint[WORD_LENGTH-1];
assign bin_wir = (regTObinint[WORD_LENGTH-1]==0) ? regTObinint : (~regTObinint + 1'b1);
						

endmodule