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
    logic [1:0] pool_size, pool_stride;
    logic en_maxpooling;

    logic [15:0] img_width_config_monitor;
    logic [15:0] img_height_config_monitor;
    logic [2:0] kernel_size_config_monitor;
    logic [2:0] stride_config_monitor;
    logic [1:0] activation_config_monitor;
    logic [15:0] number_kernel_config_monitor;
    logic [1:0] pool_size_config_monitor, pool_stride_config_monitor;
    logic en_maxpooling_config_monitor;
    logic [2:0] lane_count_monitor;

    logic start_config_pixel_buffer_loader_monitor;
    logic start_config_weight_buffer_loader_monitor;
    logic start_config_activation_monitor;
    logic start_config_ofm_monitor;
    logic start_config_maxpooling_monitor;

    logic done_config_pixel_buffer_loader_monitor;
    logic done_config_weight_buffer_loader_monitor;
    logic done_config_activation_monitor;
    logic done_config_ofm;
    logic done_config_maxpooling_monitor;

    logic rd_en_pixel_monitor, rd_en_wgt_monitor, rd_en_bias_monitor;
    logic valid_pixel_monitor, valid_wgt_monitor, valid_bias_monitor;

    logic signed [`DATA_WIDTH-1:0] rd_data_pixel_monitor, rd_data_wgt_monitor;
    logic signed [(`DATA_WIDTH*2)-1:0]rd_data_bias_monitor;

    logic [`IFM_ADDR_WIDTH-1:0] rd_addr_pixel_monitor;
    logic [`WGT_ADDR_WIDTH-1:0] rd_addr_wgt_monitor;
    logic [`BIAS_ADDR_WIDTH-1:0] rd_addr_bias_monitor;

    logic start_calc_monitor;
    logic clear_window_reg_monitor, clear_wgt_reg_monitor, clear_bias_reg_monitor;
    logic done_calc_monitor;

    logic valid_window_out_monitor;
    logic valid_wgt_out_monitor;
    logic last_window_out_monitor;
    logic [599:0] window_packed_monitor, weight_packed_monitor;
    logic [599:0] window_reg_0, window_reg_1, window_reg_2, window_reg_3, window_reg_4;
    logic [599:0] wgt_reg_0, wgt_reg_1, wgt_reg_2, wgt_reg_3, wgt_reg_4;

    logic [2:0] window_cnt_monitor;
    logic [2:0] wgt_cnt_monitor;
    logic [2:0] bias_cnt_monitor;

    logic [5:0] cycle_out_monitor;
    logic signed [`DATA_WIDTH-1:0] a1_monitor, a2_monitor, a3_monitor, a4_monitor, a5_monitor;
    logic signed [`DATA_WIDTH-1:0] b1_monitor, b2_monitor, b3_monitor, b4_monitor, b5_monitor;
    
    logic signed [47:0] c1_monitor, c2_monitor, c3_monitor, c4_monitor, c5_monitor;
    logic signed [47:0] c6_monitor, c7_monitor, c8_monitor, c9_monitor, c10_monitor;
    logic signed [47:0] c11_monitor, c12_monitor, c13_monitor, c14_monitor, c15_monitor;
    logic signed [47:0] c16_monitor, c17_monitor, c18_monitor, c19_monitor, c20_monitor;
    logic signed [47:0] c21_monitor, c22_monitor, c23_monitor, c24_monitor, c25_monitor;

    logic signed [47:0] col1_out_monitor, col2_out_monitor, col3_out_monitor, col4_out_monitor, col5_out_monitor;
    logic col1_valid_monitor, col2_valid_monitor, col3_valid_monitor, col4_valid_monitor, col5_valid_monitor;

    logic signed [47:0] bias_reg0_monitor, bias_reg1_monitor, bias_reg2_monitor, bias_reg3_monitor, bias_reg4_monitor;
    logic signed [47:0] bias_adder_result0_monitor, bias_adder_result1_monitor, bias_adder_result2_monitor, bias_adder_result3_monitor, bias_adder_result4_monitor;
    logic valid_bias_adder_result0_monitor, valid_bias_adder_result1_monitor, valid_bias_adder_result2_monitor, valid_bias_adder_result3_monitor, valid_bias_adder_result4_monitor;
    
    logic signed [47:0] activation_result0_monitor, activation_result1_monitor, activation_result2_monitor, activation_result3_monitor, activation_result4_monitor;
    logic valid_activation_result0_monitor, valid_activation_result1_monitor, valid_activation_result2_monitor, valid_activation_result3_monitor, valid_activation_result4_monitor;

    logic signed [23:0] quantization_result0_monitor, quantization_result1_monitor, quantization_result2_monitor, quantization_result3_monitor, quantization_result4_monitor;
    logic valid_quantization_result0_monitor, valid_quantization_result1_monitor, valid_quantization_result2_monitor, valid_quantization_result3_monitor, valid_quantization_result4_monitor;
    
    logic signed [23:0] maxpooling_result0_monitor, maxpooling_result1_monitor, maxpooling_result2_monitor, maxpooling_result3_monitor, maxpooling_result4_monitor;
    logic valid_maxpooling_result0_monitor, valid_maxpooling_result1_monitor, valid_maxpooling_result2_monitor, valid_maxpooling_result3_monitor, valid_maxpooling_result4_monitor;
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
        .pool_size(pool_size),
        .pool_stride(pool_stride),
        .en_maxpooling(en_maxpooling),
        .lane_count_monitor(lane_count_monitor),

        .img_width_config_monitor(img_width_config_monitor),
        .img_height_config_monitor(img_height_config_monitor),
        .kernel_size_config_monitor(kernel_size_config_monitor),
        .stride_config_monitor(stride_config_monitor),
        .activation_config_monitor(activation_config_monitor),
        .number_kernel_config_monitor(number_kernel_config_monitor),
        .pool_size_config_monitor(pool_size_config_monitor), .pool_stride_config_monitor(pool_stride_config_monitor),
        .en_maxpooling_config_monitor(en_maxpooling_config_monitor),

        .start_config_pixel_buffer_loader_monitor(start_config_pixel_buffer_loader_monitor),
        .start_config_weight_buffer_loader_monitor(start_config_weight_buffer_loader_monitor),
        .start_config_activation_monitor(start_config_activation_monitor),
        .start_config_maxpooling_monitor(start_config_maxpooling_monitor),
        .start_config_ofm_monitor(start_config_ofm_monitor),

        .done_config_pixel_buffer_loader_monitor(done_config_pixel_buffer_loader_monitor),
        .done_config_weight_buffer_loader_monitor(done_config_weight_buffer_loader_monitor),
        .done_config_activation_monitor(done_config_activation_monitor),
        .done_config_maxpooling_monitor(done_config_maxpooling_monitor),
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

        .start_calc_monitor(start_calc_monitor),
        .clear_window_reg_monitor(clear_window_reg_monitor), .clear_wgt_reg_monitor(clear_wgt_reg_monitor), .clear_bias_reg_monitor(clear_bias_reg_monitor),
        .done_calc_monitor(done_calc_monitor),

        .valid_window_out_monitor(valid_window_out_monitor),
        .valid_wgt_out_monitor(valid_wgt_out_monitor),
        .last_window_out_monitor(last_window_out_monitor),

        .window_packed_monitor(window_packed_monitor), .weight_packed_monitor(weight_packed_monitor),

        .window_reg_0(window_reg_0), .window_reg_1(window_reg_1), .window_reg_2(window_reg_2), .window_reg_3(window_reg_3), .window_reg_4(window_reg_4),
        .wgt_reg_0(wgt_reg_0), .wgt_reg_1(wgt_reg_1), .wgt_reg_2(wgt_reg_2), .wgt_reg_3(wgt_reg_3), .wgt_reg_4(wgt_reg_4),
        .window_cnt_monitor(window_cnt_monitor),
        .wgt_cnt_monitor(wgt_cnt_monitor),
        .bias_cnt_monitor(bias_cnt_monitor),

        .cycle_out_monitor(cycle_out_monitor),

        .a1_monitor(a1_monitor), .a2_monitor(a2_monitor), .a3_monitor(a3_monitor), .a4_monitor(a4_monitor), .a5_monitor(a5_monitor),
        .b1_monitor(b1_monitor), .b2_monitor(b2_monitor), .b3_monitor(b3_monitor), .b4_monitor(b4_monitor), .b5_monitor(b5_monitor),

        .c1_monitor(c1_monitor), .c2_monitor(c2_monitor), .c3_monitor(c3_monitor), .c4_monitor(c4_monitor), .c5_monitor(c5_monitor),
        .c6_monitor(c6_monitor), .c7_monitor(c7_monitor), .c8_monitor(c8_monitor), .c9_monitor(c9_monitor), .c10_monitor(c10_monitor),
        .c11_monitor(c11_monitor), .c12_monitor(c12_monitor), .c13_monitor(c13_monitor), .c14_monitor(c14_monitor), .c15_monitor(c15_monitor),
        .c16_monitor(c16_monitor), .c17_monitor(c17_monitor), .c18_monitor(c18_monitor), .c19_monitor(c19_monitor), .c20_monitor(c20_monitor),
        .c21_monitor(c21_monitor), .c22_monitor(c22_monitor), .c23_monitor(c23_monitor), .c24_monitor(c24_monitor), .c25_monitor(c25_monitor),

        .col1_out_monitor(col1_out_monitor), .col2_out_monitor(col2_out_monitor), .col3_out_monitor(col3_out_monitor), .col4_out_monitor(col4_out_monitor), .col5_out_monitor(col5_out_monitor),
        .col1_valid_monitor(col1_valid_monitor), .col2_valid_monitor(col2_valid_monitor), .col3_valid_monitor(col3_valid_monitor), .col4_valid_monitor(col4_valid_monitor), .col5_valid_monitor(col5_valid_monitor),
    
        .bias_reg0_monitor(bias_reg0_monitor), .bias_reg1_monitor(bias_reg1_monitor), .bias_reg2_monitor(bias_reg2_monitor), .bias_reg3_monitor(bias_reg3_monitor), .bias_reg4_monitor(bias_reg4_monitor),
        .bias_adder_result0_monitor(bias_adder_result0_monitor), .bias_adder_result1_monitor(bias_adder_result1_monitor), .bias_adder_result2_monitor(bias_adder_result2_monitor), .bias_adder_result3_monitor(bias_adder_result3_monitor), .bias_adder_result4_monitor(bias_adder_result4_monitor),
        .valid_bias_adder_result0_monitor(valid_bias_adder_result0_monitor), .valid_bias_adder_result1_monitor(valid_bias_adder_result1_monitor), .valid_bias_adder_result2_monitor(valid_bias_adder_result2_monitor), .valid_bias_adder_result3_monitor(valid_bias_adder_result3_monitor), .valid_bias_adder_result4_monitor(valid_bias_adder_result4_monitor),
        
        .activation_result0_monitor(activation_result0_monitor), .activation_result1_monitor(activation_result1_monitor), .activation_result2_monitor(activation_result2_monitor), .activation_result3_monitor(activation_result3_monitor), .activation_result4_monitor(activation_result4_monitor),
        .valid_activation_result0_monitor(valid_activation_result0_monitor), .valid_activation_result1_monitor(valid_activation_result1_monitor), .valid_activation_result2_monitor(valid_activation_result2_monitor), .valid_activation_result3_monitor(valid_activation_result3_monitor), .valid_activation_result4_monitor(valid_activation_result4_monitor),

        .quantization_result0_monitor(quantization_result0_monitor), .quantization_result1_monitor(quantization_result1_monitor), .quantization_result2_monitor(quantization_result2_monitor), .quantization_result3_monitor(quantization_result3_monitor), .quantization_result4_monitor(quantization_result4_monitor),
        .valid_quantization_result0_monitor(valid_quantization_result0_monitor), .valid_quantization_result1_monitor(valid_quantization_result1_monitor), .valid_quantization_result2_monitor(valid_quantization_result2_monitor), .valid_quantization_result3_monitor(valid_quantization_result3_monitor), .valid_quantization_result4_monitor(valid_quantization_result4_monitor),

        .maxpooling_result0_monitor(maxpooling_result0_monitor), .maxpooling_result1_monitor(maxpooling_result1_monitor), .maxpooling_result2_monitor(maxpooling_result2_monitor), .maxpooling_result3_monitor(maxpooling_result3_monitor), .maxpooling_result4_monitor(maxpooling_result4_monitor),
        .valid_maxpooling_result0_monitor(valid_maxpooling_result0_monitor), .valid_maxpooling_result1_monitor(valid_maxpooling_result1_monitor), .valid_maxpooling_result2_monitor(valid_maxpooling_result2_monitor), .valid_maxpooling_result3_monitor(valid_maxpooling_result3_monitor), .valid_maxpooling_result4_monitor(valid_maxpooling_result4_monitor)
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
        img_width = 16'd5; img_height = 16'd5;
        kernel_size = 3'd3; stride = 3'd1;
        activation = 2'd1;
        number_kernel = 16'd6;
        pool_size = 2'd2; pool_stride = 2'd1;
        en_maxpooling = 1'b1;
        done_config_ofm = 0;
        #13; rst = 1;
        #10; rst = 0;
        #10; start_system = 1;
        #10; start_system = 0;
        wait(done_config_pixel_buffer_loader_monitor == 1)
        #10; done_config_ofm = 1;
        #10; done_config_ofm = 0;
        wait(number_kernel_config_monitor == 15'd1)
        #5000; $finish;
    end
endmodule