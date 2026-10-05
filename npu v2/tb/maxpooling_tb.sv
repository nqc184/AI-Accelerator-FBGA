`timescale 1ns/1ps

module tb_maxpooling;

    parameter DATA_WIDTH = 24;

    logic clk;
    logic rst;

    logic config_en;
    logic [1:0] pool_size;
    logic [1:0] stride;
    logic [15:0] img_width;

    logic signed [DATA_WIDTH-1:0] data_in;
    logic valid_in;
    logic signed [DATA_WIDTH-1:0] data_out;
    logic valid_out;


    maxpooling #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_POOL(3)
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
        input [DATA_WIDTH-1:0] pixel;
        begin
            @(negedge clk);
            data_in  = pixel;
            valid_in = 1'b1;
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
        rst = 1;
        config_en = 0;

        pool_size = 0;
        stride    = 0;
        img_width = 0;

        data_in  = 0;
        valid_in = 0;
        #20;
        rst = 0;

        @(negedge clk);
        config_en = 1;
        pool_size = 2;
        stride    = 2;
        img_width = 5;
        @(negedge clk);
        config_en = 0;

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

        #10;
        send_invalid(0);
        #50;
        $finish;
    end


    always @(posedge clk) begin
        if (valid_out) begin
            $display("TIME=%0t | MAXPOOL OUTPUT = %0d | VALID = %b",
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