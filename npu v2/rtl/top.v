module top #(
    parameter DATA_WIDTH = 24,
    parameter IMG_SIZE = 16384,
    parameter BUFFER_DEPTH = (IMG_SIZE + 4) / 5,  
    parameter BUFFER_ADDR_WIDTH  = 12,                   
    parameter BUFFER_CNT_WIDTH = 14   
)(
    input clk, rst,
    input start_system,
);
    //System Controll
    system_controller system_controller_inst (
        .clk(clk),
        .rst(rst),
        .start(),
        .ifm_done(),
        .wgt_done(),
        .bias_done(),
        .start_load(),
        .start_npu()
    );

    //Memory Controller
    memory_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .IFM_ADDR_WIDTH(14),
        .WGT_ADDR_WIDTH(10),
        .BIAS_ADDR_WIDTH(10),
        .OUT_ADDR_WIDTH(10)
    ) memory_controller_inst (
        .clk(clk),
        .rst(rst),
        .start_load(),

        .ifm_tdata(),
        .ifm_tvalid(),
        .ifm_tlast(),
        .ifm_tready(),

        .wgt_tdata(),
        .wgt_tvalid(),
        .wgt_tlast(),
        .wgt_tready(),

        .bias_tdata(),
        .bias_tvalid(),
        .bias_tlast(),
        .bias_tready(),

        .ifm_wr_en(),
        .ifm_wr_addr(),
        .ifm_wr_data(),

        .wgt_wr_en(),
        .wgt_wr_addr(),
        .wgt_wr_data(),

        .bias_wr_en(),
        .bias_wr_addr(),
        .bias_wr_data(),

        .ifm_done(),
        .wgt_done(),
        .bias_done(),

        .npu_out_data(),
        .npu_out_valid(),
        .npu_out_last(),
        .compute_done(),

        .npu_out_ready(),

        .out_wr_en(),
        .out_wr_addr(),
        .out_wr_data(),

        .done_load_in(),
        .done_load_out()
    );

    //Input Buffer
    buffer #(
        .DW(DATA_WIDTH),
        .IMG_SIZE(IMG_SIZE),
        .DEPTH(BUFFER_DEPTH),
        .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
        .CNT_WIDTH(BUFFER_CNT_WIDTH)
    ) input_buffer (
        .clk(clk),
        .rst(rst),
        .write_enable(),
        .write_data(),
        .write_last(),
        .done(),
        .read_enable(),
        .read_data(),
        .read_valid(),
        .read_last()
    );

    //Weight Buffer
    buffer #(
        .DW(DATA_WIDTH),
        .IMG_SIZE(IMG_SIZE),
        .DEPTH(BUFFER_DEPTH),
        .ADDR_WIDTH(BUFFER_ADDR_WIDTH),
        .CNT_WIDTH(BUFFER_CNT_WIDTH)
    ) weight_buffer (
        .clk(clk),
        .rst(rst),
        .write_enable(),
        .write_data(),
        .write_last(),
        .done(),
        .read_enable(),
        .read_data(),
        .read_valid(),
        .read_last()
    );
endmodule