`timescale 1ns/1ps

module axi_lite_source_tb #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_DEPTH  = 5,
    parameter FILE_NAME  = "CONFIG.mem"
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg [ADDR_WIDTH-1:0] s_axi_awaddr,
    output reg                  s_axi_awvalid,
    input  wire                 s_axi_awready,

    output reg [DATA_WIDTH-1:0] s_axi_wdata,
    output reg [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    output reg                  s_axi_wvalid,
    input  wire                 s_axi_wready,

    input  wire [1:0] s_axi_bresp,
    input  wire       s_axi_bvalid,
    output reg        s_axi_bready
);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    initial begin
        $readmemh(FILE_NAME,mem);
    end

    reg [2:0] index;

    localparam IDLE       = 3'd0;
    localparam SEND       = 3'd1;
    localparam RESP       = 3'd2;
    localparam DONE       = 3'd3;

    reg [2:0] state;


    always @(posedge clk) begin

        if(rst) begin

            state <= IDLE;

            index <= 0;

            s_axi_awaddr  <= 0;
            s_axi_awvalid <= 0;

            s_axi_wdata   <= 0;
            s_axi_wstrb   <= 4'hF;
            s_axi_wvalid  <= 0;

            s_axi_bready  <= 0;

        end

        else begin

            case(state)

                IDLE: begin

                    s_axi_awvalid <= 0;
                    s_axi_wvalid  <= 0;
                    s_axi_bready  <= 0;

                    if(start) begin

                        index <= 0;

                        s_axi_awaddr  <= 32'h00000004;
                        s_axi_wdata   <= mem[0];

                        s_axi_awvalid <= 1;
                        s_axi_wvalid  <= 1;

                        state <= SEND;

                    end

                end


                SEND: begin

                    if(s_axi_awready && s_axi_wready) begin

                        s_axi_awvalid <= 0;
                        s_axi_wvalid  <= 0;

                        s_axi_bready <= 1;

                        state <= RESP;

                    end

                end


                RESP: begin

                    if(s_axi_bvalid && s_axi_bready) begin

                        s_axi_bready <= 0;

                        if(index == MEM_DEPTH-1) begin

                            state <= DONE;
                        
                        end

                        else begin

                            index <= index + 1'b1;

                            s_axi_awaddr <= 32'h00000004 + ((index + 1'b1) * 4);
                            s_axi_wdata  <= mem[index + 1'b1];

                            s_axi_awvalid <= 1;
                            s_axi_wvalid  <= 1;

                            state <= SEND;

                        end

                    end

                end


                DONE: begin

                     if(!start)
                        state <= IDLE;

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule