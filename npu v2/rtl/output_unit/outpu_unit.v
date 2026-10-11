`timescale 1ns/1ps
module ofm_unit #(
    parameter DW = 24,
    parameter AW = 16,
    parameter DEPTH = 65536
)(
    input wire clk, rst, batch_start,
    input wire [2:0] lane_count, win_in_batch,
    input wire [AW-1:0] base_addr,

    input wire signed [DW-1:0] d0, d1, d2, d3, d4,
    input wire v0, v1, v2, v3, v4,

    input wire [4:0] rd_en,
    input wire [AW-1:0] rd_addr0, rd_addr1, rd_addr2, rd_addr3, rd_addr4,
    output wire signed [DW-1:0] rd_data0, rd_data1, rd_data2, rd_data3, rd_data4
);
    wire we0, we1, we2, we3, we4;
    wire [AW-1:0] wa0, wa1, wa2, wa3, wa4;
    wire signed [DW-1:0] wd0, wd1, wd2, wd3, wd4;

    ofm_lane #(.DW(DW), .AW(AW), .LANE(0)) lane0 (
        .clk(clk), .rst(rst), .batch_start(batch_start),
        .lane_count(lane_count), .win_in_batch(win_in_batch), .base_addr(base_addr),
        .din(d0), .dvalid(v0),
        .wr_en(we0), .wr_addr(wa0), .wr_data(wd0)
    );
    ofm_lane #(.DW(DW), .AW(AW), .LANE(1)) lane1 (
        .clk(clk), .rst(rst), .batch_start(batch_start),
        .lane_count(lane_count), .win_in_batch(win_in_batch), .base_addr(base_addr),
        .din(d1), .dvalid(v1),
        .wr_en(we1), .wr_addr(wa1), .wr_data(wd1)
    );
    ofm_lane #(.DW(DW), .AW(AW), .LANE(2)) lane2 (
        .clk(clk), .rst(rst), .batch_start(batch_start),
        .lane_count(lane_count), .win_in_batch(win_in_batch), .base_addr(base_addr),
        .din(d2), .dvalid(v2),
        .wr_en(we2), .wr_addr(wa2), .wr_data(wd2)
    );
    ofm_lane #(.DW(DW), .AW(AW), .LANE(3)) lane3 (
        .clk(clk), .rst(rst), .batch_start(batch_start),
        .lane_count(lane_count), .win_in_batch(win_in_batch), .base_addr(base_addr),
        .din(d3), .dvalid(v3),
        .wr_en(we3), .wr_addr(wa3), .wr_data(wd3)
    );
    ofm_lane #(.DW(DW), .AW(AW), .LANE(4)) lane4 (
        .clk(clk), .rst(rst), .batch_start(batch_start),
        .lane_count(lane_count), .win_in_batch(win_in_batch), .base_addr(base_addr),
        .din(d4), .dvalid(v4),
        .wr_en(we4), .wr_addr(wa4), .wr_data(wd4)
    );

    bram #(.DW(DW), .DEPTH(DEPTH), .ADDR_WIDTH(AW)) bank0 (
        .clk(clk),
        .wr_en(we0), .wr_addr(wa0), .wr_data(wd0),
        .rd_en(rd_en[0]), .rd_addr(rd_addr0), .rd_data(rd_data0)
    );
    bram #(.DW(DW), .DEPTH(DEPTH), .ADDR_WIDTH(AW)) bank1 (
        .clk(clk),
        .wr_en(we1), .wr_addr(wa1), .wr_data(wd1),
        .rd_en(rd_en[1]), .rd_addr(rd_addr1), .rd_data(rd_data1)
    );
    bram #(.DW(DW), .DEPTH(DEPTH), .ADDR_WIDTH(AW)) bank2 (
        .clk(clk),
        .wr_en(we2), .wr_addr(wa2), .wr_data(wd2),
        .rd_en(rd_en[2]), .rd_addr(rd_addr2), .rd_data(rd_data2)
    );
    bram #(.DW(DW), .DEPTH(DEPTH), .ADDR_WIDTH(AW)) bank3 (
        .clk(clk),
        .wr_en(we3), .wr_addr(wa3), .wr_data(wd3),
        .rd_en(rd_en[3]), .rd_addr(rd_addr3), .rd_data(rd_data3)
    );
    bram #(.DW(DW), .DEPTH(DEPTH), .ADDR_WIDTH(AW)) bank4 (
        .clk(clk),
        .wr_en(we4), .wr_addr(wa4), .wr_data(wd4),
        .rd_en(rd_en[4]), .rd_addr(rd_addr4), .rd_data(rd_data4)
    );
endmodule