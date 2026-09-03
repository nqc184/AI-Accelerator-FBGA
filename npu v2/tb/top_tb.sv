`timescale 1ns/1ps
`define DATA_WIDTH 24
`define AXI_BURST 128
`define IMG_SIZE 16384
`define BUFFER_DEPTH (`IMG_SIZE + 4) / 5
`define BUFFER_ADDR_WIDTH  12                   
`define BUFFER_CNT_WIDTH 14  
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
    logic [`AXI_BURST-1:0] ifm_wr_data_monitor; 

    // AXI Stream WGT
    logic [`AXI_BURST-1:0] wgt_tdata;
    logic wgt_tvalid;
    logic wgt_tlast;
    logic wgt_tready;
    logic [`AXI_BURST-1:0] wgt_wr_data_monitor;

    // AXI Stream BIAS
    logic [`AXI_BURST-1:0] bias_tdata;
    logic bias_tvalid;
    logic bias_tlast;
    logic bias_tready;
    logic [`AXI_BURST-1:0] bias_wr_data_monitor;

    top #(
        .DATA_WIDTH(`DATA_WIDTH),
        .AXI_BURST(`AXI_BURST),
        .IMG_SIZE(`IMG_SIZE),
        .BUFFER_DEPTH(`BUFFER_DEPTH),
        .BUFFER_ADDR_WIDTH(`BUFFER_ADDR_WIDTH),
        .BUFFER_CNT_WIDTH(`BUFFER_CNT_WIDTH)
    ) top_inst (
        .clk(clk),
        .rst(rst),
        .start_system(start_system),

        .start_load_monitor(start_load_monitor),
        .start_npu_monitor(start_npu_monitor),
        .ifm_done_monitor(ifm_done_monitor),
        .wgt_done_monitor(wgt_done_monitor),
        .bias_done_monitor(bias_done_monitor),

        // AXI Stream IFM
        .ifm_tdata(ifm_tdata),
        .ifm_tvalid(ifm_tvalid),
        .ifm_tlast(ifm_tlast),
        .ifm_tready(ifm_tready),
        .ifm_wr_data_monitor(ifm_wr_data_monitor),

        // AXI Stream WGT
        .wgt_tdata(wgt_tdata),
        .wgt_tvalid(wgt_tvalid),
        .wgt_tlast(wgt_tlast),
        .wgt_tready(wgt_tready),
        .wgt_wr_data_monitor(wgt_wr_data_monitor),

        // AXI Stream BIAS
        .bias_tdata(bias_tdata),
        .bias_tvalid(bias_tvalid),
        .bias_tlast(bias_tlast),
        .bias_tready(bias_tready),
        .bias_wr_data_monitor(bias_wr_data_monitor)
    );

    axi_stream_source_tb #(
        .DATA_WIDTH(`DATA_WIDTH),
        .MEM_DEPTH(`IMG_SIZE),
        .FILE_NAME("IFM.mem"),
        .ADDR_WIDTH(14)
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
        .MEM_DEPTH(`IMG_SIZE),
        .FILE_NAME("WGT.mem"),
        .ADDR_WIDTH(14)
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
        .MEM_DEPTH(`IMG_SIZE),
        .FILE_NAME("BIAS.mem"),
        .ADDR_WIDTH(14)
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
        #13; rst = 0;
        #10; start_system = 1;
        #10; start_system = 0;
        wait(ifm_done_monitor);
        #10; $finish;
    end
endmodule