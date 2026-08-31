`timescale 1ns/1ps
`define DW 24
`define IMG_SIZE 16384
`define DEPTH (`IMG_SIZE + 4) / 5 
`define ADDR_WIDTH 12                   
`define CNT_WIDTH 14  

module input_fifo_tb();
    logic clk;
    logic rst;
 
    logic         write_enable;   
    logic [127:0] write_data;    
    logic         write_last;   
    logic           ifm_done;       
 
    logic read_enable;                  
    logic  signed [`DW-1:0] read_data;       
    logic  read_valid;
    logic  read_last;

    ifm_buffer #(
        .DW(`DW),         
        .IMG_SIZE(`IMG_SIZE),    
        .DEPTH(`DEPTH),         
        .ADDR_WIDTH(`ADDR_WIDTH),                      
        .CNT_WIDTH(`CNT_WIDTH)                      
    )dut(
        .clk(clk),
        .rst(rst),
    
        .write_enable(write_enable),   
        .write_data(write_data),    
        .write_last(write_last),   
        .ifm_done(ifm_done),       
    
        .read_enable(read_enable),                  
        .read_data(read_data),       
        .read_valid(read_valid),
        .read_last(read_last)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; 
        write_enable = 0; write_data = 128'd0; write_last = 0;
        read_enable = 0; 
        #13;
        rst = 0;
        #10;
        write_enable = 1; write_data = 128'h1F000005000004000003000002000001;
        #10;
        write_data = 128'h1F00000A000009000008000007000006;
        #10;
        write_enable = 0; write_data = 128'h1F00000A00000B00000C00000D00000E;
        #10;
        write_last = 1;
        #12;
        read_enable = 1;
        #100;
        read_enable = 0;
        #10;
        $finish;
    end
endmodule