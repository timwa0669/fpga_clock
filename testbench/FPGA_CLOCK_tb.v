`timescale 1ns / 1ns

module FPGA_CLOCK_tb;
        reg [6:0] control_status;
        reg beep_enabled;

        reg beep_button_posedge;
        reg set_button_posedge;
        reg add_button_posedge;
        reg rst;
        reg clk_1s;
        reg [23:0] current_time_data;
        reg [23:0] beep_time_data;

        wire [23:0] time_data;
        wire [6:0] control_status_next;
        wire [2:0] current_time_clk;
        wire [2:0] beep_time_clk;
        wire mode;
        wire beep;
        wire flash_hour;
        wire flash_minute;
        wire flash_second;

        initial begin
                control_status = 7'b000_000_1;
                beep_enabled = 1'b0;
                beep_button_posedge = 1'b0;
                set_button_posedge = 1'b0;
                add_button_posedge = 1'b0;
                beep_time_data = 10;
                current_time_data = 20;
                clk_1s = 1'b1;
                rst = 1'b1;

                #100
                set_button_posedge = 1'b1;
                #100
                set_button_posedge = 1'b0;
                #100
                add_button_posedge = 1'b1;
                #100
                add_button_posedge = 1'b0;

                #100
                set_button_posedge = 1'b1;
                #100
                set_button_posedge = 1'b0;
                #100
                add_button_posedge = 1'b1;
                #100
                add_button_posedge = 1'b0;

                #100
                set_button_posedge = 1'b1;
                #100
                set_button_posedge = 1'b0;
                #100
                add_button_posedge = 1'b1;
                #100
                add_button_posedge = 1'b0;

                #100
                set_button_posedge = 1'b1;
                #100
                set_button_posedge = 1'b0;
                #100
                add_button_posedge = 1'b1;
                #100
                add_button_posedge = 1'b0;

                #100
                set_button_posedge = 1'b1;
                #100
                set_button_posedge = 1'b0;
                #100
                add_button_posedge = 1'b1;
                #100
                add_button_posedge = 1'b0;

                #100
                set_button_posedge = 1'b1;
                #100
                set_button_posedge = 1'b0;
                #100
                add_button_posedge = 1'b1;
                #100
                add_button_posedge = 1'b0;

                #100
                beep_button_posedge = 1'b1;
                #100
                beep_button_posedge = 1'b0;

                #100
                beep_button_posedge = 1'b1;
                #100
                beep_button_posedge = 1'b0;

                #100
                rst = 1'b0;
                #1000
                $stop;
        end

        always @(posedge set_button_posedge or negedge rst) begin
                if (rst == 0) begin
                        control_status <= 7'b000_000_1;
                end else begin
                        if (add_button_posedge == 0) begin
                                control_status <= control_status_next;
                        end
                end
        end

        always @(posedge beep_button_posedge or negedge rst) begin
                if (rst == 1'b0) begin
                        beep_enabled <= 1'b0;
                end else begin
                        beep_enabled <= ~beep_enabled;
                end
        end

        assign led_beep_enabled_port = beep_enabled;
        assign current_time_clk[2] = control_status[3] & add_button_posedge;
        assign current_time_clk[1] = control_status[2] & add_button_posedge;
        assign current_time_clk[0] = (control_status[1] & add_button_posedge) | (control_status[0] & clk_1s);
        assign beep_time_clk[2] = control_status[6] & add_button_posedge;
        assign beep_time_clk[1] = control_status[5] & add_button_posedge;
        assign beep_time_clk[0] = control_status[4] & add_button_posedge;
        assign control_status_next = (control_status == 7'b100_000_0) ? 7'b000_000_1 : (control_status << 1);
        assign mode = control_status[0];
        assign time_data = (control_status[6] | control_status[5] | control_status[4]) ? beep_time_data : current_time_data;
        assign beep = (beep_time_data == current_time_data) & control_status[0];
        assign flash_second = control_status[1] | control_status[4];
        assign flash_minute = control_status[2] | control_status[5];
        assign flash_hour = control_status[3] | control_status[6];
endmodule
