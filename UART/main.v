module top (
    input wire clk,             // 100 MHz clock from the Basys 3 board
    input wire reset,           // Reset signal
    input wire rx,              // UART RX pin
    output wire hsync,          // VGA HSYNC signal
    output wire vsync,          // VGA VSYNC signal
    output wire [3:0] red,      // VGA Red signal
    output wire [3:0] green,    // VGA Green signal
    output wire [3:0] blue      // VGA Blue signal
);

    wire [7:0] uart_data;
    wire uart_ready;
    reg [11:0] pixel_data_in;
    reg write_enable;
    wire [11:0] pixel_data_out;
    wire [16:0] pixel_addr;
    
    // Clock generation for VGA (use Clocking Wizard to generate 148.5 MHz clock from 100 MHz input)
    wire vga_clk;
    // Instantiate the UART receiver
    uart_rx uart_inst (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(uart_data),
        .data_ready(uart_ready)
    );

    // BlockRAM for image storage
    image_memory img_mem (
        .clk(clk),
        .addr(pixel_addr),
        .data_in(pixel_data_in),
        .we(write_enable),
        .data_out(pixel_data_out)
    );

    // VGA controller
    vga_display vga_inst (
        .clk(vga_clk),
        .reset(reset),
        .pixel_data(pixel_data_out),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .video_on(),
        .pixel_addr(pixel_addr)
    );

   // Handle incoming UART data and write to BlockRAM
    always @(posedge clk) begin
        if (uart_ready) begin
            pixel_data_in <= {uart_data[7:4], uart_data[3:0], uart_data[3:0]}; // Convert 8-bit UART data to 12-bit RGB
            write_enable <= 1;
        end else begin
            write_enable <= 0;
        end
    end

endmodule      