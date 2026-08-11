module silu #(
    parameter DATA_WIDTH = 48
)(
    input  wire                          clk,
    input  wire                          rst,
    input  wire                          en,
    input  wire                          valid_in,
    input  wire signed [DATA_WIDTH-1:0]  data_in,

    output reg  signed [DATA_WIDTH-1:0]  data_out,
    output reg                           data_valid_silu,
    output wire signed [95:0]  mult,
    output wire signed [DATA_WIDTH-1:0]  dto_sigmoid,
    output wire  signed [DATA_WIDTH-1:0]     w_data_in_reg0
);

reg signed [DATA_WIDTH-1:0] data_in_reg0, data_in_reg1;
assign w_data_in_reg0 = data_in_reg0;
wire signed [DATA_WIDTH-1:0] data_out_sigmoid;
wire                         data_valid_sigmoid;
assign dto_sigmoid = data_out_sigmoid;
reg valid_in_sigmoid;
sigmoid sigmoid_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .data_in(data_in),
    .valid_in(valid_in),
    .data_out(data_out_sigmoid),
    .data_valid_sigmoid(data_valid_sigmoid)
);
wire signed [95:0] mult_result;
assign mult_result = $signed(data_in_reg1) * $signed(data_out_sigmoid);
assign mult = mult_result;
reg valid_d0;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_in_reg0     <= 0;
	    data_in_reg1    <= 0;
        data_out        <= 0;
        data_valid_silu <= 0;
        valid_in_sigmoid <= 0;
        valid_d0 <= 0;
    end
    else begin
        if(en) begin
          if(valid_in)
            data_in_reg0 <= data_in;
            data_in_reg1 <= data_in_reg0;
            if (data_valid_sigmoid) begin
                data_out <= mult_result[79:32];
                data_valid_silu <= 1'b1;
            end
            else begin
                data_out <= 0;
                data_valid_silu <= 1'b0;
            end
          end
    end
end

endmodule