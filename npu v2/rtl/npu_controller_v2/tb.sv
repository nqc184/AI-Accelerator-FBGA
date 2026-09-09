`timescale 1ns/1ps
module tb;
    logic clk, rst, start_npu;
    logic [2:0] current_state_monitor;

    logic [15:0] img_width, img_height;
    logic [2:0] kernel_size, stride;
    logic [1:0] activation;

    logic [15:0] img_width_config, img_height_config;
    logic [2:0] kernel_size_config, stride_config;
    logic [1:0] activation_config;

    logic start_config_pixel_buffer_loader, start_config_weight_buffer_loader;
    logic start_config_activation, start_config_ofm;

    logic done_config_pixel_buffer_loader, done_config_weight_buffer_loader;
    logic done_config_activation, done_config_ofm;

    npu_controller dut(
        .clk(clk), .rst(rst), .start_npu(start_npu),
        .current_state_monitor(current_state_monitor),

        .img_width(img_width), .img_height(img_height),
        .kernel_size(kernel_size), .stride(stride),
        .activation(activation),

        .img_width_config(img_width_config), .img_height_config(img_height_config),
        .kernel_size_config(kernel_size_config), .stride_config(stride_config),
        .activation_config(activation_config),

        .start_config_pixel_buffer_loader(start_config_pixel_buffer_loader), .start_config_weight_buffer_loader(start_config_weight_buffer_loader),
        .start_config_activation(start_config_activation), .start_config_ofm(start_config_ofm),

        .done_config_pixel_buffer_loader(done_config_pixel_buffer_loader), .done_config_weight_buffer_loader(done_config_weight_buffer_loader),
        .done_config_activation(done_config_activation), .done_config_ofm(done_config_ofm)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start_npu = 0;
        img_width = 16'd36; img_height = 16'd36;
        kernel_size = 3'd3; stride = 3'd2;
        activation = 2'd1;
        done_config_pixel_buffer_loader = 0; done_config_weight_buffer_loader = 0;
        done_config_activation = 0; done_config_ofm = 0;
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

        #200 $finish;
    end 

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
endmodule