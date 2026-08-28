`timescale 1ns/1ps
module npu_ctl_tb;
    logic clk, rst;
    logic [2:0] state_out;
    logic start_config, start_compute;

    logic start_config_pixel_buffer_loader;
    logic start_config_weight_buffer_loader;
    logic start_config_activation;
    logic start_config_ofm;

    logic done_config_pixel_buffer_loader;
    logic done_config_weight_buffer_loader;
    logic done_config_activation;
    logic done_config_ofm;

    npu_controller uut(
        .clk(clk), .rst(rst), 
        .state_out(state_out),
        .start_config(start_config), .start_compute(start_compute),

        .start_config_pixel_buffer_loader(start_config_pixel_buffer_loader),
        .start_config_weight_buffer_loader(start_config_weight_buffer_loader),
        .start_config_activation(start_config_activation),
        .start_config_ofm(start_config_ofm),

        .done_config_pixel_buffer_loader(done_config_pixel_buffer_loader),
        .done_config_weight_buffer_loader(done_config_weight_buffer_loader),
        .done_config_activation(done_config_activation),
        .done_config_ofm(done_config_ofm)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start_config = 0; start_compute = 0;
        done_config_pixel_buffer_loader = 0;
        done_config_weight_buffer_loader = 0;
        done_config_activation = 0;
        done_config_ofm = 0;
        #13; rst = 0; 
        #10; start_config = 1;
        #10; start_config = 0;
        #10; done_config_pixel_buffer_loader = 1; done_config_weight_buffer_loader = 1;
        #10; done_config_pixel_buffer_loader = 0; done_config_weight_buffer_loader = 0; done_config_activation = 1;
        #10; done_config_activation = 0; done_config_ofm = 1;
        #10; done_config_ofm = 0;
        #100; $finish;
    end

    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end
endmodule