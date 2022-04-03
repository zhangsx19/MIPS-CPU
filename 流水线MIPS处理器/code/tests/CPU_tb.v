`timescale 1ns/1ps
`define PERIOD 10
module CPU_tb();
reg reset;
reg clk;
wire [7:0] leds;
wire [11:0] digits;
reg Rx_Serial;
wire Tx_Serial;
parameter CLKS_PER_BIT = 16'd10417;
parameter MEM_SIZE = 64;
CPU cpu1(reset, clk, Rx_Serial, leds, digits, Tx_Serial);
reg delay=0;
initial begin
    reset = 1;
    clk = 1;
    Rx_Serial<=1;
    #100 reset = 0;
    #200 delay = 1;
end
//clock
always #(`PERIOD/2) clk = ~clk;
//uart 2 mem
reg [15:0] r_Clock_Count;
reg [9:0] data[11: 0];
reg [3:0] r_Bit_Index;
reg [3:0] i;
initial begin
    data[0]<=10'b1000001010;//最大重量为5
    data[1]<=10'b1000001010;//item_num=5
    data[2]<=10'b1000000100;//第一个物品重量2
    data[3]<=10'b1000011000;//第一个物品价值12
    data[4]<=10'b1000000010;//1
    data[5]<=10'b1000010100;//10
    data[6]<=10'b1000000110;//3
    data[7]<=10'b1000101000;//20
    data[8]<=10'b1000000100;//2
    data[9]<=10'b1000011110;//15
    data[10]<=10'b1000000010;//1
    data[11]<=10'b1000010000;//8
    r_Clock_Count<=16'b0;
    r_Bit_Index<=4'b0;
    i<=4'b0;
end
always @(posedge clk or posedge reset)
begin
    if(~reset&&delay&&i<12)begin
        if (r_Clock_Count < CLKS_PER_BIT-1) r_Clock_Count <= r_Clock_Count + 1;
        else begin
           r_Clock_Count <= 0;
           Rx_Serial<=data[i][r_Bit_Index];
           if(r_Bit_Index<9) r_Bit_Index = r_Bit_Index+1;
           else begin 
           r_Bit_Index=0;
           i=i+1;
           end
        end
    end
end
endmodule
