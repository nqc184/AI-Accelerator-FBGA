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

    output clear_window_reg, clear_wgt_reg, clear_bias_reg,

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

    reg [2:0] next_state, current_state;
    assign current_state_monitor = current_state;

    reg [2:0] window_cnt;
    reg [2:0] wgt_cnt;
    reg [2:0] bias_cnt;

    assign window_cnt_monitor = window_cnt;
    assign wgt_cnt_monitor = wgt_cnt;
    assign bias_cnt_monitor = bias_cnt;

    reg pixel_cfg_sent, wgt_cfg_sent, act_cfg_sent, ofm_cfg_sent;
    reg start_calc_sent;
    reg done_config_pixel_buffer_loader_flag, done_config_weight_buffer_loader_flag;
    reg done_config_activation_flag, done_config_ofm_flag;

    reg valid_pixel_reg, valid_wgt_reg, valid_bias_reg;
    reg [13:0] rd_addr_pixel_reg, rd_addr_wgt_reg, rd_addr_bias_reg;

    reg [15:0] img_width_reg, img_height_reg;
    reg [2:0] kernel_size_reg, stride_reg;
    reg [1:0] activation_reg;
    reg [15:0] number_kernel_reg;

    reg start_calc_reg;
    reg clear_window_reg_r, clear_wgt_reg_r, clear_bias_reg_r;
    reg last_window_out_reg;
    reg [2:0] wgt_batch_target;   

    reg [15:0] pix_col, pix_row;      
    reg [2:0] pix_win_req;           
    reg pix_req_done;          

    reg [7:0] wgt_req_cnt;           
    reg [7:0] wgt_words_target;      

    wire [15:0] k1 = kernel_size_reg - 16'd1;
    wire pix_is_win = (pix_row >= k1) && (pix_col >= k1) && (pix_row % stride_reg == k1 % stride_reg) && (pix_col % stride_reg == k1 % stride_reg);
    wire pix_is_last = (pix_col == img_width_reg-1) && (pix_row == img_height_reg-1);
    wire pix_stop_now = (pix_is_win && pix_win_req == WINDOW_COUNT-1) || pix_is_last;

    assign rd_en_pixel = (current_state == LOAD) && !pix_req_done;
    assign rd_en_wgt = (current_state == LOAD) && (wgt_req_cnt < wgt_words_target);
    assign rd_en_bias = (current_state == LOAD) && (bias_cnt < wgt_batch_target);

    //Combinational logic (next state)
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                next_state = start_npu ? CONFIG : IDLE;
            end
            CONFIG: begin
                if (done_config_pixel_buffer_loader_flag && done_config_weight_buffer_loader_flag &&
                    done_config_activation_flag && done_config_ofm_flag) begin
                    next_state = LOAD;
                end
            end
            LOAD: begin
                if (pix_req_done && window_cnt == pix_win_req &&
                    wgt_cnt  == wgt_batch_target &&
                    bias_cnt == wgt_batch_target && !valid_bias_reg) begin
                    next_state = COMPUTE;
                end
            end
            COMPUTE: begin
                if (done_calc) begin
                    if (last_window_out_reg) begin
                        next_state = (number_kernel_reg != 0) ? LOAD : DONE;
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

    //Sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            done_config_pixel_buffer_loader_flag <= 1'b0;
            done_config_weight_buffer_loader_flag <= 1'b0;
            done_config_activation_flag <= 1'b0;
            done_config_ofm_flag <= 1'b0;

            pixel_cfg_sent <= 1'b0;
            wgt_cfg_sent <= 1'b0;
            act_cfg_sent <= 1'b0;
            ofm_cfg_sent <= 1'b0;
            start_calc_sent <= 1'b0;

            window_cnt <= 3'd0; wgt_cnt <= 3'd0; bias_cnt <= 3'd0;

            valid_pixel_reg <= 1'b0; valid_wgt_reg <= 1'b0; valid_bias_reg <= 1'b0;
            rd_addr_pixel_reg <= 14'd0; rd_addr_wgt_reg <= 14'd0; rd_addr_bias_reg <= 14'd0;

            img_width_reg <= 16'd0; img_height_reg <= 16'd0;
            kernel_size_reg <= 3'd0; stride_reg <= 3'd0;
            activation_reg <= 2'd0;

            number_kernel_reg <= 16'd0;
            start_calc_reg <= 1'b0; 
            clear_window_reg_r <= 1'b0; clear_wgt_reg_r <= 1'b0; clear_bias_reg_r <= 1'b0;

            last_window_out_reg <= 1'b0;
            wgt_batch_target <= 3'd0;

            pix_col <= 16'd0; pix_row <= 16'd0;
            pix_win_req <= 3'd0; pix_req_done <= 1'b0;
            wgt_req_cnt <= 8'd0; wgt_words_target <= 8'd0;
        end
        else begin
            current_state <= next_state;
            clear_window_reg_r <= (current_state == CONFIG  && next_state == LOAD) || (current_state == COMPUTE && next_state == LOAD);
            clear_wgt_reg_r <= (current_state == COMPUTE) && done_calc && last_window_out_reg;
            clear_bias_reg_r <= (current_state == COMPUTE) && done_calc && last_window_out_reg;
            if (current_state == CONFIG && next_state == LOAD) begin
                wgt_batch_target  <= (number_kernel_reg > WEIGHT_COUNT) ? WEIGHT_COUNT[2:0] : number_kernel_reg[2:0];
                wgt_words_target  <= ((number_kernel_reg > WEIGHT_COUNT) ? WEIGHT_COUNT[2:0] : number_kernel_reg[2:0])
                                      * (kernel_size_reg * kernel_size_reg);
                number_kernel_reg <= (number_kernel_reg > WEIGHT_COUNT) ? number_kernel_reg - WEIGHT_COUNT : 16'd0;

                pix_col <= 16'd0; pix_row <= 16'd0;
                pix_win_req <= 3'd0; pix_req_done <= 1'b0;
                window_cnt <= 3'd0; wgt_cnt <= 3'd0; wgt_req_cnt <= 8'd0; bias_cnt <= 3'd0;
                rd_addr_pixel_reg <= 14'd0; rd_addr_wgt_reg <= 14'd0; rd_addr_bias_reg <= 14'd0;
                last_window_out_reg <= 1'b0;
            end

            if (current_state == COMPUTE && next_state == LOAD) begin
                window_cnt <= 3'd0;
                pix_win_req <= 3'd0;
                pix_req_done <= 1'b0;

                if (last_window_out_reg) begin
                    wgt_cnt <= 3'd0;
                    wgt_req_cnt <= 8'd0;
                    bias_cnt <= 3'd0;
                    last_window_out_reg <= 1'b0;
                    rd_addr_pixel_reg <= 14'd0;

                    wgt_batch_target <= (number_kernel_reg > WEIGHT_COUNT) ? WEIGHT_COUNT[2:0] : number_kernel_reg[2:0];
                    wgt_words_target <= ((number_kernel_reg > WEIGHT_COUNT) ? WEIGHT_COUNT[2:0] : number_kernel_reg[2:0])
                                          * (kernel_size_reg * kernel_size_reg);
                    number_kernel_reg <= (number_kernel_reg > WEIGHT_COUNT) ? number_kernel_reg - WEIGHT_COUNT : 16'd0;
                end
            end
        end

        if (current_state == IDLE) begin
            if (start_npu) begin
                img_width_reg <= img_width; img_height_reg <= img_height;
                kernel_size_reg <= kernel_size; stride_reg <= stride;
                activation_reg <= activation;
                number_kernel_reg <= number_kernel;
            end
        end

        if (current_state == CONFIG) begin
            if (!pixel_cfg_sent) pixel_cfg_sent <= 1'b1;
            if (!wgt_cfg_sent) wgt_cfg_sent <= 1'b1;
            if (!act_cfg_sent) act_cfg_sent <= 1'b1;
            if (!ofm_cfg_sent) ofm_cfg_sent <= 1'b1;

            if (done_config_pixel_buffer_loader)  done_config_pixel_buffer_loader_flag  <= 1'b1;
            if (done_config_weight_buffer_loader) done_config_weight_buffer_loader_flag <= 1'b1;
            if (done_config_activation) done_config_activation_flag <= 1'b1;
            if (done_config_ofm) done_config_ofm_flag <= 1'b1;
        end
        else begin
            pixel_cfg_sent <= 1'b0;
            wgt_cfg_sent <= 1'b0;
            act_cfg_sent <= 1'b0;
            ofm_cfg_sent <= 1'b0;

            done_config_pixel_buffer_loader_flag <= 1'b0;
            done_config_weight_buffer_loader_flag <= 1'b0;
            done_config_activation_flag <= 1'b0;
            done_config_ofm_flag <= 1'b0;
        end

        if (current_state == LOAD) begin
            //Load Pixel
            if (rd_en_pixel) begin
                rd_addr_pixel_reg <= pix_is_last ? 14'd0 : rd_addr_pixel_reg + 14'd1;
                if (pix_col == img_width_reg - 1) begin
                    pix_col <= 16'd0;
                    pix_row <= (pix_row == img_height_reg-1) ? 16'd0 : pix_row + 16'd1;
                end
                else begin
                    pix_col <= pix_col + 16'd1;
                end
                if (pix_is_win) pix_win_req <= pix_win_req + 3'd1;
                if (pix_stop_now) pix_req_done <= 1'b1;
            end
            valid_pixel_reg <= rd_en_pixel;   

            if (valid_window_out && window_cnt < WINDOW_COUNT) window_cnt <= window_cnt + 3'd1;
            if (last_window_out) last_window_out_reg <= 1'b1;

            //Load Weight
            if (rd_en_wgt) begin
                wgt_req_cnt <= wgt_req_cnt + 8'd1;
                rd_addr_wgt_reg <= rd_addr_wgt_reg + 14'd1;
            end
            valid_wgt_reg <= rd_en_wgt;   
            if (valid_wgt_out && wgt_cnt < wgt_batch_target) wgt_cnt <= wgt_cnt + 3'd1;

            //Load Bias
            if (rd_en_bias) begin
                bias_cnt <= bias_cnt + 3'd1;
                rd_addr_bias_reg <= rd_addr_bias_reg + 14'd1;
            end
            valid_bias_reg <= rd_en_bias;   
        end
        if (current_state == COMPUTE) begin
            if (!start_calc_sent) begin
                start_calc_reg  <= 1'b1;
                start_calc_sent <= 1'b1;
            end
            else begin
                start_calc_reg <= 1'b0; 
            end
        end
        else begin
            start_calc_sent <= 1'b0;  
        end
    end

    //Output logic
    assign img_width_config = img_width_reg;
    assign img_height_config = img_height_reg;
    assign kernel_size_config = kernel_size_reg;
    assign stride_config = stride_reg;
    assign activation_config = activation_reg;

    assign start_config_pixel_buffer_loader  = (current_state == CONFIG && !pixel_cfg_sent) ? 1'b1 : 1'b0;
    assign start_config_weight_buffer_loader = (current_state == CONFIG && !wgt_cfg_sent) ? 1'b1 : 1'b0;
    assign start_config_activation = (current_state == CONFIG && !act_cfg_sent) ? 1'b1 : 1'b0;
    assign start_config_ofm = (current_state == CONFIG && !ofm_cfg_sent) ? 1'b1 : 1'b0;

    assign rd_addr_pixel = (current_state == LOAD) ? rd_addr_pixel_reg : 14'd0;
    assign rd_addr_wgt = (current_state == LOAD) ? rd_addr_wgt_reg : 14'd0;
    assign rd_addr_bias = (current_state == LOAD) ? rd_addr_bias_reg : 14'd0;

    assign valid_pixel = valid_pixel_reg;
    assign valid_wgt = valid_wgt_reg;
    assign valid_bias = valid_bias_reg;

    assign number_kernel_monitor = number_kernel_reg;
    assign start_calc = start_calc_reg;
    assign clear_window_reg = clear_window_reg_r;
    assign clear_wgt_reg = clear_wgt_reg_r;
    assign clear_bias_reg = clear_bias_reg_r;
endmodule