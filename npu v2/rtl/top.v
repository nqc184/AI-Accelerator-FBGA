module top #(
    parameter DATA_WIDTH = 24,
    parameter AXI_BURST = 128,
    parameter IMG_SIZE = 16384,
    parameter BUFFER_DEPTH = (IMG_SIZE + 4) / 5,  
    parameter BUFFER_ADDR_WIDTH  = 12,                   
    parameter BUFFER_CNT_WIDTH = 14   
)(
    input clk, rst,
    input start_system,

    //System Control
    output start_load_monitor, start_npu_monitor,

    //Memory Control
    output ifm_done_monitor,
    output wgt_done_monitor,
    output bias_done_monitor,
    output ifm_wr_en_monitor,
    output [AXI_BURST-1:0] ifm_wr_data_monitor,
    output wgt_wr_en_monitor,
    output [AXI_BURST-1:0] wgt_wr_data_monitor,
    output bias_wr_en_monitor,
    output [AXI_BURST-1:0] bias_wr_data_monitor,

    //AXI STREAM
    input signed [AXI_BURST-1:0] ifm_tdata,
    input ifm_tvalid,
    input ifm_tlast,
    output ifm_tready,

    input signed [AXI_BURST-1:0] wgt_tdata,
    input wgt_tvalid,
    input wgt_tlast,
    output wgt_tready,

    input signed [AXI_BURST-1:0] bias_tdata,
    input bias_tvalid,
    input bias_tlast,
    output bias_tready
);
    //System Controll
    wire start_load, start_npu;
    assign start_load_monitor = start_load;
    assign start_npu_monitor = start_npu;
    wire ifm_done;
    wire wgt_done;
    wire bias_done;
    assign ifm_done_monitor = ifm_done;
    assign wgt_done_monitor = wgt_done;
    assign bias_done_monitor = bias_done;
    system_controller system_controller_inst (
        .clk(clk),
        .rst(rst),
        .start(start_system),
        .ifm_done(ifm_done),
        .wgt_done(wgt_done),
        .bias_done(bias_done),
        .start_load(start_load),
        .start_npu(start_npu)
    );

    //Memory Controller
    wire ifm_wr_en; 
    wire [AXI_BURST-1:0] ifm_wr_data;
    wire wgt_wr_en;
    wire [AXI_BURST-1:0] wgt_wr_data;
    wire bias_wr_en;
    wire [AXI_BURST-1:0] bias_wr_data;
    assign ifm_wr_data_monitor = ifm_wr_data;
    assign wgt_wr_en_monitor = wgt_wr_en;
    assign wgt_wr_data_monitor = wgt_wr_data;
    assign bias_wr_en_monitor = bias_wr_en;
    assign bias_wr_data_monitor = bias_wr_data;
    memory_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .AXI_BURST(AXI_BURST)
    ) memory_controller_inst (
        .clk(clk),
        .rst(rst),
        .start_load(start_load),

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

        .ifm_wr_en(ifm_wr_en),
        .ifm_wr_data(ifm_wr_data),

        .wgt_wr_en(wgt_wr_en),
        .wgt_wr_data(wgt_wr_data),

        .bias_wr_en(bias_wr_en),
        .bias_wr_data(bias_wr_data),

        .ifm_done(ifm_done),
        .wgt_done(wgt_done),
        .bias_done(bias_done),

        .npu_out_data(0),
        .npu_out_valid(0),
        .npu_out_last(0),
        .compute_done(0),

        .npu_out_ready(),

        .out_wr_en(),
        .out_wr_data(),

        .done_load_in(),
        .done_load_out()
    );
endmodule