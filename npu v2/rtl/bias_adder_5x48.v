module bias_adder_5x48 (
    input wire clk, rst, clr,

    input wire bias_wr_en,
    input wire [2:0] bias_wr_sel,
    input wire [47:0] bias_wr_data,

    input wire [47:0] data_in0, data_in1, data_in2, data_in3, data_in4,
    input wire data_valid0, data_valid1, data_valid2, data_valid3, data_valid4,

    output reg [47:0] result0, result1, result2, result3, result4,
    output reg result_valid0, result_valid1, result_valid2, result_valid3, result_valid4
);

    reg [47:0] bias_reg [0:4];

    always @(posedge clk) begin
        if (rst || clr) begin
            bias_reg[0] <= 48'b0;
            bias_reg[1] <= 48'b0;
            bias_reg[2] <= 48'b0;
            bias_reg[3] <= 48'b0;
            bias_reg[4] <= 48'b0;

            result0 <= 48'b0;
            result1 <= 48'b0;
            result2 <= 48'b0;
            result3 <= 48'b0;
            result4 <= 48'b0;

            result_valid0 <= 1'b0;
            result_valid1 <= 1'b0;
            result_valid2 <= 1'b0;
            result_valid3 <= 1'b0;
            result_valid4 <= 1'b0;
        end
        else begin
            if (bias_wr_en) begin
                case (bias_wr_sel)
                    3'd0: bias_reg[0] <= bias_wr_data;
                    3'd1: bias_reg[1] <= bias_wr_data;
                    3'd2: bias_reg[2] <= bias_wr_data;
                    3'd3: bias_reg[3] <= bias_wr_data;
                    3'd4: bias_reg[4] <= bias_wr_data;

                    default: begin
                    end
                endcase
            end

            result_valid0 <= data_valid0;
            result_valid1 <= data_valid1;
            result_valid2 <= data_valid2;
            result_valid3 <= data_valid3;
            result_valid4 <= data_valid4;

            if (data_valid0) result0 <= data_in0 + bias_reg[0];
            if (data_valid1) result1 <= data_in1 + bias_reg[1];
            if (data_valid2) result2 <= data_in2 + bias_reg[2];
            if (data_valid3) result3 <= data_in3 + bias_reg[3];
            if (data_valid4) result4 <= data_in4 + bias_reg[4];
        end
    end

endmodule