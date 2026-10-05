module maxpooling #(
    parameter DATA_WIDTH = 24,
    parameter MAX_POOL   = 3
)(
    input clk,
    input rst,

    input config_en,
    input [1:0] pool_size,
    input [1:0] stride,
    input [15:0] img_width,

    input signed [DATA_WIDTH-1:0] data_in,
    input valid_in,

    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg valid_out
);

    reg [1:0] pool_size_reg;
    reg [1:0] stride_reg;
    reg [15:0] img_width_reg;

    reg [15:0] row_count;
    reg [15:0] col_count;

    reg signed [DATA_WIDTH-1:0] line_buffer [0:MAX_POOL-2][0:1023];

    reg signed [DATA_WIDTH-1:0] window [0:MAX_POOL-1][0:MAX_POOL-1];

    reg signed [DATA_WIDTH-1:0] max_value;

    integer i;
    integer j;

    always @(posedge clk) begin

        if (rst) begin

            pool_size_reg <= 2'd2;
            stride_reg    <= 2'd2;
            img_width_reg <= 16'd0;

            row_count <= 16'd0;
            col_count <= 16'd0;

            data_out  <= 0;
            valid_out <= 1'b0;

            max_value <= 0;

            for (i = 0; i < MAX_POOL-1; i = i + 1) begin
                for (j = 0; j < 1024; j = j + 1) begin
                    line_buffer[i][j] <= 0;
                end
            end

            for (i = 0; i < MAX_POOL; i = i + 1) begin
                for (j = 0; j < MAX_POOL; j = j + 1) begin
                    window[i][j] <= 0;
                end
            end

        end

        else begin

            valid_out <= 1'b0;

            if (config_en) begin

                pool_size_reg <= pool_size;
                stride_reg    <= stride;
                img_width_reg <= img_width;

                row_count <= 16'd0;
                col_count <= 16'd0;

            end

            else if (valid_in) begin
                if (pool_size_reg == 1) begin

                    data_out  <= data_in;
                    valid_out <= 1'b1;

                end

                else if (pool_size_reg == 2) begin

                    if (row_count >= 1) begin

                        window[1][0] <= line_buffer[0][col_count];
                        window[1][1] <= data_in;

                        window[0][1] <= line_buffer[0][col_count];

                    end

                    line_buffer[0][col_count] <= data_in;

                    if ((row_count >= 1) &&
                        (col_count >= 1) &&
                        ((row_count - 1) % stride_reg == 0) &&
                        ((col_count - 1) % stride_reg == 0)) begin

                        max_value = data_in;

                        if (line_buffer[0][col_count-1] > max_value)
                            max_value = line_buffer[0][col_count-1];

                        if (line_buffer[0][col_count] > max_value)
                            max_value = line_buffer[0][col_count];

                        if (line_buffer[0][col_count-1] > max_value)
                            max_value = line_buffer[0][col_count-1];

                        data_out  <= max_value;
                        valid_out <= 1'b1;

                    end

                end

                else if (pool_size_reg == 3) begin

                    if (row_count >= 2) begin

                        if (col_count < 1024) begin

                            window[2][0] <= line_buffer[0][col_count];
                            window[2][1] <= line_buffer[1][col_count];
                            window[2][2] <= data_in;

                        end

                    end

                    if (col_count < 1024) begin

                        line_buffer[1][col_count] <=
                            line_buffer[0][col_count];

                        line_buffer[0][col_count] <= data_in;

                    end

                    if ((row_count >= 2) &&
                        (col_count >= 2) &&
                        ((row_count - 2) % stride_reg == 0) &&
                        ((col_count - 2) % stride_reg == 0)) begin

                        max_value = data_in;

                        if (line_buffer[0][col_count] > max_value)
                            max_value = line_buffer[0][col_count];

                        if (line_buffer[1][col_count] > max_value)
                            max_value = line_buffer[1][col_count];

                        if (line_buffer[0][col_count-1] > max_value)
                            max_value = line_buffer[0][col_count-1];

                        if (line_buffer[1][col_count-1] > max_value)
                            max_value = line_buffer[1][col_count-1];

                        if (line_buffer[0][col_count-2] > max_value)
                            max_value = line_buffer[0][col_count-2];

                        if (line_buffer[1][col_count-2] > max_value)
                            max_value = line_buffer[1][col_count-2];

                        data_out  <= max_value;
                        valid_out <= 1'b1;

                    end

                end

                if (col_count == img_width_reg - 1) begin

                    col_count <= 16'd0;
                    row_count <= row_count + 1'b1;

                end

                else begin

                    col_count <= col_count + 1'b1;

                end

            end

        end

    end

endmodule