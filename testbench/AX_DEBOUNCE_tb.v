`timescale 10ns / 1ns

module AX_DEBOUNCE_tb
        (
                output button_out
        );
        reg rst;
        reg clk;
        reg button_in;

        AX_DEBOUNCE ax_debounce
        (
                .clk(clk),
                .rst(rst),
                .button_in(button_in),
                .button_out(button_out),
                .button_posedge(button_posedge),
                .button_negedge(button_negedge)
        );

        initial begin
                rst = 1;
                clk = 0;
                button_in = 1;
                #0;
        end

        always #1 clk = ~clk;


        always #250_000 button_in = ~button_in;
endmodule