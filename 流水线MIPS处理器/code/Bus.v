module Bus (clk,reset,MemRead,MemWrite,
Address,Write_data,Read_data,
bcd7,leds,Rx_Serial,Tx_Serial);
input clk, reset, MemRead, MemWrite, Rx_Serial;
input [31: 0] Address, Write_data;
output [31: 0] Read_data;
output [11: 0] bcd7;
output [7:0] leds;
output Tx_Serial;
//in turns 
wire clk1;
clk_divider1 hd1(clk,reset,clk1);
wire [3:0] an;
fourbitcter fourbitcter1(clk1,reset,an);
//DataMemory
wire EN_DataMemory;
assign EN_DataMemory = Address <= 32'h000007ff&&Address>=32'h00000000;
wire [31:0] Mem_data;
DataMemory DataMemory1(.reset(reset), .clk(clk), .Address(Address), 
.Write_data(Write_data), .MemRead(MemRead && EN_DataMemory), .MemWrite(MemWrite && EN_DataMemory), .Mem_data(Mem_data));
//LED
    LED LED1(.clk(clk),.reset(reset),.LEDctrl(MemWrite && Address == 32'h4000000c),.ledin(Write_data[7:0]),.led(leds));
// bcd
wire [6:0]bcd7out;
bcd7 bcd7_1(.clk(clk),.reset(reset),.bcd7ctrl(MemWrite && Address == 32'h40000010),.bcd7in(Write_data[15:0]),.an(an),.dout(bcd7out));
assign bcd7={an,1'b0,bcd7out};
//uart
wire UART_CON_read;
wire UART_RXD_read;
wire UART_TXD_write;
assign UART_TXD_write = Address == 32'h40000018&&MemWrite;
assign UART_RXD_read = Address == 32'h4000001C&&MemRead;
assign UART_CON_read = Address == 32'h40000020&&MemRead;
/*--------------------------------UART RX-------------------------*/
wire Rx_DV;
wire [7:0] Rx_Byte;
parameter CLKS_PER_BIT = 16'd10417; 
uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst
        (.i_Clock(clk),
         .i_Rx_Serial(Rx_Serial),
         .o_Rx_DV(Rx_DV),
         .o_Rx_Byte(Rx_Byte)
         );
wire [31:0] UART_RXD;
assign UART_RXD = {24'b0,Rx_Byte};
//read data
assign Read_data = EN_DataMemory?Mem_data:
UART_RXD_read?(UART_CON[3]?UART_RXD:32'hffffffff)
:32'b0;

 /*--------------------------------UART TX-------------------------*/
wire Tx_Active;//1表示处于发送状态，0表示不在
wire Tx_Done;
uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst
        (.i_Clock(clk),
         .i_Tx_DV(UART_TXD_write),
         .i_Tx_Byte(Write_data[7:0]),
         .o_Tx_Active(Tx_Active),
         .o_Tx_Serial(Tx_Serial),
         .o_Tx_Done(Tx_Done)
         );
/*--------------------------------UART_CON-------------------------*/
reg [31:0] UART_CON;
always@(posedge reset or posedge clk)
begin
        if(reset) UART_CON <= 32'b0;   
        else begin 
            UART_CON[4] = Tx_Active;
            if (UART_CON_read) UART_CON[3:2] <= 2'b00;
            else begin 
                if(Rx_DV) UART_CON[3]=1'b1;//recv done (最后一条存进的指令不会跟清空UART_CON的指令)
                if(Tx_Done) UART_CON[2]=1'b1;
            end
        end
end
endmodule
