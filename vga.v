`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:06 04/13/2010 
// Design Name: 
// Module Name:    counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
	input clk,
	input 	reset,
	input  [1:0] sel,
	output reg [3:0] red,
	output reg [3:0] green,
	output reg [3:0] blue,
	output reg	 hsync,
	output reg	 vsync
//	input	[7:0] sw
	
    );
//	localparam H_DISPLAY       = 640; // horizontal display area
//	localparam H_L_BORDER      =  48; // horizontal left border
//	localparam H_R_BORDER      =  16; // horizontal right border
//	localparam H_RETRACE       =  96; // horizontal retrace
//	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
//	localparam START_H_RETRACE = H_DISPLAY + H_R_BORDER;
//	localparam END_H_RETRACE   = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
//	localparam V_DISPLAY       = 480; // vertical display area
//	localparam V_T_BORDER      =  10; // vertical top border
//	localparam V_B_BORDER      =  33; // vertical bottom border
//	localparam V_RETRACE       =   2; // vertical retrace
//	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
//    localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
//	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;  
parameter hpixels = 12'd799;
parameter vlines = 12'd524;
parameter hbp = 12'd144;
parameter hfp = 12'd751;
parameter vbp = 12'd35;
parameter vfp = 12'd514;
parameter W = 256;
parameter H = 256;
wire [10:0] C1, R1;
wire [11:0] output_data;

reg [11:0] hc_new;
reg [9:0] hc;
reg [9:0] vc;
reg vidon;
reg spriteon;
reg vsenable;

always @ (posedge clk)
	if (reset || vsenable)	hc_new <= 0;
	else					hc_new <= hc_new + 1;

always@* hc = hc_new[11:2];
			
always@* vsenable = hc == hpixels - 1;
	
always @* hsync = hc > (127);

always @ (posedge clk)
	if (reset || vc_clr)	vc <= 0;
	else if (vsenable)		vc <= vc + 1;

assign vc_clr = vsenable & (vc == vlines - 1);

always@* vsync = vc > 2;

always @(*) vidon = ((hc < hfp) && (hc > hbp) && (vc < vfp) && (vc > vbp));



assign C1 = 11'd100;
assign R1 = 11'd100;


always @(*) spriteon = ((hc >= C1 + hbp) && (hc < C1 + hbp + W) && (vc >= R1 + vbp) && (vc < R1 + vbp + H));

always@(posedge clk)
	if(reset)	
		addr_cnt <= 0;
	else if((spriteon == 1) && (vidon == 1))
		addr_cnt <= addr_cnt + 1;

reg [11:0] pixel_buffer [0:8];
integer i;
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 9; i = i + 1)
            pixel_buffer[i] <= 0;
    end else if ((spriteon == 1) && (vidon == 1)) begin
        // Shift pixels to make room for new data
        pixel_buffer[0] <= pixel_buffer[1];
        pixel_buffer[1] <= pixel_buffer[2];
        pixel_buffer[2] <= output_data;  // New pixel data
        pixel_buffer[3] <= pixel_buffer[4];
        pixel_buffer[4] <= pixel_buffer[5];
        pixel_buffer[5] <= pixel_buffer[0];
        pixel_buffer[6] <= pixel_buffer[7];
        pixel_buffer[7] <= pixel_buffer[8];
        pixel_buffer[8] <= pixel_buffer[3];
    end
end

// Averaging Filter
wire [11:0] avg_data;
assign avg_data = (
    pixel_buffer[0] + pixel_buffer[1] + pixel_buffer[2] +
    pixel_buffer[3] + pixel_buffer[4] + pixel_buffer[5] +
    pixel_buffer[6] + pixel_buffer[7] + pixel_buffer[8]
) / 9;
	
wire [3:0] gray;
assign gray = (output_data[11:8] * 3 + output_data[7:4] * 6 + output_data[3:0] * 1) / 10;


wire [3:0] gray2[0:8];
generate
    genvar j;
    for (j = 0; j < 9; j = j + 1) begin
        assign gray2[j] = (pixel_buffer[j][11:8] * 3 + pixel_buffer[j][7:4] * 6 + pixel_buffer[j][3:0] * 1) / 10;
    end
endgenerate

// Sobel Gx and Gy calculations
wire signed [7:0] Gx;
wire signed [7:0] Gy;

assign Gx = gray2[2] - gray[20]
          + (gray2[5] << 1) - (gray2[3] << 1)
          + gray2[8] - gray2[6];

assign Gy = gray2[0] + (gray2[1] << 1) + gray2[2]
          - gray2[6] - (gray2[7] << 1) - gray2[8];

// Edge intensity (magnitude approximation)
wire [7:0] edge_intensity;
assign edge_intensity = (Gx > 0 ? Gx : -Gx) + (Gy > 0 ? Gy : -Gy);


always @(*)
	begin
		red = 0;
		green = 0;
		blue = 0;
		if (sel== 2'b00) begin
		
		if ((spriteon == 1) && (vidon == 1))
			begin
				blue 	= output_data[3:0];
				green 	= output_data[7:4];
				red	= output_data[11:8];
			end
			end
	   else if(sel==2'b01) begin
	   
	   if ((spriteon == 1) && (vidon == 1)) begin
        blue = avg_data[3:0];
        green = avg_data[7:4];
        red = avg_data[11:8];
    end
	   end
	else if (sel==2'b10) begin
	if ((spriteon == 1) && (vidon == 1)) begin
        red = gray;
        green = gray;
        blue = gray;
	
	end   
	   
	  
	end else begin
	if ((spriteon == 1) && (vidon == 1)) begin
        red = edge_intensity[7:4];    // Use most significant bits for grayscale
        green = edge_intensity[7:4];
        blue = edge_intensity[7:4];
        
         end
       end
     end
reg [17:0] addr_cnt;


blk_mem_gen_1 pitcure (
  .clka(clk),    // input wire clka
  .addra(addr_cnt[17:2]),  // input wire [15 : 0] addra
  .douta(output_data)  // output wire [7 : 0] douta
);	
endmodule
