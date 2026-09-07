module bram #(
    parameter DW         = 24,     
    parameter DEPTH      = 16384,  
    parameter ADDR_WIDTH = 14      
)(
    input  wire clk,
 
    input  wire                  wr_en,
    input  wire [ADDR_WIDTH-1:0] wr_addr,
    input  wire signed [DW-1:0]  wr_data,
 
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] rd_addr,
    output reg  signed [DW-1:0]  rd_data
);
 
    reg signed [DW-1:0] mem [0:DEPTH-1];
 
    always @(posedge clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
    end
 
    always @(posedge clk) begin
        if (rd_en)
            rd_data <= mem[rd_addr];
    end
 
endmodule