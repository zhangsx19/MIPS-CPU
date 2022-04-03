`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/22 14:45:30
// Design Name: 
// Module Name: ErrorTarget
// Project Name: 
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


module ErrorTargetReg(reset, clk, ErrorTargetWrite, ErrorTarget_i, ErrorTarget_o);
    //Input Clock Signals
    input reset;             
    input clk;
    //Input Control Signals             
    input ErrorTargetWrite;
    //Input PC             
    input [4:0] ErrorTarget_i;
    //Output PC  
    output reg [4:0] ErrorTarget_o; 


    always@(posedge reset or posedge clk)
    begin
        if(reset) begin
            ErrorTarget_o <= 0;
        end else if (ErrorTargetWrite) begin
            ErrorTarget_o <= ErrorTarget_i;
        end else begin
            ErrorTarget_o <= ErrorTarget_o;
        end
    end
endmodule

