module reg6_en (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [5:0] d,
    output reg [5:0] q
);
    always @(posedge clk) begin
        if (rst) begin
            q <= 6'b0;
        end
        else if (en) begin
            q <= d;
        end
    end

endmodule