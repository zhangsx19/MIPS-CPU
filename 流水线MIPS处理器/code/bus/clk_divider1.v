module clk_divider1 (clk_in,reset,clk_out);
input clk_in,reset;
output reg clk_out;
reg [12:0] cnt;
always @(posedge reset or posedge clk_in)
begin
    if(reset) begin
    cnt<=13'b0;
    clk_out=0;
    end
    else if(cnt==13'b1001110000111)
    begin
        cnt<=0;
        clk_out=~clk_out;
    end
    else
    cnt<=cnt+1;
end
endmodule
