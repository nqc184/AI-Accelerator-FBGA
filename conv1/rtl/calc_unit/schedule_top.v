`timescale 1ns/1ps
module schedule_top #(parameter DW=24)(
    input wire clk,
    input wire reset,
    input wire start,

    input wire signed [599:0] IFM0,
    input wire signed [599:0] IFM1,
    input wire signed [599:0] IFM2,
    input wire signed [599:0] IFM3,
    input wire signed [599:0] IFM4,

    input wire signed [599:0] WGT0,
    input wire signed [599:0] WGT1,
    input wire signed [599:0] WGT2,
    input wire signed [599:0] WGT3,
    input wire signed [599:0] WGT4,

    output [5:0] cycle_out,

    output wire signed [DW-1:0] a1,
    output wire signed [DW-1:0] a2,
    output wire signed [DW-1:0] a3,
    output wire signed [DW-1:0] a4,
    output wire signed [DW-1:0] a5,

    output wire signed [DW-1:0] b1,
    output wire signed [DW-1:0] b2,
    output wire signed [DW-1:0] b3,
    output wire signed [DW-1:0] b4,
    output wire signed [DW-1:0] b5,

    output wire done
);

    wire [5:0] cycle;
    assign cycle_out = cycle;
    wire load;

    schedule_ctl schedule_controller_inst(
        .clk(clk),
        .reset(reset),
        .start(start),
        .load(load),
        .cycle(cycle),
        .done(done)
    );

    schedule_block schedule_block_inst(
        .clk(clk),
        .reset(reset),
        .load(load),
        .cycle(cycle),

        .IFM0(IFM0),
        .IFM1(IFM1),
        .IFM2(IFM2),
        .IFM3(IFM3),
        .IFM4(IFM4),

        .WGT0(WGT0),
        .WGT1(WGT1),
        .WGT2(WGT2),
        .WGT3(WGT3),
        .WGT4(WGT4),

        .a1(a1),
        .a2(a2),
        .a3(a3),
        .a4(a4),
        .a5(a5),

        .b1(b1),
        .b2(b2),
        .b3(b3),
        .b4(b4),
        .b5(b5)
    );

endmodule