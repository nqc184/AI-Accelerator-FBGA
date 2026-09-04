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
 
    typedef enum logic [1:0] {
        IDLE = 2'd0,
        SEND = 2'd1,
        DONE = 2'd2
    } state_t;
 
    state_t state;
 
    logic signed [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    logic [ADDR_WIDTH-1:0] index;
 
    initial begin
        $readmemh(FILE_NAME, mem);
    end

    task automatic pack_beat(input logic [ADDR_WIDTH-1:0] base_idx);
        logic [4:0] mask;
        int valid_count;
        int invalid_count;
 
        if (base_idx >= MEM_DEPTH)
            valid_count = 0;
        else if (MEM_DEPTH - base_idx >= 5)
            valid_count = 5;
        else
            valid_count = MEM_DEPTH - base_idx;
 
        invalid_count = 5 - valid_count; 
 
        mask = 5'b00000;
        for (int k = 0; k < 5; k++) begin
            if (k >= invalid_count)
                mask[4-k] = 1'b1; 
        end
 
        m_axis_tdata[127:125] <= 3'b000;
        m_axis_tdata[124:120] <= mask;
 
        for (int k = 0; k < 5; k++) begin
            if (k >= invalid_count) begin
                automatic int j = k - invalid_count;
                m_axis_tdata[119-DATA_WIDTH*k -: DATA_WIDTH] <= mem[base_idx + (valid_count-1-j)];
            end
            else
                m_axis_tdata[119-DATA_WIDTH*k -: DATA_WIDTH] <= '0;
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