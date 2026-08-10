`timescale 1ns / 1ps

module memory_controller #(
    parameter DATA_WIDTH      = 24,
    parameter IFM_ADDR_WIDTH  = 10,
    parameter WGT_ADDR_WIDTH  = 10,
    parameter BIAS_ADDR_WIDTH = 10,
    parameter OUT_ADDR_WIDTH  = 10
)(
    input wire clk,
    input wire rst,

    input wire start_load,

    input wire signed [DATA_WIDTH-1:0] ifm_tdata,
    input wire ifm_tvalid,
    input wire ifm_tlast,
    output reg ifm_tready,

    input wire signed [DATA_WIDTH-1:0] wgt_tdata,
    input wire wgt_tvalid,
    input wire wgt_tlast,
    output reg wgt_tready,

    input wire signed [DATA_WIDTH-1:0] bias_tdata,
    input wire bias_tvalid,
    input wire bias_tlast,
    output reg bias_tready,

    output reg ifm_wr_en,
    output reg [IFM_ADDR_WIDTH-1:0] ifm_wr_addr,
    output reg signed [DATA_WIDTH-1:0] ifm_wr_data,

    output reg wgt_wr_en,
    output reg [WGT_ADDR_WIDTH-1:0] wgt_wr_addr,
    output reg signed [DATA_WIDTH-1:0] wgt_wr_data,

    output reg bias_wr_en,
    output reg [BIAS_ADDR_WIDTH-1:0] bias_wr_addr,
    output reg signed [DATA_WIDTH-1:0] bias_wr_data,

    output reg ifm_done,
    output reg wgt_done,
    output reg bias_done,

    input wire signed [DATA_WIDTH-1:0] npu_out_data,
    input wire npu_out_valid,
    input wire npu_out_last,
    input wire compute_done,

    output reg npu_out_ready,

    output reg out_wr_en,
    output reg [OUT_ADDR_WIDTH-1:0] out_wr_addr,
    output reg signed [DATA_WIDTH-1:0] out_wr_data,

    output wire done_load_in,
    output reg done_load_out
);

    localparam IDLE = 1'b0;
    localparam LOAD = 1'b1;

    reg state;

    assign done_load_in = ifm_done & wgt_done & bias_done;

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;

            ifm_tready <= 0;
            wgt_tready <= 0;
            bias_tready <= 0;

            ifm_wr_en <= 0;
            wgt_wr_en <= 0;
            bias_wr_en <= 0;

            ifm_wr_addr <= 0;
            wgt_wr_addr <= 0;
            bias_wr_addr <= 0;

            ifm_wr_data <= 0;
            wgt_wr_data <= 0;
            bias_wr_data <= 0;

            ifm_done <= 0;
            wgt_done <= 0;
            bias_done <= 0;

        end

        else begin
            ifm_wr_en <= 0;
            wgt_wr_en <= 0;
            bias_wr_en <= 0;

            case(state)
            IDLE: begin

                if(start_load) begin

                    ifm_wr_addr <= 0;
                    wgt_wr_addr <= 0;
                    bias_wr_addr <= 0;

                    ifm_done <= 0;
                    wgt_done <= 0;
                    bias_done <= 0;

                    ifm_tready <= 1;
                    wgt_tready <= 1;
                    bias_tready <= 1;

                    state <= LOAD;
                end
            end

            LOAD: begin

                if(ifm_tvalid && ifm_tready) begin

                    ifm_wr_en <= 1;
                    ifm_wr_data <= ifm_tdata;

                    ifm_wr_addr <= ifm_wr_addr + 1;

                    if(ifm_tlast) begin
                        ifm_wr_en <= 0;
                        ifm_done <= 1;
                        ifm_tready <= 0;
                    end

                end


                if(wgt_tvalid && wgt_tready) begin

                    wgt_wr_en <= 1;
                    wgt_wr_data <= wgt_tdata;

                    wgt_wr_addr <= wgt_wr_addr + 1'b1;


                    if(wgt_tlast) begin
                        wgt_wr_en <= 0;
                        wgt_done <= 1;
                        wgt_tready <= 0;
                    end

                end


                if(bias_tvalid && bias_tready) begin

                    bias_wr_en <= 1;
                    bias_wr_data <= bias_tdata;
                    
                    bias_wr_addr <= bias_wr_addr + 1'b1;

                    if(bias_tlast) begin
                        bias_wr_en <= 0;
                        bias_done <= 1;
                        bias_tready <= 0;
                    end

                end


                if(done_load_in)
                    state <= IDLE;

            end


            default:
                state <= IDLE;

            endcase

        end

    end


    always @(posedge clk) begin

        if(rst) begin

            out_wr_en <= 0;
            out_wr_addr <= 0;
            out_wr_data <= 0;

            npu_out_ready <= 0;
            done_load_out <= 0;

        end

        else begin

            out_wr_en <= 0;


            if(compute_done) begin

                npu_out_ready <= 1;
                out_wr_addr <= 0;
                done_load_out <= 0;

            end


            if(npu_out_valid && npu_out_ready) begin

                out_wr_en <= 1;
                out_wr_data <= npu_out_data;

                out_wr_addr <= out_wr_addr + 1'b1;


                if(npu_out_last) begin

                    done_load_out <= 1;
                    npu_out_ready <= 0;

                end

            end

        end

    end

endmodule