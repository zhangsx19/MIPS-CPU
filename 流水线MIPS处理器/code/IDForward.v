`timescale  1ns / 1ps
module IDForward (EX_DM_Write_register,EX_DM_RegWrite,IF_ID_Rs,IF_ID_Rt,ID_isForward);
input EX_DM_RegWrite;
input [4: 0] EX_DM_Write_register, IF_ID_Rs, IF_ID_Rt;
output ID_isForward;
// 0 ID/EX
// 1 forward EX/DM
assign ID_isForward =(EX_DM_RegWrite &&(EX_DM_Write_register != 5'h0) &&(EX_DM_Write_register == IF_ID_Rs));
//last last of jr and jalr is R
endmodule
