module bias_adder_unit (
    input clk, rst,
    input col1_valid, col2_valid, col3_valid, col4_valid, col5_valid,
    input signed [47:0] col1_out, col2_out, col3_out, col4_out, col5_out,
    input [47:0] reg0, reg1, reg2, reg3, reg4,

);
    demux_1to5 #(
        .DW(48)
    )demux_inst(
        .din(),
        .sel(),
        .dout0(), .dout1(), .dout2(), .dout3(), .dout4()
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst0(
        .clk(clk), .rst(rst), .en(),
        .valid_in(col1_valid),
        .data_in(col1_out),
        .bias(reg0),

        .data_out(),
        .valid_out()
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst1(
        .clk(clk), .rst(rst), .en(),
        .valid_in(col2_valid),
        .data_in(col2_out),
        .bias(reg1),

        .data_out(),
        .valid_out()
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst2(
        .clk(clk), .rst(rst), .en(),
        .valid_in(col3_valid),
        .data_in(col3_out),
        .bias(reg2),

        .data_out(),
        .valid_out()
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst3(
        .clk(clk), .rst(rst), .en(),
        .valid_in(col4_valid),
        .data_in(col4_out),
        .bias(reg3),

        .data_out(),
        .valid_out()
    );

    bias_adder #(
        .DATA_WIDTH(48)
    )bias_adder_inst4(
        .clk(clk), .rst(rst), .en(),
        .valid_in(col5_valid),
        .data_in(col5_out),
        .bias(reg4),

        .data_out(),
        .valid_out()
    );
endmodule