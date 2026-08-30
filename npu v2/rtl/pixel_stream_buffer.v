`timescale 1ns/1ps

module pixel_stream_buffer #(
    parameter DW = 24,
    parameter MAX_W = 1024,
    parameter K = 5
)(
    input  wire clk, rst, clear,
    input  wire start_config,
    input  wire [15:0] img_w, img_h,
    input  wire [2:0]  kernel_size, stride,
    input  wire        valid_in,
    input  wire signed [DW-1:0] pixel_in,

    output reg         valid_out,
    output reg         done_config,
    output reg         last_window_out,

    output wire signed [(DW*K*K)-1:0] window_out_flat,
    output wire signed [(DW*K*K)-1:0] window_out_masked_flat,
    output reg  signed [599:0] window_packed
);

    reg [15:0] reg_img_w, reg_img_h;
    reg [2:0]  reg_kernel, reg_stride;

    reg [15:0] windows_w;
    reg [15:0] windows_h;
    reg [31:0] total_windows;

    localparam S_IDLE  = 3'd0,
               S_LOAD  = 3'd1,
               S_CALC1 = 3'd2,
               S_CALC2 = 3'd3,
               S_READY = 3'd4;
    reg [2:0] state;

    reg signed [DW-1:0] window_raw [0:K-1][0:K-1];
    reg signed [DW-1:0] line_buffers [0:K-2][0:MAX_W-1];
    reg signed [DW-1:0] window_out_masked [0:K-1][0:K-1];

    reg [15:0] col_cnt, row_cnt;

    integer i, r, c;

    always @(posedge clk or posedge rst) begin
        if (rst || clear) begin
            state         <= S_IDLE;
            done_config   <= 1'b0;

            reg_img_w     <= 16'd0;
            reg_img_h     <= 16'd0;
            reg_kernel    <= 3'd0;
            reg_stride    <= 3'd0;

            windows_w     <= 16'd0;
            windows_h     <= 16'd0;
            total_windows <= 32'd0;
            window_packed <= 0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    done_config <= 1'b0;
                    if (start_config)
                        state <= S_LOAD;
                end

                S_LOAD: begin
                    reg_img_w  <= img_w;
                    reg_img_h  <= img_h;
                    reg_kernel <= kernel_size;
                    reg_stride <= stride;
                    state      <= S_CALC1;
                end

                S_CALC1: begin
                    windows_w <= ((reg_img_w - reg_kernel) / reg_stride) + 16'd1;
                    windows_h <= ((reg_img_h - reg_kernel) / reg_stride) + 16'd1;
                    state <= S_CALC2;
                end

                S_CALC2: begin
                    total_windows <= windows_w * windows_h;
                    done_config   <= 1'b1;
                    state         <= S_READY;
                end

                S_READY: begin
                    done_config <= 1'b0;
                    if (start_config)
                        state <= S_LOAD;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    always @(posedge clk) begin
        if (valid_in) begin
            line_buffers[0][col_cnt] <= pixel_in;

            for (i = 1; i < K-1; i = i + 1)
                line_buffers[i][col_cnt] <= line_buffers[i-1][col_cnt];

            window_raw[0][0] <= pixel_in;

            for (c = 1; c < K; c = c + 1)
                window_raw[0][c] <= window_raw[0][c-1];

            for (r = 1; r < K; r = r + 1) begin
                window_raw[r][0] <= line_buffers[r-1][col_cnt];
                for (c = 1; c < K; c = c + 1)
                    window_raw[r][c] <= window_raw[r][c-1];
            end
        end
    end

    generate
        genvar gr, gc;
        for (gr = 0; gr < K; gr = gr + 1) begin : gen_out_r
            for (gc = 0; gc < K; gc = gc + 1) begin : gen_out_c
                assign window_out_flat[((gr*K+gc)*DW)+:DW] = window_raw[gr][gc];
                assign window_out_masked_flat[((gr*K+gc)*DW)+:DW] = window_out_masked[gr][gc];
            end
        end
    endgenerate

    always @(*) begin
        for (r = 0; r < K; r = r + 1) begin
            for (c = 0; c < K; c = c + 1) begin
                if (r < reg_kernel && c < reg_kernel)
                    window_out_masked[r][c] = window_raw[r][c];
                else
                    window_out_masked[r][c] = 'sd0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst || clear) begin
            col_cnt <= 16'd0;
            row_cnt <= 16'd0;
            valid_out <= 1'b0;
            last_window_out <= 1'b0;
        end
        else if (valid_in) begin
            if (col_cnt == reg_img_w - 1) begin
                col_cnt <= 16'd0;
                if (row_cnt == reg_img_h - 1)
                    row_cnt <= 16'd0;
                else
                    row_cnt <= row_cnt + 1;
            end
            else begin
                col_cnt <= col_cnt + 1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst || clear) begin
            valid_out <= 1'b0;
            last_window_out <= 1'b0;
        end
        else begin
            if (valid_in &&
                (row_cnt >= reg_kernel - 1) &&
                (col_cnt >= reg_kernel - 1) &&
                (row_cnt % reg_stride == (reg_kernel - 1) % reg_stride) &&
                (col_cnt % reg_stride == (reg_kernel - 1) % reg_stride)) begin

                valid_out <= 1'b1;
                last_window_out <= (row_cnt == reg_img_h - 1 &&
                                    col_cnt == reg_img_w - 1);
            end
            else begin
                valid_out <= 1'b0;
                last_window_out <= 1'b0;
            end
        end
    end

    integer idx;
    integer total;

    always @(*) begin
        window_packed = 'sd0;

        total = reg_kernel * reg_kernel;
        idx = 0;

        for (r = 0; r < reg_kernel; r = r + 1) begin
            for (c = 0; c < reg_kernel; c = c + 1) begin
                window_packed[((24-(total-1-idx))*24)+:24] = window_raw[r][c];
                idx = idx + 1;
            end
        end
    end

endmodule