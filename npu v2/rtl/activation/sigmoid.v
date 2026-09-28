module sigmoid (
    input  wire         clk,
    input  wire         rst,
    input  wire         en,
    input  wire signed [47:0]  data_in,
    input wire valid_in,

    output wire signed [47:0]  data_out,
    output reg          data_valid_sigmoid
);

reg signed [47:0] address_x0;
reg valid_d1;
wire signed [47:0] data_out_x0;
wire signed [47:0] data_out_x1;

sigmoid_LUT sigmoid_lut_inst (
    .clk(clk),
    .address_a(address_x0),
    .address_b(48'd0),      // Chưa dùng
    .data_out_a(data_out_x0),
    .data_out_b(data_out_x1)
);
always @(posedge clk or posedge rst) begin
    if (rst) begin
        address_x0 <= 24'd0;
        valid_d1 <= 1'b0;
        data_valid_sigmoid <= 1'b0;
    end
    else begin
        if (en ) begin
        if (valid_in) begin
            address_x0 <= data_in;
        end
        valid_d1 <= valid_in;
        data_valid_sigmoid <= valid_d1;
    end
end
end
assign data_out = data_out_x0;
endmodule