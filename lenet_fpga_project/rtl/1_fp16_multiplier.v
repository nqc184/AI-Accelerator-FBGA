`timescale 1ns/1ps

module fp16_multiplier(
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [15:0] result
);

    reg sign_a, sign_b;
    reg [4:0] exp_a, exp_b;
    reg [9:0] frac_a, frac_b;
    reg [10:0] mant_a, mant_b;
    reg [21:0] mant_product;
    reg sign_result;
    reg [5:0] exp_temp;
    reg [4:0] exp_norm;
    reg [9:0] frac_norm;
    reg guard_bit;
    reg round_bit;
    reg sticky_bit;
    reg [10:0] mant_round;
    reg overflow;
    reg zero_input;

    always @(*) begin
        sign_a = a[15];
        sign_b = b[15];

        exp_a = a[14:10];
        exp_b = b[14:10];

        frac_a = a[9:0];
        frac_b = b[9:0];

        sign_result = sign_a ^ sign_b;

        zero_input = (a[14:0] == 15'd0) ||
                     (b[14:0] == 15'd0);

        if (exp_a != 0)
            mant_a = {1'b1, frac_a};
        else
            mant_a = {1'b0, frac_a};

        if (exp_b != 0)
            mant_b = {1'b1, frac_b};
        else
            mant_b = {1'b0, frac_b};

        mant_product = mant_a * mant_b;

        exp_temp = {1'b0, exp_a} +
                   {1'b0, exp_b} -
                   6'd15;

        exp_norm = 5'd0;
        frac_norm = 10'd0;
        mant_round = 11'd0;

        guard_bit = 1'b0;
        round_bit = 1'b0;
        sticky_bit = 1'b0;

        overflow = 1'b0;

        if (zero_input) begin
            result = {sign_result, 15'd0};
        end
        else begin

            if (mant_product[21]) begin
                exp_norm = exp_temp[4:0] + 5'd1;
                frac_norm = mant_product[20:11];

                guard_bit = mant_product[10];
                round_bit = mant_product[9];
                sticky_bit = |mant_product[8:0];
            end
            else begin
                exp_norm = exp_temp[4:0];
                frac_norm = mant_product[19:10];

                guard_bit = mant_product[9];
                round_bit = mant_product[8];
                sticky_bit = |mant_product[7:0];
            end

            if (guard_bit &&
                (round_bit || sticky_bit || frac_norm[0])) begin

                mant_round = {1'b0, frac_norm} + 11'd1;

            end
            else begin

                mant_round = {1'b0, frac_norm};

            end

            if (mant_round[10]) begin
                exp_norm = exp_norm + 5'd1;
                frac_norm = 10'd0;
            end
            else begin
                frac_norm = mant_round[9:0];
            end

            if (exp_norm >= 5'd31) begin

                result = {
                    sign_result,
                    5'b11111,
                    10'b0000000000
                };

            end
            else if (exp_temp[5]) begin

                result = {
                    sign_result,
                    5'd0,
                    10'd0
                };

            end
            else begin

                result = {
                    sign_result,
                    exp_norm,
                    frac_norm
                };

            end
        end
    end

endmodule