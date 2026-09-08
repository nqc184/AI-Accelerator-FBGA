`timescale 1ns/1ps
`define DATA_WIDTH 24
`define AXI_BURST 128
`define IMG_SIZE 16384
`define WGT_SIZE 150
`define BIAS_SIZE 6
`define IFM_ADDR_WIDTH  14
`define WGT_ADDR_WIDTH  8
`define BIAS_ADDR_WIDTH 4

module top_tb();
    logic clk;
    logic rst;
    logic start_system;
    logic start_load_monitor, start_npu_monitor;
    logic ifm_done_monitor, wgt_done_monitor, bias_done_monitor;

    // AXI Stream IFM
    logic [`AXI_BURST-1:0] ifm_tdata;
    logic ifm_tvalid;
    logic ifm_tlast;
    logic ifm_tready;
    logic ifm_unpack_en_monitor;
    logic [`IFM_ADDR_WIDTH-1:0] ifm_unpack_wr_addr_monitor;
    logic [`DATA_WIDTH-1:0] ifm_unpack_data_monitor;

    // AXI Stream WGT
    logic [`AXI_BURST-1:0] wgt_tdata;
    logic wgt_tvalid;
    logic wgt_tlast;
    logic wgt_tready;
    logic wgt_unpack_en_monitor;
    logic [`WGT_ADDR_WIDTH-1:0] wgt_unpack_wr_addr_monitor;
    logic [`DATA_WIDTH-1:0] wgt_unpack_data_monitor;

    // AXI Stream BIAS
    logic [`AXI_BURST-1:0] bias_tdata;
    logic bias_tvalid;
    logic bias_tlast;
    logic bias_tready;
    logic bias_unpack_en_monitor;
    logic [`BIAS_ADDR_WIDTH-1:0] bias_unpack_wr_addr_monitor;
    logic [`DATA_WIDTH-1:0] bias_unpack_data_monitor;

    logic rd_en_pixel;
    logic [`IFM_ADDR_WIDTH-1:0] rd_addr_pixel;
    logic [`DATA_WIDTH-1:0] rd_data_pixel_monitor;

    logic rd_en_wgt;
    logic [`WGT_ADDR_WIDTH-1:0] rd_addr_wgt;
    logic [`DATA_WIDTH-1:0] rd_data_wgt_monitor;

    logic rd_en_bias;
    logic [`BIAS_ADDR_WIDTH-1:0] rd_addr_bias;
    logic [`DATA_WIDTH-1:0] rd_data_bias_monitor;

    top #(
        .DATA_WIDTH(`DATA_WIDTH),
        .AXI_BURST(`AXI_BURST),
        .IMG_SIZE(`IMG_SIZE),
        .WGT_SIZE(`WGT_SIZE),
        .BIAS_SIZE(`BIAS_SIZE),
        .IFM_ADDR_WIDTH(`IFM_ADDR_WIDTH),
        .WGT_ADDR_WIDTH(`WGT_ADDR_WIDTH),
        .BIAS_ADDR_WIDTH(`BIAS_ADDR_WIDTH)
    ) top_inst (
        .clk(clk),
        .rst(rst),
        .start_system(start_system),

        .start_load_monitor(start_load_monitor),
        .start_npu_monitor(start_npu_monitor),
        .ifm_done_monitor(ifm_done_monitor),
        .wgt_done_monitor(wgt_done_monitor),
        .bias_done_monitor(bias_done_monitor),

        .ifm_tdata(ifm_tdata),
        .ifm_tvalid(ifm_tvalid),
        .ifm_tlast(ifm_tlast),
        .ifm_tready(ifm_tready),
        .ifm_unpack_en_monitor(ifm_unpack_en_monitor),
        .ifm_unpack_wr_addr_monitor(ifm_unpack_wr_addr_monitor),
        .ifm_unpack_data_monitor(ifm_unpack_data_monitor),

        .wgt_tdata(wgt_tdata),
        .wgt_tvalid(wgt_tvalid),
        .wgt_tlast(wgt_tlast),
        .wgt_tready(wgt_tready),
        .wgt_unpack_en_monitor(wgt_unpack_en_monitor),
        .wgt_unpack_wr_addr_monitor(wgt_unpack_wr_addr_monitor),
        .wgt_unpack_data_monitor(wgt_unpack_data_monitor),

        .bias_tdata(bias_tdata),
        .bias_tvalid(bias_tvalid),
        .bias_tlast(bias_tlast),
        .bias_tready(bias_tready),
        .bias_unpack_en_monitor(bias_unpack_en_monitor),
        .bias_unpack_wr_addr_monitor(bias_unpack_wr_addr_monitor),
        .bias_unpack_data_monitor(bias_unpack_data_monitor),

        .rd_en_pixel(rd_en_pixel),
        .rd_addr_pixel(rd_addr_pixel),
        .rd_data_pixel_monitor(rd_data_pixel_monitor),

        .rd_en_wgt(rd_en_wgt),
        .rd_addr_wgt(rd_addr_wgt),
        .rd_data_wgt_monitor(rd_data_wgt_monitor),

        .rd_en_bias(rd_en_bias),
        .rd_addr_bias(rd_addr_bias),
        .rd_data_bias_monitor(rd_data_bias_monitor)
    );

    axi_stream_source_tb #(
        .DATA_WIDTH(`DATA_WIDTH),
        .MEM_DEPTH(`IMG_SIZE),
        .FILE_NAME("IFM.mem"),
        .ADDR_WIDTH(`IFM_ADDR_WIDTH)
    ) axi_stream_ifm (
        .clk(clk),
        .rst(rst),
        .start(start_load_monitor),
        .m_axis_tdata(ifm_tdata),
        .m_axis_tvalid(ifm_tvalid),
        .m_axis_tlast(ifm_tlast),
        .m_axis_tready(ifm_tready)
    );

    axi_stream_source_tb #(
        .DATA_WIDTH(`DATA_WIDTH),
        .MEM_DEPTH(`WGT_SIZE),
        .FILE_NAME("WGT.mem"),
        .ADDR_WIDTH(`WGT_ADDR_WIDTH)
    ) axi_stream_wgt (
        .clk(clk),
        .rst(rst),
        .start(start_load_monitor),
        .m_axis_tdata(wgt_tdata),
        .m_axis_tvalid(wgt_tvalid),
        .m_axis_tlast(wgt_tlast),
        .m_axis_tready(wgt_tready)
    );

    axi_stream_source_tb #(
        .DATA_WIDTH(`DATA_WIDTH),
        .MEM_DEPTH(`BIAS_SIZE),
        .FILE_NAME("BIAS.mem"),
        .ADDR_WIDTH(`BIAS_ADDR_WIDTH)
    ) axi_stream_bias (
        .clk(clk),
        .rst(rst),
        .start(start_load_monitor),
        .m_axis_tdata(bias_tdata),
        .m_axis_tvalid(bias_tvalid),
        .m_axis_tlast(bias_tlast),
        .m_axis_tready(bias_tready)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start_system = 0;
        rd_en_pixel = 0; rd_en_wgt = 0; rd_en_bias = 0;
        rd_addr_pixel = 0; rd_addr_wgt = 0; rd_addr_bias = 0;
        #13; rst = 0;
        #10; start_system = 1;
        #10; start_system = 0;
        wait(ifm_done_monitor);
        for(int i = 0; i < 50; i++) begin
            rd_en_pixel = 1;
            rd_addr_pixel = i;
            rd_en_wgt = 1;
            rd_addr_wgt = i;
            rd_en_bias = 1;
            rd_addr_bias = i;
            #10;
        end
        rd_en_pixel = 0; rd_en_wgt = 0; rd_en_bias = 0;
        rd_addr_pixel = 0; rd_addr_wgt = 0; rd_addr_bias = 0;
        #10; $finish;
    end
endmodule