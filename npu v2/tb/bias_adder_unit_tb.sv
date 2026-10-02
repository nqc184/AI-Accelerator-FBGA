`timescale 1ns/1ps
module tb;
    logic clk, rst;
    logic col1_valid, col2_valid, col3_valid, col4_valid, col5_valid;
    logic signed [47:0] col1_out, col2_out, col3_out, col4_out, col5_out;
    logic signed [47:0] bias_in;
    logic [2:0] sel;
    logic signed [47:0] bias_reg0_monitor, bias_reg1_monitor, bias_reg2_monitor, bias_reg3_monitor, bias_reg4_monitor;
    logic signed [47:0] bias_adder_result0, bias_adder_result1, bias_adder_result2, bias_adder_result3, bias_adder_result4;
    logic valid_bias_adder_result0, valid_bias_adder_result1, valid_bias_adder_result2, valid_bias_adder_result3, valid_bias_adder_result4;

    bias_adder_unit dut (
        .clk(clk),
        .rst(rst),
        .col1_valid(col1_valid),
        .col2_valid(col2_valid),
        .col3_valid(col3_valid),
        .col4_valid(col4_valid),
        .col5_valid(col5_valid),
        .col1_out(col1_out),
        .col2_out(col2_out),
        .col3_out(col3_out),
        .col4_out(col4_out),
        .col5_out(col5_out),
        .bias_in(bias_in),
        .sel(sel),
        .bias_reg0_monitor(bias_reg0_monitor),
        .bias_reg1_monitor(bias_reg1_monitor),
        .bias_reg2_monitor(bias_reg2_monitor),
        .bias_reg3_monitor(bias_reg3_monitor),
        .bias_reg4_monitor(bias_reg4_monitor),
        .bias_adder_result0(bias_adder_result0),
        .bias_adder_result1(bias_adder_result1),
        .bias_adder_result2(bias_adder_result2),
        .bias_adder_result3(bias_adder_result3),
        .bias_adder_result4(bias_adder_result4),
        .valid_bias_adder_result0(valid_bias_adder_result0),
        .valid_bias_adder_result1(valid_bias_adder_result1),
        .valid_bias_adder_result2(valid_bias_adder_result2),
        .valid_bias_adder_result3(valid_bias_adder_result3),
        .valid_bias_adder_result4(valid_bias_adder_result4)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        col1_valid = 0;
        col2_valid = 0;
        col3_valid = 0;
        col4_valid = 0;
        col5_valid = 0;
        col1_out = 0;
        col2_out = 0;
        col3_out = 0;
        col4_out = 0;
        col5_out = 0;
        bias_in = 0;
        sel = 0;

        #10 rst = 0;
        @(posedge clk);
        bias_in = 48'sd10; sel = 3'd0; 
        @(posedge clk);
        bias_in = 48'sd20; sel = 3'd1; 
        @(posedge clk);
        bias_in = 48'sd30; sel = 3'd2; 
        @(posedge clk);
        bias_in = 48'sd40; sel = 3'd3; 
        @(posedge clk);
        bias_in = 48'sd50; sel = 3'd4; 

        @(posedge clk);
        col1_valid = 1; col1_out = 48'sd100;
        col2_valid = 1; col2_out = 48'sd200;
        col3_valid = 1; col3_out = 48'sd300;
        col4_valid = 1; col4_out = 48'sd400;
        col5_valid = 1; col5_out = 48'sd500;
        #10; $finish;
    end

    initial begin
        $dumpfile("bias_adder_unit_tb.vcd");
        $dumpvars(0, tb);
    end
endmodule