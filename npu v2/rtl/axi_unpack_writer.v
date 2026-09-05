module axi_unpack_writer #(
    parameter DATA_WIDTH = 24,
    parameter ADDR_WIDTH = 14
)(
    input  wire         clk,
    input  wire         rst,
 
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tvalid,
    input  wire         s_axis_tlast,
    output reg          s_axis_tready,
 
    output reg                      bram_wr_en,
    output reg  [ADDR_WIDTH-1:0]    bram_wr_addr,
    output reg  signed [DATA_WIDTH-1:0] bram_wr_data,
 
    output reg  done  
);
 
    localparam IDLE  = 1'b0;
    localparam DRAIN = 1'b1;
 
    reg state;
    reg [127:0] tdata_latch;
    reg         tlast_latch;
    reg [2:0]   k;                  
    reg [ADDR_WIDTH-1:0] wr_addr_cnt;  
 
    wire [4:0] mask_latch = tdata_latch[124:120];
 
    function automatic signed [DATA_WIDTH-1:0] get_slot(input [127:0] d, input [2:0] kk);
        get_slot = d[119-DATA_WIDTH*kk -: DATA_WIDTH];
    endfunction
 
    always @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            s_axis_tready <= 1'b1;
            bram_wr_en    <= 1'b0;
            bram_wr_addr  <= {ADDR_WIDTH{1'b0}};
            bram_wr_data  <= {DATA_WIDTH{1'b0}};
            wr_addr_cnt   <= {ADDR_WIDTH{1'b0}};
            k             <= 3'd4;
            done          <= 1'b0;
        end
        else begin
            bram_wr_en <= 1'b0; 
            done       <= 1'b0;
 
            case (state)
                IDLE: begin
                    s_axis_tready <= 1'b1;
                    if (s_axis_tvalid && s_axis_tready) begin
                        tdata_latch   <= s_axis_tdata;
                        tlast_latch   <= s_axis_tlast;
                        k             <= 3'd4;
                        s_axis_tready <= 1'b0; 
                        state         <= DRAIN;
                    end
                end
 
                DRAIN: begin
                    if (mask_latch[4-k]) begin
                        bram_wr_en   <= 1'b1;
                        bram_wr_addr <= wr_addr_cnt;
                        bram_wr_data <= get_slot(tdata_latch, k);
                        wr_addr_cnt  <= wr_addr_cnt + 1'b1;
                    end
 
                    if (k == 3'd0) begin
                        if (tlast_latch)
                            done <= 1'b1;
                        s_axis_tready <= 1'b1; 
                        state         <= IDLE;
                    end
                    else begin
                        k <= k - 3'd1;
                    end
                end
 
                default: state <= IDLE;
            endcase
        end
    end
 
endmodule