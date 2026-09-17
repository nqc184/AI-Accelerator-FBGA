module npu_controller (
    input clk, rst, start_npu,
    output [2:0] current_state_monitor,

    input [15:0] img_width, img_height,
    input [2:0] kernel_size, stride,
    input [1:0] activation,
    input [15:0] number_kernel,

    output [15:0] img_width_config, img_height_config,
    output [2:0] kernel_size_config, stride_config,
    output [1:0] activation_config,
    output [15:0] number_kernel_monitor,

    output start_config_pixel_buffer_loader, start_config_weight_buffer_loader,
    output start_config_activation, start_config_ofm,

    input done_config_pixel_buffer_loader, done_config_weight_buffer_loader,
    input done_config_activation, done_config_ofm,

    output rd_en_pixel, 
    output [13:0] rd_addr_pixel, 
    output rd_en_wgt, 
    output [13:0] rd_addr_wgt, 
    output rd_en_bias, 
    output [13:0] rd_addr_bias, 
    output valid_pixel, valid_wgt, valid_bias,

    output start_calc,
    input done_calc,

    input valid_window_out, valid_wgt_out,
    input last_window_out,

    output [2:0] window_cnt_monitor, wgt_cnt_monitor, bias_cnt_monitor
);
    localparam IDLE = 3'd0;
    localparam CONFIG = 3'd1;
    localparam LOAD = 3'd2;
    localparam COMPUTE = 3'd3;
    localparam DONE = 3'd4;

    localparam WINDOW_COUNT = 5;
    localparam WEIGHT_COUNT = 5;
    localparam BIAS_COUNT = 5;

    reg [2:0] next_state, current_state;
    assign current_state_monitor = current_state;

    reg [2:0] window_cnt;
    reg [2:0] wgt_cnt;
    reg [2:0] bias_cnt;

    assign window_cnt_monitor = window_cnt;
    assign wgt_cnt_monitor = wgt_cnt;
    assign bias_cnt_monitor = bias_cnt;

    reg done_config_pixel_buffer_loader_flag, done_config_weight_buffer_loader_flag;
    reg done_config_activation_flag, done_config_ofm_flag;

    reg rd_en_pixel_reg, rd_en_wgt_reg, rd_en_bias_reg;
    reg valid_pixel_reg, valid_wgt_reg, valid_bias_reg;
    reg [13:0] rd_addr_pixel_reg, rd_addr_wgt_reg, rd_addr_bias_reg;

    reg [15:0] number_kernel_reg;
    reg start_calc_reg;
    reg last_window_out_reg;
    reg [2:0] wgt_batch_target;

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
                    next_state = LOAD;
                end
            end
            LOAD: begin
                if (window_cnt == WINDOW_COUNT && wgt_cnt == WEIGHT_COUNT && bias_cnt == BIAS_COUNT && last_window_out_reg) begin
                    next_state = COMPUTE;
                end
            end
            COMPUTE: begin
                 if (done_calc) begin
                    if (last_window_out_reg) begin
                        if (number_kernel_reg != 0) begin
                            next_state = LOAD; 
                        end
                        else begin
                            next_state = DONE; 
                        end
                    end
                    else begin
                        next_state = LOAD;
                    end
                end
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

            window_cnt <= 3'd0; wgt_cnt <= 3'd0; bias_cnt <= 3'd0;

            rd_en_pixel_reg <= 1'b0; rd_en_wgt_reg <= 1'b0; rd_en_bias_reg <= 1'b0;
            valid_pixel_reg <= 0; valid_wgt_reg <= 0; valid_bias_reg <= 0;
            rd_addr_pixel_reg <= 14'd0; rd_addr_wgt_reg <= 14'd0; rd_addr_bias_reg <=14'd0;

            number_kernel_reg <= 0;
            start_calc_reg <= 0;

            last_window_out_reg <= 0;
            wgt_batch_target <= 3'd0;
        end
        else begin
            current_state <= next_state;
            if (current_state == COMPUTE && next_state == LOAD) begin
                wgt_batch_target <= (number_kernel_reg > WEIGHT_COUNT) ? WEIGHT_COUNT[2:0] : number_kernel_reg[2:0];
                window_cnt <= 3'd0;
                if (last_window_out_reg) begin
                    wgt_cnt  <= 3'd0;
                    bias_cnt <= 3'd0;
                    last_window_out_reg <= 1'b0;
                    rd_addr_pixel_reg <= 14'd0; 
                end
            end
        end
        if (current_state == IDLE) begin
            if (start_npu) begin
                number_kernel_reg <= number_kernel;
            end
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
        if(current_state == LOAD) begin
            //Load Pixel
            if (window_cnt < WINDOW_COUNT) begin 
                rd_en_pixel_reg <= 1'b1;
                if(rd_en_pixel_reg) begin 
                    valid_pixel_reg <= rd_en_pixel_reg;
                    rd_addr_pixel_reg <= rd_addr_pixel_reg + 1;
                end
            end
            else if (window_cnt == WINDOW_COUNT) rd_en_pixel_reg <= 0;
            if (valid_window_out && window_cnt < WINDOW_COUNT) window_cnt <= window_cnt + 1;
            if (last_window_out) begin 
                last_window_out_reg <= 1;
            end
            //Load Weight
            if (number_kernel_reg > WEIGHT_COUNT) begin
                if (wgt_cnt < WEIGHT_COUNT) begin
                    rd_en_wgt_reg <= 1'b1;
                    if(rd_en_wgt_reg) begin
                        valid_wgt_reg <= rd_en_wgt_reg;
                        rd_addr_wgt_reg <= rd_addr_wgt_reg + 1;
                    end
                end
                else if (wgt_cnt == WEIGHT_COUNT) begin
                    rd_en_wgt_reg <= 0;
                    number_kernel_reg <= number_kernel_reg - wgt_cnt;
                end
                if (valid_wgt_out && wgt_cnt < number_kernel_reg) wgt_cnt <= wgt_cnt + 1;
            end
            else if (number_kernel_reg <= WEIGHT_COUNT) begin
                if (wgt_cnt < number_kernel_reg) begin
                    rd_en_wgt_reg <= 1'b1;
                    if(rd_en_wgt_reg) begin 
                        valid_wgt_reg <= rd_en_wgt_reg;
                        rd_addr_wgt_reg <= rd_addr_wgt_reg + 1;
                    end
                end
                else if (wgt_cnt == number_kernel_reg) begin
                    rd_en_wgt_reg <= 0; 
                    number_kernel_reg <= 0;
                end
                if (valid_wgt_out) wgt_cnt <= wgt_cnt + 1;
            end
            //Load Bias
            if (bias_cnt < BIAS_COUNT) begin
                rd_en_bias_reg <= 1'b1;
                bias_cnt <= bias_cnt + 1; 
                if(rd_en_bias_reg) begin 
                    valid_bias_reg <= rd_en_bias_reg;
                    rd_addr_bias_reg <= rd_addr_bias_reg + 1;
                end
            end
            else if (bias_cnt == BIAS_COUNT) rd_en_bias_reg <= 0;
        end
        if (current_state == COMPUTE) begin
            start_calc_reg <= 1;
            if (done_calc) begin
                start_calc_reg <= 0;
            end
        end
    end
    //Output logic
    assign img_width_config = img_width;
    assign img_height_config = img_height;
    assign kernel_size_config = kernel_size;
    assign stride_config = stride;
    assign activation_config = activation;
    
    assign start_config_pixel_buffer_loader = (current_state == CONFIG) ? 1'b1 : 1'b0;
    assign start_config_weight_buffer_loader = (current_state == CONFIG) ? 1'b1 : 1'b0;
    assign start_config_activation = (current_state == CONFIG) ? 1'b1 : 1'b0;
    assign start_config_ofm = (current_state == CONFIG) ? 1'b1 : 1'b0;

    assign rd_en_pixel = (current_state == LOAD) ? rd_en_pixel_reg : 0;
    assign rd_addr_pixel = (current_state == LOAD) ? rd_addr_pixel_reg : 14'd0;
    assign rd_en_wgt = (current_state == LOAD) ? rd_en_wgt_reg : 0; 
    assign rd_addr_wgt = (current_state == LOAD) ? rd_addr_wgt_reg : 14'd0;
    assign rd_en_bias = (current_state == LOAD) ? rd_en_bias_reg : 0; 
    assign rd_addr_bias = (current_state == LOAD) ? rd_addr_bias_reg : 14'd0;

    assign valid_pixel = valid_pixel_reg;
    assign valid_wgt = valid_wgt_reg;
    assign valid_bias = valid_bias_reg; 

    assign number_kernel_monitor = number_kernel_reg;
    assign start_calc = start_calc_reg;
endmodule