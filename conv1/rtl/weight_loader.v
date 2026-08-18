`timescale 1ns/1ps

module weight_loader #(
    parameter DW    = 24,
    parameter MAX_K = 5
)(
    input                           clk,
    input                           rst,
    input                           clear,

    input                           start_config,
    input      [2:0]                kernel_size,
    output reg                      done_config,

    input                           valid_in,
    input      signed [DW-1:0]      weight_in,

    output reg                      valid_weight_out,
    output reg signed [MAX_K*MAX_K*DW-1:0] weight_packed
);

    localparam MAX_WEIGHT = MAX_K*MAX_K;

    reg signed [DW-1:0] weight_buf [0:MAX_WEIGHT-1];

    reg [2:0] kernel_size_reg;
    reg [5:0] required_count;
    reg [5:0] count;
    reg       config_done;

    integer i;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            kernel_size_reg  <= 0;
            required_count   <= 0;
            count            <= 0;

            config_done      <= 0;
            done_config      <= 0;
            valid_weight_out <= 0;

            weight_packed <= 0;

            for(i=0;i<MAX_WEIGHT;i=i+1)
                weight_buf[i] <= 0;

        end
        else begin
            done_config      <= 0;
            valid_weight_out <= 0;

            if(clear) begin
                count           <= 0;
                config_done     <= 0;
                required_count  <= 0;
                kernel_size_reg <= 0;
                weight_packed   <= 0;

                for(i=0;i<MAX_WEIGHT;i=i+1)
                    weight_buf[i] <= 0;

            end
            else if(start_config) begin
                kernel_size_reg <= kernel_size;
                count <= 0;

                case(kernel_size)
                    3'd2: required_count <= 4;
                    3'd3: required_count <= 9;
                    3'd4: required_count <= 16;
                    3'd5: required_count <= 25;
                    default: required_count <= 0;
                endcase

                config_done <= 1;
                done_config <= 1;

            end
            else if(config_done &&
                    valid_in &&
                    (count < required_count)) begin

                weight_buf[count] <= weight_in;

                if(count == required_count-1) begin

                    for(i=0;i<MAX_WEIGHT;i=i+1) begin
                        if(i < required_count)
                            weight_packed[(MAX_WEIGHT-1-i)*DW +: DW]
                                <= (i==count) ? weight_in : weight_buf[i];
                        else
                            weight_packed[(MAX_WEIGHT-1-i)*DW +: DW]
                                <= 0;
                    end

                    valid_weight_out <= 1;
                    count <= 0;

                end
                else begin
                    count <= count + 1;
                end
            end
        end
    end

endmodule