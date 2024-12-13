module gaussian_blur_top (
    input                   CLOCK_50,
    input            [1:0]  KEY,         // Only using KEY[0] and KEY[1]
    output                  VGA_BLANK_N,
    output           [7:0]  VGA_B,
    output                  VGA_CLK,
    output           [7:0]  VGA_G,
    output           [7:0]  VGA_R,
    output                  VGA_HS,
    output                  VGA_SYNC_N,
    output                  VGA_VS
);

// Basic signal assignments
wire clk;
wire rst;
assign clk = CLOCK_50;
assign rst = KEY[0];

// VGA signals
wire active_pixels;
wire frame_done;
wire [9:0] x;
wire [9:0] y;

// Memory interface signals
wire [14:0] display_address;
wire [23:0] mem_data;
wire [14:0] process_address;
wire [23:0] processed_data;
wire write_enable;
wire processing_done;
wire processing_active;

// Calculate display address
assign display_address = (y[8:2]) + ((x[9:2]) * 120);

// Process control with debouncing
reg prev_key1;
reg processing_triggered;
reg [15:0] debounce_counter;
parameter DEBOUNCE_LIMIT = 16'd50000;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        processing_triggered <= 0;
        prev_key1 <= 1;
        debounce_counter <= 0;
    end else begin
        prev_key1 <= KEY[1];
        
        if (prev_key1 && !KEY[1] && debounce_counter == 0) begin // Falling edge
            processing_triggered <= 1;
            debounce_counter <= DEBOUNCE_LIMIT;
        end else if (processing_triggered && processing_done) begin
            processing_triggered <= 0;
        end
        
        if (debounce_counter > 0)
            debounce_counter <= debounce_counter - 1;
    end
end

// Memory control signals
wire should_process = processing_active || processing_done;
wire [14:0] mem_address = should_process ? process_address : display_address;
wire [23:0] output_data = should_process ? processed_data : mem_data;

// Gaussian processor instance
gaussian_processor processor (
    .clk(clk),
    .rst(rst),
    .start_process(processing_triggered),
    .pixel_data(mem_data),
    .display_address(display_address),
    .process_address(process_address),
    .processed_data(processed_data),
    .write_enable(write_enable),
    .processing_done(processing_done),
    .processing_active(processing_active)
);

// Memory instance
vga_frame frame_mem (
    .address(mem_address),
    .clock(clk),
    .data(processed_data),
    .wren(write_enable),
    .q(mem_data)
);

// VGA frame driver instance
vga_frame_driver frame_driver (
    .clk(clk),
    .rst(rst),
    .active_pixels(active_pixels),
    .frame_done(frame_done),
    .x(x),
    .y(y),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_CLK(VGA_CLK),
    .VGA_HS(VGA_HS),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_VS(VGA_VS),
    .VGA_B(VGA_B),
    .VGA_G(VGA_G),
    .VGA_R(VGA_R),
    .the_vga_draw_frame_write_mem_address(display_address),
    .the_vga_draw_frame_write_mem_data(output_data),
    .the_vga_draw_frame_write_a_pixel(active_pixels)
);

endmodule