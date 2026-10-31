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
    logic [2:0] current_state_monitor;

    // AXI Stream IFM
    logic [`AXI_BURST-1:0] ifm_tdata;
    logic ifm_tvalid;
    logic ifm_tlast;
    logic ifm_tready;

    // AXI Stream WGT
    logic [`AXI_BURST-1:0] wgt_tdata;
    logic wgt_tvalid;
    logic wgt_tlast;
    logic wgt_tready;

    // AXI Stream BIAS
    logic [`AXI_BURST-1:0] bias_tdata;
    logic bias_tvalid;
    logic bias_tlast;
    logic bias_tready;

    logic [15:0] img_width;
    logic [15:0] img_height;
    logic [2:0] kernel_size;
    logic [2:0] stride;
    logic [1:0] activation;
    logic [15:0] number_kernel;
    logic [1:0] pool_size, pool_stride;
    logic en_maxpooling;
    
    logic read_start_monitor, read_done_monitor, write_done_monitor;
    logic npu_done;
    top #(
        .DATA_WIDTH(`DATA_WIDTH),
        .AXI_BURST(`AXI_BURST),
        .IMG_SIZE(`IMG_SIZE),
        .DEPTH((`IMG_SIZE + 4) / 5),
        .WGT_SIZE(`WGT_SIZE),
        .BIAS_SIZE(`BIAS_SIZE),
        .IFM_ADDR_WIDTH(`IFM_ADDR_WIDTH),
        .WGT_ADDR_WIDTH(`WGT_ADDR_WIDTH),
        .BIAS_ADDR_WIDTH(`BIAS_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start_system(start_system),

        .start_load_monitor(start_load_monitor),
        .start_npu_monitor(start_npu_monitor),
        .ifm_done_monitor(ifm_done_monitor),
        .wgt_done_monitor(wgt_done_monitor),
        .bias_done_monitor(bias_done_monitor),

        .current_state_monitor(current_state_monitor),

        .ifm_tdata(ifm_tdata),
        .ifm_tvalid(ifm_tvalid),
        .ifm_tlast(ifm_tlast),
        .ifm_tready(ifm_tready),

        .wgt_tdata(wgt_tdata),
        .wgt_tvalid(wgt_tvalid),
        .wgt_tlast(wgt_tlast),
        .wgt_tready(wgt_tready),

        .bias_tdata(bias_tdata),
        .bias_tvalid(bias_tvalid),
        .bias_tlast(bias_tlast),
        .bias_tready(bias_tready),

        .img_width(img_width),
        .img_height(img_height),
        .kernel_size(kernel_size),
        .stride(stride),
        .activation(activation),
        .number_kernel(number_kernel),
        .pool_size(pool_size),
        .pool_stride(pool_stride),
        .en_maxpooling(en_maxpooling),
    
        .read_start_monitor(read_start_monitor), 
        .read_done_monitor(read_done_monitor), 
        .write_done_monitor(write_done_monitor),
        .npu_done(npu_done)
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
        .DATA_WIDTH(`DATA_WIDTH * 2),
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
        clk = 0; rst = 0; start_system = 0;
        img_width = 16'd32; img_height = 16'd32;
        kernel_size = 3'd5; stride = 3'd1;
        activation = 2'd1;
        number_kernel = 16'd5;
        pool_size = 2'd2; pool_stride = 2'd1;
        en_maxpooling = 1'b1;
        #13; rst = 1;
        #10; rst = 0;
        #10; start_system = 1;
        #10; start_system = 0;
        wait(npu_done == 1)
        #10; $finish;
    end
endmodule