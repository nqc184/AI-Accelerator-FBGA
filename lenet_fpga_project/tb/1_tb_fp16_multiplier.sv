`timescale 1ns/1ps

module tb_fp16_multiplier;

    logic [15:0] a;
    logic [15:0] b;
    logic [15:0] result;

    integer pass_count;
    integer fail_count;

    fp16_multiplier dut (
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

            if (exponent == 0 && fraction == 0) begin
                value = 0.0;
            end
            else if (exponent == 0) begin
                mantissa = fraction / 1024.0;
                value = mantissa * (2.0 ** (-14));
            end
            else if (exponent == 31) begin
                if (fraction == 0)
                    value = 1.0e30;
                else
                    value = 0.0 / 0.0;
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

    function automatic logic [15:0] real_to_fp16(input real value);
        real abs_value;
        real normalized;
        real scaled_fraction;
        integer sign;
        integer exponent;
        integer fraction;
        integer rounded_fraction;
        integer exp_bits;
        begin
            if (value == 0.0) begin
                real_to_fp16 = 16'h0000;
            end
            else begin
                sign = (value < 0.0);
                abs_value = (value < 0.0) ? -value : value;

                exponent = 0;
                normalized = abs_value;

                while (normalized >= 2.0) begin
                    normalized = normalized / 2.0;
                    exponent = exponent + 1;
                end

                while (normalized < 1.0) begin
                    normalized = normalized * 2.0;
                    exponent = exponent - 1;
                end

                exp_bits = exponent + 15;

                if (exp_bits <= 0) begin
                    real_to_fp16 = {sign, 15'd0};
                end
                else if (exp_bits >= 31) begin
                    real_to_fp16 = {
                        sign,
                        5'b11111,
                        10'b0000000000
                    };
                end
                else begin
                    scaled_fraction = (normalized - 1.0) * 1024.0;
                    rounded_fraction = $rtoi(scaled_fraction + 0.5);

                    if (rounded_fraction >= 1024) begin
                        rounded_fraction = 0;
                        exp_bits = exp_bits + 1;
                    end

                    if (exp_bits >= 31) begin
                        real_to_fp16 = {
                            sign,
                            5'b11111,
                            10'b0000000000
                        };
                    end
                    else begin
                        fraction = rounded_fraction;

                        real_to_fp16 = {
                            sign,
                            exp_bits[4:0],
                            fraction[9:0]
                        };
                    end
                end
            end
        end
    endfunction

    task automatic test_case(
        input string test_name,
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
                    test_name,
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
                    test_name,
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

        a = 16'd0;
        b = 16'd0;

        $display("");
        $display("==============================================================");
        $display("                  FP16 MULTIPLIER TEST");
        $display("==============================================================");
        $display("");

        test_case(
            "1.0 * 1.0",
            16'h3C00,
            16'h3C00,
            16'h3C00
        );

        test_case(
            "1.5 * 2.0",
            16'h3E00,
            16'h4000,
            16'h4200
        );

        test_case(
            "0.5 * 0.5",
            16'h3800,
            16'h3800,
            16'h3400
        );

        test_case(
            "2.0 * 4.0",
            16'h4000,
            16'h4400,
            16'h4800
        );

        test_case(
            "2.0 * 3.0",
            16'h4000,
            16'h4200,
            16'h4600
        );

        test_case(
            "-2.0 * 3.0",
            16'hC000,
            16'h4200,
            16'hC600
        );

        test_case(
            "-2.0 * -3.0",
            16'hC000,
            16'hC200,
            16'h4600
        );

        test_case(
            "-1.0 * 1.0",
            16'hBC00,
            16'h3C00,
            16'hBC00
        );

        test_case(
            "1.0 * -1.0",
            16'h3C00,
            16'hBC00,
            16'hBC00
        );

        test_case(
            "-1.0 * -1.0",
            16'hBC00,
            16'hBC00,
            16'h3C00
        );

        test_case(
            "0.0 * 5.0",
            16'h0000,
            16'h4500,
            16'h0000
        );

        test_case(
            "5.0 * 0.0",
            16'h4500,
            16'h0000,
            16'h0000
        );

        test_case(
            "1.5 * 1.5",
            16'h3E00,
            16'h3E00,
            16'h40A0
        );

        test_case(
            "2.5 * 2.5",
            16'h4100,
            16'h4100,
            16'h4420
        );

        test_case(
            "4.0 * 4.0",
            16'h4400,
            16'h4400,
            16'h4800
        );

        test_case(
            "8.0 * 8.0",
            16'h4800,
            16'h4800,
            16'h5000
        );

        test_case(
            "1.0009766 * 1.0009766",
            16'h3C04,
            16'h3C04,
            16'h3C08
        );

        $display("");
        $display("==============================================================");
        $display("                         SUMMARY");
        $display("==============================================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("TOTAL = %0d", pass_count + fail_count);
        $display("==============================================================");
        $display("");

        if (fail_count == 0)
            $display("*************** ALL TESTS PASSED ***************");
        else
            $display("*************** SOME TESTS FAILED **************");

        $display("");

        #10;
        $finish;
    end

endmodule