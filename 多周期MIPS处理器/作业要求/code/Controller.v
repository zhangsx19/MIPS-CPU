`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: Controller
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


module Controller(reset, clk, OpCode, Funct, 
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
    //Output Control Signals
    output reg PCWrite;
    output reg PCWriteCond;
    output reg IorD;
    output reg MemWrite;
    output reg MemRead;
    output reg IRWrite;
    output reg [1:0]MemtoReg;
    output reg [1:0] RegDst;
    output reg RegWrite;
    output reg ExtOp;
    output reg LuiOp;
    output reg [1:0] ALUSrcA;
    output reg [1:0] ALUSrcB;
    output reg [3:0] ALUOp;
    output reg [1:0] PCSource;
    
    //--------------Your code below-----------------------
    parameter [3:0] sIF = 4'b0000,sID = 4'b0001,sEXE1=4'b0010,sEXEB=4'b0011,sEXE2=4'b0100,sEXEJ=4'b0101,
    sMEM=4'b0110,sWB1=4'b0111,sWB2=4'b1000,sreset=4'b1001;
    //sIF和sID为自定义的parameter，分别用来指代取指令状态和指令解码状态
    reg [3:0]state;//state为3比特reg信号，用来指代当前状态
    always @(posedge reset or posedge clk) begin
     if (reset) begin
         state<=sreset;//跳到PC=0(首条指令）的IF阶段
         
     end 
     else begin
          case (state)
          sreset:state<=sIF;
          sIF: state <= sID;
          sID: begin
                    if ( OpCode == 6'h04)//beq
                        state <= sEXEB;
                    else if ( OpCode == 6'h23 || OpCode == 6'h2b)//sw,lw
                        state <= sEXE2;
                    else if ( OpCode == 6'h02 || OpCode == 6'h03 || (OpCode == 6'h0 &&(Funct==6'h08||Funct==6'h09)))
                    //j,jal,jr,jalr
                        state <= sEXEJ;
                    else 
                        state <= sEXE1;
                end
          sEXE1: state <= sWB1;
          sEXEB: state <= sIF;
          sEXEJ: state <= sIF;
          sEXE2:begin
                  if ( OpCode == 6'h0f)state <= sWB2;//lui
                  else state <= sMEM;
                end 
          sWB1: state <= sIF;
          sWB2: state <= sIF;
          sMEM: begin//lw sw
                  if ( OpCode == 6'h2b)state <= sIF;//sw
                  else state <= sWB2;  //lw
                end      
          endcase
     end
    end

    //PCSource
    always @(*) begin
        if (state == sIF) begin
            PCSource[1:0] = 2'b00;
        end else if (OpCode == 6'h04) begin 
            PCSource[1:0] = 2'b01;//beq
        end else if (OpCode == 6'h02|| OpCode == 6'h03) begin 
            PCSource[1:0] = 2'b10;//j jal
        end else if (OpCode == 6'h00&&(Funct == 6'h08|| Funct == 6'h09)) begin 
            PCSource[1:0] = 2'b11;//jr jalr
        end else begin
            PCSource[1:0] = 2'b00;
        end
    end
    //ALUSrcA
    wire Rtype1;
    assign Rtype1=OpCode==6'h00&&(Funct==6'h20||Funct==6'h21||Funct==6'h22||Funct==6'h23||Funct==6'h24||Funct==6'h25
    ||Funct==6'h26||Funct==6'h27||Funct==6'h2a||Funct==6'h2b||Funct==6'h08||Funct==6'h09||Funct==6'h28);
    always @(*) begin
        if (state == sIF|| state == sID) begin
            ALUSrcA[1:0] = 2'b00;
        end else if (OpCode == 6'h00&&(Funct == 6'h00|| Funct == 6'h02|| Funct == 6'h03)) begin 
            ALUSrcA[1:0] = 2'b10;//sll sra srl
         end else if (Rtype1) begin 
            ALUSrcA[1:0] = 2'b01;
        end else begin
            ALUSrcA[1:0] = 2'b01;
        end
    end
    //ALUSrcB
    wire Itype;
    assign Itype=(OpCode==6'h23||OpCode==6'h2b||OpCode==6'h0f||OpCode==6'h08||OpCode==6'h09||OpCode==6'h0c||OpCode==6'h0a||
    OpCode==6'h0b);
    always @(*) begin
        if (state == sIF) begin
            ALUSrcB[1:0] = 2'b01;
        end else if (state == sID) begin 
            ALUSrcB[1:0] = 2'b11;
        end else if (Itype) begin 
            ALUSrcB[1:0] = 2'b10;
        end else begin
            ALUSrcB[1:0] = 2'b00;
        end
    end
    //ExtOp
    always @(*) begin
        if (state == sID) begin
            ExtOp = 1;
        end else if (OpCode == 6'h0c) begin 
            ExtOp = 0;
        end else begin
            ExtOp =1;
        end
    end
    //LuiOp
    always @(*) begin
        if (state == sIF) begin
            LuiOp = 0;
        end else if (OpCode == 6'h0f) begin 
            LuiOp = 1;
        end else begin
            LuiOp =0;
        end
    end
    //RegWrite
    always @(*) begin
        if (state==sWB1||state==sWB2) begin
            RegWrite = 1;
        end else if (state == sID&&(OpCode == 6'h03||(OpCode == 6'h00&&Funct==6'h09))) begin 
            RegWrite = 1;//jalr jal
        end else begin
            RegWrite =0;
        end
    end
    //RegDst 
    wire Rdtype;
    assign Rdtype=OpCode==6'h00&&(Funct==6'h20||Funct==6'h21||Funct==6'h22||Funct==6'h23||Funct==6'h24||Funct==6'h25
    ||Funct==6'h26||Funct==6'h27||Funct==6'h2a||Funct==6'h2b||Funct==6'h00||Funct==6'h02||Funct==6'h03||Funct==6'h09
    ||Funct==6'h28);
    always @(*) begin
        if (Rdtype) begin
            RegDst = 2'b01;//rd
        end else if (state == sID&&OpCode == 6'h03) begin 
            RegDst = 2'b10;// jal $ra
        end else begin
            RegDst =2'b0;//rt
        end
    end
    //MemtoReg
    always @(*) begin
        if (state==sWB1) begin
            MemtoReg = 2'b01;//ALUOUT
        end else if (state == sID&&(OpCode == 6'h03||(OpCode == 6'h00&&Funct==6'h09))) begin 
            MemtoReg = 2'b10;// PC+4
        end else begin
            MemtoReg =2'b00;//MDR
        end
    end
    //IRWrite
    always @(*) begin
        if (state==sIF) begin
            IRWrite = 1;
        end else begin
            IRWrite =0;
        end
    end
    //MemRead
    always @(*) begin
        if (state==sIF||(state==sMEM&&OpCode == 6'h23)) begin
            MemRead = 1;//lw
        end else begin
            MemRead =0;
        end
    end
    //MemWrite
    always @(*) begin
        if (state==sMEM&&OpCode == 6'h2b) begin
            MemWrite = 1;//sw
        end else begin
            MemWrite =0;
        end
    end
    //IorD
    always @(*) begin
        if (state==sMEM) begin
            IorD = 1;//sw or lw
        end else begin
            IorD =0;
        end
    end
    //PCWriteCond
    always @(*) begin
        if (state==sEXEB&&OpCode == 6'h04) begin
            PCWriteCond = 1;//beq Branch complete
        end else begin
            PCWriteCond =0;
        end
    end
    //PCWrite
    always @(*) begin
        if (state==sIF||state==sEXEJ) begin
            PCWrite = 1;
        end else begin
            PCWrite =0;
        end
    end
    //--------------Your code above-----------------------
    

    //ALUOp
    always @(*) begin
        ALUOp[3] = OpCode[0];
        if (state == sIF || state == sID) begin
            ALUOp[2:0] = 3'b000;//ALUOp=3'b000: ALUConf <= aluADD;
        end else if (OpCode == 6'h00) begin 
            ALUOp[2:0] = 3'b010;//have Funct
        end else if (OpCode == 6'h04) begin
            ALUOp[2:0] = 3'b001;//beq
        end else if (OpCode == 6'h0c) begin
            ALUOp[2:0] = 3'b100;//andi
        end else if (OpCode == 6'h0a || OpCode == 6'h0b) begin
            ALUOp[2:0] = 3'b101;//slti
        end else begin
            ALUOp[2:0] = 3'b000;
        end
    end
    
endmodule