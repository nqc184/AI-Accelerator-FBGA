module npu_controller (
    input clk, rst, start_npu,
    output [2:0] current_state_monitor,

    input [15:0] img_width, img_height,
    input [2:0] kernel_size, stride,
    input [1:0] activation,

    output [15:0] img_width_config, img_height_config,
    output [2:0] kernel_size_config, stride_config,
    output [1:0] activation_config,

    output start_config_pixel_buffer_loader, start_config_weight_buffer_loader,
    output start_config_activation, start_config_ofm,

    input done_config_pixel_buffer_loader, done_config_weight_buffer_loader,
    input done_config_activation, done_config_ofm
);
    localparam IDLE = 3'd0;
    localparam CONFIG = 3'd1;
    localparam COMPUTE = 3'd2;
    localparam DONE = 3'd3;

    reg [2:0] next_state, current_state;
    assign current_state_monitor = current_state;

    reg done_config_pixel_buffer_loader_flag, done_config_weight_buffer_loader_flag;
    reg done_config_activation_flag, done_config_ofm_flag;
    //Combinational logic (next state)
    always @(*) begin
        next_state = current_state;
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
                if (done_config_pixel_buffer_loader_flag && done_config_weight_buffer_loader_flag &&
                    done_config_activation_flag && done_config_ofm_flag) begin
                    next_state = COMPUTE;
                end
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
            done_config_pixel_buffer_loader_flag <= 1'b0;
            done_config_weight_buffer_loader_flag <= 1'b0;
            done_config_activation_flag <= 1'b0;
            done_config_ofm_flag <= 1'b0;
        end
        else begin
            current_state <= next_state;
        end
        if (current_state == CONFIG) begin
            if (done_config_pixel_buffer_loader) done_config_pixel_buffer_loader_flag <= 1'b1;
            if (done_config_weight_buffer_loader) done_config_weight_buffer_loader_flag <= 1'b1;
            if (done_config_activation) done_config_activation_flag <= 1'b1;
            if (done_config_ofm) done_config_ofm_flag <= 1'b1;
        end
        else begin
            done_config_pixel_buffer_loader_flag <= 1'b0;
            done_config_weight_buffer_loader_flag <= 1'b0;
            done_config_activation_flag <= 1'b0;
            done_config_ofm_flag <= 1'b0;
        end
    end
    //Output logic
    assign img_width_config = (current_state == CONFIG) ? img_width : 16'd0;
    assign img_height_config = (current_state == CONFIG) ? img_height : 16'd0;
    assign kernel_size_config = (current_state == CONFIG) ? kernel_size : 3'd0;
    assign stride_config = (current_state == CONFIG) ? stride : 3'd0;
    assign activation_config = (current_state == CONFIG) ? activation : 2'd0;
    
    assign start_config_pixel_buffer_loader = (current_state == CONFIG) ? 1'b1 : 1'b0;
    assign start_config_weight_buffer_loader = (current_state == CONFIG) ? 1'b1 : 1'b0;
    assign start_config_activation = (current_state == CONFIG) ? 1'b1 : 1'b0;
    assign start_config_ofm = (current_state == CONFIG) ? 1'b1 : 1'b0;
endmodule