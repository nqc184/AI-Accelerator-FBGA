module calc_unit #(
    parameter DW = 24,
    parameter START_CYCLE_COL_1 = 25,
    parameter START_CYCLE_COL_2 = 26,
    parameter START_CYCLE_COL_3 = 27,
    parameter START_CYCLE_COL_4 = 28,
    parameter START_CYCLE_COL_5 = 29
)(

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

    output wire signed [23:0] a1_monitor,
    output wire signed [23:0] a2_monitor,
    output wire signed [23:0] a3_monitor,
    output wire signed [23:0] a4_monitor,
    output wire signed [23:0] a5_monitor,

    output wire signed [23:0] b1_monitor,
    output wire signed [23:0] b2_monitor,
    output wire signed [23:0] b3_monitor,
    output wire signed [23:0] b4_monitor,
    output wire signed [23:0] b5_monitor,

    output wire signed [47:0] c1,
    output wire signed [47:0] c2,
    output wire signed [47:0] c3,
    output wire signed [47:0] c4,
    output wire signed [47:0] c5,

    output wire signed [47:0] c6,
    output wire signed [47:0] c7,
    output wire signed [47:0] c8,
    output wire signed [47:0] c9,
    output wire signed [47:0] c10,

    output wire signed [47:0] c11,
    output wire signed [47:0] c12,
    output wire signed [47:0] c13,
    output wire signed [47:0] c14,
    output wire signed [47:0] c15,

    output wire signed [47:0] c16,
    output wire signed [47:0] c17,
    output wire signed [47:0] c18,
    output wire signed [47:0] c19,
    output wire signed [47:0] c20,

    output wire signed [47:0] c21,
    output wire signed [47:0] c22,
    output wire signed [47:0] c23,
    output wire signed [47:0] c24,
    output wire signed [47:0] c25,

    output signed [47:0] col1_out, col2_out, col3_out, col4_out, col5_out,
    output col1_valid, col2_valid, col3_valid, col4_valid, col5_valid,

    output wire done
);
    wire signed [23:0] a1,a2,a3,a4,a5;
    wire signed [23:0] b1,b2,b3,b4,b5;

    wire load;

    schedule_top #(.DW(24))schedule_unit_inst(
        .clk(clk),
        .reset(reset),
        .start(start),
        .cycle_out(cycle_out),

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
        .b5(b5),

        .done(done)
    );

    mac_top mac_unit_inst(
        .clk(clk),
        .reset(reset),
        .start(start),

        .done(),

        .a1(a1), .a2(a2), .a3(a3), .a4(a4), .a5(a5),
        .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5),

        .c1(c1),  .c2(c2),  .c3(c3),  .c4(c4),  .c5(c5),
        .c6(c6),  .c7(c7),  .c8(c8),  .c9(c9),  .c10(c10),
        .c11(c11), .c12(c12), .c13(c13), .c14(c14), .c15(c15),
        .c16(c16), .c17(c17), .c18(c18), .c19(c19), .c20(c20),
        .c21(c21), .c22(c22), .c23(c23), .c24(c24), .c25(c25)
    );

    wire [5:0] cycle_out_reg;
    reg6_en cycle_reg_inst(
        .clk(clk),
        .rst(reset),
        .en(1'b1),
        .d(cycle_out),
        .q(cycle_out_reg)
    );

    output_mux_bank #(
        .START_CYCLE_COL_1(START_CYCLE_COL_1),
        .START_CYCLE_COL_2(START_CYCLE_COL_2),
        .START_CYCLE_COL_3(START_CYCLE_COL_3),
        .START_CYCLE_COL_4(START_CYCLE_COL_4),
        .START_CYCLE_COL_5(START_CYCLE_COL_5)
    )output_mux_inst(
        .cycle(cycle_out_reg),

        .c1(c1), .c2(c2), .c3(c3), .c4(c4), .c5(c5),
        .c6(c6), .c7(c7), .c8(c8), .c9(c9), .c10(c10),
        .c11(c11), .c12(c12), .c13(c13), .c14(c14), .c15(c15),
        .c16(c16), .c17(c17), .c18(c18), .c19(c19), .c20(c20),
        .c21(c21), .c22(c22), .c23(c23), .c24(c24), .c25(c25),

        .col1_out(col1_out), .col2_out(col2_out), .col3_out(col3_out), .col4_out(col4_out), .col5_out(col5_out),
        .col1_valid(col1_valid), .col2_valid(col2_valid), .col3_valid(col3_valid), .col4_valid(col4_valid), .col5_valid(col5_valid)
    );

    assign a1_monitor = a1;
    assign a2_monitor = a2;
    assign a3_monitor = a3;
    assign a4_monitor = a4;
    assign a5_monitor = a5;

    assign b1_monitor = b1;
    assign b2_monitor = b2;
    assign b3_monitor = b3;
    assign b4_monitor = b4;
    assign b5_monitor = b5;
endmodule