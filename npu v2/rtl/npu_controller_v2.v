module npu_controller (
    input clk, rst, start_npu,
    output [2:0] current_state_monitor
);
    localparam IDLE = 3'd0;
    localparam CONFIG = 3'd1;
    localparam COMPUTE = 3'd2;
    localparam DONE = 3'd3;

    reg [2:0] next_state, current_state;
    assign current_state_monitor = current_state;
    //Combinational logic (next state)
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start_npu) begin
                    next_state = CONFIG;
                end
                else begin
                    next_state = IDLE;
                end
            end
            CONFIG: begin
                
            end
            COMPUTE: begin
            
            end
            DONE: begin

            end
        endcase
    end
    //Sequential logic (current state)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    //Output logic
endmodule