`timescale  1ns / 1ps
module bcd7 (clk,reset,bcd7ctrl,bcd7in,an,dout);
input clk, reset, bcd7ctrl;
input [3:0] an;
input [15: 0] bcd7in;
output wire[6:0] dout;
reg [15: 0]bcd7in_save;
always@(posedge reset or posedge clk)
begin
        if(reset) bcd7in_save <= 16'h0000;   
        else if (bcd7ctrl) bcd7in_save <= bcd7in;
end
wire [3:0] din;
assign din=(an==4'b1000)?bcd7in_save[15:12]:((an==4'b0100)?bcd7in_save[11:8]:((an==4'b0010)?bcd7in_save[7:4]:bcd7in_save[3:0]));
assign dout= (din==4'h0)?7'b0111111:
             (din==4'h1)?7'b0000110:
             (din==4'h2)?7'b1011011:
             (din==4'h3)?7'b1001111:
             (din==4'h4)?7'b1100110:
             (din==4'h5)?7'b1101101:
             (din==4'h6)?7'b1111101:
             (din==4'h7)?7'b0000111:
             (din==4'h8)?7'b1111111:
             (din==4'h9)?7'b1101111:
             (din==4'ha)?7'b1110111:
             (din==4'hb)?7'b1111100:
             (din==4'hc)?7'b0111001:
             (din==4'hd)?7'b1011110:
             (din==4'he)?7'b1111001:
             (din==4'hf)?7'b1110001:7'b0;

endmodule

