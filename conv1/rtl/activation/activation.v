module activation#(
    parameter DATA_WIDTH = 48,
    parameter LEAK_SHIFT = 4
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire valid_in,
    input wire start_activation,
    input wire [1:0] mode,
    input wire signed [DATA_WIDTH-1:0] data_in_activation,
    output reg signed [DATA_WIDTH-1:0] data_out_activation,
    output reg done_config_activation,
    output reg data_valid_activation
);
wire signed [DATA_WIDTH-1:0] data_out_sigmoid;
wire signed [DATA_WIDTH-1:0] data_out_leaky_relu;
wire signed [DATA_WIDTH-1:0] data_out_silu;
reg [1:0] reg_mode;
wire data_valid_sigmoid;
wire data_valid_leaky_relu;
wire data_valid_silu;
wire en_leaky_relu;
wire en_sigmoid;
wire en_silu;
assign en_leaky_relu = en && (reg_mode == 2'b00 || reg_mode == 2'b01);
assign en_sigmoid = en && (reg_mode == 2'b10);
assign en_silu = en && (reg_mode == 2'b11);
always @(posedge clk or posedge rst) begin
    if (rst) begin
        done_config_activation <= 0;
        reg_mode <= 0;
    end else if (en) begin
        done_config_activation <= 0;
        if(start_activation) begin
            reg_mode <= mode;
            done_config_activation <= 1;
        end
    end
end
always @(*) begin
    data_out_activation = 0;
    data_valid_activation = 0;
    case (reg_mode)
        2'b00: begin
            data_out_activation = data_out_leaky_relu;
            data_valid_activation = data_valid_leaky_relu;
        end
        2'b01: begin
            data_out_activation = data_out_leaky_relu;
            data_valid_activation = data_valid_leaky_relu;
        end
        2'b10: begin
            data_out_activation = data_out_sigmoid;
            data_valid_activation = data_valid_sigmoid;
        end
        2'b11: begin
            data_out_activation = data_out_silu;
            data_valid_activation = data_valid_silu;
        end
        default: begin
            data_out_activation = 0;
            data_valid_activation = 0;
        end
    endcase
end
leaky_relu #(
    .DATA_WIDTH(DATA_WIDTH),
    .LEAK_SHIFT(LEAK_SHIFT)
) leaky_relu_inst (
    .clk(clk),
    .rst(rst),
    .en(en_leaky_relu),
    .valid_in(valid_in),
    .mode(reg_mode[0]),
    .data_in(data_in_activation),
    .data_out(data_out_leaky_relu),
    .data_valid_leaky_relu(data_valid_leaky_relu)
);
sigmoid sigmoid_inst (
    .clk(clk),
    .rst(rst),
    .en(en_sigmoid),
    .data_in(data_in_activation),
    .valid_in(valid_in),
    .data_out(data_out_sigmoid),
    .data_valid_sigmoid(data_valid_sigmoid)
);
silu  #(
    .DATA_WIDTH(DATA_WIDTH)
) silu_inst (
    .clk(clk),
    .rst(rst),
    .en(en_silu),
    .data_in(data_in_activation),
    .valid_in(valid_in),
    .data_out(data_out_silu),
    .data_valid_silu(data_valid_silu),
    .mult(),
    .dto_sigmoid(),
    .w_data_in_reg0()
);
endmodule