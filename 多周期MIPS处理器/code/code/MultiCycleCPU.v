`timescale 1ns / 1ps
module MultiCycleCPU (reset, clk);
    //Input Clock Signals
    input reset;
    input clk;
    //--------------Your code below-----------------------
    //pc
    wire [31:0] PC;
	wire [31:0] PC_next;
	wire PCWrite;//pcдʹ��
	wire PCWriteCond;
	wire Zero;//beq --alu output
	wire PCWrite_all;
	assign PCWrite_all=PCWrite||(PCWriteCond&&Zero);
	PC PC1(.reset(reset), .clk(clk), .PCWrite(PCWrite_all), .PC_i(PC_next), .PC_o(PC));
    //InstAndDataMemory
    wire [31:0] AData,BData;
    wire MemWrite;
    wire MemRead;
    wire [31:0] Read_data;
    wire [31:0] Mem_data;
    wire [31:0] Address;
    assign Address=(IorD==0)?PC:ALU_out;//PC��Ķ�·ѡ����
	InstAndDataMemory instruction_memory3(.reset(reset), .clk(clk), .Address(Address), .Write_data(BData),
	 .MemRead(MemRead), .MemWrite(MemWrite), .Mem_data(Mem_data));
	
	//instReg
	wire IRWrite;
	wire [5:0]  OpCode;
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;
    wire [4:0]  Shamt;
    wire [5:0]  Funct;
	InstReg InstReg1(.reset(reset), .clk(clk), .IRWrite(IRWrite), .Instruction(Mem_data), .OpCode(OpCode), .rs(rs), .rt(rt), .rd(rd),
	 .Shamt(Shamt), .Funct(Funct));
	 //MDR
	 wire [31:0] MDR; 
	 RegTemp MemoryReg(.reset(reset), .clk(clk), .Data_i(Mem_data), .Data_o(MDR));
	//controller
    wire IorD;
    wire [1:0]MemtoReg;
    wire [1:0]RegDst;
    wire RegWrite;
    wire ExtOp;
    wire LuiOp;
    wire [1:0]ALUSrcA;
    wire [1:0]ALUSrcB;
    wire [3:0]ALUOp;
    wire [1:0]PCSource;
	Controller Controller1(.reset(reset), .clk(clk), .OpCode(OpCode), .Funct(Funct),
                .PCWrite(PCWrite), .PCWriteCond(PCWriteCond), .IorD(IorD), .MemWrite(MemWrite), .MemRead(MemRead),
                .IRWrite(IRWrite), .MemtoReg(MemtoReg), .RegDst(RegDst), .RegWrite(RegWrite), .ExtOp(ExtOp), .LuiOp(LuiOp),
                .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .ALUOp(ALUOp), .PCSource(PCSource));
	//register file
	wire [4:0] Write_register;
	assign Write_register = (RegDst == 2'b00)? rt: (RegDst == 2'b01)? rd: 5'b11111;
	//$ra �Ĵ�����д��Ĵ���ǰ����·ѡ����
	wire [31:0] RFWrite_data, Read_data1, Read_data2;
	wire [31:0] ALU_out;
	RegisterFile register_file1(.reset(reset), .clk(clk), .RegWrite(RegWrite), 
		.Read_register1(rs), .Read_register2(rt), .Write_register(Write_register),
		.Write_data(RFWrite_data), .Read_data1(Read_data1), .Read_data2(Read_data2));
	//A B
	RegTemp AReg(.reset(reset), .clk(clk), .Data_i(Read_data1), .Data_o(AData));
	RegTemp BReg(.reset(reset), .clk(clk), .Data_i(Read_data2), .Data_o(BData));
	//immprocess
	wire [31:0] ImmExtOut;
    wire [31:0] ImmExtShift;
    wire [15:0] Immediate;
    assign Immediate={rd,Shamt,Funct};
	ImmProcess ImmProcess1(ExtOp, LuiOp, Immediate, ImmExtOut, ImmExtShift);
	//alu controller
	wire [4:0] ALUConf;
	wire Sign;
	ALUControl alu_control1(.ALUOp(ALUOp), .Funct(Funct), .ALUConf(ALUConf), .Sign(Sign));//�����ź�
	//alu
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [31:0] ALU_Result;
	assign ALU_in1 = (ALUSrcA==2'b10)? {27'b0, Shamt}: ((ALUSrcA==2'b01)?AData:PC);//ALU��һ����ǰ����·ѡ����
	assign ALU_in2 = (ALUSrcB==2'b11)?ImmExtShift: ((ALUSrcB==2'b10)?ImmExtOut: //ALU�ڶ�����ǰ����·ѡ����
	((ALUSrcB==2'b01)?4:BData));
	ALU alu1(.ALUConf(ALUConf), .Sign(Sign), .In1(ALU_in1), .In2(ALU_in2), .Zero(Zero), .Result(ALU_Result));
	RegTemp ALUOUTReg(.reset(reset), .clk(clk), .Data_i(ALU_Result), .Data_o(ALU_out));
	assign RFWrite_data=(MemtoReg==2'b10)?PC:((MemtoReg==2'b01)?ALU_out:MDR);//�Ĵ�����д������ǰ�Ķ�·ѡ����,ID�׶�PC+4д��$ra
	wire [31:0] Jump_target;
	wire [25:0] Jump_addr;
	assign Jump_addr={rs,rt,rd,Shamt,Funct};
	assign Jump_target = {PC[31:28], Jump_addr, 2'b00};//j�� PC����λ+addr+00
	assign PC_next = (PCSource == 2'b00)? ALU_Result: ((PCSource == 2'b01)?ALU_out:((PCSource == 2'b10)?Jump_target: AData));
	//�µ�PC����Դ��ѡ���ź�
    //--------------Your code above-----------------------

endmodule