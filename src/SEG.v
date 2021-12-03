module FLASH_SEG
        (
                input flash_clk,
                input flash,
                input [7:0] time_seg_data_in,
                output [7:0] time_seg_data_out
        );

        assign time_seg_data_out = flash_clk & flash ? { 8{flash_clk} } : time_seg_data_in;
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
