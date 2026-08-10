`timescale 1ns / 1ps
module schedule_block #(parameter DW=24)(
    input wire clk, reset,
    input wire load,
    input wire [5:0] cycle,

    input wire signed [599:0] IFM0,
    input wire signed [599:0] IFM1,
    input wire signed [599:0] IFM2,
    input wire signed [599:0] IFM3,
    input wire signed [599:0] IFM4,

    input wire signed [599:0] WGT0,
    input wire signed [599:0] WGT1,
    input wire signed [599:0] WGT2,
    input wire signed [599:0] WGT3,
    input wire signed [599:0] WGT4,

    output reg signed [DW-1:0] a1, a2, a3, a4, a5,
    output reg signed [DW-1:0] b1, b2, b3, b4, b5
);
    integer i;
    reg signed [DW-1:0] rIFM0 [0:24];
    reg signed [DW-1:0] rIFM1 [0:24];
    reg signed [DW-1:0] rIFM2 [0:24];
    reg signed [DW-1:0] rIFM3 [0:24];
    reg signed [DW-1:0] rIFM4 [0:24];

    reg signed [DW-1:0] rWGT0 [0:24];
    reg signed [DW-1:0] rWGT1 [0:24];
    reg signed [DW-1:0] rWGT2 [0:24];
    reg signed [DW-1:0] rWGT3 [0:24];
    reg signed [DW-1:0] rWGT4 [0:24];

    always @(posedge clk) begin
        if(reset) begin
            for(i=0;i<25;i=i+1) begin
                rIFM0[i] <= 0;
                rIFM1[i] <= 0;
                rIFM2[i] <= 0;
                rIFM3[i] <= 0;
                rIFM4[i] <= 0;

                rWGT0[i] <= 0;
                rWGT1[i] <= 0;
                rWGT2[i] <= 0;
                rWGT3[i] <= 0;
                rWGT4[i] <= 0;
            end
        end
            
        
        else if(load) begin
            for(i=0;i<25;i=i+1) begin
                rIFM0[i] <= IFM0[599-24*i -:24];
                rIFM1[i] <= IFM1[599-24*i -:24];
                rIFM2[i] <= IFM2[599-24*i -:24];
                rIFM3[i] <= IFM3[599-24*i -:24];
                rIFM4[i] <= IFM4[599-24*i -:24];

                rWGT0[i] <= WGT0[599-24*i -:24];
                rWGT1[i] <= WGT1[599-24*i -:24];
                rWGT2[i] <= WGT2[599-24*i -:24];
                rWGT3[i] <= WGT3[599-24*i -:24];
                rWGT4[i] <= WGT4[599-24*i -:24];
            end
        end
    end
    

    always @(*) begin
        a1 = 0;
        a2 = 0;
        a3 = 0;
        a4 = 0;
        a5 = 0;
        b1 = 0;
        b2 = 0;
        b3 = 0;
        b4 = 0;
        b5 = 0;
        if(cycle>=1 && cycle<=25) 
            a1 = rIFM0[cycle-1];

        if(cycle>=2 && cycle<=26) 
            a2 = rIFM1[cycle-2];

        if(cycle>=3 && cycle<=27) 
            a3 = rIFM2[cycle-3];

        if(cycle>=4 && cycle<=28) 
            a4 = rIFM3[cycle-4];

        if(cycle>=5 && cycle<=29) 
            a5 = rIFM4[cycle-5];

        if(cycle>=1 && cycle<=25)
            b1 = rWGT0[cycle-1];
        
        if(cycle>=2 && cycle<=26)
            b2 = rWGT1[cycle-2];
        
        if(cycle>=3 && cycle<=27)
            b3 = rWGT2[cycle-3];
        
        if(cycle>=4 && cycle<=28)
            b4 = rWGT3[cycle-4];
        
        if(cycle>=5 && cycle<=29)
            b5 = rWGT4[cycle-5];
    end
endmodule
