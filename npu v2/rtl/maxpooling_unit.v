module maxpooling_unit#(
    parameter DATA_WIDTH = 24,
    parameter MAX_POOL = 3,
    parameter MAX_WIDTH = 1024
)(
    input clk, rst,

    input enable,
    input config_start,

    input [1:0]  pool_size,
    input [1:0]  stride,
    input [15:0] img_width,

    input signed [DATA_WIDTH-1:0] data_in_0, data_in_1, data_in_2, data_in_3, data_in_4,
    input valid_in_0, valid_in_1, valid_in_2, valid_in_3, valid_in_4,
    output reg signed [DATA_WIDTH-1:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4,
    output reg valid_out_0, valid_out_1, valid_out_2, valid_out_3, valid_out_4,

    output reg config_done
);
    wire config_done_0, config_done_1, config_done_2, config_done_3, config_done_4;
    assign config_done = config_done_0 & config_done_1 & config_done_2 & config_done_3 & config_done_4;
    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(MAX_POOL),
        .MAX_WIDTH(MAX_WIDTH)
    )maxpooling_inst_0(
        .clk(clk), .rst(rst),

        .enable(enable),
        .config_start(config_start),

        .pool_size(pool_size),
        .stride(stride),
        .img_width(img_width),

        .data_in(data_in_0),
        .valid_in(valid_in_0),
        .data_out(data_out_0),
        .valid_out(valid_out_0),

        .config_done(config_done_0)
    );

    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(MAX_POOL),
        .MAX_WIDTH(MAX_WIDTH)
    )maxpooling_inst_1(
        .clk(clk), .rst(rst),

        .enable(enable),
        .config_start(config_start),

        .pool_size(pool_size),
        .stride(stride),
        .img_width(img_width),

        .data_in(data_in_1),
        .valid_in(valid_in_1),
        .data_out(data_out_1),
        .valid_out(valid_out_1),

        .config_done(config_done_1)
    );

    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(MAX_POOL),
        .MAX_WIDTH(MAX_WIDTH)
    )maxpooling_inst_2(
        .clk(clk), .rst(rst),
        
        .enable(enable),
        .config_start(config_start),

        .pool_size(pool_size),
        .stride(stride),
        .img_width(img_width),

        .data_in(data_in_2),
        .valid_in(valid_in_2),
        .data_out(data_out_2),
        .valid_out(valid_out_2),

        .config_done(config_done_2)
    );

    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(MAX_POOL),
        .MAX_WIDTH(MAX_WIDTH)
    )maxpooling_inst_3(
        .clk(clk), .rst(rst),

        .enable(enable), 
        .config_start(config_start),
    
        .pool_size(pool_size),
        .stride(stride),
        .img_width(img_width),

        .data_in(data_in_3),
        .valid_in(valid_in_3),
        .data_out(data_out_3),
        .valid_out(valid_out_3),

        .config_done(config_done_3)
    );

    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(MAX_POOL),
        .MAX_WIDTH(MAX_WIDTH)
    )maxpooling_inst_4(
        .clk(clk), .rst(rst),

        .enable(enable),
        .config_start(config_start),

        .pool_size(pool_size),
        .stride(stride),
        .img_width(img_width),

        .data_in(data_in_4),
        .valid_in(valid_in_4),
        .data_out(data_out_4),
        .valid_out(valid_out_4),

        .config_done(config_done_4)
    );
endmodule