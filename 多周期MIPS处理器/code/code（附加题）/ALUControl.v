`timescale 1ns / 1ps
module ALUControl(ALUOp, Funct, ALUConf, Sign);
	//Control Signals
	input [3:0] ALUOp;
	//Inst. Signals
	input [5:0] Funct;
	//Output Control Signals
	output reg [4:0] ALUConf;
	output Sign;

	parameter aluADD = 5'b00000;
	parameter aluOR  = 5'b00001;
	parameter aluAND = 5'b00010;
	parameter aluSUB = 5'b00110;
	parameter aluSLT = 5'b00111;
	parameter aluNOR = 5'b01100;
	parameter aluXOR = 5'b01101;
	parameter aluSRL = 5'b10000;
	parameter aluSRA = 5'b11000;
	parameter aluSLL = 5'b11001;
	parameter aluSETSUB = 5'b11010;
	assign Sign = (ALUOp[2:0] == 3'b010)? ~Funct[0]: ~ALUOp[3];
	
	reg [4:0] aluFunct;
	always @(*)
		case (Funct)
			6'b00_0000: aluFunct <= aluSLL;//sll
			6'b00_0010: aluFunct <= aluSRL;//srl
			6'b00_0011: aluFunct <= aluSRA;//sra
			6'b10_0000: aluFunct <= aluADD;//add
			6'b10_0001: aluFunct <= aluADD;//addu
			6'b10_0010: aluFunct <= aluSUB;//sub
			6'b10_0011: aluFunct <= aluSUB;//subu
			6'b10_0100: aluFunct <= aluAND;//and
			6'b10_0101: aluFunct <= aluOR;//or
			6'b10_0110: aluFunct <= aluXOR;//xor
			6'b10_0111: aluFunct <= aluNOR;//nor
			6'b10_1010: aluFunct <= aluSLT;//slt
			6'b10_1011: aluFunct <= aluSLT;//sltu
			6'b10_1000: aluFunct <= aluSETSUB;//setsub
			default: aluFunct <= aluADD;//jr jalr
		endcase
	
	always @(*)
		case (ALUOp[2:0])
			3'b000: ALUConf <= aluADD;
			3'b001: ALUConf <= aluSUB;
			3'b100: ALUConf <= aluAND;
			3'b101: ALUConf <= aluSLT;
			3'b010: ALUConf <= aluFunct;//opcode=0
			default: ALUConf <= aluADD;
		endcase

endmodule
