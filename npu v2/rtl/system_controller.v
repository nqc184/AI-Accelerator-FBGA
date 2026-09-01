`timescale 1ns/1ps

module system_controller(
    input wire clk,
    input wire rst,

    input wire start,

    input wire ifm_done,
    input wire wgt_done,
    input wire bias_done,

    output reg start_load,
    output reg start_npu
);

    localparam IDLE    = 2'd0;
    localparam LOAD    = 2'd1;
    localparam COMPUTE = 2'd2;

    reg [1:0] state;

    reg ifm_done_reg;
    reg wgt_done_reg;
    reg bias_done_reg;

    wire ifm_done_flag;
    wire wgt_done_flag;
    wire bias_done_flag;

    assign ifm_done_flag = ifm_done_reg  | ifm_done;
    assign wgt_done_flag = wgt_done_reg  | wgt_done;
    assign bias_done_flag = bias_done_reg | bias_done; 

    always @(posedge clk) begin

        if(rst) begin
            state <= IDLE;
            start_load <= 0;
            start_npu <= 0;
            ifm_done_reg    <= 0;
            wgt_done_reg    <= 0;
            bias_done_reg   <= 0;
        end

        else begin

            start_load <= 0;
            start_npu <= 0;


            if(ifm_done)
                ifm_done_reg <= 1;

            if(wgt_done)
                wgt_done_reg <= 1;

            if(bias_done)
                bias_done_reg <= 1;

            case(state)

                IDLE: begin
                    if(start) begin
                        start_load <= 1;
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    if(ifm_done_flag && wgt_done_flag && bias_done_flag) begin
                        start_npu <= 1;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    ifm_done_reg    <= 0;
                    wgt_done_reg    <= 0;
                    bias_done_reg   <= 0;
                    state <= IDLE;
                end

                default: begin

                    state <= IDLE;
                end
            endcase
        end
    end
endmodule