`timescale 1ns / 1ns

module AX_DEBOUNCE_tb;
        reg rst;
        reg clk;
        reg button_in;
        wire button_out;
        wire button_posedge;
        wire button_negedge;

        AX_DEBOUNCE ax_debounce_
        (
                .clk(clk),
                .rst(rst),
                .button_in(button_in),
                .button_out(button_out),
                .button_posedge(button_posedge),
                .button_negedge(button_negedge)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b0;
                button_in = 1'b1;
                #100
                rst = 1'b1;
                #2000
                button_in = 1'b0;
                #({$random} %1000)
                button_in = ~button_in;
                #({$random} %1000)
                button_in = ~button_in;
                #({$random} %1000)
                button_in = ~button_in;
                #({$random} %1000)
                button_in = ~button_in;	
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;	
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = 1'b0;

                #1000000000
                button_in = 1'b1;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;	
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = 1'b1;
                
                #1000000000
                button_in = 1'b0;
                #({$random} %1000)
                button_in = ~button_in;
                #({$random} %1000)
                button_in = ~button_in;
                #({$random} %1000)
                button_in = ~button_in;
                #({$random} %1000)
                button_in = ~button_in;	
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;	
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = 1'b0;

                #1000000000
                button_in = 1'b1;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;	
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = ~button_in;
                #({$random} %10000000)
                button_in = 1'b1;
                #10
                $stop;
        end

        always #10 clk = ~clk;
endmodule
