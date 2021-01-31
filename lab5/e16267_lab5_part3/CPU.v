// Computer Architecture (CO224) - Lab 05
// Design: CPU of Simple Processor
// Author: E/16/267


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
//output = select for alu and input to muxes in the cpu module

module control_unit(OPCODE,SELECT,MUX_IMMEDIATE,MUX_SIGNED,WRITE);	//control unit
	input [7:0] OPCODE;
	output [2:0] SELECT;
	output MUX_IMMEDIATE,MUX_SIGNED,WRITE;
	reg MUX_IMMEDIATE,MUX_SIGNED,WRITE;
	
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
				end
			8'b00000001:
			#1	begin 	//for add	
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				end
			8'b00001001:
			#1	begin 	//sub
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b1;
				end
			8'b00000010:
			#1	begin 	//and	
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				end
			8'b00000011:
			#1	begin 	//or
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b1;
				MUX_SIGNED = 1'b0;
				end
			8'b00001000:
			#1	begin 	//for load	
				WRITE=1'b1; 
				MUX_IMMEDIATE = 1'b0;
				MUX_SIGNED = 1'b0;
				end	
		endcase
			
	end
endmodule

//dedicated adder for increment pc by 4
module adder(NUM1,NUM2,SUM);
    input[31:0] NUM1,NUM2;
	output [31:0] SUM;
	 
	assign SUM=NUM1 +NUM2;
	
endmodule

//cpu module
//instruction decoding ,pc increment happens here
module cpu(PC,INSTRUCTION,CLK,RESET);
	input [31:0] INSTRUCTION;
	input CLK,RESET;
	output reg [31:0] PC;
	
	wire WRITE;
	wire [31:0] Sum;
	
    wire [31:0] PC_NEXT;
	wire [2:0] ALUOP,SRC_2 ,SRC_1,DESTINATION;
	wire IMMEDIATE_SELECT,SUB_SELECT; //control signal to 2's compliment and immediate operand in alu
	wire [7:0] OPCODE,Immediate,OUT1,OUT2,ALURESULT,twosComplement,muxSout,muxIout;
	
	//instruction decoding  
	assign  DESTINATION    = INSTRUCTION[18:16];
	assign  OPCODE 		   = INSTRUCTION[31:24];
	assign  Immediate      = INSTRUCTION[7:0];
	assign  SRC_1          = INSTRUCTION[10:8];
	assign  SRC_2          = INSTRUCTION[2:0];
	
	
	
    adder PCadder(PC,4,Sum);
    control_unit mycu(OPCODE,ALUOP,IMMEDIATE_SELECT,SUB_SELECT,WRITE);
	reg_file regfile(ALURESULT,OUT1,OUT2,DESTINATION,SRC_1,SRC_2,WRITE,CLK,RESET);
	twos_compliment mytwos_compliment(twosComplement,OUT2);
	mux mulx_Sign(muxSout,SUB_SELECT,OUT2,twosComplement);   
	mux mulx_Immediate(muxIout,IMMEDIATE_SELECT,Immediate,muxSout);
	alu myalu(OUT1,muxIout,ALURESULT,ALUOP);
	
	
                      	
	assign #2 PC_NEXT=Sum; //#2 delay when pc is adding by 4 using adder
    always@(RESET)
	begin
	if(RESET)
	begin
	#1			//update with delay of #1
	PC =-32'd4;
	end
	end
	
	always@(posedge CLK)
	begin
	if(!RESET) begin
	#1			//update with delay of #1
	PC = PC_NEXT;
	end
	end
	
endmodule




