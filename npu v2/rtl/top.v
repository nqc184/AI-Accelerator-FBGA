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
    output [(DATA_WIDTH*2)-1:0] bias_unpack_data_monitor,

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

    output done_config_pixel_buffer_loader_monitor, done_config_weight_buffer_loader_monitor,
    input done_config_activation, done_config_ofm,

    output rd_en_pixel_monitor, rd_en_wgt_monitor, rd_en_bias_monitor,
    output valid_pixel_monitor, valid_wgt_monitor, valid_bias_monitor, 
    output signed [DATA_WIDTH-1:0] rd_data_pixel_monitor, rd_data_wgt_monitor, rd_data_bias_monitor,
    output [IFM_ADDR_WIDTH-1:0] rd_addr_pixel_monitor,
    output [WGT_ADDR_WIDTH-1:0] rd_addr_wgt_monitor,
    output [BIAS_ADDR_WIDTH-1:0] rd_addr_bias_monitor,

    output start_calc_monitor,
    output done_calc_monitor,
    output clear_window_reg_monitor, clear_wgt_reg_monitor, clear_bias_reg_monitor,
    output valid_window_out_monitor, valid_wgt_out_monitor, last_window_out_monitor,
    output [599:0] window_packed_monitor, weight_packed_monitor,
    output [599:0] window_reg_0, window_reg_1, window_reg_2, window_reg_3, window_reg_4,
    output [599:0] wgt_reg_0, wgt_reg_1, wgt_reg_2, wgt_reg_3, wgt_reg_4,
    output [2:0] window_cnt_monitor, wgt_cnt_monitor, bias_cnt_monitor,

    output [5:0] cycle_out_monitor,
    output signed [DATA_WIDTH-1:0] a1_monitor, a2_monitor, a3_monitor, a4_monitor, a5_monitor,
    output signed [DATA_WIDTH-1:0] b1_monitor, b2_monitor, b3_monitor, b4_monitor, b5_monitor,
    
    output signed [47:0] c1_monitor, c2_monitor, c3_monitor, c4_monitor, c5_monitor,
    output signed [47:0] c6_monitor, c7_monitor, c8_monitor, c9_monitor, c10_monitor,
    output signed [47:0] c11_monitor, c12_monitor, c13_monitor, c14_monitor, c15_monitor,
    output signed [47:0] c16_monitor, c17_monitor, c18_monitor, c19_monitor, c20_monitor,
    output signed [47:0] c21_monitor, c22_monitor, c23_monitor, c24_monitor, c25_monitor,

    output signed [47:0] col1_out_monitor, col2_out_monitor, col3_out_monitor, col4_out_monitor, col5_out_monitor,
    output col1_valid_monitor, col2_valid_monitor, col3_valid_monitor, col4_valid_monitor, col5_valid_monitor,

    output signed [47:0] bias_adder_result0_monitor, bias_adder_result1_monitor, bias_adder_result2_monitor, bias_adder_result3_monitor, bias_adder_result4_monitor,
    output signed bias_adder_valid0_monitor, bias_adder_valid1_monitor, bias_adder_valid2_monitor, bias_adder_valid3_monitor, bias_adder_valid4_monitor
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

    wire done_config_pixel_buffer_loader, done_config_weight_buffer_loader;
    assign done_config_pixel_buffer_loader_monitor = done_config_pixel_buffer_loader;
    assign done_config_weight_buffer_loader_monitor = done_config_weight_buffer_loader;

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

    wire start_calc;
    wire done_calc;
    assign done_calc_monitor = done_calc;
    assign start_calc_monitor = start_calc;
    wire clear_window_reg, clear_wgt_reg;
    assign clear_window_reg_monitor = clear_window_reg;
    assign clear_wgt_reg_monitor = clear_wgt_reg;
    assign clear_bias_reg_monitor = clear_bias_reg;

    wire valid_pixel, valid_wgt, valid_bias;
    assign valid_pixel_monitor = valid_pixel;
    assign valid_wgt_monitor = valid_wgt;
    assign valid_bias_monitor = valid_bias;

    wire valid_window_out, valid_wgt_out, last_window_out;
    assign valid_window_out_monitor = valid_window_out;
    assign valid_wgt_out_monitor = valid_wgt_out;
    assign last_window_out_monitor = last_window_out;

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

        .valid_pixel(valid_pixel), .valid_wgt(valid_wgt), .valid_bias(valid_bias),

        .start_calc(start_calc),
        .clear_window_reg(clear_window_reg), .clear_wgt_reg(clear_wgt_reg), .clear_bias_reg(clear_bias_reg),
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
    bram #(.DW(DATA_WIDTH*2), .DEPTH(BIAS_SIZE), .ADDR_WIDTH(BIAS_ADDR_WIDTH)) bias_bram (
        .clk(clk),
        .wr_en(bias_unpack_wr_en), .wr_addr(bias_unpack_wr_addr), .wr_data(bias_unpack_wr_data),
        .rd_en(rd_en_bias), .rd_addr(rd_addr_bias), .rd_data(rd_data_bias)
    );

    //Pixel Loader 
    wire [599:0] window_packed;
    assign window_packed_monitor = window_packed;
    pixel_loader #(
        .DW(24), .MAX_W(128), .K(5)
    )pixel_stream_buffer_inst(
        .clk(clk), .rst(rst), .clear(1'b0), .start_config(start_config_pixel_buffer_loader),
        .img_w(img_width_config), .img_h(img_height_config), .kernel_size(kernel_size_config), .stride(stride_config),
        .valid_in(valid_pixel), .pixel_in(rd_data_pixel),

        .valid_out(valid_window_out), .done_config(done_config_pixel_buffer_loader),
        .last_window_out(last_window_out),

        .window_out_flat(),
        .window_out_masked_flat(),
        .window_packed(window_packed)
    );

    //Weight Loader
    wire [599:0] weight_packed;
    assign weight_packed_monitor = weight_packed;
    weight_loader #(
        .DW(24),
        .MAX_K(5)
    )weight_loader_inst(
        .clk(clk), .rst(rst), .clear(1'b0), .start_config(start_config_weight_buffer_loader),
        .kernel_size(kernel_size_config), .done_config(done_config_weight_buffer_loader),

        .valid_in(valid_wgt), .weight_in(rd_data_wgt),

        .valid_weight_out(valid_wgt_out), .weight_packed(weight_packed)
    );

    //Reg 5x600 for Window
    wire [599:0] window_0, window_1, window_2, window_3, window_4;
    assign window_reg_0 = window_0;
    assign window_reg_1 = window_1;
    assign window_reg_2 = window_2;
    assign window_reg_3 = window_3;
    assign window_reg_4 = window_4;

    reg_file_5x600 window_reg_file(
        .clk(clk), .rst(rst), .clr(clear_window_reg),

        .wr_en(valid_window_out),
        .wr_sel(window_cnt_monitor),
        .wr_data(window_packed),

        .reg0(window_0), .reg1(window_1), .reg2(window_2), .reg3(window_3), .reg4(window_4)
    );

    //Reg 5x600 for Weight
    wire [599:0] wgt_reg [4:0];
    assign wgt_reg_0 = wgt_reg[0];
    assign wgt_reg_1 = wgt_reg[1];
    assign wgt_reg_2 = wgt_reg[2];
    assign wgt_reg_3 = wgt_reg[3];
    assign wgt_reg_4 = wgt_reg[4];
    reg_file_5x600 weigh_reg_file(
        .clk(clk), .rst(rst), .clr(clear_wgt_reg),

        .wr_en(valid_wgt_out),
        .wr_sel(wgt_cnt_monitor),
        .wr_data(weight_packed),

        .reg0(wgt_reg[0]), .reg1(wgt_reg[1]), .reg2(wgt_reg[2]), .reg3(wgt_reg[3]), .reg4(wgt_reg[4])
    );

    //MAC 
    wire [5:0] cycle_out;
    wire signed [DATA_WIDTH-1:0] a1, a2, a3, a4, a5;
    wire signed [DATA_WIDTH-1:0] b1, b2, b3, b4, b5;
    
    wire [47:0] c1, c2, c3, c4, c5;
    wire [47:0] c6, c7, c8, c9, c10;
    wire [47:0] c11, c12, c13, c14, c15;
    wire [47:0] c16, c17, c18, c19, c20;
    wire [47:0] c21, c22, c23, c24, c25;

    assign cycle_out_monitor = cycle_out;
    assign a1_monitor = a1;
    assign a2_monitor = a2;
    assign a3_monitor = a3;
    assign a4_monitor = a4;
    assign a5_monitor = a5;
    assign b1_monitor = b1;
    assign b2_monitor = b2;
    assign b3_monitor = b3;
    assign b4_monitor = b4;
    assign b5_monitor = b5;
    
    assign c1_monitor  = c1;
    assign c2_monitor  = c2;
    assign c3_monitor  = c3;
    assign c4_monitor  = c4;
    assign c5_monitor  = c5;

    assign c6_monitor  = c6;
    assign c7_monitor  = c7;
    assign c8_monitor  = c8;
    assign c9_monitor  = c9;
    assign c10_monitor = c10;

    assign c11_monitor = c11;
    assign c12_monitor = c12;
    assign c13_monitor = c13;
    assign c14_monitor = c14;
    assign c15_monitor = c15;

    assign c16_monitor = c16;
    assign c17_monitor = c17;
    assign c18_monitor = c18;
    assign c19_monitor = c19;
    assign c20_monitor = c20;

    assign c21_monitor = c21;
    assign c22_monitor = c22;
    assign c23_monitor = c23;
    assign c24_monitor = c24;
    assign c25_monitor = c25;

    wire signed [47:0] col1_out, col2_out, col3_out, col4_out, col5_out;
    wire col1_valid, col2_valid, col3_valid, col4_valid, col5_valid;
    assign col1_out_monitor = col1_out;
    assign col2_out_monitor = col2_out;
    assign col3_out_monitor = col3_out;
    assign col4_out_monitor = col4_out;
    assign col5_out_monitor = col5_out;

    assign col1_valid_monitor = col1_valid;
    assign col2_valid_monitor = col2_valid;
    assign col3_valid_monitor = col3_valid;
    assign col4_valid_monitor = col4_valid;
    assign col5_valid_monitor = col5_valid;

    calc_unit #(.DW(24)
    )calc_unit_inst(
        .clk(clk), .reset(rst), .start(start_calc),

        .IFM0(window_0), .IFM1(window_1), .IFM2(window_2), .IFM3(window_3), .IFM4(window_4),
        .WGT0(wgt_reg[0]), .WGT1(wgt_reg[1]), .WGT2(wgt_reg[2]), .WGT3(wgt_reg[3]), .WGT4(wgt_reg[4]),
        .cycle_out(cycle_out),

        .a1_monitor(a1), .a2_monitor(a2), .a3_monitor(a3), .a4_monitor(a4), .a5_monitor(a5),
        .b1_monitor(b1), .b2_monitor(b2), .b3_monitor(b3), .b4_monitor(b4), .b5_monitor(b5),

        .c1(c1), .c2(c2), .c3(c3), .c4(c4), .c5(c5),
        .c6(c6), .c7(c7), .c8(c8), .c9(c9), .c10(c10),
        .c11(c11), .c12(c12), .c13(c13), .c14(c14), .c15(c15),
        .c16(c16), .c17(c17), .c18(c18), .c19(c19), .c20(c20),
        .c21(c21), .c22(c22), .c23(c23), .c24(c24), .c25(c25),

        .col1_out(col1_out), .col2_out(col2_out), .col3_out(col3_out), .col4_out(col4_out), .col5_out(col5_out),
        .col1_valid(col1_valid), .col2_valid(col2_valid), .col3_valid(col3_valid), .col4_valid(col4_valid), .col5_valid(col5_valid),

        .done(done_calc)
    );

     //Bias Adder 5x48
    wire [47:0] bias_adder_result0, bias_adder_result1, bias_adder_result2, bias_adder_result3, bias_adder_result4;
    wire bias_adder_valid0, bias_adder_valid1, bias_adder_valid2, bias_adder_valid3, bias_adder_valid4; 
    assign bias_adder_result0_monitor = bias_adder_result0;
    assign bias_adder_result1_monitor = bias_adder_result1;
    assign bias_adder_result2_monitor = bias_adder_result2;
    assign bias_adder_result3_monitor = bias_adder_result3;
    assign bias_adder_result4_monitor = bias_adder_result4;
    assign bias_adder_valid0_monitor = bias_adder_valid0;
    assign bias_adder_valid1_monitor = bias_adder_valid1;
    assign bias_adder_valid2_monitor = bias_adder_valid2;
    assign bias_adder_valid3_monitor = bias_adder_valid3;
    assign bias_adder_valid4_monitor = bias_adder_valid4;
    bias_adder_5x48 bias_adder(
        .clk(clk), .rst(rst), .clr(clear_bias_reg),

        .bias_wr_en(valid_bias),
        .bias_wr_sel(bias_cnt_monitor),
        .bias_wr_data(rd_data_bias),

        .data_in0(col1_out), .data_in1(col2_out), .data_in2(col3_out), .data_in3(col4_out), .data_in4(col5_out),
        .data_valid0(col1_valid), .data_valid1(col2_valid), .data_valid2(col3_valid), .data_valid3(col4_valid), .data_valid4(col5_valid),

        .result0(bias_adder_result0), .result1(bias_adder_result1), .result2(bias_adder_result2), .result3(bias_adder_result3), .result4(bias_adder_result4),
        .result_valid0(bias_adder_valid0), .result_valid1(bias_adder_valid1), .result_valid2(bias_adder_valid2), .result_valid3(bias_adder_valid3), .result_valid4(bias_adder_valid4)
    );

    //Activation 
    activation_5x #(
        .DATA_WIDTH(48),
        .LEAK_SHIFT(4)
    ) activation_5x_inst (
        .clk(clk), .rst(rst),
        .en0(), .en1(), .en2(), .en3(), .en4(),

        .valid_in0(), .valid_in1(), .valid_in2(), .valid_in3(), .valid_in4(),

        .start_activation(),
        .mode(),

        .data_in_activation0(),
        .data_in_activation1(),
        .data_in_activation2(),
        .data_in_activation3(),
        .data_in_activation4(),

        .data_out_activation0(),
        .data_out_activation1(),
        .data_out_activation2(),
        .data_out_activation3(),
        .data_out_activation4(),

        .done_config_activation(),

        .data_valid_activation0(),
        .data_valid_activation1(),
        .data_valid_activation2(),
        .data_valid_activation3(),
        .data_valid_activation4()
    );

    //Quantization
    
endmodule