`timescale 1ns/1ps
module tb;
    logic clk, rst, start_npu;
    logic [2:0] current_state_monitor;

    logic [15:0] img_width, img_height;
    logic [2:0] kernel_size, stride;
    logic [1:0] activation;
    logic [15:0] number_kernel;

    logic [15:0] img_width_config, img_height_config;
    logic [2:0] kernel_size_config, stride_config;
    logic [1:0] activation_config;

    logic start_config_pixel_buffer_loader, start_config_weight_buffer_loader;
    logic start_config_activation, start_config_ofm;

    logic done_config_pixel_buffer_loader, done_config_weight_buffer_loader;
    logic done_config_activation, done_config_ofm;

    logic rd_en_pixel;
    logic [13:0] rd_addr_pixel; 
    logic rd_en_wgt;
    logic [13:0] rd_addr_wgt; 
    logic rd_en_bias; 
    logic [13:0] rd_addr_bias; 

    logic valid_pixel, valid_wgt, valid_bias;

    logic start_calc;
    logic done_calc;

    logic valid_window_out, valid_wgt_out, last_window_out;
    logic [15:0] number_kernel_monitor;
    logic [2:0] window_cnt_monitor, wgt_cnt_monitor, bias_cnt_monitor;

    npu_controller dut(
        .clk(clk), .rst(rst), .start_npu(start_npu),
        .current_state_monitor(current_state_monitor),

        .img_width(img_width), .img_height(img_height),
        .kernel_size(kernel_size), .stride(stride),
        .activation(activation),
        .number_kernel(number_kernel),

        .img_width_config(img_width_config), .img_height_config(img_height_config),
        .kernel_size_config(kernel_size_config), .stride_config(stride_config),
        .activation_config(activation_config),

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

        .start_calc(start_calc), .done_calc(done_calc),

        .valid_window_out(valid_window_out),
        .valid_wgt_out(valid_wgt_out),
        .last_window_out(last_window_out),
        .number_kernel_monitor(number_kernel_monitor),
        .window_cnt_monitor(window_cnt_monitor), .wgt_cnt_monitor(wgt_cnt_monitor), .bias_cnt_monitor(bias_cnt_monitor)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start_npu = 0;
        img_width = 16'd36; img_height = 16'd36;
        kernel_size = 3'd3; stride = 3'd2;
        activation = 2'd1;
        number_kernel = 16'd6;
        done_config_pixel_buffer_loader = 0; done_config_weight_buffer_loader = 0;
        done_config_activation = 0; done_config_ofm = 0;
        valid_window_out = 0; valid_wgt_out = 0; last_window_out = 0;
        done_calc = 0;
        #13 rst = 0;
        #10 start_npu = 1;
        #10 start_npu = 0;

        #50 done_config_pixel_buffer_loader = 1;
        #10 done_config_pixel_buffer_loader = 0;

        #50 done_config_weight_buffer_loader = 1;
        #10 done_config_weight_buffer_loader = 0;

        #50 done_config_activation = 1;
        #10 done_config_activation = 0;

        #50 done_config_ofm = 1;
        #10 done_config_ofm = 0;

        #130; valid_window_out = 1; valid_wgt_out = 1;
        #50; valid_window_out = 0; valid_wgt_out = 0;
        #100; done_calc = 1;
        #10; done_calc = 0;
        #100; valid_window_out = 1; 
        #50; valid_window_out = 0;  
        #100; done_calc = 1;
        #10; done_calc = 0;
        #50; valid_window_out = 1;
        #20; last_window_out = 1; 
        #10; valid_window_out = 0; last_window_out = 0; 
        #100; done_calc = 1;
        #10; done_calc = 0;
        #20 $finish;
    end 

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
endmodule