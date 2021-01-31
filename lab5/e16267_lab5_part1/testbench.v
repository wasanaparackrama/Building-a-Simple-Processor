// Computer Architecture (CO224) - Lab 05
// Design: ALU File testbench of Simple Processor
// Author: E/16/267


module test;
	reg [7:0] data1, data2; 			//for  inputs
	reg [2:0] select;					//alu operations
	wire[7:0] Result;
	alu ALUTEST(data1,data2,Result,select); 
	
	initial
	begin
		$monitor($time," DATA1: %b, DATA2: %b, SELECT: %b, RESULT: %b",data1,data2,select,Result);
		$dumpfile("ALU_Wavedata.vcd");
		$dumpvars(0,test);
	end

	initial
	begin
		data1 = 8'b00001111; 
		data2 = 8'b00000101;
		select = 3'b000;	    //FORWARD	
		#10
		select = 3'b001;		//ADD
		#10
		select = 3'b010;   		//AND
		#10
		select = 3'b011;		//OR
		#10
		select = 3'b111;		//RESERVED
		#20
		$finish;
		
		
		
	end
endmodule
