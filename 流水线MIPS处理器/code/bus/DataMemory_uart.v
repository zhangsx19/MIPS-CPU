module DataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	input reset, clk,MemRead, MemWrite;
	input [31:0] Address, Write_data;
	output [31:0] Mem_data;
	
	parameter RAM_SIZE = 69;//=2^RAM_SIZE_BIT+5个外�?
	parameter RAM_SIZE_BIT = 6;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	assign Mem_data = MemRead?(Address==32'h4000000C)?RAM_data[64]:
	(Address==32'h40000010)?RAM_data[65]:
	(Address==32'h40000018)?RAM_data[66]:
	(Address==32'h4000001C)?RAM_data[67]:
	(Address==32'h40000020)?RAM_data[68]:
	RAM_data[Address[RAM_SIZE_BIT + 1:2]]
	: 32'h00000000;
	
	integer i;
	always @(posedge reset or posedge clk)
		if (reset)
			for (i = 0; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		else if (MemWrite)begin
		    if (Address==32'h4000000C)RAM_data[64]<= Write_data;
		    else if (Address==32'h40000010)RAM_data[65] <= Write_data;
		    else if (Address==32'h40000018)RAM_data[66] <= Write_data;
		    else if (Address==32'h4000001C)RAM_data[67] <= Write_data;
		    else if (Address==32'h40000020)RAM_data[68] <= Write_data;
			else RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
	    end
endmodule
