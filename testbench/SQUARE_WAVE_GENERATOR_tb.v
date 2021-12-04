`timescale 1ns / 1ns

module SQUARE_WAVE_GENERATOR_tb;
        reg clk;
        reg rst;
        wire sw;

        SQUARE_WAVE_GENERATOR #(
                .cycle(32'd100)
        ) square_wave_generator_ (
                .clk(clk),
                .rst(rst),
                .sw(sw)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b1;

                #4000 rst = 1'b0;
                #4010 $stop;
        end

        always #10 clk = ~clk;
endmodule
