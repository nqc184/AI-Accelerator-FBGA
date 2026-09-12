module bias_adder_5 #(
    parameter DATA_WIDTH = 24
)(
    input wire clk,
    input wire rst,

    input wire signed [DATA_WIDTH-1:0] data0_in,
    input wire signed [DATA_WIDTH-1:0] data1_in,
    input wire signed [DATA_WIDTH-1:0] data2_in,
    input wire signed [DATA_WIDTH-1:0] data3_in,
    input wire signed [DATA_WIDTH-1:0] data4_in,

    input wire valid0_in,
    input wire valid1_in,
    input wire valid2_in,
    input wire valid3_in,
    input wire valid4_in,

    input wire signed [DATA_WIDTH-1:0] bias_in,
    input wire [2:0] bias_decode,
    input wire bias_load,

    output wire signed [DATA_WIDTH-1:0] data0_out,
    output wire signed [DATA_WIDTH-1:0] data1_out,
    output wire signed [DATA_WIDTH-1:0] data2_out,
    output wire signed [DATA_WIDTH-1:0] data3_out,
    output wire signed [DATA_WIDTH-1:0] data4_out,

    output wire valid0_out,
    output wire valid1_out,
    output wire valid2_out,
    output wire valid3_out,
    output wire valid4_out
);

    reg signed [DATA_WIDTH-1:0] bias0;
    reg signed [DATA_WIDTH-1:0] bias1;
    reg signed [DATA_WIDTH-1:0] bias2;
    reg signed [DATA_WIDTH-1:0] bias3;
    reg signed [DATA_WIDTH-1:0] bias4;

    always @(posedge clk) begin
        if (rst) begin
            bias0 <= '0;
            bias1 <= '0;
            bias2 <= '0;
            bias3 <= '0;
            bias4 <= '0;
        end
        else if (bias_load) begin
            case (bias_decode)
                3'd0: bias0 <= bias_in;
                3'd1: bias1 <= bias_in;
                3'd2: bias2 <= bias_in;
                3'd3: bias3 <= bias_in;
                3'd4: bias4 <= bias_in;
                default: ;
            endcase
        end
    end
    
    assign data0_out = data0_in + bias0;
    assign valid0_out = valid0_in;

    assign data1_out = data1_in + bias1;
    assign valid1_out = valid1_in;

    assign data2_out = data2_in + bias2;
    assign valid2_out = valid2_in;

    assign data3_out = data3_in + bias3;
    assign valid3_out = valid3_in;

    assign data4_out = data4_in + bias4;
    assign valid4_out = valid4_in;

endmodule