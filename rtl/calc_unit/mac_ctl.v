`timescale 1ns/1ps
module MAC_Controller(
    input  wire clk,
    input  wire reset,
    input  wire start,

    output reg clear,
    output reg done
);

reg [1:0] state;
reg [5:0] cycle;

localparam IDLE  = 2'd0,
           CLEAR = 2'd1,
           RUN   = 2'd2,
           DONE  = 2'd3;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        state <= IDLE;
        cycle <= 6'd0;
    end
    else begin
        case(state)

        IDLE: begin
            cycle <= 6'd0;
            if(start)
                state <= CLEAR;
        end

        CLEAR: begin
            cycle <= 6'd0;
            state <= RUN;
        end

        RUN: begin
            if(cycle == 6'd33)
                state <= DONE;
            else
                cycle <= cycle + 6'd1;
        end

        DONE: begin
            state <= IDLE;
        end

        endcase
    end
end

always @(*) begin
    clear = (state == CLEAR);
    done  = (state == DONE);
end

endmodule