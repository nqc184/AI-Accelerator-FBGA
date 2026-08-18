module leaky_relu #(
    parameter DATA_WIDTH = 48,
    parameter LEAK_SHIFT = 4 
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire valid_in,
    input wire mode,
    input wire signed [DATA_WIDTH-1:0] data_in,
    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg data_valid_leaky_relu
);
    reg signed [DATA_WIDTH-1:0] reg_leaky_relu;
    reg valid_d0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
            data_valid_leaky_relu <= 0;
            reg_leaky_relu <= 0;
            valid_d0 <= 0;
        end else if (en) begin

           data_out <= reg_leaky_relu;

           if (valid_in) begin
           if (data_in >= 0) begin
                reg_leaky_relu <= data_in;
            end else begin
                reg_leaky_relu <= (mode) ? data_in >>> LEAK_SHIFT : 0;
            end
           end
           data_valid_leaky_relu <= valid_d0;
           valid_d0 <= valid_in;
        end
    end
endmodule