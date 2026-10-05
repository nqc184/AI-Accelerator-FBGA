module maxpooling #(
    parameter DATA_WIDTH = 24,
    parameter MAX_POOL   = 3,
    parameter MAX_STRIDE = 3
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

            data_out  <= {DATA_WIDTH{1'b0}};
            valid_out <= 1'b0;

            max_value <= {DATA_WIDTH{1'b0}};

            for (i = 0; i < MAX_POOL; i = i + 1) begin
                for (j = 0; j < MAX_POOL; j = j + 1) begin
                    window[i][j] <= {DATA_WIDTH{1'b0}};
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

                window[row_count % pool_size_reg]
                       [col_count % pool_size_reg] <= data_in;

                if ((row_count >= pool_size_reg - 1) &&
                    (col_count >= pool_size_reg - 1) &&
                    (((row_count - (pool_size_reg - 1)) % stride_reg) == 0) &&
                    (((col_count - (pool_size_reg - 1)) % stride_reg) == 0)) begin

                    max_value = window[0][0];

                    for (i = 0; i < MAX_POOL; i = i + 1) begin
                        for (j = 0; j < MAX_POOL; j = j + 1) begin

                            if ((i < pool_size_reg) &&
                                (j < pool_size_reg)) begin

                                if (window[i][j] > max_value)
                                    max_value = window[i][j];

                            end

                        end
                    end

                    if (data_in > max_value)
                        max_value = data_in;

                    data_out  <= max_value;
                    valid_out <= 1'b1;

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