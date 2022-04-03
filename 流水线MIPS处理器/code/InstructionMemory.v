module InstructionMemory(Address, Instruction);
	input [31:0] Address;
	output reg [31:0] Instruction;
	always @(*)
		case (Address[9:2])
			8'd0: Instruction <= 32'h3c010000;
			8'd1: Instruction <= 32'h34300000;
			8'd2: Instruction <= 32'h8e080000;
			8'd3: Instruction <= 32'h8e090004;
			8'd4: Instruction <= 32'h22100008;
			8'd5: Instruction <= 32'h3c010000;
            8'd6: Instruction <= 32'h34310080;
            8'd7: Instruction <= 32'h20120000;
            8'd8: Instruction <= 32'h1249001c;
            8'd9: Instruction <= 32'h001250c0;
            8'd10: Instruction <= 32'h020a5820;
            8'd11: Instruction <= 32'h8d6c0000;
            8'd12: Instruction <= 32'h8d6d0004;
            8'd13: Instruction <= 32'h21130000;
            8'd14: Instruction <= 32'h06600014;
            8'd15: Instruction <= 32'h026ca82a;
            8'd16: Instruction <= 32'h12a00001;
            8'd17: Instruction <= 32'h08100020;
            8'd18: Instruction <= 32'h00137080;
            8'd19: Instruction <= 32'h022e7820;
            8'd20: Instruction <= 32'h026c5022;
            8'd21: Instruction <= 32'h000a5080;
            8'd22: Instruction <= 32'h022ac020;
            8'd23: Instruction <= 32'h8dea0000;
            8'd24: Instruction <= 32'h8f0b0000;
            8'd25: Instruction <= 32'h016dc820;
            8'd26: Instruction <= 32'h032ab02a;
            8'd27: Instruction <= 32'h16c00001;
            8'd28: Instruction <= 32'h0810001f;
            8'd29: Instruction <= 32'hadea0000;
            8'd30: Instruction <= 32'h08100020;
            8'd31: Instruction <= 32'hadf90000;
            8'd32: Instruction <= 32'h20010001;
            8'd33: Instruction <= 32'h02619822;
            8'd34: Instruction <= 32'h0810000e;
            8'd35: Instruction <= 32'h22520001;
            8'd36: Instruction <= 32'h08100008;
            8'd37: Instruction <= 32'h0008c880;
            8'd38: Instruction <= 32'h0239b820;
            8'd39: Instruction <= 32'h8ee20000;
            8'd40: Instruction <= 32'h3c014000;
            8'd41: Instruction <= 32'h34240010;
            8'd42: Instruction <= 32'hac820000;
            8'd43: Instruction <= 32'h08100028;
		endcase
endmodule