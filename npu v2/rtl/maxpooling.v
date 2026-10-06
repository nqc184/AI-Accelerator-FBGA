module maxpooling #(
    parameter DATA_WIDTH = 24,
    parameter MAX_POOL   = 3,
    parameter MAX_WIDTH  = 1024
)(
    input clk,
    input rst,

    input enable,
    input config_start,

    input [1:0]  pool_size,
    input [1:0]  stride,
    input [15:0] img_width,

    input signed [DATA_WIDTH-1:0] data_in,
    input valid_in,

    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg valid_out,

    output reg config_done
);
    reg [1:0]  pool_size_reg;
    reg [1:0]  stride_reg;
    reg [15:0] img_width_reg;

    reg [15:0] row_count;
    reg [15:0] col_count;

    reg signed [DATA_WIDTH-1:0] line_buffer [0:MAX_POOL-2][0:MAX_WIDTH-1];

    reg signed [DATA_WIDTH-1:0] cur_col1;
    reg signed [DATA_WIDTH-1:0] cur_col2;

    reg signed [DATA_WIDTH-1:0] prev1_col1;
    reg signed [DATA_WIDTH-1:0] prev1_col2;

    reg signed [DATA_WIDTH-1:0] prev2_col1;
    reg signed [DATA_WIDTH-1:0] prev2_col2;

    reg signed [DATA_WIDTH-1:0] max_value;

    integer i;
    integer j;

    function is_aligned;

        input [15:0] coordinate;
        input [1:0]  step;

        begin

            case (step)

                2'd1: begin
                    is_aligned = 1'b1;
                end

                2'd2: begin
                    is_aligned = ((coordinate % 2) == 0);
                end

                2'd3: begin
                    is_aligned = ((coordinate % 3) == 0);
                end

                default: begin
                    is_aligned = 1'b0;
                end

            endcase

        end

    endfunction

    always @(posedge clk) begin

        if (rst) begin
            pool_size_reg <= 2'd2;
            stride_reg    <= 2'd2;
            img_width_reg <= 16'd0;

            row_count <= 16'd0;
            col_count <= 16'd0;

            data_out <= 0;
            valid_out <= 1'b0;
            config_done <= 1'b0;

            cur_col1 <= 0;
            cur_col2 <= 0;

            prev1_col1 <= 0;
            prev1_col2 <= 0;

            prev2_col1 <= 0;
            prev2_col2 <= 0;

            max_value <= 0;

            for (i = 0; i < MAX_POOL-1; i = i + 1) begin
                for (j = 0; j < MAX_WIDTH; j = j + 1) begin
                    line_buffer[i][j] <= 0;
                end
            end

        end

        else begin
            valid_out  <= 1'b0;
            config_done <= 1'b0;

            if (config_start) begin

                if (pool_size < 2'd1) pool_size_reg <= 2'd1;
                else if (pool_size > MAX_POOL) pool_size_reg <= MAX_POOL;
                else pool_size_reg <= pool_size;

                if (stride < 2'd1) stride_reg <= 2'd1;
                else if (stride > 2'd3) stride_reg <= 2'd3;
                else stride_reg <= stride;
                img_width_reg <= img_width;

                row_count <= 16'd0;
                col_count <= 16'd0;

                cur_col1   <= 0;
                cur_col2   <= 0;

                prev1_col1 <= 0;
                prev1_col2 <= 0;

                prev2_col1 <= 0;
                prev2_col2 <= 0;
                config_done <= 1'b1;

            end

            else if (!enable) begin

                data_out  <= data_in;
                valid_out <= valid_in;

            end

            else if (valid_in) begin
                if (pool_size_reg == 2'd1) begin

                    if (is_aligned(
                            row_count,
                            stride_reg
                        ) &&
                        is_aligned(
                            col_count,
                            stride_reg
                        )) begin

                        data_out  <= data_in;
                        valid_out <= 1'b1;

                    end

                end

                else if (pool_size_reg == 2'd2) begin
                    if ((row_count >= 16'd1) &&
                        (col_count >= 16'd1)) begin
                        if (is_aligned(
                                row_count - 16'd1,
                                stride_reg
                            ) &&
                            is_aligned(
                                col_count - 16'd1,
                                stride_reg
                            )) begin
                            max_value = data_in;
                            // A
                            if (prev1_col1 > max_value) max_value = prev1_col1;
                            // B
                            if (line_buffer[0][col_count] > max_value) max_value = line_buffer[0][col_count];
                            // C
                            if (cur_col1 > max_value) max_value = cur_col1;
                            // D
                            if (data_in > max_value) max_value = data_in;
                            data_out  <= max_value;
                            valid_out <= 1'b1;
                        end
                    end
                end

                else if (pool_size_reg == 2'd3) begin
                    if ((row_count >= 16'd2) &&
                        (col_count >= 16'd2)) begin
                        if (is_aligned(
                                row_count - 16'd2,
                                stride_reg
                            ) &&
                            is_aligned(
                                col_count - 16'd2,
                                stride_reg
                            )) begin
                            max_value = data_in;
                            // A
                            if (prev2_col2 > max_value) max_value = prev2_col2;
                            // B
                            if (prev2_col1 > max_value) max_value = prev2_col1;
                            // C
                            if (line_buffer[1][col_count] > max_value) max_value = line_buffer[1][col_count];
                            // D
                            if (prev1_col2 > max_value) max_value = prev1_col2;
                            // E
                            if (prev1_col1 > max_value) max_value = prev1_col1;
                            // F
                            if (line_buffer[0][col_count] > max_value) max_value = line_buffer[0][col_count];
                            // G
                            if (cur_col2 > max_value) max_value = cur_col2;
                            // H
                            if (cur_col1 > max_value) max_value = cur_col1;
                            // I
                            if (data_in > max_value) max_value = data_in;
                            data_out  <= max_value;
                            valid_out <= 1'b1;
                        end
                    end
                end
                line_buffer[1][col_count] <= line_buffer[0][col_count];
                line_buffer[0][col_count] <= data_in;
                if (col_count == 16'd0) begin
                    cur_col2 <= 0;
                    cur_col1 <= data_in;

                    prev1_col2 <= 0;
                    prev1_col1 <= line_buffer[0][col_count];

                    prev2_col2 <= 0;
                    prev2_col1 <= line_buffer[1][col_count];
                end

                else begin
                    cur_col2 <= cur_col1;
                    cur_col1 <= data_in;

                    prev1_col2 <= prev1_col1;
                    prev1_col1 <= line_buffer[0][col_count];

                    prev2_col2 <= prev2_col1;
                    prev2_col1 <= line_buffer[1][col_count];

                end

                if (col_count == img_width_reg - 16'd1) begin

                    col_count <= 16'd0;
                    row_count <= row_count + 16'd1;

                end

                else begin

                    col_count <= col_count + 16'd1;

                end

            end

        end

    end

endmodule