`timescale 1ns/1ps

module tb_fp16_adder;

    logic [15:0] a;
    logic [15:0] b;
    logic [15:0] result;

    integer pass_count;
    integer fail_count;

    fp16_adder dut (
        .a(a),
        .b(b),
        .result(result)
    );

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

    task automatic test_case(
        input string name,
        input logic [15:0] a_in,
        input logic [15:0] b_in,
        input logic [15:0] expected
    );

        begin

            a = a_in;
            b = b_in;

            #10;

            if (result === expected) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | %-25s | A=%h (%f) | B=%h (%f) | RESULT=%h (%f)",
                    name,
                    a,
                    fp16_to_real(a),
                    b,
                    fp16_to_real(b),
                    result,
                    fp16_to_real(result)
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL | %-25s | A=%h (%f) | B=%h (%f) | RESULT=%h (%f) | EXPECTED=%h (%f)",
                    name,
                    a,
                    fp16_to_real(a),
                    b,
                    fp16_to_real(b),
                    result,
                    fp16_to_real(result),
                    expected,
                    fp16_to_real(expected)
                );

            end

        end

    endtask

    initial begin

        pass_count = 0;
        fail_count = 0;

        $display("");
        $display("==============================================================");
        $display("                    FP16 ADDER TEST");
        $display("==============================================================");
        $display("");

        test_case(
            "Same sign",
            16'h3E00,
            16'h4000,
            16'h4080
        );

        test_case(
            "Same sign negative",
            16'hBE00,
            16'hC000,
            16'hC080
        );

        test_case(
            "Different sign",
            16'h4000,
            16'hBC00,
            16'h3C00
        );

        test_case(
            "Different sign negative",
            16'hBC00,
            16'h4000,
            16'hBC00
        );

        test_case(
            "Equal magnitude",
            16'h4000,
            16'hC000,
            16'h0000
        );

        test_case(
            "1.0 + 1.0",
            16'h3C00,
            16'h3C00,
            16'h4000
        );

        test_case(
            "1.5 + 1.5",
            16'h3E00,
            16'h3E00,
            16'h4200
        );

        test_case(
            "2.0 + 2.0",
            16'h4000,
            16'h4000,
            16'h4400
        );

        test_case(
            "2.0 + 3.0",
            16'h4000,
            16'h4200,
            16'h4500
        );

        test_case(
            "1.0 + 0.5",
            16'h3C00,
            16'h3800,
            16'h3E00
        );

        test_case(
            "1.0 - 0.5",
            16'h3C00,
            16'hB800,
            16'h3800
        );

        test_case(
            "2.0 - 1.5",
            16'h4000,
            16'hBE00,
            16'h3800
        );

        test_case(
            "8.0 + 1.0",
            16'h4800,
            16'h3C00,
            16'h4900
        );

        test_case(
            "8.0 - 1.0",
            16'h4800,
            16'hBC00,
            16'h4780
        );

        test_case(
            "Large exponent difference",
            16'h6400,
            16'h3C00,
            16'h6400
        );

        test_case(
            "Zero + number",
            16'h0000,
            16'h4200,
            16'h4200
        );

        test_case(
            "Number + zero",
            16'h4200,
            16'h0000,
            16'h4200
        );

        test_case(
            "Zero + zero",
            16'h0000,
            16'h0000,
            16'h0000
        );

        test_case(
            "Normalization left",
            16'h3C00,
            16'hB800,
            16'h3800
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