module FPGA_CLOCK
(       
        input clk,
        input rst,                      // 未消抖按键输入：复位信号
        input set_button_raw,           // 未消抖按键输入：更改控制状态
        input beep_button_raw,          // 未消抖按键输入：响铃开关
        input add_button_raw,           // 未消抖按键输入：自增当前控制的时间
        output beep_port,
        output [5:0] seg_sel_port,
        output [7:0] seg_data_port,
        output led_beep_enabled_port
);
        wire [23:0] current_time_data;
        wire [23:0] beep_time_data;

        wire [47:0] time_seg_data;
        wire [23:0] time_data;
        wire clk_1s;
        wire [6:0] control_status_next; // 下一控制状态
        wire [2:0] current_time_clk;
        wire [2:0] beep_time_clk;
        wire mode;                      // 时间单元间进位控制
                                        // 0: 禁止秒→分，分→时单元间进位
                                        // 1: 允许时间单元间进位控制
        wire beep;
        wire beep_button_posedge;
        wire set_button_posedge;
        wire add_button_posedge;
        wire square_wave;
        wire [7:0] seg_data_0;
        wire [7:0] seg_data_1;
        wire [7:0] seg_data_2;
        wire [7:0] seg_data_3;
        wire [7:0] seg_data_4;
        wire [7:0] seg_data_5;
        wire flash_hour;
        wire flash_minute;
        wire flash_second;

        reg [6:0] control_status;       // 当前控制状态
                                        //  1: 当前时间 秒 1s自增
                                        //  2: 人工控制 当前时间 秒 自增
                                        //  4: 人工控制 当前时间 分 自增
                                        //  8: 人工控制 当前时间 时 自增
                                        // 16: 人工控制 响铃时间 秒 自增
                                        // 32: 人工控制 响铃时间 分 自增
                                        // 64: 人工控制 响铃时间 时 自增
        reg beep_enabled;

        initial begin
                control_status <= 7'b000_000_1;
                beep_enabled <= 1'b0;
        end

        TIMER #(.cycle(32'd50_000_000)) timer_1s (.clk(clk), .rst(rst), .cy(clk_1s));

        // 当前时间控制模块

        TIME_MODULE current_time (.clk(current_time_clk), .rst(rst), .mode(mode), .time_data(current_time_data));

        // 响铃时间控制模块

        TIME_MODULE beep_time    (.clk(beep_time_clk),    .rst(rst), .mode(0),    .time_data(beep_time_data)   );

        // 数码管解码模块

        SEG_DECODER decoder_0 (.bin_data(time_data[23-:4]), .dot(0), .seg_data(time_seg_data[47-:8]));
        SEG_DECODER decoder_1 (.bin_data(time_data[19-:4]), .dot(1), .seg_data(time_seg_data[39-:8]));
        SEG_DECODER decoder_2 (.bin_data(time_data[15-:4]), .dot(0), .seg_data(time_seg_data[31-:8]));
        SEG_DECODER decoder_3 (.bin_data(time_data[11-:4]), .dot(1), .seg_data(time_seg_data[23-:8]));
        SEG_DECODER decoder_4 (.bin_data(time_data[07-:4]), .dot(0), .seg_data(time_seg_data[15-:8]));
        SEG_DECODER decoder_5 (.bin_data(time_data[03-:4]), .dot(1), .seg_data(time_seg_data[07-:8]));

        // 数码管显示输出模块

        SEG_SCAN seg_scan 
                (
                        .clk(clk),
                        .rst(rst),
                        .seg_sel(seg_sel_port),
                        .seg_data(seg_data_port),
                        .seg_data_0(seg_data_0),
                        .seg_data_1(seg_data_1),
                        .seg_data_2(seg_data_2),
                        .seg_data_3(seg_data_3),
                        .seg_data_4(seg_data_4),
                        .seg_data_5(seg_data_5)
                );

        // 蜂鸣器（闹钟响铃）控制器

        BEEP_CONTROLLER beep_controller (.clk(square_wave), .rst(rst), .beep(beep), .beep_enabled(beep_enabled), .beep_port(beep_port));

        // 按键消抖模块

        AX_DEBOUNCE ax_debounce_beep_button (.clk(clk), .rst(rst), .button_in(beep_button_raw), .button_posedge(beep_button_posedge));
        AX_DEBOUNCE ax_debounce_set_button  (.clk(clk), .rst(rst), .button_in(set_button_raw),  .button_posedge(set_button_posedge) );
        AX_DEBOUNCE ax_debounce_add_button  (.clk(clk), .rst(rst), .button_in(add_button_raw),  .button_posedge(add_button_posedge) );

        SQUARE_WAVE_GENERATOR #(.cycle(32'd12_500_000)) sw_gen (.clk(clk), .rst(rst), .sw(square_wave));

        // 数码管闪烁控制模块

        FLASH_SEG flash_seg_0 (.flash_clk(square_wave), .flash(flash_hour),   .time_seg_data_in(time_seg_data[47-:8]), .time_seg_data_out(seg_data_0));
        FLASH_SEG flash_seg_1 (.flash_clk(square_wave), .flash(flash_hour),   .time_seg_data_in(time_seg_data[39-:8]), .time_seg_data_out(seg_data_1));
        FLASH_SEG flash_seg_2 (.flash_clk(square_wave), .flash(flash_minute), .time_seg_data_in(time_seg_data[31-:8]), .time_seg_data_out(seg_data_2));
        FLASH_SEG flash_seg_3 (.flash_clk(square_wave), .flash(flash_minute), .time_seg_data_in(time_seg_data[23-:8]), .time_seg_data_out(seg_data_3));
        FLASH_SEG flash_seg_4 (.flash_clk(square_wave), .flash(flash_second), .time_seg_data_in(time_seg_data[15-:8]), .time_seg_data_out(seg_data_4));
        FLASH_SEG flash_seg_5 (.flash_clk(square_wave), .flash(flash_second), .time_seg_data_in(time_seg_data[07-:8]), .time_seg_data_out(seg_data_5));

        // 自增信号输出位置控制

        always @(posedge set_button_posedge or negedge rst) begin
                if (rst == 0) begin
                        control_status <= 7'b000_000_1;
                end else begin
                        if (add_button_posedge == 0) begin
                                control_status <= control_status_next;
                        end
                end
        end

        // 响铃信号控制

        always @(posedge beep_button_posedge or negedge rst) begin
                if (rst == 1'b0) begin
                        beep_enabled <= 1'b0;
                end else begin
                        beep_enabled <= ~beep_enabled;
                end
        end

        // 是否启用响铃

        assign led_beep_enabled_port = beep_enabled;

        // 当前时间自增信号控制

        assign current_time_clk[2] = control_status[3] & add_button_posedge;
        assign current_time_clk[1] = control_status[2] & add_button_posedge;
        assign current_time_clk[0] = (control_status[1] & add_button_posedge) | (control_status[0] & clk_1s);

        // 响铃时间自增信号控制

        assign beep_time_clk[2] = control_status[6] & add_button_posedge;
        assign beep_time_clk[1] = control_status[5] & add_button_posedge;
        assign beep_time_clk[0] = control_status[4] & add_button_posedge;

        // 自增信号输出位置控制

        assign control_status_next = (control_status == 7'b100_000_0) ? 7'b000_000_1 : (control_status << 1);
        assign mode = control_status[0];
        assign time_data = (control_status[6] | control_status[5] | control_status[4]) ? beep_time_data : current_time_data;

        // 当前时间是否要响铃

        assign beep = (beep_time_data == current_time_data) & control_status[0];

        // 闪烁控制

        assign flash_second = control_status[1] | control_status[4];
        assign flash_minute = control_status[2] | control_status[5];
        assign flash_hour = control_status[3] | control_status[6];
endmodule
