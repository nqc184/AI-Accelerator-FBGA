`timescale 1ns / 1ps

module npu_controller (
    input clk,
    input rst,
    input start,

    output reg start_config_pixel_buffer_loader,
    output reg start_config_weight_buffer_loader,
    output reg start_config_activation,
    output reg start_config_ofm,

    input [15:0] img_width,
    input [15:0] img_height,
    input [2:0]  kernel_size,
    input [2:0]  stride,
    input [1:0]  activation,

    input done_config_pixel_buffer_loader,
    input done_config_weight_buffer_loader,
    input done_config_activation,
    input done_config_ofm,

    output reg [15:0] img_width_config,
    output reg [15:0] img_height_config,
    output reg [2:0]  kernel_size_config,
    output reg [2:0]  stride_config,
    output reg [1:0]  activation_config,

    output reg rd_en_ifm,
    output reg rd_en_wgt,
    output reg rd_en_bias,
    
    input ifm_reg_full,
    input wgt_reg_full,

    input [9:0] select_reg_ifm,
    input [9:0] select_reg_wgt,
    input [9:0] select_reg_bias,

    input valid_window_out,
    input last_window_out,

    output reg start_calc,
    input calc_done,

    output reg clear_select_reg_ifm,
    output reg clear_select_reg_wgt,
    output reg clear_select_reg_bias,

    input full_ofm,

    output reg done_npu,

    output reg [2:0] state_out,
    output reg block_ifm_read
);
    localparam IDLE          = 3'd0;
    localparam CONFIG        = 3'd1;
    localparam PRE_IMPLEMENT = 3'd2;
    localparam IMPLEMENT    = 3'd3;
    localparam DONE          = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;

    reg config_sent;

    reg pixel_config_done_hold;
    reg weight_config_done_hold;
    reg activation_config_done_hold;
    reg ofm_config_done_hold;

    reg wgt_loaded;
    reg bias_loaded;

    reg calc_started;
    
    reg last_window_hold;
    reg last_window_d1;

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

                if (start)
                    next_state = CONFIG;

            end

            CONFIG: begin

                if (pixel_config_done_hold &&
                    weight_config_done_hold &&
                    activation_config_done_hold &&
                    ofm_config_done_hold) begin

                    next_state = PRE_IMPLEMENT;

                end

            end

            PRE_IMPLEMENT: begin

                if ((ifm_reg_full &&
                    wgt_reg_full &&
                    bias_loaded)||last_window_d1) begin
                    next_state = IMPLEMENT;
                end

            end

            IMPLEMENT: begin

                if (calc_done) begin
                    if (last_window_hold)     
                        next_state = DONE;
                    else
                        next_state = PRE_IMPLEMENT;
                end

            end

            DONE: begin

                next_state = DONE;

            end


            default: begin

                next_state = IDLE;

            end

        endcase

    end

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            config_sent <= 1'b0;

            img_width_config  <= 16'd0;
            img_height_config <= 16'd0;
            kernel_size_config <= 3'd0;
            stride_config      <= 3'd0;
            activation_config  <= 2'd0;


            pixel_config_done_hold      <= 1'b0;
            weight_config_done_hold     <= 1'b0;
            activation_config_done_hold <= 1'b0;
            ofm_config_done_hold        <= 1'b0;

            wgt_loaded  <= 1'b0;
            bias_loaded <= 1'b0;

            calc_started <= 1'b0;
            
            last_window_hold <= 1'b0;
            last_window_d1   <= 1'b0;
        end

        else begin
            if (last_window_out) begin
                last_window_hold <= 1'b1;
                last_window_d1 <= last_window_out;
            end
    
            if (calc_done) begin
                last_window_d1   <= 1'b0;
            end
            if (state == IDLE && start) begin

                img_width_config   <= img_width;
                img_height_config  <= img_height;
                kernel_size_config <= kernel_size;
                stride_config      <= stride;
                activation_config  <= activation;

            end

            if (state != CONFIG) begin

                pixel_config_done_hold      <= 1'b0;
                weight_config_done_hold     <= 1'b0;
                activation_config_done_hold <= 1'b0;
                ofm_config_done_hold        <= 1'b0;

            end

            else begin

                if (done_config_pixel_buffer_loader)
                    pixel_config_done_hold <= 1'b1;

                if (done_config_weight_buffer_loader)
                    weight_config_done_hold <= 1'b1;

                if (done_config_activation)
                    activation_config_done_hold <= 1'b1;

                if (done_config_ofm)
                    ofm_config_done_hold <= 1'b1;

            end


            if (state == IDLE) begin

                config_sent <= 1'b0;

            end

            else if (state == CONFIG && !config_sent) begin

                config_sent <= 1'b1;

            end

            if (state == CONFIG) begin

                wgt_loaded <= 1'b0;

            end

            else if (state == PRE_IMPLEMENT) begin

                if (select_reg_wgt == 10'd5)
                    wgt_loaded <= 1'b1;

            end

            if (state == CONFIG) begin

                bias_loaded <= 1'b0;

            end

            else if (state == PRE_IMPLEMENT) begin

                if (select_reg_bias == 10'd5)
                    bias_loaded <= 1'b1;

            end

            if (state != IMPLEMENT) begin

                calc_started <= 1'b0;

            end

            else begin

                calc_started <= 1'b1;

                if (calc_done)
                    calc_started <= 1'b0;

            end

        end

    end

    always @(*) begin

        start_config_pixel_buffer_loader = 1'b0;
        start_config_weight_buffer_loader = 1'b0;
        start_config_activation = 1'b0;
        start_config_ofm = 1'b0;

        rd_en_ifm  = 1'b0;
        rd_en_wgt  = 1'b0;
        rd_en_bias = 1'b0;

        start_calc = 1'b0;

        clear_select_reg_ifm  = 1'b0;
        clear_select_reg_wgt = 1'b0;
        clear_select_reg_bias = 1'b0;

        done_npu = 1'b0;
        
        block_ifm_read = 1'b0;


        case (state)

            CONFIG: begin

                if (!config_sent) begin

                    start_config_pixel_buffer_loader = 1'b1;
                    start_config_weight_buffer_loader = 1'b1;
                    start_config_activation = 1'b1;
                    start_config_ofm = 1'b1;

                end

            end

            PRE_IMPLEMENT: begin

                 if ((select_reg_ifm < 10'd4 ||
                    (select_reg_ifm == 10'd4 && !valid_window_out)) &&
                    !last_window_hold && !last_window_out)
                    rd_en_ifm = 1'b1;
                else  rd_en_ifm = 1'b0;

                if (!wgt_loaded &&
                    select_reg_wgt < 10'd5)

                    rd_en_wgt = 1'b1;

                if (!bias_loaded &&
                    select_reg_bias < 10'd5)

                    rd_en_bias = 1'b1;
                    
                if (select_reg_ifm == 10'd4)
                    block_ifm_read = 1'b1;

            end

            IMPLEMENT: begin

                rd_en_ifm  = 1'b0;
                rd_en_wgt  = 1'b0;
                rd_en_bias = 1'b0;

               if ((ifm_reg_full &&
                     wgt_reg_full &&
                     bias_loaded &&
                     !calc_started) ||
                    (last_window_d1 && !calc_started)) begin
                
                    start_calc = 1'b1;
                
                end

            end

            DONE: begin

                rd_en_ifm  = 1'b0;
                rd_en_wgt  = 1'b0;
                rd_en_bias = 1'b0;

                start_calc = 1'b0;

                done_npu = 1'b1;

            end

        endcase

        if (state == IMPLEMENT && calc_done) begin

            clear_select_reg_ifm = 1'b1;

        end

        if (full_ofm)
            done_npu = 1'b1;

    end

endmodule