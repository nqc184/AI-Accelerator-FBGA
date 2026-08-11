`timescale 1ns/1ps

module axi_stream_source_tb #(
    parameter DATA_WIDTH = 24,
    parameter MEM_DEPTH  = 1024,
    parameter FILE_NAME  = "IFM.mem",
    parameter ADDR_WIDTH = 10
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg signed [DATA_WIDTH-1:0] m_axis_tdata,
    output reg m_axis_tvalid,
    output reg m_axis_tlast,
    input wire m_axis_tready
);


reg signed [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];


initial begin
    $readmemh(FILE_NAME, mem);
end


reg [ADDR_WIDTH-1:0] index;


localparam IDLE = 2'd0;
localparam SEND = 2'd1;
localparam DONE = 2'd2;

reg [1:0] state;


always @(posedge clk) begin

    if(rst) begin

        state <= IDLE;

        index <= 0;

        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
        m_axis_tlast <= 0;

    end

    else begin

        case(state)

        IDLE: begin

            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;

            if(start) begin

                index <= 0;

                m_axis_tdata <= mem[0];
                m_axis_tvalid <= 1;

                state <= SEND;

            end

        end


        SEND: begin

            if(m_axis_tvalid && m_axis_tready) begin


                if(index == MEM_DEPTH-1) begin

                    m_axis_tlast <= 1;

                    state <= DONE;

                end

                else begin

                    index <= index + 1'b1;

                    m_axis_tdata <= mem[index+1'b1];

                end

            end

        end


        DONE: begin

            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;

        end


        default:
            state <= IDLE;


        endcase

    end

end


endmodule