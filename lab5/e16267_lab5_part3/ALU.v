/*E/16/267*/
/*lab5_part1*/


module alu(DATA1,DATA2,RESULT,SELECT);

input  [7:0] DATA1,DATA2;		// ALU  Inputs 
input  [2:0] SELECT;			// ALU Selection
output [7:0] RESULT;			// ALU 8-bit Output
reg RESULT;				

always @(DATA1,DATA2,SELECT)

begin

case(SELECT)
	3'b000: #1 RESULT = DATA2;			//FORWARD	
	3'b001: #2 RESULT = DATA1 + DATA2;	//ADD
	3'b010: #1 RESULT = DATA1 & DATA2;  //AND
	3'b011: #1 RESULT = DATA1 | DATA2;  //OR
    default:RESULT=8'bx;			    //RESERVED
       

endcase
end
endmodule

