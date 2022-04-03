`timescale 1ns / 1ps
module ALU(ALUConf,Sign,In1,In2,Zero,Result,overflow);
    // Control Signals
    input [4:0] ALUConf;
    input Sign;
    // Input Data Signals
    input [31:0] In1;
    input [31:0] In2;
    // Output 
    output Zero;
    output overflow;
    output reg [31:0] Result;
    //Zero logic
    assign Zero = (Result == 0);//beq
    //overflow logic
    wire addflow;
    wire subflow;
    assign addflow=(In1[31]&&In2[31]&&~Result[31])||(~In1[31]&&~In2[31]&&Result[31]);
    assign subflow=(~In1[31]&&In2[31]&&Result[31])||(In1[31]&&~In2[31]&&~Result[31]);
    assign overflow=(ALUConf==5'b0)?addflow:((ALUConf==5'b00110)?subflow:0);

    //ALU logic
    wire [1:0]ss;
	assign ss = {In1[31], In2[31]};
	
	wire lt_31;
	assign lt_31 = (In1[30:0] < In2[30:0]);//same sign
	
	wire lt_signed;
	assign lt_signed = (In1[31] ^ In2[31])? 
		((ss == 2'b01)? 0: 1): lt_31;

    always @(*) begin
		case (ALUConf)
			5'b00000: Result <= In1 + In2;//add
			5'b00001: Result <= In1 | In2;//or
			5'b00010: Result <= In1 & In2;//and
			5'b00110: Result <= In1 - In2;//sub beq
			5'b00111: Result <= {31'h00000000, Sign? lt_signed: (In1 < In2)};//slt sltu
			5'b01100: Result <= ~(In1 | In2);//nor
			5'b01101: Result <= In1 ^ In2;//xor
			5'b10000: Result <= (In2 >> In1[4:0]);//srl
			5'b11000: Result <= ({{32{In2[31]}}, In2} >> In1[4:0]);//sra
            5'b11001: Result <= (In2 << In1[4:0]);//sll
            //5'b11010: Result<= In1&(~In2);//setsub
			default: Result <= 32'h00000000;
		endcase
    end

endmodule
