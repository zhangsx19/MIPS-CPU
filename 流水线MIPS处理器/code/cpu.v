module CPU(reset, clk, Rx_Serial, leds, bcd7, Tx_Serial);
input reset, clk, Rx_Serial;
output [7:0] leds;
output [11:0] bcd7;
output Tx_Serial;
//clk divider
    //wire clk;
    //clk_divider hd(sys_clk_in,reset,clk);
//IF
//pc reg
wire [31: 0] PC, PC_next,jump_target, branch_target, jr_target, PC_4;
wire PCWrite,BranchOrnot,EX_Stall;
wire [1: 0] PCSrc;
assign PC_4 = {PC[31], PC[30:0] + 31'd4};//adder
assign PCWrite = ~EX_Stall;
assign PC_next = BranchOrnot ? branch_target :
       (PCSrc == 2'b00) ? PC_4 :
       (PCSrc == 2'b01) ? jump_target :
       (PCSrc == 2'b10) ? jr_target :PC_4;
PC_reg PC1(.reset(reset),.clk(clk),.PCWrite(PCWrite),.PC_i(PC_next),.PC_o(PC));
//instruction memory
wire [31: 0] Instruction;
InstructionMemory InstructionMemory1(.Address(PC),.Instruction(Instruction));
//IF/ID reg
wire IF_ID_Flush;
reg [31:0]IF_ID_Instruction,IF_ID_PC_4;
always @(posedge clk or posedge reset)
  begin
    if (reset)
      begin
        IF_ID_Instruction <= 32'h0;
        IF_ID_PC_4 <= 32'h0;
      end
    else if(~EX_Stall)
      begin
        IF_ID_Instruction <= IF_ID_Flush ? 32'h0 : Instruction;
        IF_ID_PC_4 <= PC_4;
      end
  end
//ID
//jump
assign jump_target = {IF_ID_PC_4[31: 28], IF_ID_Instruction[25: 0], 2'b00};
//controller
wire IsJump,RegWrite,MemRead,MemWrite,ALUSrcA,ALUSrcB,ExtOp,LuiOp;
wire [2: 0] ID_BranchOp;
wire [1: 0] ID_RegDst,MemToReg;
wire [3: 0] ALUOp;
controller controller1(.OpCode(IF_ID_Instruction[31: 26]),.Funct(IF_ID_Instruction[5: 0]),
.PCSrc(PCSrc),.BranchOp(ID_BranchOp),.IsJump(IsJump),
.RegWrite(RegWrite),.RegDst(ID_RegDst),.MemRead(MemRead),.MemWrite(MemWrite),.MemToReg(MemToReg),
.ALUSrcA(ALUSrcA),.ALUSrcB(ALUSrcB),.ALUOp(ALUOp),.ExtOp(ExtOp),.LuiOp(LuiOp));
//extend and shift
wire [31: 0] ExtendOrShift_Imm;
assign ExtendOrShift_Imm = LuiOp?{IF_ID_Instruction[15 : 0], 16'b0}:
(ExtOp ?{{17{IF_ID_Instruction[15]}}, IF_ID_Instruction[14 : 0]}: {16'b0, IF_ID_Instruction[15 : 0]});
// Hazard Unit
wire ID_EX_Flush;
reg ID_EX_MemRead;
reg [4:0] ID_EX_Rt;
reg [4:0] EX_DM_Write_register;
reg EX_DM_MemRead;
HazardCheck HazardCheck1(.reset(reset),.BranchOrnot(BranchOrnot),.IsJump(IsJump),
.ID_EX_MemRead(ID_EX_MemRead),.ID_EX_Rt(ID_EX_Rt),.IF_ID_Rs(IF_ID_Instruction[25: 21]),.IF_ID_Rt(IF_ID_Instruction[20: 16]),
.EX_DM_MemRead(EX_DM_MemRead),.EX_DM_Write_register(EX_DM_Write_register),
.EX_Stall(EX_Stall),.IF_ID_Flush(IF_ID_Flush),.ID_EX_Flush(ID_EX_Flush));
//RegisterFiles
wire [31: 0] rsData, rtData;
reg [31:0] DM_WB_Write_data;
reg [4: 0] DM_WB_Write_register;
reg DM_WB_RegWrite;
RegisterFiles RegisterFiles1(.reset(reset), .clk(clk), .RegWrite(DM_WB_RegWrite), 
.Read_register1(IF_ID_Instruction[25: 21]),.Read_register2(IF_ID_Instruction[20: 16]), .Write_register(DM_WB_Write_register), 
.Write_data(DM_WB_Write_data), .Read_data1(rsData), .Read_data2(rtData));
// ID Forward
wire ID_isForward;
reg EX_DM_RegWrite;
IDForward IDForward1(.EX_DM_Write_register(EX_DM_Write_register),.EX_DM_RegWrite(EX_DM_RegWrite),.IF_ID_Rs(IF_ID_Instruction[25: 21]),
.IF_ID_Rt(IF_ID_Instruction[20: 16]),.ID_isForward(ID_isForward));
wire [31: 0] rs_data_forward_id;
reg [31: 0] EX_DM_ALUresult;
assign rs_data_forward_id =(ID_isForward) ? EX_DM_ALUresult:rsData;
// jr target
assign jr_target = rs_data_forward_id;
//ID/EX reg
reg ID_EX_ALUSrcA,ID_EX_ALUSrcB,ID_EX_RegWrite,ID_EX_MemWrite;
reg [31:0] ID_EX_PC_4,ID_EX_rsData,ID_EX_rtData,ID_EX_ExtendOrShift_Imm;
reg [2: 0] ID_EX_BranchOp;
reg [4: 0] ID_EX_Rs,ID_EX_Rd,ID_EX_Shamt;
reg [5: 0] ID_EX_Funct;
reg [1: 0] ID_EX_RegDst,ID_EX_MemToReg;
reg [3: 0] ID_EX_ALUOp;
always @(posedge clk or posedge reset)
  begin
    if (reset)
      begin
        ID_EX_PC_4 <= 32'h0;
        ID_EX_rsData <= 32'h0;
        ID_EX_rtData <= 32'h0;
        ID_EX_ExtendOrShift_Imm <= 32'h0;
        ID_EX_Rs <= 5'h0;
        ID_EX_Rt <= 5'h0;
        ID_EX_Rd <= 5'h0;
        ID_EX_Shamt <=5'h0;
        ID_EX_Funct <=6'h0;
        ID_EX_ALUOp <= 4'h0;
        ID_EX_BranchOp <= 3'b0;
        ID_EX_ALUSrcA <= 3'b0;
        ID_EX_ALUSrcB <=3'b0;
        ID_EX_RegDst <= 2'b0;
        ID_EX_MemToReg <= 2'b0;
        ID_EX_MemWrite <= 1'b0;
        ID_EX_MemRead <= 1'b0;
        ID_EX_RegWrite <= 1'b0;
      end
    else
      begin
        ID_EX_PC_4 <= IF_ID_PC_4;
        ID_EX_rsData <= rs_data_forward_id;
        ID_EX_rtData <= rtData;
        ID_EX_ExtendOrShift_Imm <= ExtendOrShift_Imm;
        ID_EX_Rs <= IF_ID_Instruction[25: 21];
        ID_EX_Rt <= IF_ID_Instruction[20: 16];
        ID_EX_Rd <= IF_ID_Instruction[15: 11];
        ID_EX_Shamt <= IF_ID_Instruction[10:6];
        ID_EX_Funct <= IF_ID_Instruction[5:0];
        ID_EX_ALUOp <= ALUOp;
        ID_EX_BranchOp <= ID_BranchOp;
        ID_EX_ALUSrcA <= ALUSrcA;
        ID_EX_ALUSrcB <= ALUSrcB;
        ID_EX_RegDst <= ID_RegDst;
        ID_EX_MemToReg <= MemToReg;
        ID_EX_MemWrite <= ID_EX_Flush ? 1'b0 : MemWrite;
        ID_EX_MemRead <= ID_EX_Flush ? 1'b0 : MemRead;
        ID_EX_RegWrite <= ID_EX_Flush ? 1'b0 : RegWrite;
      end
  end
//EX
//ALUcontroller
wire Sign;
wire [4:0] ALUConf;
ALUcontroller ALUcontroller1(.ALUOp(ID_EX_ALUOp), .Funct(ID_EX_Funct), .ALUConf(ALUConf), .Sign(Sign));
//ALU
wire [31: 0] ALUresult,ALUIn1, ALUIn2;
wire Zero,overflow;//beq not compare in alu
wire [31: 0] rs_data_forward_ex, rt_data_forward_ex;
assign ALUIn1 = ID_EX_ALUSrcA ? ID_EX_Shamt :rs_data_forward_ex;
assign ALUIn2 = ID_EX_ALUSrcB ? ID_EX_ExtendOrShift_Imm : rt_data_forward_ex;
ALU ALU1(.ALUConf(ALUConf),.Sign(Sign),.In1(ALUIn1),.In2(ALUIn2),.Zero(Zero),.Result(ALUresult),.overflow(overflow));
//Branch 
assign branch_target = ID_EX_PC_4 + {ID_EX_ExtendOrShift_Imm[29: 0], 2'b00};//adder and shifter
BranchComp BranchComp1(.In1(rs_data_forward_ex),.In2(rt_data_forward_ex),.BranchOp(ID_EX_BranchOp),
.bgezOrbltz(ID_EX_Rt),.BranchOrnot(BranchOrnot));
//EXForward
wire [1: 0] EX_Forward_1, EX_Forward_2;
EXForward EXForward1(.EX_DM_Write_register(EX_DM_Write_register),.DM_WB_Write_register(DM_WB_Write_register),
.EX_DM_RegWrite(EX_DM_RegWrite),.DM_WB_RegWrite(DM_WB_RegWrite),
.ID_EX_Rs(ID_EX_Rs),.ID_EX_Rt(ID_EX_Rt),
.EX_Forward_1(EX_Forward_1),.EX_Forward_2(EX_Forward_2));
//EX/DM reg
// RegDst mux-EX_DM_Write_register
wire [4: 0] Write_register;
assign Write_register = ID_EX_RegDst == 2'b01 ? ID_EX_Rd :
ID_EX_RegDst == 2'b00 ? ID_EX_Rt: 5'd31 ;
reg [31:0] EX_DM_PC_4,EX_DM_rtData;
reg [1: 0] EX_DM_MemToReg;
reg EX_DM_MemWrite;
always @(posedge clk or posedge reset)
  begin
    if (reset)
      begin
        EX_DM_PC_4 <= 32'h0;
        EX_DM_ALUresult <= 32'h0;
        EX_DM_rtData <= 32'h0;
        EX_DM_Write_register <= 5'h0;
        EX_DM_MemToReg <= 2'h0;
        EX_DM_MemWrite <= 1'b0;
        EX_DM_MemRead <= 1'b0;
        EX_DM_RegWrite <= 1'b0;
      end
    else
      begin
        EX_DM_PC_4 <= ID_EX_PC_4;
        EX_DM_ALUresult <= ALUresult;
        EX_DM_rtData <= rt_data_forward_ex;
        EX_DM_Write_register <= Write_register;
        EX_DM_MemToReg <= ID_EX_MemToReg;
        EX_DM_MemWrite <= ID_EX_MemWrite;
        EX_DM_MemRead <= ID_EX_MemRead;
        EX_DM_RegWrite <= ID_EX_RegWrite;
      end
  end



assign rs_data_forward_ex = (EX_Forward_1 == 2'b01) ? EX_DM_ALUresult :
(EX_Forward_1 == 2'b10) ? DM_WB_Write_data:
ID_EX_rsData;
assign rt_data_forward_ex = (EX_Forward_2 == 2'b01) ? EX_DM_ALUresult :
(EX_Forward_2 == 2'b10) ? DM_WB_Write_data :
ID_EX_rtData;
//DM
//bus
wire [31: 0] MemData;
Bus bus(.clk(clk),.reset(reset),.MemRead(EX_DM_MemRead),.MemWrite(EX_DM_MemWrite),
.Address(EX_DM_ALUresult),.Write_data(EX_DM_rtData),.Read_data(MemData),.bcd7(bcd7),.leds(leds),
.Rx_Serial(Rx_Serial),.Tx_Serial(Tx_Serial));

//DM/WB reg
// MemToReg mux-DM_WB_Write_data
wire [31: 0] Write_data;

assign Write_data = (EX_DM_MemToReg == 2'b10) ?EX_DM_PC_4 :
(EX_DM_MemToReg == 2'b01) ? MemData :EX_DM_ALUresult;
always @(posedge clk or posedge reset)
  begin
    if (reset)
      begin
        DM_WB_Write_data <= 32'b0;
        DM_WB_Write_register <= 5'b0;
        DM_WB_RegWrite <= 1'b0;
      end
    else
      begin
        DM_WB_Write_data <= Write_data;
        DM_WB_Write_register <= EX_DM_Write_register;
        DM_WB_RegWrite <= EX_DM_RegWrite;
      end
  end
 endmodule