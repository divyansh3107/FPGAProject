`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 03:56:30 PM
// Design Name: 
// Module Name: clock_file
// Project Name: 
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


module clk_25mhz(
    input clk,
    input reset,
    output reg new_clk_25
    );

reg [2:0] count;

initial begin 
new_clk_25=0;
count = 0;
end

always @ (posedge clk) begin
if (reset) begin
    new_clk_25<=0;
    count=0;
    end
else begin
 if (count == 1) begin 
    new_clk_25<= ~new_clk_25;
    count<= 0;
    end
 else begin
    count=count+1;
    end
end
end
endmodule
