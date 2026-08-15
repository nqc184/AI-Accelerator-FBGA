`timescale 1ns/1ps  

`define DATA_WIDTH 24
`define ADDR_WIDTH 10
`define IMG_SIZE 1024

module tb;
    logic clk, rst, start;
    //AXI Lite
    logic [31:0] axi_awaddr;
    logic        axi_awvalid;
    logic        axi_awready;

    logic [31:0] axi_wdata;
    logic [3:0]  axi_wstrb;
    logic        axi_wvalid;
    logic        axi_wready;

    logic [1:0]  axi_bresp;
    logic        axi_bvalid;
    logic        axi_bready;

    logic [15:0] img_width;
    logic [15:0] img_height;
    logic [2:0]  kernel_size;
    logic [2:0]  stride;
    logic [1:0]  activation;

    logic config_done;

    //AXI Stream
    logic signed [`DATA_WIDTH-1:0] ifm_tdata;
    logic ifm_tvalid;
    logic ifm_tlast;
    logic ifm_tready;

    logic signed [`DATA_WIDTH-1:0] wgt_tdata;
    logic wgt_tvalid;
    logic wgt_tlast;
    logic wgt_tready;

    logic signed [`DATA_WIDTH-1:0] bias_tdata;
    logic bias_tvalid;
    logic bias_tlast;
    logic bias_tready;

    logic start_load, start_compute;
    
    logic done_npu;

    top #(
        .DATA_WIDTH(`DATA_WIDTH),
        .ADDR_WIDTH(`ADDR_WIDTH),
        .IMG_SIZE(`IMG_SIZE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .config_done(config_done),
        //AXI Stream
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

        .start_load(start_load),
        .start_compute(start_compute),
        
        .img_width(img_width),
        .img_height(img_height),
        .kernel_size(kernel_size),
        .stride(stride),
        .activation(activation),
        
        .done_npu(done_npu)
    );

    // AXI Stream For IFM
    axi_stream_source_tb #(
        .DATA_WIDTH(24),
        .MEM_DEPTH(1024),
        .FILE_NAME("IFM.mem"),
        .ADDR_WIDTH(10)
    )ifm_source(
        .clk(clk),
        .rst(rst),
        .start(start_load),

        .m_axis_tdata(ifm_tdata),
        .m_axis_tvalid(ifm_tvalid),
        .m_axis_tlast(ifm_tlast),
        .m_axis_tready(ifm_tready)
    );

    //AXI Stream For WGT
    axi_stream_source_tb #(
        .DATA_WIDTH(24),
        .MEM_DEPTH(150),
        .FILE_NAME("WGT.mem"),
        .ADDR_WIDTH(10)
    )wgt_source(
        .clk(clk),
        .rst(rst),
        .start(start_load),
        .m_axis_tdata(wgt_tdata),
        .m_axis_tvalid(wgt_tvalid),
        .m_axis_tlast(wgt_tlast),
        .m_axis_tready(wgt_tready)
    );

    //AXI Stream For BIAS
    axi_stream_source_tb #(
        .DATA_WIDTH(24),
        .MEM_DEPTH(6),
        .FILE_NAME("BIAS.mem"),
        .ADDR_WIDTH(10)
    )bias_source(
        .clk(clk),
        .rst(rst),
        .start(start_load),
        .m_axis_tdata(bias_tdata),
        .m_axis_tvalid(bias_tvalid),
        .m_axis_tlast(bias_tlast),
        .m_axis_tready(bias_tready)
    );

    //AXI Lite 
    axi_lite_source_tb #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .MEM_DEPTH(5),
        .FILE_NAME("CONFIG.mem")
    ) config_source (
        .clk(clk),
        .rst(rst),
        .start(start_load),

        .s_axi_awaddr (axi_awaddr),
        .s_axi_awvalid(axi_awvalid),
        .s_axi_awready(axi_awready),

        .s_axi_wdata (axi_wdata),
        .s_axi_wstrb (axi_wstrb),
        .s_axi_wvalid(axi_wvalid),
        .s_axi_wready(axi_wready),

        .s_axi_bresp (axi_bresp),
        .s_axi_bvalid(axi_bvalid),
        .s_axi_bready(axi_bready)
    );

    axi_lite_slave #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32)
    ) config_slave (
        .clk(clk),
        .rst(rst),

        .s_axi_awaddr (axi_awaddr),
        .s_axi_awvalid(axi_awvalid),
        .s_axi_awready(axi_awready),

        .s_axi_wdata (axi_wdata),
        .s_axi_wstrb (axi_wstrb),
        .s_axi_wvalid(axi_wvalid),
        .s_axi_wready(axi_wready),

        .s_axi_bresp (axi_bresp),
        .s_axi_bvalid(axi_bvalid),
        .s_axi_bready(axi_bready),

        .s_axi_araddr (10'd0),
        .s_axi_arvalid(1'b0),
        .s_axi_arready(),

        .s_axi_rdata (),
        .s_axi_rresp (),
        .s_axi_rvalid(),
        .s_axi_rready(1'b0),

        .img_width(img_width),
        .img_height(img_height),
        .kernel_size(kernel_size),
        .stride(stride),
        .activation(activation),

        .config_done(config_done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;

        #10 rst = 0;

        #10 start = 1;
        #10 start = 0;

        wait(done_npu == 1)
        #150;
        $finish;
    end
endmodule