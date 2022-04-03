`timescale  1ns / 1ps
module EXForward (EX_DM_Write_register,DM_WB_Write_register,EX_DM_RegWrite,DM_WB_RegWrite,
ID_EX_Rs,ID_EX_Rt,
EX_Forward_1,EX_Forward_2);
input EX_DM_RegWrite, DM_WB_RegWrite;
input [4: 0] EX_DM_Write_register, DM_WB_Write_register, ID_EX_Rs, ID_EX_Rt;
output [1: 0] EX_Forward_1, EX_Forward_2;//forward rs /rt
// 01 from EX/DM  10 from DM/WB
assign EX_Forward_1 = (EX_DM_RegWrite &&(EX_DM_Write_register != 5'h00) &&(EX_DM_Write_register == ID_EX_Rs))? 2'b01://last R
(DM_WB_RegWrite &&(DM_WB_Write_register != 5'h00) &&(DM_WB_Write_register == ID_EX_Rs))? 2'b10//last last R or lw
: 2'b00;
assign EX_Forward_2 =(EX_DM_RegWrite &&(EX_DM_Write_register != 5'h00) &&(EX_DM_Write_register == ID_EX_Rt))? 2'b01://last R
(DM_WB_RegWrite &&(DM_WB_Write_register != 5'h00) &&(DM_WB_Write_register == ID_EX_Rt))? 2'b10//last last R or lw 
: 2'b00;
endmodule
