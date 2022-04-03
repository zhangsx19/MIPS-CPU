`timescale 1ns / 1ps
module HazardCheck (reset,BranchOrnot,IsJump,
ID_EX_MemRead,ID_EX_Rt,IF_ID_Rs,IF_ID_Rt,
EX_DM_MemRead,EX_DM_Write_register,
EX_Stall,IF_ID_Flush,ID_EX_Flush);
input BranchOrnot, IsJump, ID_EX_MemRead, EX_DM_MemRead,reset;
input [4: 0] ID_EX_Rt, IF_ID_Rs, IF_ID_Rt,EX_DM_Write_register;
output EX_Stall, IF_ID_Flush, ID_EX_Flush;
// Load Use Hazard 
wire EX_Stall, DM_Stall; // EX_Stall for lw, and DM_Stall for lw -> jr/branch
assign EX_Stall = reset ? 1'b0 :
ID_EX_MemRead &&(ID_EX_Rt == IF_ID_Rs ||ID_EX_Rt == IF_ID_Rt);//current is ID ,last is lw
//øÿ÷∆√∞œ’beq j
assign IF_ID_Flush = reset ? 1'b0 : (IsJump || BranchOrnot);
assign ID_EX_Flush = reset ? 1'b0 : BranchOrnot||EX_Stall;
endmodule
