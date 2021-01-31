// Computer Architecture (CO224) - Lab 05
// Design: Register File of Simple Processor
// Author: E/16/267

module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);

//reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);

	input CLK,WRITE,RESET;
	input [2:0] INADDRESS,OUT1ADDRESS, OUT2ADDRESS;
	input [7:0] IN;
	output [7:0] OUT1, OUT2;
	
	reg [7:0] r[7:0]; //for assign to 7 registers
	integer i;

	assign #2 OUT1=r[OUT1ADDRESS];
	assign #2 OUT2=r[OUT2ADDRESS];
	
	//for reset=1 with level trigerring
	always @(RESET) 	
	begin
		if(RESET)
		#2   //timing delay
			for (i=0; i<8; i=i+1)   //making registers array
			begin
                r[i]=8'b00000000; 
			end
	end
	
	//for no reset && write with edge triggering
	always @(posedge CLK)
	begin
		if(!RESET && WRITE)
			begin
				#2 r[INADDRESS]=IN;  //assign writedata to registers
			end
	end
	
	
	
endmodule