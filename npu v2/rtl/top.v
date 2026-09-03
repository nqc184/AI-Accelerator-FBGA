module top #(
    parameter DATA_WIDTH = 24,
    parameter AXI_BURST = 128,
    parameter IMG_SIZE = 16384,
    parameter BUFFER_DEPTH = (IMG_SIZE + 4) / 5,  
    parameter BUFFER_ADDR_WIDTH  = 12,                   
    parameter BUFFER_CNT_WIDTH = 14   
)(
   
);
    
endmodule