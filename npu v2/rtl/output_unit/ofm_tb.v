
`timescale 1ns/1ps

module ofm_tb;

    parameter DATA_WIDTH = 24;

    reg clk;
    reg rst;

    reg [DATA_WIDTH-1:0] data_in0;
    reg [DATA_WIDTH-1:0] data_in1;
    reg [DATA_WIDTH-1:0] data_in2;
    reg [DATA_WIDTH-1:0] data_in3;
    reg [DATA_WIDTH-1:0] data_in4;

    reg valid_in0;
    reg valid_in1;
    reg valid_in2;
    reg valid_in3;
    reg valid_in4;

    reg config_start;
    reg [15:0] img_width;
    reg [15:0] img_height;
    reg [15:0] num_kernels;

    wire config_done;
    wire write_done;

    reg read_start;
    wire [DATA_WIDTH-1:0] data_out;
    wire valid_out;
    wire [$clog2(256)-1:0] kernel_out;
    wire [31:0] addr_out;
    wire read_done;
    wire overflow;

    integer i;
    integer count;
    integer errors;
    integer expected_data;
    integer expected_kernel;
    integer expected_addr;

    ofm #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_IMG_WIDTH(1024),
        .MAX_KERNELS(256)
    ) dut (
        .clk(clk),
        .rst(rst),

        .data_in0(data_in0),
        .data_in1(data_in1),
        .data_in2(data_in2),
        .data_in3(data_in3),
        .data_in4(data_in4),

        .valid_in0(valid_in0),
        .valid_in1(valid_in1),
        .valid_in2(valid_in2),
        .valid_in3(valid_in3),
        .valid_in4(valid_in4),

        .config_start(config_start),
        .img_width(img_width),
        .img_height(img_height),
        .num_kernels(num_kernels),

        .config_done(config_done),
        .write_done(write_done),

        .read_start(read_start),
        .data_out(data_out),
        .valid_out(valid_out),
        .kernel_out(kernel_out),
        .addr_out(addr_out),
        .read_done(read_done),
        .overflow(overflow)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("ofm.vcd");
        $dumpvars(0, ofm_tb);

        rst = 1;

        data_in0 = 0;
        data_in1 = 0;
        data_in2 = 0;
        data_in3 = 0;
        data_in4 = 0;

        valid_in0 = 0;
        valid_in1 = 0;
        valid_in2 = 0;
        valid_in3 = 0;
        valid_in4 = 0;

        config_start = 0;
        img_width = 2;
        img_height = 2;
        num_kernels = 6;

        read_start = 0;
        count = 0;
        errors = 0;

        repeat (3) @(negedge clk);
        rst = 0;

        @(negedge clk);
        config_start = 1;

        @(negedge clk);
        config_start = 0;

        wait(config_done);
        $display("[%0t] Configuration completed", $time);

        if (write_done !== 0) begin
            $display("ERROR: write_done should be 0 before writing");
            errors = errors + 1;
        end

        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);

            valid_in0 = 1;
            valid_in1 = 1;
            valid_in2 = 1;
            valid_in3 = 1;
            valid_in4 = 1;

            data_in0 = 100 + i;
            data_in1 = 200 + i;
            data_in2 = 300 + i;
            data_in3 = 400 + i;
            data_in4 = 500 + i;
        end

        @(negedge clk);

        valid_in1 = 0;
        valid_in2 = 0;
        valid_in3 = 0;
        valid_in4 = 0;

        for (i = 0; i < 4; i = i + 1) begin
            valid_in0 = 1;
            data_in0 = 600 + i;
            @(negedge clk);
        end

        valid_in0 = 0;

        wait(write_done === 1'b1);
        @(negedge clk);

        $display("[%0t] write_done asserted", $time);

        if (overflow !== 0) begin
            $display("ERROR: overflow asserted unexpectedly");
            errors = errors + 1;
        end

        read_start = 1;
        @(negedge clk);
        read_start = 0;

        while (count < 24) begin
            @(negedge clk);

            if (valid_out) begin
                expected_kernel = count / 4;
                expected_addr = count % 4;
                expected_data = (expected_kernel + 1) * 100
                              + expected_addr;

                $display(
                    "Kernel=%0d Addr=%0d Data=%0d Expected=%0d",
                    kernel_out,
                    addr_out,
                    data_out,
                    expected_data
                );

                if (kernel_out !== expected_kernel) begin
                    $display("ERROR: incorrect kernel index");
                    errors = errors + 1;
                end

                if (addr_out !== expected_addr) begin
                    $display("ERROR: incorrect pixel address");
                    errors = errors + 1;
                end

                if (data_out !== expected_data) begin
                    $display("ERROR: incorrect pixel data");
                    errors = errors + 1;
                end

                count = count + 1;
            end
        end

        wait(read_done === 1'b1);

        $display("[%0t] read_done asserted", $time);

        if (count != 24) begin
            $display("ERROR: incorrect output pixel count");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("========== TEST PASSED ==========");
        else
            $display("========== TEST FAILED: %0d errors ==========", errors);

        #20;
        $finish;
    end

    initial begin
        #10000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule