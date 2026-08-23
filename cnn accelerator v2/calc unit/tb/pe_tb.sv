`timescale 1ns/1ps
`define N 24
`define ACC 48
`define FRAC_BITS 16
module tb_pe;
    logic clk, rst, clr;
    logic en;
    logic signed [`N-1:0] pixel, weight;
    logic signed [`N-1:0] pixel_out, weight_out;
    logic signed [`ACC-1:0] acc;

    pe #(.N(), .ACC()) uut(
        .clk(clk), .rst(rst), .clr(clr),
        .en(en),
        .pixel(pixel), .weight(weight),
        .pixel_out(pixel), .weight_out(weight),
        .acc(acc)
    );

    always #5 clk = ~clk;

    function signed [`N-1:0] to_fixed(input real val);
        to_fixed = $rtoi(val * (2.0 ** `FRAC_BITS) + (val >= 0 ? 0.5 : -0.5));
    endfunction
 
    function real acc_to_real(input signed [`ACC-1:0] val);
        reg signed [`ACC/2-1:0] hi;
        reg        [`ACC/2-1:0] lo;
        begin
            hi = val[`ACC-1 : `ACC/2];
            lo = val[`ACC/2-1 : 0];
            acc_to_real = ($itor(hi) * (2.0 ** (`ACC/2)) + $itor(lo)) / (2.0 ** (`FRAC_BITS*2));
        end
    endfunction
 
    real pixel_r, weight_r;
    real expected_acc;
    real actual_acc;
    real err;
    integer errors;
 
    task apply(input real p_val, input real w_val, input clr_val, input en_val);
        begin
            pixel_r  = p_val;
            weight_r = w_val;
            pixel    = to_fixed(p_val);
            weight   = to_fixed(w_val);
            clr      = clr_val;
            en       = en_val;
            @(posedge clk);
            #1;
        end
    endtask
 
    task check_result;
        begin
            actual_acc = acc_to_real(acc);
            err = actual_acc - expected_acc;
            if (err < 0) err = -err;
 
            if (err > 0.001) begin
                $display("FAIL: expected=%0.4f  actual=%0.4f", expected_acc, actual_acc);
                errors = errors + 1;
            end
            else begin
                $display("PASS: expected=%0.4f  actual=%0.4f", expected_acc, actual_acc);
            end
        end
    endtask

     initial begin
        rst = 1; clr = 0; en = 0;
        pixel = 0; weight = 0;
        errors = 0;
        expected_acc = 0.0;
 
        @(posedge clk); @(posedge clk);
        rst = 0;
 
        apply(1.5, 2.0, 1, 1);
        expected_acc = 1.5 * 2.0;
        check_result();
 
        apply(-3.25, 4.5, 0, 1);
        expected_acc = expected_acc + (-3.25 * 4.5);
        check_result();
 
        apply(0.125, -8.0, 0, 1);
        expected_acc = expected_acc + (0.125 * -8.0);
        check_result();
 
        apply(-1.0, -1.0, 0, 1);
        expected_acc = expected_acc + (-1.0 * -1.0);
        check_result();
 
        apply(0.0, 0.0, 1, 0);
        expected_acc = 0.0;
        check_result();
 
        apply(2.0, 3.0, 0, 0);
        check_result();
 
        $display("=========================================================");
        if (errors == 0)
            $display("PASS: tat ca test case deu khop (trong sai so cho phep)");
        else
            $display("FAIL: %0d test case sai", errors);
 
        $finish;
    end
endmodule