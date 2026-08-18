`timescale 1ns/1ps

module tb_pe;

    logic clk;
    logic reset;
    logic clear;
    logic valid_in;

    logic [15:0] in_a;
    logic [15:0] in_b;

    logic valid_out;
    logic [15:0] out_a;
    logic [15:0] out_b;
    logic [15:0] out_c;

    integer pass_count;
    integer fail_count;

    pe dut(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .valid_in(valid_in),
        .in_a(in_a),
        .in_b(in_b),
        .out_a(out_a),
        .out_b(out_b),
        .out_c(out_c),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    function automatic real fp16_to_real(input logic [15:0] data);

        integer sign;
        integer exponent;
        integer fraction;
        real mantissa;
        real value;

        begin
            sign = data[15];
            exponent = data[14:10];
            fraction = data[9:0];

            if ((exponent == 0) && (fraction == 0)) begin
                value = 0.0;
            end
            else begin
                mantissa = 1.0 + (fraction / 1024.0);
                value = mantissa * (2.0 ** (exponent - 15));
            end

            if (sign)
                fp16_to_real = -value;
            else
                fp16_to_real = value;
        end

    endfunction

    task automatic reset_pe;

        begin
            reset = 1'b1;
            clear = 1'b0;
            valid_in = 1'b0;
            in_a = 16'h0000;
            in_b = 16'h0000;

            @(posedge clk);
            #1;

            reset = 1'b0;

            @(posedge clk);
            #1;
        end

    endtask

    task automatic clear_test(
        input string name
    );

        begin
            clear = 1'b1;
            valid_in = 1'b0;

            @(posedge clk);
            #1;

            clear = 1'b0;

            @(posedge clk);
            #1;

            if ((out_c === 16'h0000) &&
                (valid_out === 1'b0)) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | %-25s | ACC=%h | VALID=%b",
                    name,
                    out_c,
                    valid_out
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL | %-25s | ACC=%h | EXPECTED=0000 | VALID=%b",
                    name,
                    out_c,
                    valid_out
                );

            end
        end

    endtask

    task automatic mac_test(
        input string name,
        input logic [15:0] a_in,
        input logic [15:0] b_in,
        input logic [15:0] expected_acc
    );

        begin

            in_a = a_in;
            in_b = b_in;
            valid_in = 1'b1;

            @(posedge clk);
            #1;

            valid_in = 1'b0;

            @(posedge clk);
            #1;

            if ((out_c === expected_acc) &&
                (out_a === a_in) &&
                (out_b === b_in) &&
                (valid_out === 1'b1)) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | %-25s | A=%h(%f) | B=%h(%f) | ACC=%h(%f) | VALID=%b",
                    name,
                    a_in,
                    fp16_to_real(a_in),
                    b_in,
                    fp16_to_real(b_in),
                    out_c,
                    fp16_to_real(out_c),
                    valid_out
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL | %-25s | A=%h(%f) | B=%h(%f) | ACC=%h(%f) | EXPECTED=%h(%f) | VALID=%b",
                    name,
                    a_in,
                    fp16_to_real(a_in),
                    b_in,
                    fp16_to_real(b_in),
                    out_c,
                    fp16_to_real(out_c),
                    expected_acc,
                    fp16_to_real(expected_acc),
                    valid_out
                );

            end

        end

    endtask

    task automatic invalid_test(
        input string name,
        input logic [15:0] a_in,
        input logic [15:0] b_in,
        input logic [15:0] expected_acc
    );

        begin

            in_a = a_in;
            in_b = b_in;
            valid_in = 1'b0;

            @(posedge clk);
            #1;

            @(posedge clk);
            #1;

            if ((out_c === expected_acc) &&
                (valid_out === 1'b0)) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | %-25s | A=%h | B=%h | ACC=%h(%f) | VALID=%b",
                    name,
                    a_in,
                    b_in,
                    out_c,
                    fp16_to_real(out_c),
                    valid_out
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL | %-25s | A=%h | B=%h | ACC=%h | EXPECTED=%h | VALID=%b",
                    name,
                    a_in,
                    b_in,
                    out_c,
                    expected_acc,
                    valid_out
                );

            end

        end

    endtask

    initial begin

        clk = 1'b0;
        reset = 1'b0;
        clear = 1'b0;
        valid_in = 1'b0;
        in_a = 16'h0000;
        in_b = 16'h0000;

        pass_count = 0;
        fail_count = 0;

        $display("");
        $display("==============================================================");
        $display("                     FP16 PE TESTBENCH");
        $display("==============================================================");
        $display("");

        reset_pe();

        clear_test(
            "Clear accumulator"
        );

        mac_test(
            "1.5 * 2.0 + 0",
            16'h3E00,
            16'h4000,
            16'h4200
        );

        mac_test(
            "1.0 * 2.0 + 3",
            16'h3C00,
            16'h4000,
            16'h4500
        );

        mac_test(
            "2.0 * 2.0 + 5",
            16'h4000,
            16'h4000,
            16'h4880
        );

        invalid_test(
            "VALID = 0",
            16'h4400,
            16'h4400,
            16'h4880
        );

        mac_test(
            "1.0 * 1.0 + 9",
            16'h3C00,
            16'h3C00,
            16'h4900
        );

        invalid_test(
            "VALID = 0 again",
            16'h4000,
            16'h4000,
            16'h4900
        );

        clear_test(
            "Clear after MAC"
        );

        mac_test(
            "2.0 * 3.0 + 0",
            16'h4000,
            16'h4200,
            16'h4600
        );

        mac_test(
            "-2.0 * 3.0 + 6",
            16'hC000,
            16'h4200,
            16'h0000
        );

        $display("");
        $display("==============================================================");
        $display("                         SUMMARY");
        $display("==============================================================");
        $display("PASS  = %0d", pass_count);
        $display("FAIL  = %0d", fail_count);
        $display("TOTAL = %0d", pass_count + fail_count);
        $display("==============================================================");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $display("");

        #10;
        $finish;

    end

endmodule