`timescale 1ns/1ps

module tb_maxpooling;

    parameter DATA_WIDTH = 24;

    reg clk;
    reg rst;

    reg config_en;
    reg [1:0] pool_size;
    reg [1:0] stride;
    reg [15:0] img_width;

    reg signed [DATA_WIDTH-1:0] data_in;
    reg valid_in;

    wire signed [DATA_WIDTH-1:0] data_out;
    wire valid_out;


    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(3),
        .MAX_STRIDE(3)
    ) dut (
        .clk(clk),
        .rst(rst),

        .config_en(config_en),
        .pool_size(pool_size),
        .stride(stride),
        .img_width(img_width),

        .data_in(data_in),
        .valid_in(valid_in),

        .data_out(data_out),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    task send_pixel;
        input signed [DATA_WIDTH-1:0] pixel;
        begin
            @(negedge clk);

            data_in  = pixel;
            valid_in = 1'b1;

            @(negedge clk);

            data_in  = 0;
            valid_in = 1'b0;
        end
    endtask

    task send_invalid;
        begin
            @(negedge clk);

            data_in  = 0;
            valid_in = 1'b0;
        end
    endtask


    initial begin

        clk = 0;

        rst       = 1'b1;
        config_en = 1'b0;

        pool_size = 0;
        stride    = 0;
        img_width = 0;

        data_in  = 0;
        valid_in = 0;

        #20;

        rst = 1'b0;

        @(negedge clk);

        config_en = 1'b1;

        pool_size = 2;
        stride    = 2;
        img_width = 2;


        @(negedge clk);

        config_en = 1'b0;

        send_pixel(24'd1);

        send_pixel(24'd2);
        send_invalid;

        send_pixel(24'd4);

        send_pixel(24'd5);

        #30;


        $finish;

    end

    always @(posedge clk) begin

        if (valid_in) begin
            $display(
                "TIME=%0t | INPUT  data=%0d valid=%b",
                $time,
                data_in,
                valid_in
            );
        end

        if (valid_out) begin
            $display(
                "TIME=%0t | OUTPUT data=%0d valid=%b",
                $time,
                data_out,
                valid_out
            );
        end

    end

    initial begin 
        $dumpfile("dump.vcd"); $dumpvars;
    end

endmodule