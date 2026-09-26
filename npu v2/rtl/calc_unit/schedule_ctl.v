module schedule_ctl (
    input  wire clk,
    input  wire reset,
    input  wire start,

    output reg  load,
    output reg [5:0] cycle,
    output reg  done
);

reg [1:0] state;

localparam IDLE = 2'd0,
           LOAD = 2'd1,
           FEED = 2'd2,
           DONE = 2'd3;

localparam MAX_CYCLE = 6'd33;

always @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
        cycle <= 6'd0;
        load  <= 1'b0;
        done  <= 1'b0;
    end
    else begin
        case(state)

        IDLE: begin
            load  <= 1'b0;
            done  <= 1'b0;
            cycle <= 6'd0;

            if(start)
                state <= LOAD;
        end

        LOAD: begin
            cycle <= 6'd0;
            load  <= 1'b1;
            state <= FEED;
        end

        FEED: begin
            load <= 1'b0;

            if(cycle == MAX_CYCLE) begin
                cycle <= 6'd0;
                state <= DONE;
            end
            else
                cycle <= cycle + 6'd1;
        end

        DONE: begin
            done  <= 1'b1;
            cycle <= 6'd0;
            state <= IDLE;
        end

        endcase
    end
end

endmodule