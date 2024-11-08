module uart_rx (
    input wire clk,              // Clock signal (100 MHz on Basys 3)
    input wire reset,            // Reset signal
    input wire rx,               // UART RX pin
    output reg [7:0] data_out,   // Output 8-bit data
    output reg data_ready        // Signal to indicate new data received
);

    parameter BAUD_RATE = 115200;
    parameter CLOCK_FREQ = 100_000_000;
    parameter BIT_TIME = CLOCK_FREQ / BAUD_RATE;

    reg [15:0] bit_timer = 0;
    reg [3:0] bit_counter = 0;
    reg [7:0] rx_shift_reg = 0;
    reg rx_state = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_timer <= 0;
            bit_counter <= 0;
            rx_state <= 0;
            data_ready <= 0;
        end else begin
            case (rx_state)
                0: begin  // Waiting for start bit
                    if (rx == 0) begin
                        bit_timer <= BIT_TIME / 2;
                        bit_counter <= 0;
                        rx_state <= 1;
                    end
                end
                1: begin  // Receiving bits
                    if (bit_timer == 0) begin
                        bit_timer <= BIT_TIME;
                        if (bit_counter < 8) begin
                            rx_shift_reg <= {rx, rx_shift_reg[7:1]};
                            bit_counter <= bit_counter + 1;
                        end else begin
                            data_out <= rx_shift_reg;
                            data_ready <= 1;
                            rx_state <= 0;
                        end
                    end else begin
                        bit_timer <= bit_timer - 1;
                    end
                end
            endcase
        end
    end

endmodule