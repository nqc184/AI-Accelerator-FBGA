module npu_controller (
    input clk, rst, 
    output reg [2:0] state_out,
    input start_config, start_compute,

    output start_config_pixel_buffer_loader,
    output start_config_weight_buffer_loader,
    output start_config_activation,
    output start_config_ofm,

    input done_config_pixel_buffer_loader,
    input done_config_weight_buffer_loader,
    input done_config_activation,
    input done_config_ofm
);
    localparam IDLE = 3'd0;
    localparam CONFIG = 3'd1;
    localparam COMPUTE = 3'd2;
    localparam DONE = 3'd3;
    
    reg [2:0] state;
    reg [2:0] next_state;

    //Config
    reg config_sent;

    reg start_config_pixel_buffer_loader_reg;
    reg start_config_weight_buffer_loader_reg;
    reg start_config_activation_reg;
    reg start_config_ofm_reg;

    assign start_config_pixel_buffer_loader = start_config_pixel_buffer_loader_reg;
    assign start_config_weight_buffer_loader = start_config_weight_buffer_loader_reg;
    assign start_config_activation = start_config_activation_reg;
    assign start_config_ofm = start_config_ofm_reg;

    reg pixel_config_done_hold;
    reg weight_config_done_hold;
    reg activation_config_done_hold;
    reg ofm_config_done_hold;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        state_out = state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start_config) begin
                    next_state = CONFIG;
                end
                if (start_compute) begin
                    next_state = COMPUTE;
                end
            end

            CONFIG: begin
                if (pixel_config_done_hold && weight_config_done_hold && activation_config_done_hold && ofm_config_done_hold) begin
                    next_state = IDLE;
                end
            end

            COMPUTE: begin
            end

            DONE: begin
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    always @(posedge clk or posedge rst) begin 
        if (rst) begin
            config_sent <= 1'b0;
            pixel_config_done_hold <= 0;
            weight_config_done_hold <= 0;
            activation_config_done_hold <= 0;
            ofm_config_done_hold <= 0;
        end
        else begin
            if (state == IDLE) begin
                config_sent <= 1'b0;
            end
            else if (state == CONFIG && !config_sent) begin
                config_sent <= 1'b1;
            end
            if (state != CONFIG) begin
                pixel_config_done_hold      <= 0;
                weight_config_done_hold     <= 0;
                activation_config_done_hold <= 0;
                ofm_config_done_hold        <= 0;
            end
            else begin
                if (done_config_pixel_buffer_loader)
                    pixel_config_done_hold <= 1;
                if (done_config_weight_buffer_loader)
                    weight_config_done_hold <= 1;
                if (done_config_activation)
                    activation_config_done_hold <= 1;
                if (done_config_ofm)
                    ofm_config_done_hold <= 1;
            end
        end
    end

    always @(*) begin
        start_config_pixel_buffer_loader_reg = 0;
        start_config_weight_buffer_loader_reg = 0;
        start_config_activation_reg = 0;
        start_config_ofm_reg = 0;
        case (state)
           CONFIG: begin
                if (!config_sent) begin
                    start_config_pixel_buffer_loader_reg = 1'b1;
                    start_config_weight_buffer_loader_reg = 1'b1;
                    start_config_activation_reg = 1'b1;
                    start_config_ofm_reg = 1'b1;
                end
            end
            
        endcase
    end
endmodule