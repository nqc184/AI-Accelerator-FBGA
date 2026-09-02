`timescale 1ns/1ps

module axi_stream_source_tb #(
    parameter DATA_WIDTH = 24,
    parameter MEM_DEPTH  = 16384,
    parameter FILE_NAME  = "IFM.mem",
    parameter ADDR_WIDTH = 14
)(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    output reg  [127:0] m_axis_tdata,
    output reg          m_axis_tvalid,
    output reg          m_axis_tlast,
    input  wire         m_axis_tready
);

    reg signed [DATA_WIDTH-1:0] mem[0:MEM_DEPTH-1];
    reg [ADDR_WIDTH-1:0] index;

    localparam IDLE = 2'd0;
    localparam SEND = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;
    integer k;

    initial begin
        $readmemh(FILE_NAME, mem);
    end

    task automatic pack_beat(input [ADDR_WIDTH-1:0] base_idx);
        reg [4:0] mask;
        begin
            mask = 5'b00000;
            m_axis_tdata = 128'b0;
            for (k = 0; k < 5; k = k + 1) begin
                if (base_idx + k < MEM_DEPTH) begin
                    mask[4-k] = 1'b1; 
                    m_axis_tdata[119-DATA_WIDTH*k -: DATA_WIDTH] = mem[base_idx + k];
                end
            end
            m_axis_tdata[127:125] = 3'b000;
            m_axis_tdata[124:120] = mask;
        end
    endtask

    always @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            index         <= 0;
            m_axis_tdata  <= 128'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    m_axis_tvalid <= 1'b0;
                    m_axis_tlast  <= 1'b0;

                    if (start) begin
                        index <= 0;
                        pack_beat(0);

                        m_axis_tvalid <= 1'b1;
                        m_axis_tlast  <= (MEM_DEPTH <= 5);

                        state <= SEND;
                    end
                end

                SEND: begin
                    if (m_axis_tvalid && m_axis_tready) begin
                        if (index + 5 >= MEM_DEPTH) begin
                            m_axis_tvalid <= 1'b0;
                            m_axis_tlast  <= 1'b0;
                            state         <= DONE;
                        end
                        else begin
                            index <= index + 5;
                            pack_beat(index + 5);
                            m_axis_tlast <= (index + 10 >= MEM_DEPTH);
                        end
                    end
                end

                DONE: begin
                    m_axis_tvalid <= 1'b0;
                    m_axis_tlast  <= 1'b0;
                    state         <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule