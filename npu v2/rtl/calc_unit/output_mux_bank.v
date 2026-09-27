module output_mux_bank #(
    parameter START_CYCLE_COL_1 = 25,
    parameter START_CYCLE_COL_2 = 26,
    parameter START_CYCLE_COL_3 = 27,
    parameter START_CYCLE_COL_4 = 28,
    parameter START_CYCLE_COL_5 = 29
)(
    input wire [5:0] cycle,
    input wire signed [47:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
    input wire signed [47:0] c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,
    input wire signed [47:0] c21,c22,c23,c24,c25,

    output wire signed [47:0] col1_out, col2_out, col3_out, col4_out, col5_out,
    output wire col1_valid, col2_valid, col3_valid, col4_valid, col5_valid
);
    output_mux #(.START_CYCLE(START_CYCLE_COL_1)) mux_col1 (
        .cycle(cycle), 
        .in0(c1),.in1(c6),.in2(c11),.in3(c16),.in4(c21), 
        .data_out(col1_out), .valid_out(col1_valid)
    );
    output_mux #(.START_CYCLE(START_CYCLE_COL_2)) mux_col2 (
        .cycle(cycle), 
        .in0(c2),.in1(c7),.in2(c12),.in3(c17),.in4(c22), 
        .data_out(col2_out), .valid_out(col2_valid)
    );
    output_mux #(.START_CYCLE(START_CYCLE_COL_3)) mux_col3 (
        .cycle(cycle), 
        .in0(c3),.in1(c8),.in2(c13),.in3(c18),.in4(c23), 
        .data_out(col3_out), .valid_out(col3_valid)
    );
    output_mux #(.START_CYCLE(START_CYCLE_COL_4)) mux_col4 (
        .cycle(cycle), .in0(c4),.in1(c9),.in2(c14),.in3(c19),.in4(c24), 
        .data_out(col4_out), .valid_out(col4_valid)
    );
    output_mux #(.START_CYCLE(START_CYCLE_COL_5)) mux_col5 (
        .cycle(cycle), .in0(c5),.in1(c10),.in2(c15),.in3(c20),.in4(c25), 
        .data_out(col5_out), .valid_out(col5_valid)
    );
endmodule