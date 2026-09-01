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