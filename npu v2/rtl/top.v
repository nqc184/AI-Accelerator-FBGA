module top #(
    parameter DATA_WIDTH = 24,
    parameter AXI_BURST = 128,
    parameter IMG_SIZE = 16384,
    parameter WGT_SIZE = 150,
    parameter BIAS_SIZE = 6,
    parameter IFM_ADDR_WIDTH  = 14,
    parameter WGT_ADDR_WIDTH  = 8,
    parameter BIAS_ADDR_WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire start_system,
    output start_load_monitor, start_npu_monitor,
    output ifm_done_monitor, wgt_done_monitor, bias_done_monitor,
 
    // AXI Stream IFM
    input  wire [AXI_BURST-1:0] ifm_tdata,
    input  wire ifm_tvalid,
    input  wire ifm_tlast,
    output wire ifm_tready,
    output [DATA_WIDTH-1:0] ifm_unpack_data_monitor,
    output ifm_unpack_en_monitor,
 
    // AXI Stream WGT
    input  wire [AXI_BURST-1:0] wgt_tdata,
    input  wire wgt_tvalid,
    input  wire wgt_tlast,
    output wire wgt_tready,
    output [DATA_WIDTH-1:0] wgt_unpack_data_monitor,
    output wgt_unpack_en_monitor,
 
    // AXI Stream BIAS
    input  wire [AXI_BURST-1:0] bias_tdata,
    input  wire bias_tvalid,
    input  wire bias_tlast,
    output wire bias_tready,
    output [DATA_WIDTH-1:0] bias_unpack_data_monitor,
    output bias_unpack_en_monitor
);
    //System Controller
    wire start_load, start_npu;
    assign start_load_monitor = start_load;
    assign start_npu_monitor  = start_npu;
 
    wire ifm_done, wgt_done, bias_done;
    assign ifm_done_monitor  = ifm_done;
    assign wgt_done_monitor  = wgt_done;
    assign bias_done_monitor = bias_done;
 
    system_controller system_controller_inst (
        .clk(clk), .rst(rst), .start(start_system),
        .ifm_done(ifm_done), .wgt_done(wgt_done), .bias_done(bias_done),
        .start_load(start_load), .start_npu(start_npu)
    );
 
    //Axi Unpack
    wire ifm_unpack_wr_en;
    wire [IFM_ADDR_WIDTH-1:0] ifm_unpack_wr_addr;
    wire signed [DATA_WIDTH-1:0] ifm_unpack_wr_data;
    assign ifm_unpack_en_monitor   = ifm_unpack_wr_en;
    assign ifm_unpack_data_monitor = ifm_unpack_wr_data;
 
    wire wgt_unpack_wr_en;
    wire [WGT_ADDR_WIDTH-1:0] wgt_unpack_wr_addr;
    wire signed [DATA_WIDTH-1:0] wgt_unpack_wr_data;
    assign wgt_unpack_en_monitor   = wgt_unpack_wr_en;
    assign wgt_unpack_data_monitor = wgt_unpack_wr_data;
 
    wire bias_unpack_wr_en;
    wire [BIAS_ADDR_WIDTH-1:0] bias_unpack_wr_addr;
    wire signed [DATA_WIDTH-1:0] bias_unpack_wr_data;
    assign bias_unpack_en_monitor   = bias_unpack_wr_en;
    assign bias_unpack_data_monitor = bias_unpack_wr_data;
 
    axi_unpack_writer #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(IFM_ADDR_WIDTH)) uw_ifm (
        .clk(clk), .rst(rst),
        .s_axis_tdata(ifm_tdata), .s_axis_tvalid(ifm_tvalid),
        .s_axis_tlast(ifm_tlast), .s_axis_tready(ifm_tready),
        .bram_wr_en(ifm_unpack_wr_en), .bram_wr_addr(ifm_unpack_wr_addr), .bram_wr_data(ifm_unpack_wr_data),
        .done(ifm_done)
    );
 
    axi_unpack_writer #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(WGT_ADDR_WIDTH)) uw_wgt (
        .clk(clk), .rst(rst),
        .s_axis_tdata(wgt_tdata), .s_axis_tvalid(wgt_tvalid),
        .s_axis_tlast(wgt_tlast), .s_axis_tready(wgt_tready),
        .bram_wr_en(wgt_unpack_wr_en), .bram_wr_addr(wgt_unpack_wr_addr), .bram_wr_data(wgt_unpack_wr_data),
        .done(wgt_done)
    );
 
    axi_unpack_writer #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(BIAS_ADDR_WIDTH)) uw_bias (
        .clk(clk), .rst(rst),
        .s_axis_tdata(bias_tdata), .s_axis_tvalid(bias_tvalid),
        .s_axis_tlast(bias_tlast), .s_axis_tready(bias_tready),
        .bram_wr_en(bias_unpack_wr_en), .bram_wr_addr(bias_unpack_wr_addr), .bram_wr_data(bias_unpack_wr_data),
        .done(bias_done)
    );
endmodule