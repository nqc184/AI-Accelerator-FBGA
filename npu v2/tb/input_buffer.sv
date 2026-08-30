`timescale 1ns/1ps
`define DW 24
`define IMG_SIZE 20
`define DEPTH ((`IMG_SIZE + 4) / 5)
`define ADDR_WIDTH 12
`define CNT_WIDTH 14

module input_buffer_fifo_tb;
    logic clk;
    logic rst;

    logic         write_enable;
    logic [127:0] write_data;
    logic         write_last;
    logic         ifm_done;

    logic                   read_enable;
    logic signed [`DW-1:0]  read_data;
    logic                   read_valid;
    logic                   read_last;

    integer error_count;
    integer i;
    reg signed [`DW-1:0] expected_mem [0:`IMG_SIZE-1];

    ifm_buffer #(
        .DW        (`DW),
        .IMG_SIZE  (`IMG_SIZE),
        .DEPTH     (`DEPTH),
        .ADDR_WIDTH(`ADDR_WIDTH),
        .CNT_WIDTH (`CNT_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),

        .write_enable(write_enable),
        .write_data  (write_data),
        .write_last  (write_last),
        .ifm_done    (ifm_done),

        .read_enable(read_enable),
        .read_data  (read_data),
        .read_valid (read_valid),
        .read_last  (read_last)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    function [127:0] pack_beat;
        input signed [`DW-1:0] s0, s1, s2, s3, s4;
        input [4:0] keep;
        begin
            pack_beat = {3'b000, keep, s4, s3, s2, s1, s0};
        end
    endfunction

    task reset_dut;
        begin
            rst          = 1'b1;
            write_enable = 1'b0;
            write_data   = 128'd0;
            write_last   = 1'b0;
            read_enable  = 1'b0;
            repeat (3) @(posedge clk);
            rst = 1'b0;
            @(posedge clk);
        end
    endtask

    task write_beat;
        input [127:0] data;
        input         last;
        begin
            @(negedge clk);
            write_data   = data;
            write_last   = last;
            write_enable = 1'b1;
            @(negedge clk);
            write_enable = 1'b0;
            write_last   = 1'b0;
        end
    endtask

    task read_and_check;
        input signed [`DW-1:0] exp_val;
        begin
            @(negedge clk);
            read_enable = 1'b1;
            @(negedge clk);
            read_enable = 1'b0;

            @(negedge clk);

            if (!read_valid) begin
                $display("[%0t ns] LOI: read_valid khong len dung luc!", $time);
                error_count = error_count + 1;
            end
            else if (read_data !== exp_val) begin
                $display("[%0t ns] LOI: mong doi %0d, nhan duoc %0d", $time, exp_val, read_data);
                error_count = error_count + 1;
            end
            else begin
                $display("[%0t ns] OK: doc dung gia tri %0d", $time, read_data);
            end
        end
    endtask

    initial begin
        error_count = 0;
        for (i = 0; i < `IMG_SIZE; i = i + 1)
            expected_mem[i] = i + 1;

        reset_dut;
        i = 0;
        while (i < `IMG_SIZE) begin
            if (i + 5 <= `IMG_SIZE) begin
                write_beat(
                    pack_beat(expected_mem[i], expected_mem[i+1], expected_mem[i+2],
                              expected_mem[i+3], expected_mem[i+4], 5'b11111),
                    (i + 5 == `IMG_SIZE)
                );
                i = i + 5;
            end
            else begin
                case (`IMG_SIZE - i)
                    4: write_beat(pack_beat(expected_mem[i], expected_mem[i+1], expected_mem[i+2], expected_mem[i+3], {`DW{1'b0}}, 5'b01111), 1'b1);
                    3: write_beat(pack_beat(expected_mem[i], expected_mem[i+1], expected_mem[i+2], {`DW{1'b0}}, {`DW{1'b0}}, 5'b00111), 1'b1);
                    2: write_beat(pack_beat(expected_mem[i], expected_mem[i+1], {`DW{1'b0}}, {`DW{1'b0}}, {`DW{1'b0}}, 5'b00011), 1'b1);
                    1: write_beat(pack_beat(expected_mem[i], {`DW{1'b0}}, {`DW{1'b0}}, {`DW{1'b0}}, {`DW{1'b0}}, 5'b00001), 1'b1);
                endcase
                i = `IMG_SIZE;   
            end
        end

        @(posedge clk);
        if (!ifm_done)
            $display("[%0t ns] CANH BAO: ifm_done chua len sau khi ghi xong!", $time);
        else
            $display("[%0t ns] OK: ghi xong, ifm_done = 1", $time);

        for (i = 0; i < `IMG_SIZE; i = i + 1)
            read_and_check(expected_mem[i]);

        if (error_count == 0)
            $display(">>> TEST PASS: tat ca %0d mau dung <<<", `IMG_SIZE);
        else
            $display(">>> TEST FAIL: %0d loi <<<", error_count);

        $finish;
    end
endmodule