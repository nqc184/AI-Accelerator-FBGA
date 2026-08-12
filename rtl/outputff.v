`timescale 1ns/1ps

module output_fifo #(
parameter DATA_WIDTH = 24,
parameter ADDR_WIDTH = 10,
parameter MAX_DEPTH  = 1024
)(
input clk,
input rst,

input start_config,
input [15:0] img_width,
input [15:0] img_height,
input [2:0] kernel_size,
input [2:0] stride,
output reg done_config,

input valid_in,
input signed [DATA_WIDTH-1:0] data_in,

output reg full,

input rd_en,
output reg signed [DATA_WIDTH-1:0] data_out,
output reg valid_out,

output reg empty
);

reg signed [DATA_WIDTH-1:0] mem [0:MAX_DEPTH-1];

reg [ADDR_WIDTH-1:0] wr_ptr;
reg [ADDR_WIDTH-1:0] rd_ptr;

reg [ADDR_WIDTH:0] count_output;
reg [ADDR_WIDTH:0] ofm_size;

reg config_done;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        wr_ptr <= 0;
        rd_ptr <= 0;

        count_output <= 0;
        ofm_size <= 0;

        config_done <= 0;

        full <= 0;
        empty <= 1;

        done_config <= 0;

        data_out <= 0;
        valid_out <= 0;
    end

    else
    begin
        done_config <= 0;
        valid_out <= 0;

        if(start_config)
        begin
            ofm_size <= ((((img_width - {{13{1'b0}},kernel_size}) / {{13{1'b0}},stride}) + 1) *
             (((img_height - {{13{1'b0}},kernel_size}) / {{13{1'b0}},stride}) + 1));

            wr_ptr <= 0;
            rd_ptr <= 0;

            count_output <= 0;

            config_done <= 1;

            full <= 0;
            empty <= 1;

            done_config <= 1;
        end

        else
        begin

           if (valid_in && config_done && !full) begin
    mem[wr_ptr] <= data_in;
    wr_ptr <= wr_ptr + 1'b1;
    
    // Nếu vừa ghi xong làm cho số lượng đạt ofm_size thì mới báo full
    if (count_output + 1'b1 == ofm_size) begin
        full <= 1'b1;
    end
    
    count_output <= count_output + 1'b1;
    empty <= 1'b0;
end


            if(rd_en && !empty)
            begin
                data_out <= mem[rd_ptr];

                valid_out <= 1;

                rd_ptr <= rd_ptr + 1'b1;

                count_output <= count_output - 1'b1;


                if(count_output - 1 == 0)
                begin
                    empty <= 1;
                    full <= 0;
                end

            end

        end

    end

end

endmodule