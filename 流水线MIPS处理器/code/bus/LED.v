`timescale  1ns / 1ps
module LED (clk,reset,LEDctrl,ledin,led);
input clk, reset, LEDctrl;
input [7: 0] ledin;
output reg [7: 0] led;

always @(posedge clk or posedge reset)
begin
    if (reset)
        led <= 8'h00;
    else
      if (LEDctrl) led <= ledin;
end
endmodule
