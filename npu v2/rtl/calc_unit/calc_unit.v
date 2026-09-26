`timescale 1ns/1ps

module calc_unit #(
    parameter DW=24
)(
    input clk, reset, start_config,
    input start_mac,
    input [2:0] kernel_size,
    input [599:0] IFM, WGT,

    output done_config_mac,

    output [47:0] c1, c2, c3, c4, c5,
    output [47:0] c6, c7, c8, c9, c10,
    output [47:0] c11, c12, c13, c14, c15,
    output [47:0] c16, c17, c18, c19, c20,
    output [47:0] c21, c22, c23, c24, c25,

    output calc_done
);
    wire [23:0] a1, a2, a3, a4, a5;
    wire [23:0] b1, b2, b3, b4, b5;

    schedule_top #(
        .DW(DW)
    )schedule_inst(
        .clk(clk), .reset(reset), .start(start_mac),
        .kernel_size(kernel_size),      

        .IFM(IFM),
        .WGT(WGT),

        .a1(a1), .a2(a2), .a3(a3), .a4(a4), .a5(a5),
        .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5),
        .done(calc_done)
    );

    mac_top mac_inst(
        .clk(clk),
        .reset(reset),
        .start_config(start_config),      
        .start(start_mac),             
        .kernel_in(kernel_size),  

        .done_config(done_config_mac),       
        .done(),             

        .a1(a1), .a2(a2), .a3(a3), .a4(a4), .a5(a5),
        .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5),

        .c1(c1), .c2(c2),  .c3(c3),  .c4(c4),  .c5(c5),
        .c6(c6), .c7(c7),  .c8(c8),  .c9(c9),  .c10(c10),
        .c11(c11), .c12(c12), .c13(c13), .c14(c14), .c15(c15),
        .c16(c16), .c17(c17), .c18(c18), .c19(c19), .c20(c20),
        .c21(c21), .c22(c22), .c23(c23), .c24(c24), .c25(c25)
    );

endmodule