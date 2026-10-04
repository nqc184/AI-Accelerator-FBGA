`timescale 1ns/1ps
module maxpool_unit_tb;
    reg clk, rst, start_layer, pool_enable;
    reg [15:0] out_w, out_h;
    reg [2:0] pool_size, pool_stride;

    reg v0, v1, v2, v3, v4;
    reg signed [23:0] d0, d1, d2, d3, d4;

    wire signed [23:0] q0, q1, q2, q3, q4;
    wire o0, o1, o2, o3, o4;

    maxpool_unit #(.DW(24), .MAX_W(128), .P(3)) dut (
        .clk(clk), .rst(rst), .start_layer(start_layer), .pool_enable(pool_enable),
        .out_w(out_w), .out_h(out_h),
        .pool_size(pool_size), .pool_stride(pool_stride),
        .d0(d0), .d1(d1), .d2(d2), .d3(d3), .d4(d4),
        .v0(v0), .v1(v1), .v2(v2), .v3(v3), .v4(v4),
        .q0(q0), .q1(q1), .q2(q2), .q3(q3), .q4(q4),
        .o0(o0), .o1(o1), .o2(o2), .o3(o3), .o4(o4)
    );

    always #5 clk = ~clk;

    integer img [0:15];
    integer i;

    integer cnt0, cnt1, cnt2, cnt3, cnt4;
    reg signed [23:0] res0[0:3], res1[0:3], res2[0:3], res3[0:3], res4[0:3];

    initial begin
        img[0]=1;  img[1]=2;  img[2]=3;  img[3]=4;
        img[4]=5;  img[5]=6;  img[6]=7;  img[7]=8;
        img[8]=9;  img[9]=10; img[10]=11; img[11]=12;
        img[12]=13;img[13]=14;img[14]=15;img[15]=16;
    end

    initial begin
        clk = 0; rst = 1;
        v0=0; v1=0; v2=0; v3=0; v4=0;
        d0=0; d1=0; d2=0; d3=0; d4=0;
        pool_enable = 1; pool_size = 3'd2; pool_stride = 3'd2;
        out_w = 16'd4; out_h = 16'd4;
        start_layer = 0;
        cnt0=0; cnt1=0; cnt2=0; cnt3=0; cnt4=0;

        #12 rst = 0;
        #10 start_layer = 1;
        #10 start_layer = 0;

        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            d0 <= img[i];
            d1 <= img[i] + 100;
            d2 <= img[i] + 200;
            d3 <= img[i] + 300;
            d4 <= img[i] + 400;
            v0 <= 1; v1 <= 1; v2 <= 1; v3 <= 1; v4 <= 1;
        end
        @(posedge clk);
        v0 <= 0; v1 <= 0; v2 <= 0; v3 <= 0; v4 <= 0;

        #50;

        $display("---- Lane 0 (ky vong 6,8,14,16) ----");
        check(cnt0, res0, 6, 8, 14, 16, "lane0");

        $display("---- Lane 1 (ky vong 106,108,114,116) ----");
        check(cnt1, res1, 106, 108, 114, 116, "lane1");

        $display("---- Lane 2 (ky vong 206,208,214,216) ----");
        check(cnt2, res2, 206, 208, 214, 216, "lane2");

        $display("---- Lane 3 (ky vong 306,308,314,316) ----");
        check(cnt3, res3, 306, 308, 314, 316, "lane3");

        $display("---- Lane 4 (ky vong 406,408,414,416) ----");
        check(cnt4, res4, 406, 408, 414, 416, "lane4");

        $finish;
    end

    task automatic check(
        input integer cnt,
        input reg signed [23:0] res[0:3],
        input integer e0, e1, e2, e3,
        input [63:0] name
    );
        if (cnt != 4) begin
            $display("FAIL [%0s]: so ket qua = %0d, ky vong 4", name, cnt);
        end
        else if (res[0]==e0 && res[1]==e1 && res[2]==e2 && res[3]==e3) begin
            $display("PASS [%0s]: %0d, %0d, %0d, %0d", name, res[0], res[1], res[2], res[3]);
        end
        else begin
            $display("FAIL [%0s]: nhan %0d,%0d,%0d,%0d - ky vong %0d,%0d,%0d,%0d",
                      name, res[0], res[1], res[2], res[3], e0, e1, e2, e3);
        end
    endtask

    always @(posedge clk) begin
        if (o0) begin res0[cnt0] <= q0; cnt0 <= cnt0 + 1; end
        if (o1) begin res1[cnt1] <= q1; cnt1 <= cnt1 + 1; end
        if (o2) begin res2[cnt2] <= q2; cnt2 <= cnt2 + 1; end
        if (o3) begin res3[cnt3] <= q3; cnt3 <= cnt3 + 1; end
        if (o4) begin res4[cnt4] <= q4; cnt4 <= cnt4 + 1; end
    end
endmodule