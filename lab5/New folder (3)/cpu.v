// Computer Architecture (CO224) - Lab 05
// Design: CPU of Simple Processor with beq and j insructions
// Author: E/16/267


/*ALU module */
module alu(DATA1,DATA2,RESULT,SELECT,ZERO);

input  [7:0] DATA1,DATA2;		// ALU  Inputs 
input  [2:0] SELECT;			// ALU Selection
output [7:0] RESULT;			// ALU 8-bit Output

output ZERO;
reg [7:0] RESULT;
//connect to nor gate
wire ZERO;			


//  to get raise zero flag when result==0 using multiple input nor gate
nor n1(ZERO,RESULT[0],RESULT[1],RESULT[2],RESULT[3],RESULT[4],RESULT[5],RESULT[6],RESULT[7]);

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


/* Register file module*/
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

//multiplexer for select Two's Complement and Immediate value in the control unit
module mux(OUT,SELECT,INPUT1,INPUT2);

	input SELECT,clk;
	input [7:0] INPUT1,INPUT2;
	output reg [7:0] OUT;

	always @* 
	begin
		if (SELECT==0)
		begin
			OUT = INPUT1;
		end
		else 
		begin
			OUT = INPUT2;
		end
	end
endmodule

//twos compliment module when sustractor is called
module twos_compliment(OUT,IN);

	input [7:0] IN;
	output [7:0] OUT;
	reg [7:0] OUT;

	always @(IN)
	begin
		OUT= ~IN + 8'b00000001; //getting compliment bitwise
	end
	
endmodule

//control unit for control muxes and opcode
//input = instruction opcode
//output = select for alu and input to muxes in the cpu module and beq and j signals

module control_unit(OPCODE,SELECT,MUX_IMMEDIATE,MUX_SIGNED,WRITE,J_SIGNAL,BEQ_SIGNAL);	//control unit
	input [7:0] OPCODE;
	output [2:0] SELECT;
	//control signal outputs
	output MUX_IMMEDIATE,MUX_SIGNED,WRITE,J_SIGNAL,BEQ_SIGNAL;
	reg MUX_IMMEDIATE,MUX_SIGNED,WRITE,J_SIGNAL,BEQ_SIGNAL;
	
	//delay #1 to decoding the instruction
	assign #1 SELECT = OPCODE [2:0]; //select should be OPCODEs last three bits for alu 
	
	always @(OPCODE) 
	begin
		case(OPCODE)		//add delay of #1 to opcode
			8'b00000000:
			#1	begin 	//for mov
			    WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				BEQ_SIGNAL=1'b0;
				J_SIGNAL=1'b0;
				end
			8'b00000001:
			#1	begin 	//for add	
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				BEQ_SIGNAL=1'b0;
				J_SIGNAL=1'b0;
				end
			8'b00001001:
			#1	begin 	//sub
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b1;  //for get 2's compliement for sub
				J_SIGNAL=1'b0;
				BEQ_SIGNAL=1'b0;
				end
			8'b00000010:
			#1	begin 	//and	
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				BEQ_SIGNAL=1'b0;
				J_SIGNAL=1'b0;
				end
			8'b00000011:
			#1	begin 	//or
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				BEQ_SIGNAL=1'b0;
				J_SIGNAL=1'b0;
				end
			8'b00001000:
			#1	begin 	//for load	
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b0;
				MUX_SIGNED = 1'b0;
				BEQ_SIGNAL=1'b0;
				J_SIGNAL=1'b0;
				end	
	        8'b00011001:
			#1	begin 	//for BEQ_SIGNAL FOR SUB where beq signal=1
				WRITE=1'b0; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b1; //check equality by subtracting
				BEQ_SIGNAL=1'b1;
				J_SIGNAL=1'b0;
				end
			8'b00000110:
			#1	begin 	//for J_SIGNAL	for jump instruction
				WRITE=1'b0; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				BEQ_SIGNAL=1'b0;
				J_SIGNAL=1'b1;
				end
			
		endcase
			
	end
endmodule



//dedicated adder for increment pc by 4
module adder(NUM1,NUM2,SUM);
    input[31:0] NUM1,NUM2;
	output [31:0] SUM;
	 
	assign  #2 SUM=NUM1 +NUM2; //increment by delay of 2 when adding 4 to pc
	
endmodule



//module for add pc for beq and j operations with sigend shitf value
module Add_ALU(PCout, ShiftOut, Add_ALUOut);

	input  [31:0] PCout;
	input signed [31:0] ShiftOut;
	
	output  reg [31:0] Add_ALUOut;

	always @(*) begin
		#2 Add_ALUOut = PCout + ShiftOut;
	end
endmodule


   
   
//module to Converts a 8-bit value to a sign-extended 32-bit value.
module Sign_Extender(in, out);

input wire [7:0] in; //in - a 8-bit signed integer.
output wire [31:0] out; //out - a 32-bit signed integer.

//replicate the sign bit of input into the high 8 bits of output.
assign out = {{8{in[7]}}, in[7:0]};

endmodule





//Shifts a 32-bit value left two places.
module Left_Shift(in, out);

input  wire signed [31:0] in;
output  wire signed[31:0] out;

//Output the shifted value.
//out -- A 32-bit integer that is equivalent to the input, but shifted left 2 places.

assign out = {in[29:0], 2'b0}; 


endmodule


//cpu module
//instruction decoding ,pc increment for happens here
module cpu(PC,INSTRUCTION,CLK,RESET);
	input [31:0] INSTRUCTION;
	input CLK,RESET;
	output reg [31:0] PC;
	
	wire WRITE;
	//zero flag output from alu
	wire ZERO; 
	//control signal od BEQ and j from control unit
	wire beq,j; 
	//control signal to 2's compliment and immediate operand in alu
	wire IMMEDIATE_SELECT,SUB_SELECT; 
	//outputs of AND and OR gates of incrementing pc for j,beq
	wire result_and,result_or;
	
	//for increment pc with given signal
	wire [31:0] PC_NEXT,PC_Sumbeq;
	
	//for module alu and register
	wire [2:0] ALUOP,SRC_2 ,SRC_1,WRITEREG;
	wire [7:0] OPCODE,Immediate,OUT1,OUT2,ALURESULT,twosComplement,muxSout,muxIout;
	
	//sign-extended module and left shift module inputs outputs
	wire signed [7:0] DESTINATION;
	wire signed [31:0] shift_offset,unshift_offset;
	
	
	
	
	//instruction decoding  
	assign  WRITEREG    = INSTRUCTION[18:16];
	assign  OPCODE 		= INSTRUCTION[31:24];
	assign  Immediate   = INSTRUCTION[7:0];
	assign  SRC_1       = INSTRUCTION[10:8];
	assign  SRC_2       = INSTRUCTION[2:0];
	assign DESTINATION  = INSTRUCTION[23:16]; //for sign extender
	
	
	
	//send current pc value to increment by 4
    adder PCadder(PC,4,PC_NEXT);
	//SEND INSTRUCTION[23:16] to sign extend
	Sign_Extender add(DESTINATION,unshift_offset);
	//shift unshif offset
	Left_Shift shift(unshift_offset,shift_offset);
	//send shift_offset to increment with current PC
	Add_ALU add_pcbeq(PC_NEXT,shift_offset,PC_Sumbeq);
	//send values to control unit
    control_unit mycu(OPCODE,ALUOP,IMMEDIATE_SELECT,SUB_SELECT,WRITE,j,beq);
	//reg_file
	reg_file regfile(ALURESULT,OUT1,OUT2,WRITEREG,SRC_1,SRC_2,WRITE,CLK,RESET);
	//twosComplement module to sustractor
	twos_compliment mytwos_compliment(twosComplement,OUT2);
	//mux for select sub or other operartions
	mux mulx_Sign(muxSout,SUB_SELECT,OUT2,twosComplement);  
	//mux for select load or other muxout
	mux mulx_Immediate(muxIout,IMMEDIATE_SELECT,Immediate,muxSout);
	//send final values to done alu operations
	alu myalu(OUT1,muxIout,ALURESULT,ALUOP,ZERO);
	
	
                      	
	//when reset
    always@(RESET)
	begin
	if(RESET)
	begin
	#1			//update with delay of #1
	PC =-32'd4;
	end
	end
	
	//for get ZERO =1'b1 && beq=1'b1
	and a2(result_and,ZERO, beq);
	//for get ZERO =1'b1 && beq=1'b1 || j=1'b1
	or or1(result_or,j, result_and);
	
	always@(posedge CLK)
	 
	begin
		if(RESET)
			begin
			#1			//update with delay of #1
			PC =-32'd4;
			end
		else if(result_or==1) //if result of or gate is 1 pc increment
			begin
			#1 PC = PC_Sumbeq;
			end
		else
			begin
				#1 
				PC=PC_NEXT;
			end
		
	end
	
	
	
	
endmodule




