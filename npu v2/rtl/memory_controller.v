`timescale 1ns/1ps

module memory_controller #(
    parameter DATA_WIDTH = 24,
    parameter AXI_BURST  = 128
)(
    input wire clk,
    input wire rst,
    input wire start_load,

    input wire [AXI_BURST-1:0] ifm_tdata,
    input wire ifm_tvalid,
    input wire ifm_tlast,
    output reg ifm_tready,

    input wire [AXI_BURST-1:0] wgt_tdata,
    input wire wgt_tvalid,
    input wire wgt_tlast,
    output reg wgt_tready,

    input wire [AXI_BURST-1:0] bias_tdata,
    input wire bias_tvalid,
    input wire bias_tlast,
    output reg bias_tready,

    output reg ifm_wr_en,
    output reg [AXI_BURST-1:0] ifm_wr_data,

    output reg wgt_wr_en,
    output reg [AXI_BURST-1:0] wgt_wr_data,

    output reg bias_wr_en,
    output reg [AXI_BURST-1:0] bias_wr_data,

    output reg ifm_done,
    output reg wgt_done,
    output reg bias_done,

    input wire signed [DATA_WIDTH-1:0] npu_out_data,
    input wire npu_out_valid,
    input wire npu_out_last,
    input wire compute_done,

    output reg npu_out_ready,

    output reg out_wr_en,
    output reg signed [DATA_WIDTH-1:0] out_wr_data,

    output wire done_load_in,
    output reg done_load_out
);

    reg ifm_finished;
    reg wgt_finished;
    reg bias_finished;

    assign done_load_in = ifm_finished &&
                          wgt_finished &&
                          bias_finished;

    always @(*) begin
        ifm_tready  = start_load && !ifm_finished;
        wgt_tready  = start_load && !wgt_finished;
        bias_tready = start_load && !bias_finished;

        npu_out_ready = 1'b1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ifm_wr_en    <= 1'b0;
            ifm_wr_data  <= {AXI_BURST{1'b0}};
            wgt_wr_en    <= 1'b0;
            wgt_wr_data  <= {AXI_BURST{1'b0}};
            bias_wr_en   <= 1'b0;
            bias_wr_data <= {AXI_BURST{1'b0}};

            ifm_done     <= 1'b0;
            wgt_done     <= 1'b0;
            bias_done    <= 1'b0;

            ifm_finished  <= 1'b0;
            wgt_finished  <= 1'b0;
            bias_finished <= 1'b0;

            out_wr_en    <= 1'b0;
            out_wr_data  <= {DATA_WIDTH{1'b0}};
            done_load_out <= 1'b0;
        end
        else begin
            ifm_wr_en    <= 1'b0;
            wgt_wr_en    <= 1'b0;
            bias_wr_en   <= 1'b0;

            ifm_done     <= 1'b0;
            wgt_done     <= 1'b0;
            bias_done    <= 1'b0;

            out_wr_en    <= 1'b0;
            done_load_out <= 1'b0;

            if (ifm_tvalid && ifm_tready) begin
                ifm_wr_en   <= 1'b1;
                ifm_wr_data <= ifm_tdata;

                if (ifm_tlast) begin
                    ifm_done     <= 1'b1;
                    ifm_finished <= 1'b1;
                end
            end

            if (wgt_tvalid && wgt_tready) begin
                wgt_wr_en   <= 1'b1;
                wgt_wr_data <= wgt_tdata;

                if (wgt_tlast) begin
                    wgt_done     <= 1'b1;
                    wgt_finished <= 1'b1;
                end
            end

            if (bias_tvalid && bias_tready) begin
                bias_wr_en   <= 1'b1;
                bias_wr_data <= bias_tdata;

                if (bias_tlast) begin
                    bias_done     <= 1'b1;
                    bias_finished <= 1'b1;
                end
            end

            if (npu_out_valid && npu_out_ready) begin
                out_wr_en   <= 1'b1;
                out_wr_data <= npu_out_data;

                if (npu_out_last) begin
                    done_load_out <= 1'b1;
                end
            end
        end
    end

endmodule