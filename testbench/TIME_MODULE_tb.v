`timescale 1ns / 1ns

module TIME_MODULE_tb_1;
        reg [2:0] clk;
        reg rst;
        reg mode;
        wire [23:0] time_data;
        wire [3:0] time_data_5;
        wire [3:0] time_data_4;
        wire [3:0] time_data_3;
        wire [3:0] time_data_2;
        wire [3:0] time_data_1;
        wire [3:0] time_data_0;

        TIME_MODULE time_module_ (
                .clk(clk),
                .rst(rst),
                .mode(mode),
                .time_data(time_data)
        );

        initial begin
                mode = 1'b1;
                clk = 3'b0;
                rst = 1'b1;
                #1728000 mode = 1'b0;
                #72000 $stop;
        end

        assign time_data_5 = time_data[23-:4];
        assign time_data_4 = time_data[19-:4];
        assign time_data_3 = time_data[15-:4];
        assign time_data_2 = time_data[11-:4];
        assign time_data_1 = time_data[07-:4];
        assign time_data_0 = time_data[03-:4];

        always #10 clk[0] = ~clk[0];
endmodule

module TIME_MODULE_tb_2;
        reg [2:0] clk;
        reg rst;
        reg mode;
        wire [23:0] time_data;
        wire [3:0] time_data_5;
        wire [3:0] time_data_4;
        wire [3:0] time_data_3;
        wire [3:0] time_data_2;
        wire [3:0] time_data_1;
        wire [3:0] time_data_0;

        TIME_MODULE time_module__ (
                .clk(clk),
                .rst(rst),
                .mode(mode),
                .time_data(time_data)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b1;
                mode = 1'b0;
                #20 clk[0] = 1'b1;
                #20 clk[0] = 1'b0;
                #20 clk[1] = 1'b1;
                #20 clk[1] = 1'b0;
                #20 clk[2] = 1'b1;
                #20 clk[2] = 1'b0;
                #20 mode = 1'b1;
                #20 clk[0] = 1'b1;
                #20 clk[0] = 1'b0;
                #20 clk[1] = 1'b1;
                #20 clk[1] = 1'b0;
                #20 clk[2] = 1'b1;
                #20 clk[2] = 1'b0;
                #20 $stop;
        end

        assign time_data_5 = time_data[23-:4];
        assign time_data_4 = time_data[19-:4];
        assign time_data_3 = time_data[15-:4];
        assign time_data_2 = time_data[11-:4];
        assign time_data_1 = time_data[07-:4];
        assign time_data_0 = time_data[03-:4];
endmodule

module TIME_SEG_UNIT_tb;
        reg clk;
        reg rst;
        wire cy;
        wire [3:0] seg_data;

        TIME_SEG_UNIT #(
                .target_cy_count(4'd2),
                .target_cy_num(4'h3)
        ) time_seg_unit_ (
                .clk(clk),
                .rst(rst),
                .cy(cy),
                .seg_data(seg_data)
        );

        initial begin
                clk = 1'b0;
                rst = 1'b1;
                #240 rst = 1'b0;
                #100 $stop;
        end

        always #10 clk = ~clk;
endmodule
