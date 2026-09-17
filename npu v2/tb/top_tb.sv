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

    logic [15:0] img_width;
    logic [15:0] img_height;
    logic [2:0] kernel_size;
    logic [2:0] stride;
    logic [1:0] activation;
    logic [15:0] number_kernel;

    logic [15:0] img_width_config_monitor;
    logic [15:0] img_height_config_monitor;
    logic [2:0] kernel_size_config_monitor;
    logic [2:0] stride_config_monitor;
    logic [1:0] activation_config_monitor;
    logic [15:0] number_kernel_config_monitor;

    logic start_config_pixel_buffer_loader_monitor;
    logic start_config_weight_buffer_loader_monitor;
    logic start_config_activation_monitor;
    logic start_config_ofm_monitor;

    logic done_config_pixel_buffer_loader;
    logic done_config_weight_buffer_loader;
    logic done_config_activation;
    logic done_config_ofm;

    logic rd_en_pixel_monitor;
    logic rd_en_wgt_monitor;
    logic rd_en_bias_monitor;
    logic valid_pixel_monitor;
    logic valid_wgt_monitor;
    logic valid_bias_monitor;

    logic signed [`DATA_WIDTH-1:0] rd_data_pixel_monitor;
    logic signed [`DATA_WIDTH-1:0] rd_data_wgt_monitor;
    logic signed [`DATA_WIDTH-1:0] rd_data_bias_monitor;

    logic [`IFM_ADDR_WIDTH-1:0] rd_addr_pixel_monitor;
    logic [`WGT_ADDR_WIDTH-1:0] rd_addr_wgt_monitor;
    logic [`BIAS_ADDR_WIDTH-1:0] rd_addr_bias_monitor;

    logic start_calc;
    logic done_calc;

    logic valid_window_out;
    logic valid_wgt_out;
    logic last_window_out;

    logic [2:0] window_cnt_monitor;
    logic [2:0] wgt_cnt_monitor;
    logic [2:0] bias_cnt_monitor;

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

        .img_width(img_width),
        .img_height(img_height),
        .kernel_size(kernel_size),
        .stride(stride),
        .activation(activation),
        .number_kernel(number_kernel),

        .img_width_config_monitor(img_width_config_monitor),
        .img_height_config_monitor(img_height_config_monitor),
        .kernel_size_config_monitor(kernel_size_config_monitor),
        .stride_config_monitor(stride_config_monitor),
        .activation_config_monitor(activation_config_monitor),
        .number_kernel_config_monitor(number_kernel_config_monitor),

        .start_config_pixel_buffer_loader_monitor(start_config_pixel_buffer_loader_monitor),
        .start_config_weight_buffer_loader_monitor(start_config_weight_buffer_loader_monitor),
        .start_config_activation_monitor(start_config_activation_monitor),
        .start_config_ofm_monitor(start_config_ofm_monitor),

        .done_config_pixel_buffer_loader(done_config_pixel_buffer_loader),
        .done_config_weight_buffer_loader(done_config_weight_buffer_loader),
        .done_config_activation(done_config_activation),
        .done_config_ofm(done_config_ofm),

        .rd_en_pixel_monitor(rd_en_pixel_monitor),
        .rd_en_wgt_monitor(rd_en_wgt_monitor),
        .rd_en_bias_monitor(rd_en_bias_monitor),

        .valid_pixel_monitor(valid_pixel_monitor), .valid_wgt_monitor(valid_wgt_monitor), .valid_bias_monitor(valid_bias_monitor),

        .rd_data_pixel_monitor(rd_data_pixel_monitor),
        .rd_data_wgt_monitor(rd_data_wgt_monitor),
        .rd_data_bias_monitor(rd_data_bias_monitor),

        .rd_addr_pixel_monitor(rd_addr_pixel_monitor),
        .rd_addr_wgt_monitor(rd_addr_wgt_monitor),
        .rd_addr_bias_monitor(rd_addr_bias_monitor),

        .start_calc(start_calc),
        .done_calc(done_calc),

        .valid_window_out(valid_window_out),
        .valid_wgt_out(valid_wgt_out),
        .last_window_out(last_window_out),

        .window_cnt_monitor(window_cnt_monitor),
        .wgt_cnt_monitor(wgt_cnt_monitor),
        .bias_cnt_monitor(bias_cnt_monitor)
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
        clk = 0; rst = 0; start_system = 0;
        img_width = 16'd15; img_height = 16'd15;
        kernel_size = 3'd3; stride = 3'd1;
        activation = 2'd1;
        number_kernel = 16'd6;
        done_calc = 0;
        valid_window_out = 0; valid_wgt_out = 0; last_window_out = 0;
        #13; rst = 1;
        #10; rst = 0;
        #10; start_system = 1;
        #10; start_system = 0;
        wait(start_config_pixel_buffer_loader_monitor == 1)
        #10; done_config_pixel_buffer_loader = 1;
        done_config_weight_buffer_loader = 1;
        done_config_activation = 1; 
        done_config_ofm = 1;
        #10; done_config_pixel_buffer_loader = 0;
        done_config_weight_buffer_loader = 0;
        done_config_activation = 0; 
        done_config_ofm = 0;
        #200; $finish;
    end
endmodule