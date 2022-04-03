`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: InstAndDataMemory
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


module InstAndDataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	//Input Clock Signals
	input reset;
	input clk;
	//Input Data Signals
	input [31:0] Address;
	input [31:0] Write_data;
	//Input Control Signals
	input MemRead;
	input MemWrite;
	//Output Data
	output [31:0] Mem_data;
	
	parameter RAM_SIZE = 256;
	parameter RAM_SIZE_BIT = 8;
	parameter RAM_INST_SIZE = 32;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];

	//read data
	assign Mem_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	//write data
	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
		    // init instruction memory
            // jal机器码要减去0x00100000,beq不用
            RAM_data[8'd0] <= 32'h20040005;
            RAM_data[8'd1] <= 32'h00001026;
            RAM_data[8'd2] <= 32'h0c000004;
            RAM_data[8'd3] <= 32'h1000ffff;
            RAM_data[8'd4] <= 32'h23bdfff8;
            RAM_data[8'd5] <= 32'hafbf0004;
            RAM_data[8'd6] <= 32'hafa40000;
            RAM_data[8'd7] <= 32'h28880001;
            RAM_data[8'd8] <= 32'h11000002;
            RAM_data[8'd9] <= 32'h23bd0008;
            RAM_data[8'd10] <= 32'h03e00008;
            RAM_data[8'd11] <= 32'h00821020;
            RAM_data[8'd12] <= 32'h2084ffff;
            RAM_data[8'd13] <= 32'h0c000004;
            RAM_data[8'd14] <= 32'h8fa40000;
            RAM_data[8'd15] <= 32'h8fbf0004;
            RAM_data[8'd16] <= 32'h23bd0008;
            RAM_data[8'd17] <= 32'h00821020;
            RAM_data[8'd18] <= 32'h03e00008;
            //init instruction memory
            //reset data memory		  
			for (i = RAM_INST_SIZE - 1; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		end else if (MemWrite) begin
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
		end
	end

endmodule
