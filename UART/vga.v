module vga_display (
    input wire clk,              // Clock signal (148.5 MHz for 1920x1080@60Hz)
    input wire reset,            // Reset signal
    input wire [11:0] pixel_data, // Pixel data from BlockRAM (12-bit RGB)
    output reg hsync,            // Horizontal sync signal
    output reg vsync,            // Vertical sync signal
    output reg [3:0] red,        // VGA Red signal (4-bit)
    output reg [3:0] green,      // VGA Green signal (4-bit)
    output reg [3:0] blue,       // VGA Blue signal (4-bit)
    output wire video_on,        // Signal indicating active video region
    output wire [16:0] pixel_addr // Address for the BlockRAM
);

    // VGA Timing constants for 1920x1080@60Hz
    localparam H_DISPLAY      = 1920;
    localparam H_FRONT_PORCH  = 88;
    localparam H_SYNC_PULSE   = 44;
    localparam H_BACK_PORCH   = 148;
    localparam H_TOTAL        = 2200;

    localparam V_DISPLAY      = 1080;
    localparam V_FRONT_PORCH  = 4;
    localparam V_SYNC_PULSE   = 5;
    localparam V_BACK_PORCH   = 36;
    localparam V_TOTAL        = 1125;

    reg [11:0] h_count = 0;
    reg [11:0] v_count = 0;

    // Horizontal counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            h_count <= 0;
        else if (h_count == H_TOTAL - 1)
            h_count <= 0;
        else
            h_count <= h_count + 1;
    end

    // Vertical counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            v_count <= 0;
        else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end

    // Generate HSYNC and VSYNC signals
    always @(posedge clk) begin
        hsync <= (h_count >= (H_DISPLAY + H_FRONT_PORCH)) && (h_count < (H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)) ? 0 : 1;
        vsync <= (v_count >= (V_DISPLAY + V_FRONT_PORCH)) && (v_count < (V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)) ? 0 : 1;
    end

    // Active video region
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

    // BlockRAM pixel address
    assign pixel_addr = (h_count < H_DISPLAY && v_count < V_DISPLAY) ? (v_count * H_DISPLAY + h_count) : 17'b0;

    // Output the pixel data to VGA (RGB 4:4:4 format)
    always @(posedge clk) begin
        if (video_on) begin
            red   <= pixel_data[11:8];   // Extract the red component
            green <= pixel_data[7:4];    // Extract the green component
            blue  <= pixel_data[3:0];    // Extract the blue component
        end else begin
            red   <= 4'b0000;
            green <= 4'b0000;
            blue  <= 4'b0000;
        end
    end

endmodule