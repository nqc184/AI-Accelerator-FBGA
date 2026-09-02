`timescale 1ns/1ps
module demo_tb;
    reg clk = 0, rst = 1, start = 0;
    reg tready = 1;
    wire [127:0] tdata;
    wire tvalid, tlast;

    axi_stream_source_tb #(
        .DATA_WIDTH(24),
        .MEM_DEPTH(16384),
        .FILE_NAME("IFM.mem"),
        .ADDR_WIDTH(8)
    ) dut (
        .clk(clk), .rst(rst), .start(start),
        .m_axis_tdata(tdata),
        .m_axis_tvalid(tvalid),
        .m_axis_tlast(tlast),
        .m_axis_tready(tready)
    );

    always #5 clk = ~clk;

    initial begin
        #12 rst = 0;
        #10 start = 1;
        #10 start = 0;

        forever begin
            @(posedge clk);
            if (tvalid && tready)
                $display("t=%0t | header(3+5bit)=%b_%b | mask_hex=%h | elems(hex24)= %h %h %h %h %h | tlast=%b",
                          $time,
                          tdata[127:125], tdata[124:120], tdata[124:120],
                          tdata[119:96], tdata[95:72], tdata[71:48], tdata[47:24], tdata[23:0],
                          tlast);
        end
    end

    initial begin
        #100 $finish;
    end
endmodule