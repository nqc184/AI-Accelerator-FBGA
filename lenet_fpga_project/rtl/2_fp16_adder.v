`timescale 1ns/1ps

module fp16_adder(
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [15:0] result
);

    reg sign_a;
    reg sign_b;
    reg sign_result;

    reg [4:0] exp_a;
    reg [4:0] exp_b;
    reg [4:0] exp_result;

    reg [9:0] frac_a;
    reg [9:0] frac_b;
    reg [9:0] frac_result;

    reg [10:0] mant_a;
    reg [10:0] mant_b;

    reg [10:0] mant_large;
    reg [10:0] mant_small;

    reg [14:0] mant_large_ext;
    reg [14:0] mant_small_ext;
    reg [14:0] mant_result;

    reg [4:0] exp_large;
    reg [4:0] exp_small;
    reg [4:0] exp_diff;

    reg guard_bit;
    reg round_bit;
    reg sticky_bit;

    reg [10:0] mant_round;

    integer i;

    always @(*) begin
        sign_a = a[15];
        sign_b = b[15];

        exp_a = a[14:10];
        exp_b = b[14:10];

        frac_a = a[9:0];
        frac_b = b[9:0];

        sign_result = 1'b0;

        exp_result = 5'd0;
        frac_result = 10'd0;

        mant_a = {1'b1, frac_a};
        mant_b = {1'b1, frac_b};

        mant_large = 11'd0;
        mant_small = 11'd0;

        mant_large_ext = 15'd0;
        mant_small_ext = 15'd0;
        mant_result = 15'd0;

        exp_large = 5'd0;
        exp_small = 5'd0;
        exp_diff = 5'd0;

        guard_bit = 1'b0;
        round_bit = 1'b0;
        sticky_bit = 1'b0;

        mant_round = 11'd0;

        if (a[14:0] == 15'd0) begin
            result = b;
        end
        else if (b[14:0] == 15'd0) begin
            result = a;
        end
        else begin

            if (exp_a > exp_b) begin
                exp_large = exp_a;
                exp_small = exp_b;
                mant_large = mant_a;
                mant_small = mant_b;
                sign_result = sign_a;
            end
            else if (exp_b > exp_a) begin
                exp_large = exp_b;
                exp_small = exp_a;
                mant_large = mant_b;
                mant_small = mant_a;
                sign_result = sign_b;
            end
            else begin
                exp_large = exp_a;
                exp_small = exp_b;

                if (mant_a >= mant_b) begin
                    mant_large = mant_a;
                    mant_small = mant_b;
                    sign_result = sign_a;
                end
                else begin
                    mant_large = mant_b;
                    mant_small = mant_a;
                    sign_result = sign_b;
                end
            end

            exp_diff = exp_large - exp_small;

            mant_large_ext = {mant_large,4'b0000};
            mant_small_ext = {mant_small,4'b0000};

            if (exp_diff >= 5'd15) begin
                mant_small_ext = 15'd0;
            end
            else begin
                for (i = 0; i < 15; i = i + 1) begin
                    if (i < exp_diff)
                        mant_small_ext = mant_small_ext >> 1;
                end
            end

            if (sign_a == sign_b) begin
                mant_result = mant_large_ext + mant_small_ext;
            end
            else begin
                mant_result = mant_large_ext - mant_small_ext;
            end

            if (mant_result == 15'd0) begin
                result = 16'd0;
            end
            else begin

                exp_result = exp_large;

                if (mant_result[14]) begin
                    mant_result = mant_result >> 1;
                    exp_result = exp_result + 1'b1;
                end
                else begin
                    for (i = 0; i < 14; i = i + 1) begin
                        if ((mant_result[13] == 1'b0) &&
                            (exp_result > 0)) begin
                            mant_result = mant_result << 1;
                            exp_result = exp_result - 1'b1;
                        end
                    end
                end

                frac_result = mant_result[13:4];

                guard_bit = mant_result[3];
                round_bit = mant_result[2];
                sticky_bit = |mant_result[1:0];

                if (guard_bit &&
                    (round_bit || sticky_bit || frac_result[0])) begin

                    mant_round = {1'b0,frac_result} + 11'd1;

                end
                else begin

                    mant_round = {1'b0,frac_result};

                end

                if (mant_round[10]) begin
                    exp_result = exp_result + 1'b1;
                    frac_result = 10'd0;
                end
                else begin
                    frac_result = mant_round[9:0];
                end

                result = {
                    sign_result,
                    exp_result,
                    frac_result
                };

            end
        end
    end

endmodule