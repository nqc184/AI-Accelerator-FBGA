`timescale 1ns/1ps

module memory_controller #(
    parameter DATA_WIDTH = 24,
    parameter IFM_ADDR_WIDTH = 14,
    parameter WGT_ADDR_WIDTH = 10,
    parameter BIAS_ADDR_WIDTH = 10,
    parameter OUT_ADDR_WIDTH = 10
)(
    input wire clk,
    input wire rst,
    input wire start_load,

    input wire [127:0] ifm_tdata,
    input wire ifm_tvalid,
    input wire ifm_tlast,
    output reg ifm_tready,

    input wire [127:0] wgt_tdata,
    input wire wgt_tvalid,
    input wire wgt_tlast,
    output reg wgt_tready,

    input wire [127:0] bias_tdata,
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

    localparam IDLE = 2'd0;
    localparam LOAD = 2'd1;
    localparam UNPACK = 2'd2;

    reg [1:0] state;

    reg [127:0] ifm_data_reg;
    reg [127:0] wgt_data_reg;
    reg [127:0] bias_data_reg;

    reg [2:0] ifm_count;
    reg [2:0] wgt_count;
    reg [2:0] bias_count;

    reg ifm_last_reg;
    reg wgt_last_reg;
    reg bias_last_reg;

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

            ifm_data_reg <= 0;
            wgt_data_reg <= 0;
            bias_data_reg <= 0;

            ifm_count <= 0;
            wgt_count <= 0;
            bias_count <= 0;

            ifm_last_reg <= 0;
            wgt_last_reg <= 0;
            bias_last_reg <= 0;
        end
        else begin
            ifm_wr_en <= 0;
            wgt_wr_en <= 0;
            bias_wr_en <= 0;

            case(state)

                IDLE: begin
                    ifm_tready <= 0;
                    wgt_tready <= 0;
                    bias_tready <= 0;

                    if(start_load) begin
                        ifm_wr_addr <= 0;
                        wgt_wr_addr <= 0;
                        bias_wr_addr <= 0;

                        ifm_done <= 0;
                        wgt_done <= 0;
                        bias_done <= 0;

                        ifm_count <= 0;
                        wgt_count <= 0;
                        bias_count <= 0;

                        ifm_tready <= 1;
                        wgt_tready <= 1;
                        bias_tready <= 1;

                        state <= LOAD;
                    end
                end

                LOAD: begin

                    if(ifm_tvalid && ifm_tready) begin
                        ifm_data_reg <= ifm_tdata;
                        ifm_last_reg <= ifm_tlast;
                        ifm_count <= 0;
                        ifm_tready <= 0;
                    end

                    if(wgt_tvalid && wgt_tready) begin
                        wgt_data_reg <= wgt_tdata;
                        wgt_last_reg <= wgt_tlast;
                        wgt_count <= 0;
                        wgt_tready <= 0;
                    end

                    if(bias_tvalid && bias_tready) begin
                        bias_data_reg <= bias_tdata;
                        bias_last_reg <= bias_tlast;
                        bias_count <= 0;
                        bias_tready <= 0;
                    end

                    if((!ifm_tready) || (!wgt_tready) || (!bias_tready))
                        state <= UNPACK;

                end

                UNPACK: begin

                    if(!ifm_done) begin
                        if(ifm_count < 5) begin

                            if(ifm_data_reg[124-ifm_count]) begin

                                ifm_wr_en <= 1;

                                case(ifm_count)
                                    3'd0: ifm_wr_data <= ifm_data_reg[23:0];
                                    3'd1: ifm_wr_data <= ifm_data_reg[47:24];
                                    3'd2: ifm_wr_data <= ifm_data_reg[71:48];
                                    3'd3: ifm_wr_data <= ifm_data_reg[95:72];
                                    3'd4: ifm_wr_data <= ifm_data_reg[119:96];
                                endcase

                                ifm_wr_addr <= ifm_wr_addr + 1'b1;

                            end

                            ifm_count <= ifm_count + 1'b1;

                        end
                        else begin
                            if(ifm_last_reg)
                                ifm_done <= 1;

                            ifm_tready <= !ifm_last_reg;
                            ifm_count <= 0;
                        end
                    end

                    if(!wgt_done) begin
                        if(wgt_count < 5) begin

                            if(wgt_data_reg[124-wgt_count]) begin

                                wgt_wr_en <= 1;

                                case(wgt_count)
                                    3'd0: wgt_wr_data <= wgt_data_reg[23:0];
                                    3'd1: wgt_wr_data <= wgt_data_reg[47:24];
                                    3'd2: wgt_wr_data <= wgt_data_reg[71:48];
                                    3'd3: wgt_wr_data <= wgt_data_reg[95:72];
                                    3'd4: wgt_wr_data <= wgt_data_reg[119:96];
                                endcase

                                wgt_wr_addr <= wgt_wr_addr + 1'b1;

                            end

                            wgt_count <= wgt_count + 1'b1;

                        end
                        else begin
                            if(wgt_last_reg)
                                wgt_done <= 1;

                            wgt_tready <= !wgt_last_reg;
                            wgt_count <= 0;
                        end
                    end

                    if(!bias_done) begin
                        if(bias_count < 5) begin

                            if(bias_data_reg[124-bias_count]) begin

                                bias_wr_en <= 1;

                                case(bias_count)
                                    3'd0: bias_wr_data <= bias_data_reg[23:0];
                                    3'd1: bias_wr_data <= bias_data_reg[47:24];
                                    3'd2: bias_wr_data <= bias_data_reg[71:48];
                                    3'd3: bias_wr_data <= bias_data_reg[95:72];
                                    3'd4: bias_wr_data <= bias_data_reg[119:96];
                                endcase

                                bias_wr_addr <= bias_wr_addr + 1'b1;

                            end

                            bias_count <= bias_count + 1'b1;

                        end
                        else begin
                            if(bias_last_reg)
                                bias_done <= 1;

                            bias_tready <= !bias_last_reg;
                            bias_count <= 0;
                        end
                    end

                    if(ifm_done && wgt_done && bias_done)
                        state <= IDLE;
                    else if(ifm_count >= 5 &&
                            wgt_count >= 5 &&
                            bias_count >= 5)
                        state <= LOAD;

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