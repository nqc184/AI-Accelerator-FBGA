`timescale 1ns/1ps

module axi_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire rst,

    input wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output reg s_axi_awready,

    input wire [DATA_WIDTH-1:0] s_axi_wdata,
    input wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output reg s_axi_wready,

    output reg [1:0] s_axi_bresp,
    output reg s_axi_bvalid,
    input wire s_axi_bready,

    input wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output reg s_axi_arready,

    output reg [DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid,
    input wire s_axi_rready,

    output reg [15:0] img_width,
    output reg [15:0] img_height,
    output reg [2:0] kernel_size,
    output reg [2:0] stride,
    output reg [1:0] activation,

    output reg config_done
);

localparam ADDR_IMG_WIDTH   = 32'h00000004;
localparam ADDR_IMG_HEIGHT  = 32'h00000008;
localparam ADDR_KERNEL_SIZE = 32'h0000000C;
localparam ADDR_STRIDE      = 32'h00000010;
localparam ADDR_ACTIVATION = 32'h00000014;

reg width_loaded;
reg height_loaded;
reg kernel_loaded;
reg stride_loaded;
reg activation_loaded;


always @(posedge clk) begin

    if(rst) begin

        s_axi_awready <= 0;
        s_axi_wready  <= 0;
        s_axi_bvalid  <= 0;
        s_axi_bresp   <= 0;

        s_axi_arready <= 0;
        s_axi_rvalid  <= 0;
        s_axi_rresp   <= 0;
        s_axi_rdata   <= 0;

        img_width     <= 0;
        img_height    <= 0;
        kernel_size   <= 0;
        stride        <= 0;
        activation    <= 2'd0;

        width_loaded  <= 0;
        height_loaded <= 0;
        kernel_loaded <= 0;
        stride_loaded <= 0;
        activation_loaded <= 0;

        config_done   <= 0;

    end

    else begin

        s_axi_awready <= 0;
        s_axi_wready  <= 0;
        s_axi_arready <= 0;

        config_done <= 0;


        if(s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid) begin

            s_axi_awready <= 1;
            s_axi_wready  <= 1;

            case(s_axi_awaddr)

                ADDR_IMG_WIDTH: begin
                    img_width <= s_axi_wdata[15:0];
                    width_loaded <= 1;
                end

                ADDR_IMG_HEIGHT: begin
                    img_height <= s_axi_wdata[15:0];
                    height_loaded <= 1;
                end

                ADDR_KERNEL_SIZE: begin
                    kernel_size <= s_axi_wdata[2:0];
                    kernel_loaded <= 1;
                end

                ADDR_STRIDE: begin
                    stride <= s_axi_wdata[2:0];
                    stride_loaded <= 1;
                end

                ADDR_ACTIVATION: begin
                    activation  <= s_axi_wdata[1:0];
                    activation_loaded <= 1;
                end
            endcase

            s_axi_bvalid <= 1;
            s_axi_bresp <= 2'b00;

        end


        if(s_axi_bvalid && s_axi_bready) begin

            s_axi_bvalid <= 0;

        end


        if(width_loaded &&
            height_loaded &&
            kernel_loaded &&
            stride_loaded &&
            activation_loaded) begin

            config_done <= 1;

        end


        if(s_axi_arvalid && !s_axi_rvalid) begin

            s_axi_arready <= 1;
            s_axi_rvalid <= 1;
            s_axi_rresp <= 2'b00;

            case(s_axi_araddr)

                ADDR_IMG_WIDTH:
                    s_axi_rdata <= {16'd0,img_width};

                ADDR_IMG_HEIGHT:
                    s_axi_rdata <= {16'd0,img_height};

                ADDR_KERNEL_SIZE:
                    s_axi_rdata <= {29'd0,kernel_size};

                ADDR_STRIDE:
                    s_axi_rdata <= {29'd0,stride};
                ADDR_ACTIVATION:
                    s_axi_rdata <= {30'd0, activation}; 
                default:
                    s_axi_rdata <= 32'd0;

            endcase

        end


        if(s_axi_rvalid && s_axi_rready) begin

            s_axi_rvalid <= 0;

        end

    end

end

endmodule