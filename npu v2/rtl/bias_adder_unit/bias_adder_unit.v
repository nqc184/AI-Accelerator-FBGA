module bias_adder_unit (
    input clk, rst,
    input col1_valid, col2_valid, col3_valid, col4_valid, col5_valid,
    input signed [47:0] col1_out, col2_out, col3_out, col4_out, col5_out,
    input signed [47:0] bias_in,
    input [2:0] sel,
    output signed [47:0] bias_reg0_monitor, bias_reg1_monitor, bias_reg2_monitor, bias_reg3_monitor, bias_reg4_monitor,
    output signed [47:0] bias_adder_result0, bias_adder_result1, bias_adder_result2, bias_adder_result3, bias_adder_result4,
    output valid_bias_adder_result0, valid_bias_adder_result1, valid_bias_adder_result2, valid_bias_adder_result3, valid_bias_adder_result4
);
    reg [47:0] bias_reg0, bias_reg1, bias_reg2, bias_reg3, bias_reg4;
    assign bias_reg0_monitor = bias_reg0;
    assign bias_reg1_monitor = bias_reg1;
    assign bias_reg2_monitor = bias_reg2;
    assign bias_reg3_monitor = bias_reg3;
    assign bias_reg4_monitor = bias_reg4;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            bias_reg0 <= 0;
            bias_reg1 <= 0;
            bias_reg2 <= 0;
            bias_reg3 <= 0;
            bias_reg4 <= 0;
        end
        else begin
            if(sel == 3'd0) bias_reg0 <= bias_in;
            else if(sel == 3'd1) bias_reg1 <= bias_in;
            else if(sel == 3'd2) bias_reg2 <= bias_in;
            else if(sel == 3'd3) bias_reg3 <= bias_in;
            else if(sel == 3'd4) bias_reg4 <= bias_in;
        end
    end

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst0(
        .clk(clk), .rst(rst), .en(1'b1),
        .valid_in(col1_valid),
        .data_in(col1_out),
        .bias(bias_reg0),

        .data_out(bias_adder_result0),
        .valid_out(valid_bias_adder_result0)
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst1(
        .clk(clk), .rst(rst), .en(1'b1),
        .valid_in(col2_valid),
        .data_in(col2_out),
        .bias(bias_reg1),

        .data_out(bias_adder_result1),
        .valid_out(valid_bias_adder_result1)
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst2(
        .clk(clk), .rst(rst), .en(1'b1),
        .valid_in(col3_valid),
        .data_in(col3_out),
        .bias(bias_reg2),

        .data_out(bias_adder_result2),
        .valid_out(valid_bias_adder_result2)
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst3(
        .clk(clk), .rst(rst), .en(1'b1),
        .valid_in(col4_valid),
        .data_in(col4_out),
        .bias(bias_reg3),

        .data_out(bias_adder_result3),
        .valid_out(valid_bias_adder_result3)
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst4(
        .clk(clk), .rst(rst), .en(1'b1),
        .valid_in(col5_valid),
        .data_in(col5_out),
        .bias(bias_reg4),

        .data_out(bias_adder_result4),
        .valid_out(valid_bias_adder_result4 )
    );
endmodule