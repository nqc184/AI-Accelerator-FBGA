    `timescale 1ns/1ps

    module output_mux #(
        parameter DATA_WIDTH = 48,
        parameter START_CYCLE = 25
    )(
        input  wire [5:0] cycle,

        input  wire signed [DATA_WIDTH-1:0] in0,
        input  wire signed [DATA_WIDTH-1:0] in1,
        input  wire signed [DATA_WIDTH-1:0] in2,
        input  wire signed [DATA_WIDTH-1:0] in3,
        input  wire signed [DATA_WIDTH-1:0] in4,

        output reg  signed [DATA_WIDTH-1:0] data_out,
        output reg                          valid_out
    );

    always @(*) begin
        data_out  = 'sd0;
        valid_out = 1'b0;

        case (cycle)

            START_CYCLE: begin
                data_out  = in0;
                valid_out = 1'b1;
            end

            START_CYCLE + 1: begin
                data_out  = in1;
                valid_out = 1'b1;
            end

            START_CYCLE + 2: begin
                data_out  = in2;
                valid_out = 1'b1;
            end

            START_CYCLE + 3: begin
                data_out  = in3;
                valid_out = 1'b1;
            end

            START_CYCLE + 4: begin
                data_out  = in4;
                valid_out = 1'b1;
            end

            default: begin
                data_out  = 'sd0;
                valid_out = 1'b0;
            end

        endcase
    end

    endmodule