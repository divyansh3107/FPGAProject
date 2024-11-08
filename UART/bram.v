module image_memory (
    input wire clk,
    input wire [16:0] addr,       // Address for image (we use 1920*1080 -> requires 17-bit address space)
    input wire [11:0] data_in,    // 12-bit color data (RGB 4:4:4 format)
    input wire we,                // Write enable for storing data
    output reg [11:0] data_out    // Output for reading data to display
);

    reg [11:0] memory [0:2073599]; // BlockRAM for 1920x1080 pixels (1.9 million pixels)
    
    always @(posedge clk) begin
        if (we)
            memory[addr] <= data_in;  // Write data to BlockRAM
        data_out <= memory[addr];     // Read data from BlockRAM
    end

endmodule