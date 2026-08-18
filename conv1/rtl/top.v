`timescale 1ns / 1ps

module top #(
    parameter DATA_WIDTH = 24,
    parameter ADDR_WIDTH = 10,
    parameter IMG_SIZE   = 1024
)(
    input clk, rst, start,
    input config_done,
    //AXI Stream
    input signed [DATA_WIDTH-1:0] ifm_tdata,
    input ifm_tvalid,
    input ifm_tlast,
    output ifm_tready,

    input signed [DATA_WIDTH-1:0] wgt_tdata,
    input wgt_tvalid,
    input wgt_tlast,
    output wgt_tready,

    input signed [DATA_WIDTH-1:0] bias_tdata,
    input bias_tvalid,
    input bias_tlast,
    output bias_tready,

    output start_load, start_compute,

    input [15:0] img_width,
    input [15:0] img_height,
    input [2:0]  kernel_size,
    input [2:0]  stride,
    input [1:0]  activation,
    
    output done_npu
);
    //System controller
    wire ifm_done, wgt_done, bias_done;
    system_controller system_controller_inst(
        .clk(clk),
        .rst(rst),
        .start(start),

        .config_done(config_done),
        .ifm_done(ifm_done),
        .wgt_done(wgt_done),
        .bias_done(bias_done),

        .start_load(start_load),
        .start_compute(start_compute)
    );

    //Memory controller
    wire ifm_wr_en;
    wire [ADDR_WIDTH-1:0] ifm_wr_addr;
    wire [DATA_WIDTH-1:0] ifm_wr_data;

    wire wgt_wr_en;
    wire [ADDR_WIDTH-1:0] wgt_wr_addr;
    wire [DATA_WIDTH-1:0] wgt_wr_data;

    wire bias_wr_en;
    wire [ADDR_WIDTH-1:0] bias_wr_addr;
    wire [DATA_WIDTH-1:0] bias_wr_data;
    memory_controller #(
        .DATA_WIDTH(24),
        .IFM_ADDR_WIDTH(10),
        .WGT_ADDR_WIDTH(10),
        .BIAS_ADDR_WIDTH(10),
        .OUT_ADDR_WIDTH(10)
    )memory_controller_inst(
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
        .ifm_wr_addr(ifm_wr_addr),
        .ifm_wr_data(ifm_wr_data),

        .wgt_wr_en(wgt_wr_en),
        .wgt_wr_addr(wgt_wr_addr),
        .wgt_wr_data(wgt_wr_data),

        .bias_wr_en(bias_wr_en),
        .bias_wr_addr(bias_wr_addr),
        .bias_wr_data(bias_wr_data),

        .ifm_done(ifm_done),
        .wgt_done(wgt_done),
        .bias_done(bias_done),

        .npu_out_data(24'd0),
        .npu_out_valid(1'b0),
        .npu_out_last(1'b0),
        .compute_done(1'b0),

        .npu_out_ready(),

        .out_wr_en(),
        .out_wr_addr(),
        .out_wr_data(),

        .done_load_in(),
        .done_load_out()
    );

    //NPU controller
    wire rd_en_ifm;
    wire rd_en_wgt;
    wire rd_en_bias;
    wire start_config_pixel_buffer_loader;
    wire start_config_weight_buffer_loader;
    wire start_config_activation;
    wire done_config_pixel_buffer_loader;
    wire done_config_weight_buffer_loader;
    wire done_config_activation;
    wire [15:0] img_width_config;
    wire [15:0] img_height_config;
    wire [2:0]  kernel_size_config;
    wire [2:0]  stride_config;
    wire [1:0]  activation_config;
    wire clear_select_reg_ifm;
    wire clear_select_reg_wgt;
    wire clear_selcect_reg_bias;
    wire valid_window_out;
    wire last_window_out;
    wire start_calc, calc_done;
    wire clear_addr_ifm;
    wire clear_pixel_loader;
    wire start_config_ofm;
    wire done_config_ofm;
    wire full_ofm;
    wire block_ifm_read;
    wire ifm_reg_full;
    wire wgt_reg_full;
    npu_controller npu_controller_inst(
        .clk(clk),
        .rst(rst),
        .start(start_compute),

        .start_config_pixel_buffer_loader(start_config_pixel_buffer_loader),
        .start_config_weight_buffer_loader(start_config_weight_buffer_loader),
        .start_config_activation(start_config_activation),

        .img_width(img_width),
        .img_height(img_height),
        .kernel_size(kernel_size),
        .stride(stride),
        .activation(activation),

        .done_config_pixel_buffer_loader(done_config_pixel_buffer_loader),
        .done_config_weight_buffer_loader(done_config_weight_buffer_loader),
        .done_config_activation(done_config_activation),

        .img_width_config(img_width_config),
        .img_height_config(img_height_config),
        .kernel_size_config(kernel_size_config),
        .stride_config (stride_config),
        .activation_config(activation_config),

        .rd_en_ifm(rd_en_ifm),
        .rd_en_wgt(rd_en_wgt),
        .rd_en_bias(rd_en_bias),
        .ifm_reg_full(ifm_reg_full),
        .wgt_reg_full(wgt_reg_full),

        .select_reg_ifm(select_reg_ifm),
        .select_reg_wgt(select_reg_wgt),
        .select_reg_bias(select_reg_bias),
        .valid_window_out(valid_window_out),
        .last_window_out(last_window_out),
        .start_calc(start_calc),
        .calc_done(calc_done),
        .clear_select_reg_ifm(clear_select_reg_ifm),
        .clear_select_reg_wgt(clear_select_reg_wgt),
        .clear_select_reg_bias(clear_select_reg_bias),


        .start_config_ofm(start_config_ofm),

        .done_config_ofm(done_config_ofm),

        .full_ofm(full_ofm),

        .done_npu(done_npu),
        
        .block_ifm_read(block_ifm_read)
    );

    //Bram for IFM
    wire [9:0] ifm_wr_addr_reg;
    reg10_en reg_ifm_addr_inst(
        .clk(clk),
        .rst(rst),
        .en(ifm_wr_en),
        .d(ifm_wr_addr),
        .q(ifm_wr_addr_reg)
    );

    wire [ADDR_WIDTH-1:0]        rd_addr_ifm;
    wire signed [DATA_WIDTH-1:0] rd_ifm;  
    addr_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_COUNT(IMG_SIZE)
    ) ifm_addr_counter_inst (
        .clk(clk),
        .rst(rst),
        .enable(rd_en_ifm),
        .clear(clear_addr_ifm),
        .addr(rd_addr_ifm),
        .done()
    );

    bram_data #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMG_SIZE(IMG_SIZE)
    ) ifm_bram (
        .clk(clk),
        .rst(rst),

        .wr_en  (ifm_wr_en),
        .wr_addr(ifm_wr_addr_reg),
        .wr_data(ifm_wr_data),

        .rd_en  (rd_en_ifm),
        .rd_addr(rd_addr_ifm),
        .rd_data(rd_ifm)
    );

    //Pixel Buffer Loader
    wire valid_window_out;
    wire [599:0] window_packed;
    pixel_loader #(
        .DW(DATA_WIDTH),
        .MAX_W(IMG_SIZE),
        .K(5)
    )pixel_buffer_loader_inst(
        .clk(clk),
        .rst(rst),
        .clear(clear_pixel_loader),
        .start_config(start_config_pixel_buffer_loader),
        .img_w(img_width_config),
        .img_h(img_height_config),
        .kernel_size(kernel_size_config),
        .stride(stride_config),
        .valid_in(rd_en_ifm),
        .pixel_in(rd_ifm),

        .valid_out(valid_window_out),
        .done_config(done_config_pixel_buffer_loader),
        .last_window_out(last_window_out),

        .window_out_flat(),
        .window_out_masked_flat(),
        .window_packed(window_packed)
    );
    
    wire [9:0] select_reg_ifm;
    addr_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_COUNT(IMG_SIZE)
    )counter_select_reg_inst(
        .clk(clk),
        .rst(rst),

        .enable(valid_window_out),
        .clear(clear_select_reg_ifm),

        .addr(select_reg_ifm),
        .done()
    );

    wire [599:0] ifm_reg0, ifm_reg1, ifm_reg2, ifm_reg3, ifm_reg4;
    demux1to5 #(
        .DATA_WIDTH(600)
    )demux1to5_inst2(
        .din(window_packed),
        .sel(select_reg_ifm),
        .dout0(ifm_reg0),
        .dout1(ifm_reg1),
        .dout2(ifm_reg2),
        .dout3(ifm_reg3),
        .dout4(ifm_reg4)
    );

    wire signed [599:0] reg0_window, reg1_window, reg2_window, reg3_window, reg4_window;
    wire we0_window, we1_window, we2_window, we3_window, we4_window;
    assign we0_window = valid_window_out && (select_reg_ifm == 0);
    assign we1_window = valid_window_out && (select_reg_ifm == 1);
    assign we2_window = valid_window_out && (select_reg_ifm == 2);
    assign we3_window = valid_window_out && (select_reg_ifm == 3);
    assign we4_window = valid_window_out && (select_reg_ifm == 4);
    
    reg_bank_ad register_bank1_inst(
        .clk(clk),
        .rst(rst), 
        .clear_bank_reg(clear_select_reg_ifm),
        .we0(we0_window), 
        .we1(we1_window), 
        .we2(we2_window), 
        .we3(we3_window), 
        .we4(we4_window),  
        .data_in_0(ifm_reg0), 
        .data_in_1(ifm_reg1), 
        .data_in_2(ifm_reg2), 
        .data_in_3(ifm_reg3), 
        .data_in_4(ifm_reg4),
        .data_out_0(reg0_window), 
        .data_out_1(reg1_window), 
        .data_out_2(reg2_window), 
        .data_out_3(reg3_window), 
        .data_out_4(reg4_window),
        .reg_full(ifm_reg_full)  
    );
    //Bram for WGT
    wire [9:0] wgt_wr_addr_reg;
    reg10_en reg_wgt_addr_inst(
        .clk(clk),
        .rst(rst),
        .en(wgt_wr_en),
        .d(wgt_wr_addr),
        .q(wgt_wr_addr_reg)
    );
    
    wire [ADDR_WIDTH-1:0] rd_addr_wgt;
    wire [DATA_WIDTH-1:0] rd_wgt;
    addr_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_COUNT(IMG_SIZE)
    )wgt_addr_counter_inst(
        .clk(clk),
        .rst(rst),

        .enable(rd_en_wgt),
        .clear(1'b0),

        .addr(rd_addr_wgt),
        .done()
    );

    bram_data #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMG_SIZE(IMG_SIZE)
    ) wgt_bram (
        .clk(clk),
        .rst(rst),
        .wr_en(wgt_wr_en),
        .wr_addr(wgt_wr_addr_reg),
        .wr_data(wgt_wr_data),

        .rd_en(rd_en_wgt),
        .rd_addr(rd_addr_wgt),
        .rd_data(rd_wgt)
    );

    //Weight Buffer Loader
    wire valid_weigth_out;
    wire [599:0] weight_packed;
    weight_loader #(
        .DW(24),
        .MAX_K(5)
    )weight_buffer_loader_inst(
        .clk(clk),
        .rst(rst),
        .clear(1'b0),

        .start_config(start_config_weight_buffer_loader),
        .kernel_size(kernel_size_config),
        .done_config(done_config_weight_buffer_loader),

        .valid_in(rd_en_wgt),
        .weight_in(rd_wgt),

        .valid_weight_out(valid_weight_out),
        .weight_packed(weight_packed)
    );

    wire [9:0] select_reg_wgt;
    addr_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_COUNT(IMG_SIZE)
    )counter_select_reg_wgt_inst(
        .clk(clk),
        .rst(rst),

        .enable(valid_weight_out),
        .clear(clear_select_reg_wgt),

        .addr(select_reg_wgt),
        .done()
    );

    wire [599:0] wgt_reg0, wgt_reg1, wgt_reg2, wgt_reg3, wgt_reg4;
    demux1to5 #(
        .DATA_WIDTH(600)
    )demux1to5_inst1(
        .din(weight_packed),
        .sel(select_reg_wgt),
        .dout0(wgt_reg0),
        .dout1(wgt_reg1),
        .dout2(wgt_reg2),
        .dout3(wgt_reg3),
        .dout4(wgt_reg4)
    );

    wire signed [599:0] reg0_weight, reg1_weight, reg2_weight, reg3_weight, reg4_weight;
    wire we0_weight, we1_weight, we2_weight, we3_weight, we4_weight;
    assign we0_weight = valid_weight_out && (select_reg_wgt == 0);
    assign we1_weight = valid_weight_out && (select_reg_wgt == 1);
    assign we2_weight = valid_weight_out && (select_reg_wgt == 2);
    assign we3_weight = valid_weight_out && (select_reg_wgt == 3);
    assign we4_weight = valid_weight_out && (select_reg_wgt == 4);
    
    reg_bank_ad register_bank2_inst(
        .clk(clk),
        .rst(rst), 
        .clear_bank_reg(clear_select_reg_wgt),
        .we0(we0_weight), 
        .we1(we1_weight), 
        .we2(we2_weight), 
        .we3(we3_weight), 
        .we4(we4_weight),  
        .data_in_0(wgt_reg0), 
        .data_in_1(wgt_reg1), 
        .data_in_2(wgt_reg2), 
        .data_in_3(wgt_reg3), 
        .data_in_4(wgt_reg4),
        .data_out_0(reg0_weight), 
        .data_out_1(reg1_weight), 
        .data_out_2(reg2_weight), 
        .data_out_3(reg3_weight), 
        .data_out_4(reg4_weight),
        .reg_full(wgt_reg_full)  
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

    calc_unit #(
        .DW(24)
    )calc_unit_inst(
        .clk(clk),
        .reset(rst),
        .start(start_calc),

        .IFM0(reg0_window),
        .IFM1(reg1_window),
        .IFM2(reg2_window),
        .IFM3(reg3_window),
        .IFM4(reg4_window),

        .WGT0(reg0_weight),
        .WGT1(reg1_weight),
        .WGT2(reg2_weight),
        .WGT3(reg3_weight),
        .WGT4(reg4_weight),

        .cycle_out(cycle_out),

        .a1_monitor(a1),
        .a2_monitor(a2),
        .a3_monitor(a3),
        .a4_monitor(a4),
        .a5_monitor(a5),

        .b1_monitor(b1),
        .b2_monitor(b2),
        .b3_monitor(b3),
        .b4_monitor(b4),
        .b5_monitor(b5),

        .c1(c1),
        .c2(c2),
        .c3(c3),
        .c4(c4),
        .c5(c5),

        .c6(c6),
        .c7(c7),
        .c8(c8),
        .c9(c9),
        .c10(c10),

        .c11(c11),
        .c12(c12),
        .c13(c13),
        .c14(c14),
        .c15(c15),

        .c16(c16),
        .c17(c17),
        .c18(c18),
        .c19(c19),
        .c20(c20),

        .c21(c21),
        .c22(c22),
        .c23(c23),
        .c24(c24),
        .c25(c25),

        .done(calc_done)
    );

    wire signed [47:0] col0_out, col1_out, col2_out, col3_out, col4_out;
    wire col0_valid, col1_valid, col2_valid, col3_valid, col4_valid;
    wire signed [23:0] q_col0_out, q_col1_out, q_col2_out, q_col3_out, q_col4_out;
    wire q_col0_valid, q_col1_valid, q_col2_valid, q_col3_valid, q_col4_valid;

    wire [5:0] cycle_out_reg;
    reg6_en cycle_reg_inst(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .d(cycle_out),
        .q(cycle_out_reg)
    ); 

    output_mux #(
        .START_CYCLE(25)
    ) mux_col0 (
        .cycle(cycle_out_reg),
        .in0(c1),
        .in1(c6),
        .in2(c11),
        .in3(c16),
        .in4(c21),
        .data_out(col0_out),
        .valid_out(col0_valid)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    )quatization_col0_inst(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11), 
        .valid_in(col0_valid),
        .data_in(col0_out),

        .data_out(q_col0_out),
        .valid_out(q_col0_valid)
    );

    output_mux #(
        .START_CYCLE(26)
    ) mux_col1 (
        .cycle(cycle_out_reg),
        .in0(c2),
        .in1(c7),
        .in2(c12),
        .in3(c17),
        .in4(c22),
        .data_out(col1_out),
        .valid_out(col1_valid)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_col1_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(col1_valid),
        .data_in(col1_out),

        .data_out(q_col1_out),
        .valid_out(q_col1_valid)
    );

    output_mux #(
        .START_CYCLE(27)
    ) mux_col2 (
        .cycle(cycle_out_reg),
        .in0(c3),
        .in1(c8),
        .in2(c13),
        .in3(c18),
        .in4(c23),
        .data_out(col2_out),
        .valid_out(col2_valid)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_col2_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(col2_valid),
        .data_in(col2_out),

        .data_out(q_col2_out),
        .valid_out(q_col2_valid)
    );

    output_mux #(
        .START_CYCLE(28)
    ) mux_col3 (
        .cycle(cycle_out_reg),
        .in0(c4),
        .in1(c9),
        .in2(c14),
        .in3(c19),
        .in4(c24),
        .data_out(col3_out),
        .valid_out(col3_valid)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_col3_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(col3_valid),
        .data_in(col3_out),

        .data_out(q_col3_out),
        .valid_out(q_col3_valid)
    );

    output_mux #(
        .START_CYCLE(29)
    ) mux_col4 (
        .cycle(cycle_out_reg),
        .in0(c5),
        .in1(c10),
        .in2(c15),
        .in3(c20),
        .in4(c25),
        .data_out(col4_out),
        .valid_out(col4_valid)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_col4_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(col4_valid),
        .data_in(col4_out),

        .data_out(q_col4_out),
        .valid_out(q_col4_valid)
    );

    //Bram for BIAS
    wire [9:0] bias_wr_addr_reg;
    reg10_en reg_bias_addr_inst(
        .clk(clk),
        .rst(rst),
        .en(bias_wr_en),
        .d(bias_wr_addr),
        .q(bias_wr_addr_reg)
    );

    wire [ADDR_WIDTH-1:0] rd_addr_bias;
    wire signed [DATA_WIDTH-1:0] rd_bias;  
    addr_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_COUNT(IMG_SIZE)
    ) bias_addr_counter_inst (
        .clk(clk),
        .rst(rst),
        .enable(rd_en_bias),
        .clear(1'b0),
        .addr(rd_addr_bias),
        .done()
    );

    bram_data #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMG_SIZE(IMG_SIZE)
    ) bias_bram (
        .clk(clk),
        .rst(rst),

        .wr_en  (bias_wr_en),
        .wr_addr(bias_wr_addr_reg),
        .wr_data(bias_wr_data),

        .rd_en  (rd_en_bias),
        .rd_addr(rd_addr_bias),
        .rd_data(rd_bias)
    );

    wire [9:0] select_reg_bias;
    addr_counter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_COUNT(IMG_SIZE)
    )counter_select_reg_bias_inst(
        .clk(clk),
        .rst(rst),

        .enable(rd_en_bias),
        .clear(clear_select_reg_bias),

        .addr(select_reg_bias),
        .done()
    );

    wire signed [DATA_WIDTH-1:0] bias_dout0, bias_dout1, bias_dout2, bias_dout3, bias_dout4;
    
    demux1to5 #(
        .DATA_WIDTH(DATA_WIDTH)
    )demux1to5_inst(
        .din(rd_bias),
        .sel(select_reg_bias),

        .dout0(bias_dout0),
        .dout1(bias_dout1),
        .dout2(bias_dout2),
        .dout3(bias_dout3),
        .dout4(bias_dout4)
    );

    assign we0_bias = (select_reg_bias == 0);
    assign we1_bias = (select_reg_bias == 1);
    assign we2_bias = (select_reg_bias == 2);
    assign we3_bias = (select_reg_bias == 3);
    assign we4_bias = (select_reg_bias == 4);

    wire signed [23:0] bias_reg0, bias_reg1, bias_reg2, bias_reg3, bias_reg4;
    reg24_signed bias_reg_inst(
        .clk(clk),
        .rst(rst),
        .en(we0_bias),

        .d(bias_dout0),
        .q(bias_reg0)
    );

    reg24_signed bias_reg_inst1(
        .clk(clk),
        .rst(rst),
        .en(we1_bias),

        .d(bias_dout1),
        .q(bias_reg1)
    );

    reg24_signed bias_reg_inst2(
        .clk(clk),
        .rst(rst),
        .en(we2_bias),

        .d(bias_dout2),
        .q(bias_reg2)
    );

    reg24_signed bias_reg_inst3(
        .clk(clk),
        .rst(rst),
        .en(we3_bias),

        .d(bias_dout3),
        .q(bias_reg3)
    );

    reg24_signed bias_reg_inst4(
        .clk(clk),
        .rst(rst),
        .en(we4_bias),

        .d(bias_dout4),
        .q(bias_reg4)
    );

    wire signed [23:0] bias_adder0, bias_adder1, bias_adder2, bias_adder3, bias_adder4;
    wire bias_adder_valid_out0;
    wire bias_adder_valid_out1;
    wire bias_adder_valid_out2;
    wire bias_adder_valid_out3;
    wire bias_adder_valid_out4;

    bias_adder  #(
        .DATA_WIDTH(24)
    )bias_adder_inst0(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(q_col0_valid),
        .data_in(q_col0_out),
        .bias(bias_reg0),
        .data_out(bias_adder0),
        .valid_out(bias_adder_valid_out0)
    );

    bias_adder#(
        .DATA_WIDTH(24)
    )bias_adder_inst1(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(q_col1_valid),
        .data_in(q_col1_out),
        .bias(bias_reg1),
        .data_out(bias_adder1),
        .valid_out(bias_adder_valid_out1)
    );

    bias_adder#(
        .DATA_WIDTH(24)
    )bias_adder_inst2(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(q_col2_valid),
        .data_in(q_col2_out),
        .bias(bias_reg2),
        .data_out(bias_adder2),
        .valid_out(bias_adder_valid_out2)
    );

    bias_adder#(
        .DATA_WIDTH(24)
    )bias_adder_inst3(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(q_col3_valid),
        .data_in(q_col3_out),
        .bias(bias_reg3),
        .data_out(bias_adder3),
        .valid_out(bias_adder_valid_out3)
    );

    bias_adder#(
        .DATA_WIDTH(24)
    )bias_adder_inst4(
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(q_col4_valid),
        .data_in(q_col4_out),
        .bias(bias_reg4),
        .data_out(bias_adder4),
        .valid_out(bias_adder_valid_out4)
    );

    wire signed [47:0] bias_adder0_reg, bias_adder1_reg;
    wire [47:0] bias_adder2_reg, bias_adder3_reg;
    wire [47:0] bias_adder4_reg;

    wire bias_adder_valid_out0_reg, bias_adder_valid_out1_reg;
    wire bias_adder_valid_out2_reg, bias_adder_valid_out3_reg;
    wire bias_adder_valid_out4_reg;

    reg24_to_48 scale_reg_bias_inst0(
        .clk(clk),
        .rst(rst),
        .en(1'b1),

        .valid_in(bias_adder_valid_out0),
        .data_in(bias_adder0),

        .valid_out(bias_adder_valid_out0_reg),
        .data_out(bias_adder0_reg)
    );

    reg24_to_48 scale_reg_bias_inst1(
        .clk(clk),
        .rst(rst),
        .en(1'b1),

        .valid_in(bias_adder_valid_out1),
        .data_in(bias_adder1),

        .valid_out(bias_adder_valid_out1_reg),
        .data_out(bias_adder1_reg)
    );

    reg24_to_48 scale_reg_bias_inst2(
        .clk(clk),
        .rst(rst),
        .en(1'b1),

        .valid_in(bias_adder_valid_out2),
        .data_in(bias_adder2),

        .valid_out(bias_adder_valid_out2_reg),
        .data_out(bias_adder2_reg)
    );

    reg24_to_48 scale_reg_bias_inst3(
        .clk(clk),
        .rst(rst),
        .en(1'b1),

        .valid_in(bias_adder_valid_out3),
        .data_in(bias_adder3),

        .valid_out(bias_adder_valid_out3_reg),
        .data_out(bias_adder3_reg)
    );

    reg24_to_48 scale_reg_bias_inst4(
        .clk(clk),
        .rst(rst),
        .en(1'b1),

        .valid_in(bias_adder_valid_out4),
        .data_in(bias_adder4),

        .valid_out(bias_adder_valid_out4_reg),
        .data_out(bias_adder4_reg)
    );

    //Activation
    wire signed [47:0] act_0, act_1, act_2, act_3, act_4;
    wire valid_act_out_0, valid_act_out_1, valid_act_out_2;
    wire valid_act_out_3, valid_act_out_4;

    wire done_config_activation0, done_config_activation1;
    wire done_config_activation2, done_config_activation3;
    wire done_config_activation4;

    assign done_config_activation =
       done_config_activation0 &
       done_config_activation1 &
       done_config_activation2 &
       done_config_activation3 &
       done_config_activation4;

    activation #(
        .DATA_WIDTH(48),
        .LEAK_SHIFT(4)
    ) activation_inst0 (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(bias_adder_valid_out0_reg),
        .start_activation(start_config_activation),
        .mode(activation_config),
        .data_in_activation(bias_adder0_reg),

        .data_out_activation(act_0),
        .done_config_activation(done_config_activation0),
        .data_valid_activation(valid_act_out_0)
    );

    activation #(
        .DATA_WIDTH(48),
        .LEAK_SHIFT(4)
    ) activation_inst1 (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(bias_adder_valid_out1_reg),
        .start_activation(start_config_activation),
        .mode(activation_config),
        .data_in_activation(bias_adder1_reg),

        .data_out_activation(act_1),
        .done_config_activation(done_config_activation1),
        .data_valid_activation(valid_act_out_1)
    );

    activation #(
        .DATA_WIDTH(48),
        .LEAK_SHIFT(4)
    ) activation_inst2 (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(bias_adder_valid_out2_reg),
        .start_activation(start_config_activation),
        .mode(activation_config),
        .data_in_activation(bias_adder2_reg),

        .data_out_activation(act_2),
        .done_config_activation(done_config_activation2),
        .data_valid_activation(valid_act_out_2)
    );

    activation #(
        .DATA_WIDTH(48),
        .LEAK_SHIFT(4)
    ) activation_inst3 (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(bias_adder_valid_out3_reg),
        .start_activation(start_config_activation),
        .mode(activation_config),
        .data_in_activation(bias_adder3_reg),

        .data_out_activation(act_3),
        .done_config_activation(done_config_activation3),
        .data_valid_activation(valid_act_out_3)
    );

    activation #(
        .DATA_WIDTH(48),
        .LEAK_SHIFT(4)
    ) activation_inst4 (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .valid_in(bias_adder_valid_out4_reg),
        .start_activation(start_config_activation),
        .mode(activation_config),
        .data_in_activation(bias_adder4_reg),

        .data_out_activation(act_4),
        .done_config_activation(done_config_activation4),
        .data_valid_activation(valid_act_out_4)
    );

    wire signed [DATA_WIDTH-1:0] q_act_out0;
    wire signed [DATA_WIDTH-1:0] q_act_out1;
    wire signed [DATA_WIDTH-1:0] q_act_out2;
    wire signed [DATA_WIDTH-1:0] q_act_out3;
    wire signed [DATA_WIDTH-1:0] q_act_out4;

    wire q_act_valid_out0;
    wire q_act_valid_out1;
    wire q_act_valid_out2;
    wire q_act_valid_out3;
    wire q_act_valid_out4;
    
    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_act0_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(valid_act_out_0),
        .data_in(act_0),

        .data_out(q_act_out0),
        .valid_out(q_act_valid_out0)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_act1_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(valid_act_out_1),
        .data_in(act_1),

        .data_out(q_act_out1),
        .valid_out(q_act_valid_out1)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_act2_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(valid_act_out_2),
        .data_in(act_2),

        .data_out(q_act_out2),
        .valid_out(q_act_valid_out2)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_act3_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(valid_act_out_3),
        .data_in(act_3),

        .data_out(q_act_out3),
        .valid_out(q_act_valid_out3)
    );

    quantization #(
        .DATA_IN_WIDTH(48),
        .DATA_OUT_WIDTH(24)
    ) quatization_act4_inst (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .mode_quantization(2'b11),
        .valid_in(valid_act_out_4),
        .data_in(act_4),

        .data_out(q_act_out4),
        .valid_out(q_act_valid_out4)
    );

    //Output
    wire done_config_ofm0;
    wire done_config_ofm1;
    wire done_config_ofm2;
    wire done_config_ofm3;
    wire done_config_ofm4;

    wire full_ofm0;
    wire full_ofm1;
    wire full_ofm2;
    wire full_ofm3;
    wire full_ofm4;
    
    output_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_DEPTH(IMG_SIZE)
    )output_fifo_inst0(
        .clk(clk),
        .rst(rst),

        .start_config(start_config_ofm),
        .img_width(img_width_config),
        .img_height(img_height_config),
        .kernel_size(kernel_size_config),
        .stride(stride_config),
        .done_config(done_config_ofm0),

        .valid_in(q_act_valid_out0),
        .data_in(q_act_out0),

        .full(full_ofm0),

        .rd_en(1'b0),
        .data_out(),
        .valid_out(),

        .empty()
    );

    output_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_DEPTH(IMG_SIZE)
    )output_fifo_inst1(
        .clk(clk),
        .rst(rst),
        .start_config(start_config_ofm),
        .img_width(img_width_config),
        .img_height(img_height_config),
        .kernel_size(kernel_size_config),
        .stride(stride_config),
        .done_config(done_config_ofm1),
        .valid_in(q_act_valid_out1),
        .data_in(q_act_out1),
        .full(full_ofm1),
        .rd_en(1'b0),
        .data_out(),
        .valid_out(),
        .empty()
    );

    output_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_DEPTH(IMG_SIZE)
    )output_fifo_inst2(
        .clk(clk),
        .rst(rst),
        .start_config(start_config_ofm),
        .img_width(img_width_config),
        .img_height(img_height_config),
        .kernel_size(kernel_size_config),
        .stride(stride_config),
        .done_config(done_config_ofm2),
        .valid_in(q_act_valid_out2),
        .data_in(q_act_out2),
        .full(full_ofm2),
        .rd_en(1'b0),
        .data_out(),
        .valid_out(),
        .empty()
    );

    output_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_DEPTH(IMG_SIZE)
    )output_fifo_inst3(
        .clk(clk),
        .rst(rst),
        .start_config(start_config_ofm),
        .img_width(img_width_config),
        .img_height(img_height_config),
        .kernel_size(kernel_size_config),
        .stride(stride_config),
        .done_config(done_config_ofm3),
        .valid_in(q_act_valid_out3),
        .data_in(q_act_out3),
        .full(full_ofm3),
        .rd_en(1'b0),
        .data_out(),
        .valid_out(),
        .empty()
    );

    output_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_DEPTH(IMG_SIZE)
    )output_fifo_inst4(
        .clk(clk),
        .rst(rst),
        .start_config(start_config_ofm),
        .img_width(img_width_config),
        .img_height(img_height_config),
        .kernel_size(kernel_size_config),
        .stride(stride_config),
        .done_config(done_config_ofm4),
        .valid_in(q_act_valid_out4),
        .data_in(q_act_out4),
        .full(full_ofm4),
        .rd_en(1'b0),
        .data_out(),
        .valid_out(),
        .empty()
    );

    assign full_ofm = full_ofm0 & full_ofm1 & full_ofm2 & full_ofm3 & full_ofm4;
    assign done_config_ofm = done_config_ofm0 &
                         done_config_ofm1 &
                         done_config_ofm2 &
                         done_config_ofm3 &
                         done_config_ofm4;
endmodule