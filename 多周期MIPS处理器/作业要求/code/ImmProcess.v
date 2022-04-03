`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: ImmProcess
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ImmProcess(ExtOp, LuiOp, Immediate, ImmExtOut, ImmExtShift); 
    //Input Control Signals
    input ExtOp; //'0'-zero extension, '1'-signed extension
    input LuiOp; //for lui instruction
    //Input
    input [15:0] Immediate;
    //Output
    output [31:0] ImmExtOut;
    output [31:0] ImmExtShift;

    wire [31:0] ImmExt;
    
    assign ImmExt = {ExtOp? {16{Immediate[15]}}: 16'h0000, Immediate};//有无符号拓展 
    //assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};
    assign ImmExtShift = ImmExt << 2;
    assign ImmExtOut = LuiOp? {Immediate, 16'h0000}: ImmExt;//lui指令和拓展立即数
    //assign LU_out = LuiOp? {Instruction[15:0], 16'h0000}: Ext_out;//立即数拓展


endmodule
