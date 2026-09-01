`timescale 1ns/1ps
module system_controller_tb ();
    logic clk;
    logic rst;

    logic start;

    logic ifm_done;
    logic wgt_done;
    logic bias_done;

    logic start_load;
    logic start_npu;
    system_controller dut(
        .clk(clk),
        .rst(rst),

        .start(start),

        .ifm_done(ifm_done),
        .wgt_done(wgt_done),
        .bias_done(bias_done),

        .start_load(start_load),
        .start_npu(start_npu)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0;
        ifm_done = 0; wgt_done = 0; bias_done = 0;
        #13; rst = 0;
        #10; start = 1;
        #10; start = 0;
        #60; bias_done = 1;
        #10; bias_done = 0;
        #100; wgt_done = 1;
        #10; wgt_done = 0;
        #50; ifm_done = 1;
        #10; ifm_done = 0;
        #10;
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end
endmodule