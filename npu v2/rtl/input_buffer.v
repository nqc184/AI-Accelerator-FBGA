`timescale 1ns / 1ps
module buffer #(
    parameter DW         = 24,
    parameter IMG_SIZE   = 16384,
    parameter DEPTH       = (IMG_SIZE + 4) / 5,  
    parameter ADDR_WIDTH  = 12,                   
    parameter CNT_WIDTH   = 14                   
)(
    input  wire clk,
    input  wire rst,
 
    input  wire         write_enable,   
    input  wire [127:0] write_data,    
    input  wire         write_last,   
    output reg           done,       
 
    input  wire read_enable,                  
    output reg  signed [DW-1:0] read_data,       
    output reg  read_valid,
    output reg  read_last
);
    reg signed [DW-1:0] bank0 [0:DEPTH-1];
    reg signed [DW-1:0] bank1 [0:DEPTH-1];
    reg signed [DW-1:0] bank2 [0:DEPTH-1];
    reg signed [DW-1:0] bank3 [0:DEPTH-1];
    reg signed [DW-1:0] bank4 [0:DEPTH-1];
 
    wire [4:0] keep = write_data[124:120];
 
    wire signed [DW-1:0] in0 = write_data[ 23:  0];
    wire signed [DW-1:0] in1 = write_data[ 47: 24];
    wire signed [DW-1:0] in2 = write_data[ 71: 48];
    wire signed [DW-1:0] in3 = write_data[ 95: 72];
    wire signed [DW-1:0] in4 = write_data[119: 96];
 
    reg [ADDR_WIDTH-1:0] wr_addr;
 
    always @(posedge clk) begin
        if (rst) begin
            wr_addr  <= 0;
            done <= 1'b0;
        end
        else begin
            if (write_enable) begin
 
                if (keep[0]) bank0[wr_addr] <= in0;
                if (keep[1]) bank1[wr_addr] <= in1;
                if (keep[2]) bank2[wr_addr] <= in2;
                if (keep[3]) bank3[wr_addr] <= in3;
                if (keep[4]) bank4[wr_addr] <= in4;
 
                wr_addr <= wr_addr + 1'b1;
 
                if (write_last)
                    done <= 1'b1;
            end
        end
    end

    reg [2:0]             lane;         
    reg [ADDR_WIDTH-1:0]  rd_word_addr; 
    reg [CNT_WIDTH-1:0]   cnt;         
 
    reg [ADDR_WIDTH-1:0]  rd_addr_reg;
    reg [2:0]             lane_s1, lane_s2;
    reg                    en_s1;
    reg                    last_s1;
 
    wire is_last_lane   = (lane == 3'd4);
    wire is_last_sample = (cnt  == (IMG_SIZE - 1));
 
    always @(posedge clk) begin
        if (rst) begin
            lane         <= 0;
            rd_word_addr <= 0;
            cnt          <= 0;
            rd_addr_reg  <= 0;
            lane_s1      <= 0; lane_s2 <= 0;
            en_s1        <= 0;
            last_s1      <= 0;
            read_valid   <= 0;
            read_last    <= 0;
        end
        else begin
            if (read_enable) begin
                rd_addr_reg <= rd_word_addr;
                lane_s1     <= lane;
                last_s1     <= is_last_sample;
 
                if (is_last_lane) begin
                    lane         <= 0;
                    rd_word_addr <= rd_word_addr + 1'b1;
                end
                else begin
                    lane <= lane + 1'b1;
                end
 
                cnt <= cnt + 1'b1;
            end
            en_s1 <= read_enable;
            lane_s2    <= lane_s1;
            read_valid <= en_s1;
            read_last  <= last_s1;
        end
    end
 
    reg [DW-1:0] rd0, rd1, rd2, rd3, rd4;
    always @(posedge clk) begin
        rd0 <= bank0[rd_addr_reg];
        rd1 <= bank1[rd_addr_reg];
        rd2 <= bank2[rd_addr_reg];
        rd3 <= bank3[rd_addr_reg];
        rd4 <= bank4[rd_addr_reg];
    end
 
    always @(*) begin
        case (lane_s2)
            3'd0:    read_data = rd0;
            3'd1:    read_data = rd1;
            3'd2:    read_data = rd2;
            3'd3:    read_data = rd3;
            default: read_data = rd4;
        endcase
    end
 
endmodule