module pe #(parameter N = 24, ACC = N*2)(
    input clk, rst, clr,
    input en,
    input signed [N-1:0] pixel, weight,
    output en_out, clr_out,
    output signed [N-1:0] pixel_out, weight_out,
    output signed [ACC-1:0] acc
);
    wire signed [ACC-1:0] product;
    assign product = pixel * weight;
    reg signed [N-1:0] pixel_out_reg, weight_out_reg;
    reg en_out_reg;
    reg clr_out_reg;
    reg signed [ACC-1:0] acc_reg;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            acc_reg        <= {ACC{1'b0}};
            pixel_out_reg  <= {N{1'b0}};
            weight_out_reg <= {N{1'b0}};
            en_out_reg <= 1'b0;
            clr_out_reg <= 1'b0;
        end
        else begin
            en_out_reg <= en;
            clr_out_reg <= clr;
            pixel_out_reg <= pixel;
            weight_out_reg <= weight;
            if (clr && en) begin
                acc_reg <= product;
            end
            else if (clr) begin
                acc_reg <= {ACC{1'b0}};
            end
            else if (en) begin
                acc_reg <= acc_reg + product;
            end
        end
    end

    assign acc = acc_reg;
    assign pixel_out = pixel_out_reg;
    assign weight_out = weight_out_reg;
    assign en_out = en_out_reg;
    assign clr_out = clr_out_reg;
endmodule