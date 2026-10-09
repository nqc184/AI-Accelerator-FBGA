module axi_stream_source_tb #(
    parameter int DATA_WIDTH = 24,
    parameter int MEM_DEPTH  = 16384,
    parameter string FILE_NAME = "IFM.mem",
    parameter int ADDR_WIDTH = 14
)(
    input  logic         clk,
    input  logic         rst,
    input  logic         start,
    output logic [127:0] m_axis_tdata,
    output logic         m_axis_tvalid,
    output logic         m_axis_tlast,
    input  logic         m_axis_tready
);

    // So phan tu gon duoc trong 1 beat 128-bit
    localparam int GROUP      = 128 / DATA_WIDTH;        // 24->5 ; 48->2
    localparam int DATA_BITS  = GROUP * DATA_WIDTH;       // 24->120 ; 48->96
    localparam int RESERVED   = 128 - GROUP - DATA_BITS;  // bit chua dung, luon >=0

    typedef enum logic [1:0] {
        IDLE = 2'd0,
        SEND = 2'd1,
        DONE = 2'd2
    } state_t;

    state_t state;

    logic signed [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    logic [ADDR_WIDTH-1:0] index;

    initial begin
        int fd, val, n;
        for (int i = 0; i < MEM_DEPTH; i++) mem[i] = '0;
        fd = $fopen(FILE_NAME, "r");
        n  = 0;
        while (n < MEM_DEPTH && $fscanf(fd, "%h", val) == 1) begin
            mem[n] = val;
            n++;
        end
        $fclose(fd);
    end

    task automatic pack_beat(input logic [ADDR_WIDTH-1:0] base_idx);
        logic [GROUP-1:0] mask;
        int valid_count;
        int invalid_count;

        if (base_idx >= MEM_DEPTH)
            valid_count = 0;
        else if (MEM_DEPTH - base_idx >= GROUP)
            valid_count = GROUP;
        else
            valid_count = MEM_DEPTH - base_idx;

        invalid_count = GROUP - valid_count;

        mask = '0;
        for (int k = 0; k < GROUP; k++) begin
            if (k >= invalid_count)
                mask[GROUP-1-k] = 1'b1;
        end

        if (RESERVED > 0)
            m_axis_tdata[127 -: RESERVED] <= '0;
        m_axis_tdata[127-RESERVED -: GROUP] <= mask;

        for (int k = 0; k < GROUP; k++) begin
            if (k >= invalid_count) begin
                automatic int j = k - invalid_count;
                m_axis_tdata[DATA_BITS-1-DATA_WIDTH*k -: DATA_WIDTH] <= mem[base_idx + (valid_count-1-j)];
            end
            else
                m_axis_tdata[DATA_BITS-1-DATA_WIDTH*k -: DATA_WIDTH] <= '0;
        end
    endtask

    always_ff @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            index         <= '0;
            m_axis_tdata  <= '0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end
        else begin
            unique case (state)
                IDLE: begin
                    m_axis_tvalid <= 1'b0;
                    m_axis_tlast  <= 1'b0;

                    if (start) begin
                        index <= '0;
                        pack_beat(0);

                        m_axis_tvalid <= 1'b1;
                        m_axis_tlast  <= (MEM_DEPTH <= GROUP);

                        state <= SEND;
                    end
                end

                SEND: begin
                    if (m_axis_tvalid && m_axis_tready) begin
                        if (index + GROUP >= MEM_DEPTH) begin
                            m_axis_tvalid <= 1'b0;
                            m_axis_tlast  <= 1'b0;
                            state         <= DONE;
                        end
                        else begin
                            index <= index + GROUP;
                            pack_beat(index + GROUP);
                            m_axis_tlast <= (index + 2*GROUP >= MEM_DEPTH);
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