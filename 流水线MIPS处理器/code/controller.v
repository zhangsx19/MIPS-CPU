module controller(OpCode, Funct,
	RegWrite, RegDst,MemRead, MemWrite, MemToReg,
    ALUSrcA, ALUSrcB,ALUOp, ExtOp, LuiOp,
    PCSrc,BranchOp,IsJump);
    //input 
	input [5:0] OpCode;
	input [5:0] Funct;
    //output
	output [1:0] PCSrc;
	output RegWrite,MemRead,MemWrite,ALUSrcA,ALUSrcB,ExtOp,LuiOp,IsJump;
	output [2:0] BranchOp;
	output [1:0] RegDst;
	output [1:0] MemToReg;
	output [3:0] ALUOp;
	
	assign PCSrc =
		(OpCode == 6'h02 || OpCode == 6'h03)? 2'b01://j jal
		(OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09))? 2'b10://jr jalr
		2'b00;//pc+4
			
	assign BranchOp =
		(OpCode == 6'h04)? 3'b001://beq
		(OpCode == 6'h05)? 3'b010://bne
		(OpCode == 6'h06)? 3'b011://blez
		(OpCode == 6'h07)? 3'b100://bgtz
		(OpCode == 6'h01)? 3'b101://bltz bgez
		3'b000;
	
	assign RegWrite =(~(OpCode == 6'h2b || OpCode == 6'h02 || OpCode == 6'h01 ||
	(OpCode >= 6'h04 && OpCode <= 6'h07) || (OpCode == 6'h00 && Funct == 6'h08)));//
	
	assign RegDst[1:0] =
		(OpCode == 6'h03|| (OpCode == 6'h00 && Funct == 6'h09))? 2'b10://jal jalr -$ra
        (OpCode == 6'h0) ? 2'b01 :2'b00;//R-rd default-rt
	
	assign MemRead = OpCode == 6'h23 ;//lw
	
	assign MemWrite = OpCode == 6'h2b;//sw
	
	assign MemToReg[1:0] = (OpCode == 6'h23)? 2'b01://lw
		(OpCode == 6'h03 || (OpCode == 6'h00 && Funct == 6'h09))? 2'b10: //pc+4
		2'b00;//aluResult
	
	assign ALUSrcA = OpCode == 6'h00 && (Funct == 6'h00 || Funct == 6'h02 || Funct == 6'h03);//sll srl sra--1 others--0
	
	assign ALUSrcB = ~(OpCode == 6'h0);//R-0
	
	assign ExtOp = (OpCode != 6'h0 && OpCode != 6'h0c && OpCode != 6'h0d && OpCode != 6'h0e);//
	assign LuiOp = OpCode == 6'h0f;// lui $rt=imm << 16
	
	assign ALUOp[2:0] = (OpCode == 6'h0d)? 3'b001://ori
	(OpCode == 6'h00)? 3'b010://R 
    (OpCode == 6'h0e)? 3'b011://xori
	(OpCode == 6'h0c)? 3'b100://andi
	(OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101://slti sltiu 
	3'b000;//add
		
	assign ALUOp[3] = OpCode[0];//
	assign IsJump = (OpCode == 6'h2) || (OpCode == 6'h3) ||//j jal
       ((OpCode == 6'h0) && (Funct == 6'h8 || Funct == 6'h9));//jr jalr
endmodule