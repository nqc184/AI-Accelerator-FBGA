module reg_file_5x600 (
    input clk, rst, clr,

    input wr_en,
    input [2:0] wr_sel,
    input [599:0] wr_data,

    output wire [599:0] reg0, reg1, reg2, reg3, reg4
);

    reg [599:0] reg_mem [0:4];

    always @(posedge clk) begin
        if (rst || clr) begin
            reg_mem[0] <= 600'b0;
            reg_mem[1] <= 600'b0;
            reg_mem[2] <= 600'b0;
            reg_mem[3] <= 600'b0;
            reg_mem[4] <= 600'b0;
        end
        else if (wr_en) begin
            case (wr_sel)
                3'd0: reg_mem[0] <= wr_data;
                3'd1: reg_mem[1] <= wr_data;
                3'd2: reg_mem[2] <= wr_data;
                3'd3: reg_mem[3] <= wr_data;
                3'd4: reg_mem[4] <= wr_data;
                default: begin
                end
            endcase
        end
    end

    assign reg0 = reg_mem[0];
    assign reg1 = reg_mem[1];
    assign reg2 = reg_mem[2];
    assign reg3 = reg_mem[3];
    assign reg4 = reg_mem[4];

endmodule