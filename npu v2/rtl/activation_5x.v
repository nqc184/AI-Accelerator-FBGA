module activation_5x #(
    parameter DATA_WIDTH = 48,
    parameter LEAK_SHIFT = 4
)(
    input wire clk, rst,

    input wire en0, en1, en2, en3, en4,
    input wire valid_in0, valid_in1, valid_in2, valid_in3, valid_in4,
    input wire start_activation,
    input wire [1:0] mode,
    input wire signed [DATA_WIDTH-1:0] data_in_activation0, data_in_activation1, data_in_activation2, data_in_activation3, data_in_activation4,
    output wire signed [DATA_WIDTH-1:0] data_out_activation0, data_out_activation1, data_out_activation2, data_out_activation3, data_out_activation4,
    output wire done_config_activation,
    output wire data_valid_activation0, data_valid_activation1, data_valid_activation2, data_valid_activation3, data_valid_activation4
);

    wire done_config_activation0, done_config_activation1, done_config_activation2, done_config_activation3, done_config_activation4;
    activation #(
        .DATA_WIDTH(DATA_WIDTH),
        .LEAK_SHIFT(LEAK_SHIFT)
    ) activation_inst0 (
        .clk(clk), .rst(rst), .en(en0),
        .valid_in(valid_in0),
        .start_activation(start_activation),
        .mode(mode),
        .data_in_activation(data_in_activation0),
        .data_out_activation(data_out_activation0),
        .done_config_activation(done_config_activation0),
        .data_valid_activation(data_valid_activation0)
    );

    activation #(
        .DATA_WIDTH(DATA_WIDTH),
        .LEAK_SHIFT(LEAK_SHIFT)
    ) activation_inst1 (
        .clk(clk), .rst(rst), .en(en1),
        .valid_in(valid_in1),
        .start_activation(start_activation),
        .mode(mode),
        .data_in_activation(data_in_activation1),
        .data_out_activation(data_out_activation1),
        .done_config_activation(done_config_activation1),
        .data_valid_activation(data_valid_activation1)
    );

    activation #(
        .DATA_WIDTH(DATA_WIDTH),
        .LEAK_SHIFT(LEAK_SHIFT)
    ) activation_inst2 (
        .clk(clk), .rst(rst), .en(en2),
        .valid_in(valid_in2),
        .start_activation(start_activation),
        .mode(mode),
        .data_in_activation(data_in_activation2),
        .data_out_activation(data_out_activation2),
        .done_config_activation(done_config_activation2),
        .data_valid_activation(data_valid_activation2)
    );

    activation #(
        .DATA_WIDTH(DATA_WIDTH),
        .LEAK_SHIFT(LEAK_SHIFT)
    ) activation_inst3 (
        .clk(clk), .rst(rst), .en(en3),
        .valid_in(valid_in3),
        .start_activation(start_activation),
        .mode(mode),
        .data_in_activation(data_in_activation3),
        .data_out_activation(data_out_activation3),
        .done_config_activation(done_config_activation3),
        .data_valid_activation(data_valid_activation3)
    );

    activation #(
        .DATA_WIDTH(DATA_WIDTH),
        .LEAK_SHIFT(LEAK_SHIFT)
    ) activation_inst4 (
        .clk(clk), .rst(rst), .en(en4),
        .valid_in(valid_in4),
        .start_activation(start_activation),
        .mode(mode),
        .data_in_activation(data_in_activation4),
        .data_out_activation(data_out_activation4),
        .done_config_activation(done_config_activation4),
        .data_valid_activation(data_valid_activation4)
    );

    assign done_config_activation = done_config_activation0 && done_config_activation1 && done_config_activation2
                                    && done_config_activation3 && done_config_activation4;
endmodule