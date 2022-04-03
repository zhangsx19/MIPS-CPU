`timescale  1ns / 1ps
module BranchComp (In1,In2,BranchOp,bgezOrbltz,BranchOrnot);
input [31: 0] In1, In2;
input [2: 0] BranchOp;
input [4: 0] bgezOrbltz;
output reg BranchOrnot;
always @( * )
  begin
    case (BranchOp) 
      3'b101: BranchOrnot <= (bgezOrbltz == 5'b00001) ? ~In1[31]:(bgezOrbltz == 5'b0) ? In1[31] : 0;// bgez, bltz
      3'b001: BranchOrnot <= In1 == In2;// beq
      3'b010: BranchOrnot <= ~(In1 == In2);// bne
      3'b011: BranchOrnot <= In1[31] || ~(| In1);// blez
      3'b100: BranchOrnot <= ~(In1[31] || (| In1));// bgtz
      default:
        BranchOrnot <= 0;
    endcase
  end
endmodule
