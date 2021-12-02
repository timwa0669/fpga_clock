module FPGA_CLOCK
(       
        input clk,
        input rst,
        input set_button_raw,
        input beep_button_raw,
        input add_button_raw,
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
        wire [6:0] control_status_next;
        wire [2:0] current_time_clk;
        wire [2:0] beep_time_clk;
        wire mode;
        wire should_beep;
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

        reg [6:0] control_status;
        reg beep_button_rawlatch;

        initial begin
                control_status <= 7'b000_000_1;
                beep_button_rawlatch <= 0;
        end

        TIMER #(.cycle(32'd50_000_000)) timer_1s (.clk(clk), .rst(rst), .cy(clk_1s));

        TIME_MODULE current_time (.clk(current_time_clk), .rst(rst), .mode(mode), .time_data(current_time_data));
        TIME_MODULE beep_time    (.clk(beep_time_clk),    .rst(rst), .mode(0),    .time_data(beep_time_data)   );

        SEG_DECODER decoder_0 (.bin_data(time_data[23-:4]), .dot(0), .seg_data(time_seg_data[47-:8]));
        SEG_DECODER decoder_1 (.bin_data(time_data[19-:4]), .dot(1), .seg_data(time_seg_data[39-:8]));
        SEG_DECODER decoder_2 (.bin_data(time_data[15-:4]), .dot(0), .seg_data(time_seg_data[31-:8]));
        SEG_DECODER decoder_3 (.bin_data(time_data[11-:4]), .dot(1), .seg_data(time_seg_data[23-:8]));
        SEG_DECODER decoder_4 (.bin_data(time_data[07-:4]), .dot(0), .seg_data(time_seg_data[15-:8]));
        SEG_DECODER decoder_5 (.bin_data(time_data[03-:4]), .dot(1), .seg_data(time_seg_data[07-:8]));

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

        BEEP_CONTROLLER beep_controller (.clk(square_wave), .rst(rst), .beep(should_beep), .beep_port(beep_port));

        AX_DEBOUNCE ax_debounce_beep_button
                (
                        .clk(clk),
                        .rst(rst),
                        .button_in(beep_button_raw),
                        .button_posedge(beep_button_posedge)
                );
        AX_DEBOUNCE ax_debounce_set_button
                (
                        .clk(clk),
                        .rst(rst),
                        .button_in(set_button_raw),
                        .button_posedge(set_button_posedge)
                );
        AX_DEBOUNCE ax_debounce_add_button
                (
                        .clk(clk),
                        .rst(rst),
                        .button_in(add_button_raw),
                        .button_posedge(add_button_posedge)
                );

        SQUARE_WAVE_GENERATOR #(.cycle(32'd12_500_000)) sw_gen (.clk(clk), .rst(rst), .sw(square_wave));

        FLASH_SEG flash_seg_0 (.flash_clk(square_wave), .flash(flash_hour), .time_seg_data_in(time_seg_data[47-:8]), .time_seg_data_out(seg_data_0));
        FLASH_SEG flash_seg_1 (.flash_clk(square_wave), .flash(flash_hour), .time_seg_data_in(time_seg_data[39-:8]), .time_seg_data_out(seg_data_1));
        FLASH_SEG flash_seg_2 (.flash_clk(square_wave), .flash(flash_minute), .time_seg_data_in(time_seg_data[31-:8]), .time_seg_data_out(seg_data_2));
        FLASH_SEG flash_seg_3 (.flash_clk(square_wave), .flash(flash_minute), .time_seg_data_in(time_seg_data[23-:8]), .time_seg_data_out(seg_data_3));
        FLASH_SEG flash_seg_4 (.flash_clk(square_wave), .flash(flash_second), .time_seg_data_in(time_seg_data[15-:8]), .time_seg_data_out(seg_data_4));
        FLASH_SEG flash_seg_5 (.flash_clk(square_wave), .flash(flash_second), .time_seg_data_in(time_seg_data[07-:8]), .time_seg_data_out(seg_data_5));

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
                if (rst == 0) begin
                        beep_button_rawlatch <= 0;
                end else begin
                        beep_button_rawlatch <= ~beep_button_rawlatch;
                end
        end

        assign led_beep_enabled_port = beep_button_rawlatch;
        assign current_time_clk[2] = control_status[3] & add_button_posedge;
        assign current_time_clk[1] = control_status[2] & add_button_posedge;
        assign current_time_clk[0] = (control_status[1] & add_button_posedge) | (control_status[0] & clk_1s);
        assign beep_time_clk[2] = control_status[6] & add_button_posedge;
        assign beep_time_clk[1] = control_status[5] & add_button_posedge;
        assign beep_time_clk[0] = control_status[4] & add_button_posedge;
        assign control_status_next = (control_status == 7'b100_000_0) ? 7'b000_000_1 : (control_status << 1);
        assign mode = control_status[0];
        assign time_data = (control_status[6] | control_status[5] | control_status[4]) ? beep_time_data : current_time_data;
        assign should_beep = ((beep_time_data == current_time_data) & beep_button_rawlatch & control_status[0]) ? 1'b1 : 1'b0;
        assign flash_second = control_status[1] | control_status[4];
        assign flash_minute = control_status[2] | control_status[5];
        assign flash_hour = control_status[3] | control_status[6];
endmodule

module FLASH_SEG
        (
                input flash_clk,
                input flash,
                input [7:0] time_seg_data_in,
                output [7:0] time_seg_data_out
        );

        assign time_seg_data_out = flash_clk & flash ? { 8{flash_clk} } : time_seg_data_in;
endmodule

module SQUARE_WAVE_GENERATOR
        #(
                parameter [31:0] cycle
        )
        (
                input clk,
                input rst,
                output reg sw
        );
        
        wire clk_target;

        localparam [31:0] target_cycle = cycle >> 1;

        TIMER #(.cycle(target_cycle)) timer (.clk(clk), .rst(rst), .cy(clk_target));

        initial begin
                sw <= 1'b0;
        end

        always @(posedge clk_target or negedge rst) begin
                if (rst == 1'b0) begin
                        sw <= 0;
                end else begin
                        sw <= ~sw;
                end
        end
endmodule

module TIME_MODULE
        (
                input [2:0] clk,
                input rst,
                input mode,
                output [23:0] time_data
        );
        wire [5:0] cy;
        wire [2:0] cy_controller;

        assign cy_controller = {clk[2] | (mode & cy[3]), clk[1] | (mode & cy[1]), clk[0]};

        TIME_SEG_UNIT
                second_l
                (
                        .clk(cy_controller[0]),
                        .rst(rst),
                        .cy(cy[0]),
                        .TIME_SEG_UNIT(time_data[3-:4])
                );
        TIME_SEG_UNIT
                #(
                        .target_cy_num(4'h5)
                )
                second_h
                (
                        .clk(cy[0]),
                        .rst(rst),
                        .cy(cy[1]),
                        .TIME_SEG_UNIT(time_data[7-:4])
                );
        TIME_SEG_UNIT
                minute_l
                (
                        .clk(cy_controller[1]),
                        .rst(rst),
                        .cy(cy[2]),
                        .TIME_SEG_UNIT(time_data[11-:4])
                );
        TIME_SEG_UNIT
                #(
                        .target_cy_num(4'h5)
                )
                minute_h
                (
                        .clk(cy[2]),
                        .rst(rst),
                        .cy(cy[3]),
                        .TIME_SEG_UNIT(time_data[15-:4])
                );
        TIME_SEG_UNIT
                #(
                        .target_cy_num(4'h3),
                        .target_cy_count(4'd2)
                )
                hour_l
                (
                        .clk(cy_controller[2]),
                        .rst(rst),
                        .cy(cy[4]),
                        .TIME_SEG_UNIT(time_data[19-:4])
                );
        TIME_SEG_UNIT
                #(
                        .target_cy_num(4'h2)
                )
                hour_h
                (
                        .clk(cy[4]),
                        .rst(rst),
                        .TIME_SEG_UNIT(time_data[23-:4])
                );
endmodule

module TIME_SEG_UNIT
        #(
                parameter [3:0] target_cy_count = 4'd0,
                parameter [3:0] target_cy_num = 4'h9
        )
        (
                input clk,
                input rst,
                output reg cy,
                output reg [3:0] TIME_SEG_UNIT
        );

        wire [3:0] time_next;
        wire [3:0] cy_count_next;
        wire cy_is_enough;
        wire [3:0] target_max;
        reg [3:0] cy_count;

        initial begin
                cy_count <= 4'd0;
                TIME_SEG_UNIT <= 4'h0;
                cy <= 1'b0;
        end

        assign cy_is_enough = (cy_count == target_cy_count) ? 1'b1 : 1'b0;
        assign target_max = cy_is_enough ? target_cy_num : 4'h9;
        assign cy_count_next = cy_is_enough ? 4'd0 : cy_count + 4'd1;
        assign time_next = (TIME_SEG_UNIT == target_max) ? 4'b0 : TIME_SEG_UNIT + 4'b1;

        always @(posedge clk or negedge rst) begin
                if (rst == 1'b0) begin
                        TIME_SEG_UNIT <= 4'h0;
                        cy <= 1'b0;
                end else begin
                        TIME_SEG_UNIT <= time_next;
                        cy <= (time_next == 4'b0) ? 1'b1 : 1'b0;
                end
        end

        always @(posedge cy or negedge rst) begin
                if (rst == 1'b0) begin
                        cy_count <= 4'd0;
                end else begin
                        cy_count <= cy_count_next;
                end
        end
endmodule

module TIMER
        #(
                parameter [31:0] cycle,
                parameter [31:0] rel = 32'd0
        )
        (
                input clk,
                input rst,
                output reg cy
        );
        reg [31:0] timer;

        initial begin
                timer <= rel;
                cy <= 1'b0;
        end

        always @(posedge clk or negedge rst) begin
                if (rst == 1'b0) begin
                        timer <= rel;
                        cy <= 1'b0;
                end else begin
                        if (timer == (cycle - 32'd1)) begin
                                timer <= 32'b0;
                                cy <= 1'b1;
                        end else begin
                                timer <= timer + 32'd1;
                                cy <= 1'b0;
                        end
                end
        end
endmodule

module BEEP_CONTROLLER
        (
                input clk,
                input rst,
                input beep,
                output reg beep_port
        );
        initial begin
                beep_port <= 1'b1;
        end

        always @(posedge clk or negedge rst) begin
                if (rst == 1'b0) begin
                        beep_port <= 1'b1;
                end else if (beep == 1'b1) begin
                        beep_port <= ~beep_port;
                end else begin
                        beep_port <= 1'b1;
                end
        end
endmodule

module SEG_DECODER
        (
                input [3:0] bin_data,
                input dot,
                output reg [7:0] seg_data
        );

        initial begin
                seg_data <= 7'b111_1111;
        end

        always @(bin_data or dot) begin
	        case(bin_data)
	        4'd0:seg_data <= 7'b100_0000;
	        4'd1:seg_data <= 7'b111_1001;
	        4'd2:seg_data <= 7'b010_0100;
	        4'd3:seg_data <= 7'b011_0000;
	        4'd4:seg_data <= 7'b001_1001;
	        4'd5:seg_data <= 7'b001_0010;
	        4'd6:seg_data <= 7'b000_0010;
	        4'd7:seg_data <= 7'b111_1000;
	        4'd8:seg_data <= 7'b000_0000;
	        4'd9:seg_data <= 7'b001_0000;
	        4'ha:seg_data <= 7'b000_1000;
	        4'hb:seg_data <= 7'b000_0011;
	        4'hc:seg_data <= 7'b100_0110;
	        4'hd:seg_data <= 7'b010_0001;
	        4'he:seg_data <= 7'b000_0110;
	        4'hf:seg_data <= 7'b000_1110;
	        default:seg_data <= 7'b111_1111;
	        endcase
                seg_data[7] <= ~dot;
        end
endmodule

module SEG_SCAN
        (
	        input clk,
                input rst,
	        output reg [5:0] seg_sel,
	        output reg [7:0] seg_data,
	        input [7:0] seg_data_0,
	        input [7:0] seg_data_1,
	        input [7:0] seg_data_2,
	        input [7:0] seg_data_3,
	        input [7:0] seg_data_4,
	        input [7:0] seg_data_5
        );

        wire clk_833us;
        reg [3:0] scan_sel;

        TIMER #(.cycle(32'd41_667)) timer_833us (.clk(clk), .rst(rst), .cy(clk_833us));

        initial begin
                scan_sel <= 4'd0;
		seg_sel <= 6'b11_1111;
		seg_data <= 8'hff;
        end

        always @(posedge clk_833us or negedge rst) begin
                if (rst == 1'b0) begin
                        scan_sel <= 4'd0;
                end else begin
		        if (scan_sel == 4'd5) begin
		                scan_sel <= 4'd0;
		        end else begin
		                scan_sel <= scan_sel + 4'd1;
	                end
                end
        end

        always @(posedge clk_833us or negedge rst) begin
                if (rst == 1'b0) begin
		        seg_sel <= 6'b11_1111;
		        seg_data <= 8'hff;
                end else begin
	                case(scan_sel)
		        4'd0: begin
		        	seg_sel <= 6'b11_1110;
		        	seg_data <= seg_data_0;
		        end
		        4'd1: begin
		        	seg_sel <= 6'b11_1101;
		        	seg_data <= seg_data_1;
		        end
		        4'd2: begin
		        	seg_sel <= 6'b11_1011;
		        	seg_data <= seg_data_2;
		        end
		        4'd3: begin
		        	seg_sel <= 6'b11_0111;
		        	seg_data <= seg_data_3;
		        end
		        4'd4: begin
		        	seg_sel <= 6'b10_1111;
		        	seg_data <= seg_data_4;
		        end
		        4'd5: begin
		        	seg_sel <= 6'b01_1111;
		        	seg_data <= seg_data_5;
		        end
		        default: begin
		        	seg_sel <= 6'b11_1111;
		        	seg_data <= 8'hff;
		        end
	                endcase
                end
        end
endmodule

module AX_DEBOUNCE 
        (
                input clk,
                input rst,
                input button_in,
                output reg button_posedge,
                output reg button_negedge,
                output reg button_out
        );
        parameter N = 32 ;           // debounce timer bitwidth
        parameter FREQ = 50;         // model clock :Mhz
        parameter MAX_TIME = 20;     // ms
        localparam TIMER_MAX_VAL =   MAX_TIME * 1000 * FREQ;
        reg [N-1 : 0] q_reg;         // timing regs
        reg [N-1 : 0] q_next;
        reg DFF1, DFF2;              // input flip-flops
        wire q_add;                  // control flags
        wire q_reset;
        reg button_out_d0;

        // contenious assignment for counter control
        assign q_reset = (DFF1  ^ DFF2);          // xor input flip flops to look for level chage to reset counter
        assign q_add = ~(q_reg == TIMER_MAX_VAL); // add to counter when q_reg msb is equal to 0
    
        // combo counter to manage q_next 
        always @(q_reset, q_add, q_reg) begin
                case({q_reset , q_add})
                2'b00:
                        q_next <= q_reg;
                2'b01:
                        q_next <= q_reg + 1;
                default:
                        q_next <= { N {1'b0} };
                endcase
        end

        // Flip flop inputs and q_reg update
        always @(posedge clk or negedge rst) begin
                if (rst == 1'b0) begin
                        DFF1 <= 1'b0;
                        DFF2 <= 1'b0;
                        q_reg <= { N {1'b0} };
                end else begin
                        DFF1 <= button_in;
                        DFF2 <= DFF1;
                        q_reg <= q_next;
                end
        end

        // counter control
        always @(posedge clk or negedge rst) begin
	        if (rst == 1'b0)
		        button_out <= 1'b1;
                else if (q_reg == TIMER_MAX_VAL)
                        button_out <= DFF2;
                else
                        button_out <= button_out;
                end

        always @(posedge clk or negedge rst) begin
	        if (rst == 1'b0) begin
		        button_out_d0 <= 1'b1;
		        button_posedge <= 1'b0;
		        button_negedge <= 1'b0;
	        end else begin
		        button_out_d0 <= button_out;
		        button_posedge <= ~button_out_d0 & button_out;
		        button_negedge <= button_out_d0 & ~button_out;
	        end
        end
endmodule
