`timescale 1ns/1ps

module axi_stream_source_tb #(
    parameter DATA_WIDTH = 24,
    parameter MEM_DEPTH = 16384,
    parameter FILE_NAME = "IFM.mem",
    parameter ADDR_WIDTH = 14
)(
    input wire clk,
    input wire rst,
    input wire start,
    output reg [127:0] m_axis_tdata,
    output reg m_axis_tvalid,
    output reg m_axis_tlast,
    input wire m_axis_tready
);

    reg signed [DATA_WIDTH-1:0] mem[0:MEM_DEPTH-1];
    reg [ADDR_WIDTH-1:0] index;

    localparam IDLE = 2'd0;
    localparam SEND = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;

    initial begin
        $readmemh(FILE_NAME,mem);
    end

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            index <= 0;
            m_axis_tdata <= 128'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    m_axis_tvalid <= 1'b0;
                    m_axis_tlast <= 1'b0;

                    if(start) begin
                        index <= 0;
                        m_axis_tdata <= 128'b0;
                        m_axis_tdata[127:125] <= 3'b000;

                        if(MEM_DEPTH >= 5)
                            m_axis_tdata[124:120] <= 5'b11111;
                        else begin
                            m_axis_tdata[124:120] <= 5'b00000;

                            if(MEM_DEPTH > 0)
                                m_axis_tdata[124] <= 1'b1;
                            if(MEM_DEPTH > 1)
                                m_axis_tdata[123] <= 1'b1;
                            if(MEM_DEPTH > 2)
                                m_axis_tdata[122] <= 1'b1;
                            if(MEM_DEPTH > 3)
                                m_axis_tdata[121] <= 1'b1;
                            if(MEM_DEPTH > 4)
                                m_axis_tdata[120] <= 1'b1;
                        end

                        if(MEM_DEPTH > 0)
                            m_axis_tdata[23:0] <= mem[0];
                        if(MEM_DEPTH > 1)
                            m_axis_tdata[47:24] <= mem[1];
                        if(MEM_DEPTH > 2)
                            m_axis_tdata[71:48] <= mem[2];
                        if(MEM_DEPTH > 3)
                            m_axis_tdata[95:72] <= mem[3];
                        if(MEM_DEPTH > 4)
                            m_axis_tdata[119:96] <= mem[4];

                        m_axis_tvalid <= 1'b1;

                        if(MEM_DEPTH <= 5)
                            m_axis_tlast <= 1'b1;

                        state <= SEND;
                    end
                end

                SEND: begin
                    if(m_axis_tvalid && m_axis_tready) begin
                        if(index + 5 >= MEM_DEPTH) begin
                            m_axis_tvalid <= 1'b0;
                            m_axis_tlast <= 1'b0;
                            state <= DONE;
                        end
                        else begin
                            index <= index + 5;
                            m_axis_tdata <= 128'b0;
                            m_axis_tdata[127:125] <= 3'b000;

                            if(index + 10 <= MEM_DEPTH)
                                m_axis_tdata[124:120] <= 5'b11111;
                            else begin
                                m_axis_tdata[124:120] <= 5'b00000;

                                if(index + 5 < MEM_DEPTH)
                                    m_axis_tdata[124] <= 1'b1;
                                if(index + 6 < MEM_DEPTH)
                                    m_axis_tdata[123] <= 1'b1;
                                if(index + 7 < MEM_DEPTH)
                                    m_axis_tdata[122] <= 1'b1;
                                if(index + 8 < MEM_DEPTH)
                                    m_axis_tdata[121] <= 1'b1;
                                if(index + 9 < MEM_DEPTH)
                                    m_axis_tdata[120] <= 1'b1;
                            end

                            if(index + 5 < MEM_DEPTH)
                                m_axis_tdata[23:0] <= mem[index + 5];
                            if(index + 6 < MEM_DEPTH)
                                m_axis_tdata[47:24] <= mem[index + 6];
                            if(index + 7 < MEM_DEPTH)
                                m_axis_tdata[71:48] <= mem[index + 7];
                            if(index + 8 < MEM_DEPTH)
                                m_axis_tdata[95:72] <= mem[index + 8];
                            if(index + 9 < MEM_DEPTH)
                                m_axis_tdata[119:96] <= mem[index + 9];

                            if(index + 10 >= MEM_DEPTH)
                                m_axis_tlast <= 1'b1;
                            else
                                m_axis_tlast <= 1'b0;
                        end
                    end
                end

                DONE: begin
                    m_axis_tvalid <= 1'b0;
                    m_axis_tlast <= 1'b0;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule