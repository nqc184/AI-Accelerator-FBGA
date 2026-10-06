`timescale 1ns/1ps

module tb_maxpooling;

    parameter DATA_WIDTH = 24;
    parameter MAX_POOL   = 3;
    parameter MAX_WIDTH  = 1024;

    reg clk;
    reg rst;

    reg enable;
    reg config_start;

    reg [1:0]  pool_size;
    reg [1:0]  stride;
    reg [15:0] img_width;

    reg signed [DATA_WIDTH-1:0] data_in;
    reg valid_in;

    wire signed [DATA_WIDTH-1:0] data_out;
    wire valid_out;
    wire config_done;

    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL  (MAX_POOL),
        .MAX_WIDTH (MAX_WIDTH)
    ) dut (
        .clk         (clk),
        .rst         (rst),

        .enable      (enable),
        .config_start(config_start),

        .pool_size   (pool_size),
        .stride      (stride),
        .img_width   (img_width),

        .data_in     (data_in),
        .valid_in    (valid_in),

        .data_out    (data_out),
        .valid_out   (valid_out),

        .config_done (config_done)
    );

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    task reset_dut;

    begin

        rst = 1'b1;

        enable       = 1'b0;
        config_start = 1'b0;

        pool_size = 2'd0;
        stride    = 2'd0;
        img_width = 16'd0;

        data_in  = 0;
        valid_in = 1'b0;

        repeat (3)
            @(posedge clk);

        @(negedge clk);

        rst = 1'b0;

    end

    endtask

    task configure;

        input [1:0]  cfg_pool_size;
        input [1:0]  cfg_stride;
        input [15:0] cfg_img_width;

    begin

        @(negedge clk);

        pool_size = cfg_pool_size;
        stride    = cfg_stride;
        img_width = cfg_img_width;

        config_start = 1'b1;

        @(negedge clk);

        config_start = 1'b0;

        @(posedge clk);
        #1;

        if (config_done == 1'b1) begin

            $display(
                "[PASS] CONFIG DONE : pool=%0d stride=%0d width=%0d",
                cfg_pool_size,
                cfg_stride,
                cfg_img_width
            );

        end

        else begin

            $display(
                "[FAIL] CONFIG DONE"
            );

        end

    end

    endtask
    task send_pixel;

        input integer value;

    begin
        @(negedge clk);
        data_in  = value;
        valid_in = 1'b1;
        @(negedge clk);
        valid_in = 1'b0;
    end

    endtask

    task send_bubble;

    begin

        @(negedge clk);

        data_in  = 24'd0;
        valid_in = 1'b0;

        @(negedge clk);

    end

    endtask

    always @(negedge clk) begin
        if (valid_out) begin
            $display(
                "[%0t ns] OUTPUT = %0d",
                $time,
                data_out
            );
        end
    end

    initial begin

        rst = 1'b0;

        enable       = 1'b0;
        config_start = 1'b0;

        pool_size = 0;
        stride    = 0;
        img_width = 0;

        data_in  = 0;
        valid_in = 0;

        $display("");
        $display("==============================================");
        $display(" RESET");
        $display("==============================================");

        reset_dut;

        $display("");
        $display("==============================================");
        $display(" TEST 1 : 2x2 / STRIDE 2");
        $display("==============================================");

        enable = 1'b1;

        configure(
            2'd2,
            2'd2,
            16'd5
        );

        send_pixel(1);
        send_pixel(2);
        send_pixel(3);
        send_pixel(4);
        send_pixel(5);

        send_pixel(6);
        send_pixel(7);
        send_pixel(8);
        send_pixel(9);
        send_pixel(10);

        send_pixel(11);
        send_pixel(12);
        send_pixel(13);
        send_pixel(14);
        send_pixel(15);

        send_pixel(16);
        send_pixel(17);
        send_pixel(18);
        send_pixel(19);
        send_pixel(20);

        send_pixel(21);
        send_pixel(22);
        send_pixel(23);
        send_pixel(24);
        send_pixel(25);

        repeat (2)
            @(posedge clk);

        $display("");
        $display("==============================================");
        $display(" TEST 2 : 2x2 / STRIDE 2 + BUBBLES");
        $display("==============================================");


        configure(
            2'd2,
            2'd2,
            16'd5
        );

        send_pixel(1);
        send_pixel(2);
        send_bubble;
        send_pixel(3);
        send_pixel(4);
        send_pixel(5);

        send_pixel(6);
        send_bubble;
        send_pixel(7);
        send_pixel(8);
        send_bubble;
        send_pixel(9);
        send_pixel(10);

        send_pixel(11);
        send_pixel(12);
        send_pixel(13);
        send_bubble;
        send_pixel(14);
        send_pixel(15);

        send_pixel(16);
        send_pixel(17);
        send_bubble;
        send_pixel(18);
        send_pixel(19);
        send_pixel(20);

        send_pixel(21);
        send_bubble;
        send_pixel(22);
        send_pixel(23);
        send_pixel(24);
        send_bubble;
        send_pixel(25);

        repeat (2)
            @(posedge clk);

        $display("");
        $display("==============================================");
        $display(" TEST 3 : 3x3 / STRIDE 1");
        $display("==============================================");

        configure(
            2'd3,
            2'd1,
            16'd5
        );

        send_pixel(1);
        send_pixel(2);
        send_pixel(3);
        send_pixel(4);
        send_pixel(5);

        send_pixel(6);
        send_pixel(7);
        send_pixel(8);
        send_pixel(9);
        send_pixel(10);

        send_pixel(11);
        send_pixel(12);
        send_pixel(13);
        send_pixel(14);
        send_pixel(15);

        send_pixel(16);
        send_pixel(17);
        send_pixel(18);
        send_pixel(19);
        send_pixel(20);

        send_pixel(21);
        send_pixel(22);
        send_pixel(23);
        send_pixel(24);
        send_pixel(25);

        repeat (2)
            @(posedge clk);

        $display("");
        $display("==============================================");
        $display(" TEST 4 : 1x1 / STRIDE 1");
        $display("==============================================");

        configure(
            2'd1,
            2'd1,
            16'd5
        );

        send_pixel(100);
        send_pixel(200);
        send_pixel(300);

        repeat (2)
            @(posedge clk);

        $display("");
        $display("==============================================");
        $display(" TEST 5 : BYPASS");
        $display("==============================================");


        enable = 1'b0;

        @(negedge clk);

        data_in  = 24'd1234;
        valid_in = 1'b1;

        @(negedge clk);

        #1;

        if ((data_out == 24'd1234) &&
            (valid_out == 1'b1)) begin
            $display(
                "[PASS] BYPASS : data=%0d valid=%b",
                data_out,
                valid_out
            );
        end

        else begin
            $display(
                "[FAIL] BYPASS : data=%0d valid=%b",
                data_out,
                valid_out
            );
        end

        @(negedge clk);

        data_in  = 24'd5678;
        valid_in = 1'b0;

        @(negedge clk);

        #1;

        if (valid_out == 1'b0) begin
            $display(
                "[PASS] BYPASS INVALID"
            );
        end

        else begin
            $display(
                "[FAIL] BYPASS INVALID"
            );
        end

        $display("");
        $display("==============================================");
        $display(" ALL TESTS FINISHED");
        $display("==============================================");
        #20;
        $finish;
    end
  
    initial begin 
        $dumpfile("dump.vcd"); $dumpvars;
    end

endmodule