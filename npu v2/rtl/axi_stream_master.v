module axi_stream_master #(
    parameter DW = 24,
    parameter IMG_SIZE = 16384
)(
    input clk,
    input rst,

    output reg [127:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast
);

    reg [DW-1:0] ifm_mem [0:IMG_SIZE-1];

    reg [14:0] rd_addr;

    reg [4:0] valid_bits;

    initial begin
        $readmemh("IFM.mem", ifm_mem);
    end

    always @(posedge clk) begin
        if (rst) begin
            rd_addr      <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast  <= 0;
            m_axis_tdata  <= 0;
        end
        else begin

            if (!m_axis_tvalid || m_axis_tready) begin

                if (rd_addr + 5 <= IMG_SIZE) begin

                    m_axis_tdata <= {
                        3'b000,
                        5'b11111,

                        ifm_mem[rd_addr + 4],
                        ifm_mem[rd_addr + 3],
                        ifm_mem[rd_addr + 2],
                        ifm_mem[rd_addr + 1],
                        ifm_mem[rd_addr]
                    };

                    m_axis_tvalid <= 1;

                    rd_addr <= rd_addr + 5;

                    if (rd_addr + 5 >= IMG_SIZE)
                        m_axis_tlast <= 1;
                    else
                        m_axis_tlast <= 0;

                end
                else begin

                    m_axis_tdata <= {
                        3'b000,
                        5'b01111,

                        24'd0,

                        ifm_mem[rd_addr + 3],
                        ifm_mem[rd_addr + 2],
                        ifm_mem[rd_addr + 1],
                        ifm_mem[rd_addr]
                    };

                    m_axis_tvalid <= 1;
                    m_axis_tlast  <= 1;

                    rd_addr <= IMG_SIZE;

                end
            end

            if (m_axis_tvalid &&
                m_axis_tready &&
                m_axis_tlast) begin

                m_axis_tvalid <= 0;

            end

        end
    end
endmodule