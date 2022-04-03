module clk_divider (clk_in,reset,clk_out);
input clk_in,reset;
output reg clk_out;
reg [25:0] cnt;
always @(posedge reset or posedge clk_in)
begin
    if(reset) begin
    cnt<=26'b0;
    clk_out=0;
    end
    else if(cnt==26'b10_1111_1010_1111_0000_0111_1111)//10^8/2-1 26'b10_1111_1010_1111_0000_0111_1111
    begin
        cnt<=0;
        clk_out=~clk_out;
    end
    else
    cnt<=cnt+1;
end
endmodule
