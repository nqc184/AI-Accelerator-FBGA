module reg_file_5x600 (
    input  wire         clk,
    input  wire         rst,
    input  wire         clr,

    input  wire         wr_en,
    input  wire [2:0]   wr_sel,
    input  wire [599:0] wr_data,

    output wire [599:0] reg0,
    output wire [599:0] reg1,
    output wire [599:0] reg2,
    output wire [599:0] reg3,
    output wire [599:0] reg4
);

    reg [599:0] reg0_data;
    reg [599:0] reg1_data;
    reg [599:0] reg2_data;
    reg [599:0] reg3_data;
    reg [599:0] reg4_data;

    always @(posedge clk) begin

        if (rst || clr) begin

            reg0_data <= 600'b0;
            reg1_data <= 600'b0;
            reg2_data <= 600'b0;
            reg3_data <= 600'b0;
            reg4_data <= 600'b0;

        end
        else if (wr_en) begin

            case (wr_sel)

                3'd0: begin
                    reg0_data <= wr_data;
                end

                3'd1: begin
                    reg1_data <= wr_data;
                end

                3'd2: begin
                    reg2_data <= wr_data;
                end

                3'd3: begin
                    reg3_data <= wr_data;
                end

                3'd4: begin
                    reg4_data <= wr_data;
                end

                default: begin
                end

            endcase

        end

    end

    assign reg0 = reg0_data;
    assign reg1 = reg1_data;
    assign reg2 = reg2_data;
    assign reg3 = reg3_data;
    assign reg4 = reg4_data;

endmodule