module Round_to_Nearest #(
    parameter DATA_IN_WIDTH = 48,
    parameter DATA_OUT_WIDTH = 24
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire valid_in,
    input wire signed [DATA_IN_WIDTH-1:0] data_in,
    output reg signed [DATA_OUT_WIDTH-1:0] data_out,
    output reg valid_out
);
wire signed [DATA_IN_WIDTH-1:0] stage;

localparam signed [DATA_IN_WIDTH-1:0] ROUNDING_VALUE = 48'sd32768;
localparam signed [47:0] MAX_Q816 = 48'sh007FFFFF0000;
localparam signed [47:0] MIN_Q816 = -48'sh008000000000;
reg signed [47:0] reg_stage;
reg signed [47:0] reg_data_in;
reg data_valid0,data_valid1;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_out   <= 24'sd0;
        valid_out <= 1'b0;
        data_valid0 <= 1'b0;
        data_valid1 <= 1'b0;
        reg_stage <= 48'sd0;
    end
    else begin
        if (en) begin
            if (valid_in) reg_data_in <= data_in;

            data_valid0 <= valid_in;
            data_valid1 <= data_valid0;
            valid_out <= data_valid1;

            reg_stage <= reg_data_in + (reg_data_in[47] ? -ROUNDING_VALUE : ROUNDING_VALUE);

            if (reg_stage > MAX_Q816)
                data_out <= 24'sh7FFFFF;
            else if (reg_stage < MIN_Q816)
                data_out <= 24'sh800000;
            else
                data_out <= reg_stage[39:16];
        end
    end
end
endmodule
