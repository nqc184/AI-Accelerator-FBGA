`timescale 1ns/1ps
module maxpool_unit #(
    parameter DW = 24,
    parameter MAX_W = 128,
    parameter P = 3
)(
    input  wire clk, rst, start_layer, pool_enable,
    input  wire [15:0] out_w, out_h,
    input  wire [2:0]  pool_size, pool_stride,

    input  wire signed [DW-1:0] d0, d1, d2, d3, d4,
    input  wire v0, v1, v2, v3, v4,

    output wire signed [DW-1:0] q0, q1, q2, q3, q4,
    output wire o0, o1, o2, o3, o4
);
    maxpool_lane #(.DW(DW), .MAX_W(MAX_W), .P(P)) lane0 (
        .clk(clk), .rst(rst), .start_layer(start_layer),
        .out_w(out_w), .out_h(out_h),
        .pool_size(pool_size), .pool_stride(pool_stride), .pool_enable(pool_enable),
        .din(d0), .dvalid(v0), .dout(q0), .dvalid_out(o0)
    );
    maxpool_lane #(.DW(DW), .MAX_W(MAX_W), .P(P)) lane1 (
        .clk(clk), .rst(rst), .start_layer(start_layer),
        .out_w(out_w), .out_h(out_h),
        .pool_size(pool_size), .pool_stride(pool_stride), .pool_enable(pool_enable),
        .din(d1), .dvalid(v1), .dout(q1), .dvalid_out(o1)
    );
    maxpool_lane #(.DW(DW), .MAX_W(MAX_W), .P(P)) lane2 (
        .clk(clk), .rst(rst), .start_layer(start_layer),
        .out_w(out_w), .out_h(out_h),
        .pool_size(pool_size), .pool_stride(pool_stride), .pool_enable(pool_enable),
        .din(d2), .dvalid(v2), .dout(q2), .dvalid_out(o2)
    );
    maxpool_lane #(.DW(DW), .MAX_W(MAX_W), .P(P)) lane3 (
        .clk(clk), .rst(rst), .start_layer(start_layer),
        .out_w(out_w), .out_h(out_h),
        .pool_size(pool_size), .pool_stride(pool_stride), .pool_enable(pool_enable),
        .din(d3), .dvalid(v3), .dout(q3), .dvalid_out(o3)
    );
    maxpool_lane #(.DW(DW), .MAX_W(MAX_W), .P(P)) lane4 (
        .clk(clk), .rst(rst), .start_layer(start_layer),
        .out_w(out_w), .out_h(out_h),
        .pool_size(pool_size), .pool_stride(pool_stride), .pool_enable(pool_enable),
        .din(d4), .dvalid(v4), .dout(q4), .dvalid_out(o4)
    );
endmodule