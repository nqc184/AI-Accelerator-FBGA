module top #(
    parameter DATA_WIDTH = 24,
    parameter AXI_BURST = 128,
    parameter IMG_SIZE = 16384,
    parameter DEPTH = (IMG_SIZE + 4) / 5,
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

    //NPU controller
    output [2:0] current_state_monitor,
 
    // AXI Stream IFM
    input  wire [AXI_BURST-1:0] ifm_tdata,
    input  wire ifm_tvalid,
    input  wire ifm_tlast,
    output wire ifm_tready,
    output ifm_unpack_en_monitor,
    output [IFM_ADDR_WIDTH-1:0] ifm_unpack_wr_addr_monitor,
    output [DATA_WIDTH-1:0] ifm_unpack_data_monitor,
 
    // AXI Stream WGT
    input  wire [AXI_BURST-1:0] wgt_tdata,
    input  wire wgt_tvalid,
    input  wire wgt_tlast,
    output wire wgt_tready,
    output wgt_unpack_en_monitor,
    output [WGT_ADDR_WIDTH-1:0] wgt_unpack_wr_addr_monitor,
    output [DATA_WIDTH-1:0] wgt_unpack_data_monitor,
 
    // AXI Stream BIAS
    input  wire [AXI_BURST-1:0] bias_tdata,
    input  wire bias_tvalid,
    input  wire bias_tlast,
    output wire bias_tready,
    output bias_unpack_en_monitor,
    output [BIAS_ADDR_WIDTH-1:0] bias_unpack_wr_addr_monitor,
    output [DATA_WIDTH-1:0] bias_unpack_data_monitor,

    input [15:0] img_width, img_height,
    input [2:0] kernel_size, stride,
    input [1:0] activation,
    input [15:0] number_kernel,
    output [15:0] img_width_config_monitor, img_height_config_monitor,
    output [2:0] kernel_size_config_monitor, stride_config_monitor,
    output [1:0] activation_config_monitor,
    output [15:0] number_kernel_config_monitor,

    output start_config_pixel_buffer_loader_monitor, start_config_weight_buffer_loader_monitor,
    output start_config_activation_monitor, start_config_ofm_monitor,

    input done_config_pixel_buffer_loader, done_config_weight_buffer_loader,
    input done_config_activation, done_config_ofm,

    output rd_en_pixel_monitor, rd_en_wgt_monitor, rd_en_bias_monitor,
    output signed [DATA_WIDTH-1:0] rd_data_pixel_monitor, rd_data_wgt_monitor, rd_data_bias_monitor,
    output [IFM_ADDR_WIDTH-1:0] rd_addr_pixel_monitor,
    output [WGT_ADDR_WIDTH-1:0] rd_addr_wgt_monitor,
    output [BIAS_ADDR_WIDTH-1:0] rd_addr_bias_monitor,

    output start_calc,
    input done_calc,
    input valid_window_out, valid_wgt_out, last_window_out,
    output [2:0] window_cnt_monitor, wgt_cnt_monitor, bias_cnt_monitor
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
    assign ifm_unpack_wr_addr_monitor = ifm_unpack_wr_addr;
 
    wire wgt_unpack_wr_en;
    wire [WGT_ADDR_WIDTH-1:0] wgt_unpack_wr_addr;
    wire signed [DATA_WIDTH-1:0] wgt_unpack_wr_data;
    assign wgt_unpack_en_monitor   = wgt_unpack_wr_en;
    assign wgt_unpack_data_monitor = wgt_unpack_wr_data;
    assign wgt_unpack_wr_addr_monitor = wgt_unpack_wr_addr;
 
    wire bias_unpack_wr_en;
    wire [BIAS_ADDR_WIDTH-1:0] bias_unpack_wr_addr;
    wire signed [DATA_WIDTH-1:0] bias_unpack_wr_data;
    assign bias_unpack_en_monitor   = bias_unpack_wr_en;
    assign bias_unpack_data_monitor = bias_unpack_wr_data;
    assign bias_unpack_wr_addr_monitor = bias_unpack_wr_addr;
 
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

    //NPU controller 
    wire [15:0] img_width_config, img_height_config;
    wire [2:0] kernel_size_config, stride_config;
    wire [1:0] activation_config;
    wire [15:0] number_kernel_config;

    assign img_width_config_monitor = img_width_config;
    assign img_height_config_monitor = img_height_config;
    assign kernel_size_config_monitor = kernel_size_config;
    assign stride_config_monitor = stride_config;
    assign activation_config_monitor = activation_config;
    assign number_kernel_config_monitor = number_kernel_config;

    wire start_config_pixel_buffer_loader, start_config_weight_buffer_loader;
    wire start_config_activation, start_config_ofm;

    assign start_config_pixel_buffer_loader_monitor = start_config_pixel_buffer_loader;
    assign start_config_weight_buffer_loader_monitor = start_config_weight_buffer_loader;
    assign start_config_activation_monitor = start_config_activation;
    assign start_config_ofm_monitor = start_config_ofm;

    wire rd_en_pixel, rd_en_wgt, rd_en_bias;
    wire signed [DATA_WIDTH-1:0] rd_data_pixel, rd_data_wgt, rd_data_bias;
    wire [IFM_ADDR_WIDTH-1:0] rd_addr_pixel;
    wire [WGT_ADDR_WIDTH-1:0] rd_addr_wgt;
    wire [BIAS_ADDR_WIDTH-1:0] rd_addr_bias;

    assign rd_en_pixel_monitor = rd_en_pixel; 
    assign rd_en_wgt_monitor = rd_en_wgt; 
    assign rd_en_bias_monitor = rd_en_bias;
    assign rd_data_pixel_monitor = rd_data_pixel; 
    assign rd_data_wgt_monitor = rd_data_wgt; 
    assign rd_data_bias_monitor = rd_data_bias;
    assign rd_addr_pixel_monitor = rd_addr_pixel;
    assign rd_addr_wgt_monitor = rd_addr_wgt;
    assign rd_addr_bias_monitor = rd_addr_bias;

    npu_controller npu_controller_inst(
        .clk(clk), .rst(rst), .start_npu(start_npu),
        .current_state_monitor(current_state_monitor),

        .img_width(img_width), .img_height(img_height),
        .kernel_size(kernel_size), .stride(stride),
        .activation(activation),
        .number_kernel(number_kernel),

        .img_width_config(img_width_config), .img_height_config(img_height_config),
        .kernel_size_config(kernel_size_config), .stride_config(stride_config),
        .activation_config(activation_config),
        .number_kernel_monitor(number_kernel_config),

        .start_config_pixel_buffer_loader(start_config_pixel_buffer_loader), .start_config_weight_buffer_loader(start_config_weight_buffer_loader),
        .start_config_activation(start_config_activation), .start_config_ofm(start_config_ofm),

        .done_config_pixel_buffer_loader(done_config_pixel_buffer_loader), .done_config_weight_buffer_loader(done_config_weight_buffer_loader),
        .done_config_activation(done_config_activation), .done_config_ofm(done_config_ofm),

        .rd_en_pixel(rd_en_pixel), 
        .rd_addr_pixel(rd_addr_pixel), 
        .rd_en_wgt(rd_en_wgt), 
        .rd_addr_wgt(rd_addr_wgt), 
        .rd_en_bias(rd_en_bias), 
        .rd_addr_bias(rd_addr_bias), 

        .start_calc(start_calc),
        .done_calc(done_calc),

        .valid_window_out(valid_window_out), .valid_wgt_out(valid_wgt_out),
        .last_window_out(last_window_out),

        .window_cnt_monitor(window_cnt_monitor), .wgt_cnt_monitor(wgt_cnt_monitor), .bias_cnt_monitor(bias_cnt_monitor)
    );

    //On chip Memory
    //Pixel
    bram #(.DW(DATA_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(IFM_ADDR_WIDTH)) ifm_bram (
        .clk(clk),
        .wr_en(ifm_unpack_wr_en), .wr_addr(ifm_unpack_wr_addr), .wr_data(ifm_unpack_wr_data),
        .rd_en(rd_en_pixel), .rd_addr(rd_addr_pixel), .rd_data(rd_data_pixel)
    );

    //Weight
    bram #(.DW(DATA_WIDTH), .DEPTH(WGT_SIZE), .ADDR_WIDTH(WGT_ADDR_WIDTH)) wgt_bram (
        .clk(clk),
        .wr_en(wgt_unpack_wr_en), .wr_addr(wgt_unpack_wr_addr), .wr_data(wgt_unpack_wr_data),
        .rd_en(rd_en_wgt), .rd_addr(rd_addr_wgt), .rd_data(rd_data_wgt)
    );

    //Bias 
    bram #(.DW(DATA_WIDTH), .DEPTH(BIAS_SIZE), .ADDR_WIDTH(BIAS_ADDR_WIDTH)) bias_bram (
        .clk(clk),
        .wr_en(bias_unpack_wr_en), .wr_addr(bias_unpack_wr_addr), .wr_data(bias_unpack_wr_data),
        .rd_en(rd_en_bias), .rd_addr(rd_addr_bias), .rd_data(rd_data_bias)
    );
endmodule