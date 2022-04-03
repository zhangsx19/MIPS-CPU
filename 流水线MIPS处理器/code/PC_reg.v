`timescale 1ns / 1ps
module PC_reg(reset, clk, PCWrite, PC_i, PC_o);
    //Input Clock Signals
    input reset;             
    input clk;
    //Input Control Signals             
    input PCWrite;
    //Input PC             
    input [31:0] PC_i;
    //Output PC  
    output reg [31:0] PC_o; 

    always@(posedge reset or posedge clk)
    begin
        if(reset) PC_o <= 32'h00400000;   
        else if (PCWrite) PC_o <= PC_i;  
    end
endmodule