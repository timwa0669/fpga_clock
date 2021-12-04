`timescale 1ns / 1ns

module FLASH_SEG_tb;
        reg flash_clk;
        reg flash;
        reg [7:0] time_seg_data_in;
        wire [7:0] time_seg_data_out;

        FLASH_SEG flash_seg_ (
                .flash_clk(flash_clk),
                .flash(flash),
                .time_seg_data_in(time_seg_data_in),
                .time_seg_data_out(time_seg_data_out)
        );

        initial begin
                flash_clk = 1'b0;
                flash = 1'b0;
                time_seg_data_in = 8'b0000_0000;

                #100 flash = 1'b1;
                #100 flash = 1'b0;
                #10 $stop;
        end

        always #10 flash_clk = ~flash_clk;
endmodule

module SEG_DECODER_tb;
        reg [3:0] bin_data;
        reg dot;
        wire [7:0] seg_data;

        SEG_DECODER seg_decoder_ (
                .bin_data(bin_data),
                .dot(dot),
                .seg_data(seg_data)
        );

        initial begin
                bin_data = 4'h0;
                dot = 1'b0;

                #320 $stop;
        end

        always #10 bin_data = bin_data + 1;
        always #160 dot = ~dot;
endmodule

module SEG_SCAN_tb;
        reg clk;
        reg rst;
        reg [7:0] seg_data_0;
        reg [7:0] seg_data_1;
        reg [7:0] seg_data_2;
        reg [7:0] seg_data_3;
        reg [7:0] seg_data_4;
        reg [7:0] seg_data_5;
        wire [5:0] seg_sel;
        wire [7:0] seg_data;

        SEG_SCAN seg_scan_ (
                .clk(clk),
                .rst(rst),
                .seg_data_0(seg_data_0),
                .seg_data_1(seg_data_1),
                .seg_data_2(seg_data_2),
                .seg_data_3(seg_data_3),
                .seg_data_4(seg_data_4),
                .seg_data_5(seg_data_5),
                .seg_sel(seg_sel),
                .seg_data(seg_data)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b1;
                seg_data_0 = 8'd0;
                seg_data_1 = 8'd1;
                seg_data_2 = 8'd2;
                seg_data_3 = 8'd3;
                seg_data_4 = 8'd4;
                seg_data_5 = 8'd5;
                #10_831_000 rst = 1'b0;
                #5_000_000 $stop;
        end

        always #10 clk = ~clk;
endmodule
