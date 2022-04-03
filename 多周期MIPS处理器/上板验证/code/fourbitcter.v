module fourbitcter(clk,reset,an);
input clk,reset;
output [3:0] an;
wire [3:0] an;
reg[1:0] state;
always @(posedge reset or posedge clk)
begin
    if(reset) state<=2'b00;
    else if(state==2'b11)state<=2'b00;
    else state<=state+1;    
end
assign	an=(state==2'b00)?4'b1000:
             (state==2'b01)?4'b0100:
             (state==2'b10)?4'b0010:
             (state==2'b11)?4'b0001:4'b0;
endmodule
