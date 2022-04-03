module DataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	input reset, clk,MemRead, MemWrite;
	input [31:0] Address, Write_data;
	output [31:0] Mem_data;
	
	parameter RAM_SIZE = 64;//=2^RAM_SIZE_BIT
	parameter RAM_SIZE_BIT = 6;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	assign Mem_data = MemRead?RAM_data[Address[RAM_SIZE_BIT + 1:2]]:32'h00000000;
	
	initial begin
		RAM_data[0] <= 32'h09;
		RAM_data[1] <= 32'h0b;
		RAM_data[2] <= 32'h02;
		RAM_data[3] <= 32'h0c;
		RAM_data[4] <= 32'h01;
		RAM_data[5] <= 32'h0a;
		RAM_data[6] <= 32'h03;
		RAM_data[7] <= 32'h14;
		RAM_data[8] <= 32'h02;
		RAM_data[9] <= 32'h0f;
		RAM_data[10] <= 32'h01;
		RAM_data[11] <= 32'h08;
		RAM_data[12] <= 32'h01;
		RAM_data[13] <= 32'h0b;
		RAM_data[14] <= 32'h02;
		RAM_data[15] <= 32'h20;
		RAM_data[16] <= 32'h02;
		RAM_data[17] <= 32'h0f;
		RAM_data[18] <= 32'h03;
		RAM_data[19] <= 32'h0f;
		RAM_data[20] <= 32'h01;
		RAM_data[21] <= 32'h09;
		RAM_data[22] <= 32'h02;
		RAM_data[23] <= 32'h0a;
	end
	integer i;
	always @(posedge reset or posedge clk)
		if (reset)
			for (i = 32; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		else if (MemWrite)
		    RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
endmodule
