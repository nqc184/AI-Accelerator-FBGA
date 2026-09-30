`timescale 1ns/1ps

module demux_1to5 #(
    parameter DW = 48
)(
    input  wire signed [DW-1:0] din,
    input  wire [2:0]           sel,

    output reg signed [DW-1:0] dout0,
    output reg signed [DW-1:0] dout1,
    output reg signed [DW-1:0] dout2,
    output reg signed [DW-1:0] dout3,
    output reg signed [DW-1:0] dout4
);

always @(*) begin

    dout0 = 'sd0;
    dout1 = 'sd0;
    dout2 = 'sd0;
    dout3 = 'sd0;
    dout4 = 'sd0;

    case(sel)
        3'd0: dout0 = din;
        3'd1: dout1 = din;
        3'd2: dout2 = din;
        3'd3: dout3 = din;
        3'd4: dout4 = din;
        default: ;
    endcase

end

endmodule