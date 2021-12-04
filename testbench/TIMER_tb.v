`timescale 1ns / 1ns

module TIMER_tb;
        reg clk;
        reg rst;
        wire cy;

        TIMER #(
                .cycle(32'd100),
                .rel(32'd5)
        ) timer_ (
                .clk(clk),
                .rst(rst),
                .cy(cy)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b1;

                #4000 rst = 1'b0;
                #4010 $stop;
        end

        always #10 clk = ~clk;
endmodule
