module sigmoid_LUT (
    input wire clk,
    input wire signed [47:0] address_a,
    input wire signed [47:0] address_b,

    output reg [47:0] data_out_a,
    output reg [47:0] data_out_b
);

reg [47:0] rom [0:4096];

initial begin
    $readmemh("pos_sigmoid.mem", rom);
end

wire [11:0] addr_a;
wire [11:0] addr_b;

assign addr_a = (address_a[47]) ?
                (address_a[35:24] + 12'd1) :
                 address_a[35:24];

assign addr_b = (address_b[47]) ?
                (address_b[35:24] + 12'd1) :
                 address_b[35:24];

localparam signed [47:0] POS_8 = 48'sh0008_00000000;
localparam signed [47:0] NEG_8 = 48'shFFF8_00000000;

localparam [47:0] SIGMOID_ONE  = 48'sh0001_00000000; // Q16.32 = 1.0
localparam [47:0] SIGMOID_ZERO = 48'd0;

always @(posedge clk) begin

    // Port A
    if (address_a > POS_8)
        data_out_a <= SIGMOID_ONE;
    else if (address_a < NEG_8)
        data_out_a <= SIGMOID_ZERO;
    else
        data_out_a <= rom[addr_a];

    // Port B
    if (address_b > POS_8)
        data_out_b <= SIGMOID_ONE;
    else if (address_b < NEG_8)
        data_out_b <= SIGMOID_ZERO;
    else
        data_out_b <= rom[addr_b];

end

endmodule