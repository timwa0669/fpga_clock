`timescale 1ns / 1ns

module BEEP_CONTROLLER_tb;
        reg clk;
        reg rst;
        reg beep;
        reg beep_enabled;
        wire beep_port;

        BEEP_CONTROLLER beep_controller_ (
                .clk(clk),
                .rst(rst),
                .beep(beep),
                .beep_enabled(beep_enabled),
                .beep_port(beep_port)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b0;
                beep = 1'b0;
                beep_enabled = 1'b0;

                #100 rst = 1'b1;

                #1_000 beep_enabled = 1'b1;
                #1_000 beep = 1'b1;
                #1_000 beep = 1'b0;
                #1_000 beep_enabled = 1'b0;
                #1_000 $stop;
        end

        always #10 clk = ~clk;
endmodule
