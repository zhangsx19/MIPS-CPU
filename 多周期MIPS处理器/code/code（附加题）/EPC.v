`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/22 14:32:43
// Design Name: 
// Module Name: EPC
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


module EPCReg(reset, clk, EPCWrite, EPC_i, EPC_o);
    //Input Clock Signals
    input reset;             
    input clk;
    //Input Control Signals             
    input EPCWrite;
    //Input PC             
    input [31:0] EPC_i;
    //Output PC  
    output reg [31:0] EPC_o; 


    always@(posedge reset or posedge clk)
    begin
        if(reset) begin
            EPC_o <= 0;
        end else if (EPCWrite) begin
            EPC_o <= EPC_i;
        end else begin
            EPC_o <= EPC_o;
        end
    end
endmodule
