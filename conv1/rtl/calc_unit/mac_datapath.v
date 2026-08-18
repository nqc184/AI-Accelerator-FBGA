`timescale 1ns/1ps
module mac (
    input wire clk, reset, clear,
    input wire [2:0] kernel_size, 

    input wire signed [23:0] a1, a2, a3, a4, a5,
    input wire signed [23:0] b1, b2, b3, b4, b5,

    output wire signed [47:0] c1,  c2,  c3,  c4,  c5,
    output wire signed [47:0] c6,  c7,  c8,  c9,  c10,
    output wire signed [47:0] c11, c12, c13, c14, c15,
    output wire signed [47:0] c16, c17, c18, c19, c20,
    output wire signed [47:0] c21, c22, c23, c24, c25
);

    wire signed [23:0] w_a_1_12, w_a_1_23, w_a_1_34, w_a_1_45;
    wire signed [23:0] w_a_2_12, w_a_2_23, w_a_2_34, w_a_2_45;
    wire signed [23:0] w_a_3_12, w_a_3_23, w_a_3_34, w_a_3_45;
    wire signed [23:0] w_a_4_12, w_a_4_23, w_a_4_34, w_a_4_45;
    wire signed [23:0] w_a_5_12, w_a_5_23, w_a_5_34, w_a_5_45;

    wire signed [23:0] w_b_12_1, w_b_23_1, w_b_34_1, w_b_45_1;
    wire signed [23:0] w_b_12_2, w_b_23_2, w_b_34_2, w_b_45_2;
    wire signed [23:0] w_b_12_3, w_b_23_3, w_b_34_3, w_b_45_3;
    wire signed [23:0] w_b_12_4, w_b_23_4, w_b_34_4, w_b_45_4;
    wire signed [23:0] w_b_12_5, w_b_23_5, w_b_34_5, w_b_45_5;

    wire signed [47:0] pe_c1,  pe_c2,  pe_c3,  pe_c4,  pe_c5;
    wire signed [47:0] pe_c6,  pe_c7,  pe_c8,  pe_c9,  pe_c10;
    wire signed [47:0] pe_c11, pe_c12, pe_c13, pe_c14, pe_c15;
    wire signed [47:0] pe_c16, pe_c17, pe_c18, pe_c19, pe_c20;
    wire signed [47:0] pe_c21, pe_c22, pe_c23, pe_c24, pe_c25;

    // HÀNG 1
    pe pe_1_1 (.clk(clk), .reset(reset), .clear(clear), .in_a(a1),       .in_b(b1),       .out_a(w_a_1_12), .out_b(w_b_12_1), .out_c(pe_c1));
    pe pe_1_2 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_1_12), .in_b(b2),       .out_a(w_a_1_23), .out_b(w_b_12_2), .out_c(pe_c2));
    pe pe_1_3 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_1_23), .in_b(b3),       .out_a(w_a_1_34), .out_b(w_b_12_3), .out_c(pe_c3));
    pe pe_1_4 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_1_34), .in_b(b4),       .out_a(w_a_1_45), .out_b(w_b_12_4), .out_c(pe_c4));
    pe pe_1_5 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_1_45), .in_b(b5),       .out_a(),         .out_b(w_b_12_5), .out_c(pe_c5));

    // HÀNG 2
    pe pe_2_1 (.clk(clk), .reset(reset), .clear(clear), .in_a(a2),       .in_b(w_b_12_1), .out_a(w_a_2_12), .out_b(w_b_23_1), .out_c(pe_c6));
    pe pe_2_2 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_2_12), .in_b(w_b_12_2), .out_a(w_a_2_23), .out_b(w_b_23_2), .out_c(pe_c7));
    pe pe_2_3 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_2_23), .in_b(w_b_12_3), .out_a(w_a_2_34), .out_b(w_b_23_3), .out_c(pe_c8));
    pe pe_2_4 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_2_34), .in_b(w_b_12_4), .out_a(w_a_2_45), .out_b(w_b_23_4), .out_c(pe_c9));
    pe pe_2_5 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_2_45), .in_b(w_b_12_5), .out_a(),         .out_b(w_b_23_5), .out_c(pe_c10));

    // HÀNG 3
    pe pe_3_1 (.clk(clk), .reset(reset), .clear(clear), .in_a(a3),       .in_b(w_b_23_1), .out_a(w_a_3_12), .out_b(w_b_34_1), .out_c(pe_c11));
    pe pe_3_2 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_3_12), .in_b(w_b_23_2), .out_a(w_a_3_23), .out_b(w_b_34_2), .out_c(pe_c12));
    pe pe_3_3 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_3_23), .in_b(w_b_23_3), .out_a(w_a_3_34), .out_b(w_b_34_3), .out_c(pe_c13));
    pe pe_3_4 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_3_34), .in_b(w_b_23_4), .out_a(w_a_3_45), .out_b(w_b_34_4), .out_c(pe_c14));
    pe pe_3_5 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_3_45), .in_b(w_b_23_5), .out_a(),         .out_b(w_b_34_5), .out_c(pe_c15));

    // HÀNG 4
    pe pe_4_1 (.clk(clk), .reset(reset), .clear(clear), .in_a(a4),       .in_b(w_b_34_1), .out_a(w_a_4_12), .out_b(w_b_45_1), .out_c(pe_c16));
    pe pe_4_2 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_4_12), .in_b(w_b_34_2), .out_a(w_a_4_23), .out_b(w_b_45_2), .out_c(pe_c17));
    pe pe_4_3 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_4_23), .in_b(w_b_34_3), .out_a(w_a_4_34), .out_b(w_b_45_3), .out_c(pe_c18));
    pe pe_4_4 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_4_34), .in_b(w_b_34_4), .out_a(w_a_4_45), .out_b(w_b_45_4), .out_c(pe_c19));
    pe pe_4_5 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_4_45), .in_b(w_b_34_5), .out_a(),         .out_b(w_b_45_5), .out_c(pe_c20));

    // HÀNG 5
    pe pe_5_1 (.clk(clk), .reset(reset), .clear(clear), .in_a(a5),       .in_b(w_b_45_1), .out_a(w_a_5_12), .out_b(),         .out_c(pe_c21));
    pe pe_5_2 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_5_12), .in_b(w_b_45_2), .out_a(w_a_5_23), .out_b(),         .out_c(pe_c22));
    pe pe_5_3 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_5_23), .in_b(w_b_45_3), .out_a(w_a_5_34), .out_b(),         .out_c(pe_c23));
    pe pe_5_4 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_5_34), .in_b(w_b_45_4), .out_a(w_a_5_45), .out_b(),         .out_c(pe_c24));
    pe pe_5_5 (.clk(clk), .reset(reset), .clear(clear), .in_a(w_a_5_45), .in_b(w_b_45_5), .out_a(),         .out_b(),         .out_c(pe_c25));
    
    //Output
    // --- HÀNG 1 --- (Luôn hoạt động từ mức cấu hình tối thiểu 2x2 trở lên)
    assign c1  = pe_c1;
    assign c2  = pe_c2;
    assign c3  = pe_c3;
    assign c4  = pe_c4;
    assign c5  = pe_c5;

    // --- HÀNG 2 --- (Luôn hoạt động từ mức cấu hình tối thiểu 2x2 trở lên)
    assign c6  = pe_c6;
    assign c7  = pe_c7;
    assign c8  = pe_c8;
    assign c9  = pe_c9;
    assign c10 = pe_c10;

    // --- HÀNG 3 ---
    assign c11 = pe_c11;
    assign c12 = pe_c12;
    assign c13 = pe_c13;
    assign c14 = pe_c14;
    assign c15 = pe_c15;

    // --- HÀNG 4 ---
    assign c16 = pe_c16;
    assign c17 = pe_c17;
    assign c18 = pe_c18;
    assign c19 = pe_c19;
    assign c20 = pe_c20;

    // --- HÀNG 5 ---
    assign c21 = pe_c21;
    assign c22 = pe_c22;
    assign c23 = pe_c23;
    assign c24 = pe_c24;
    assign c25 = pe_c25;

endmodule