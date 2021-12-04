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
                        .time_data(time_data[3-:4])
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
                        .time_data(time_data[7-:4])
                );
        TIME_SEG_UNIT
                minute_l
                (
                        .clk(cy_controller[1]),
                        .rst(rst),
                        .cy(cy[2]),
                        .time_data(time_data[11-:4])
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
                        .time_data(time_data[15-:4])
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
                        .time_data(time_data[19-:4])
                );
        TIME_SEG_UNIT
                #(
                        .target_cy_num(4'h2)
                )
                hour_h
                (
                        .clk(cy[4]),
                        .rst(rst),
                        .time_data(time_data[23-:4])
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
                output reg [3:0] time_data
        );

        wire [3:0] time_next;
        wire [3:0] cy_count_next;
        wire cy_is_enough;
        wire [3:0] target_max;
        reg [3:0] cy_count;

        initial begin
                cy_count <= 4'd0;
                time_data <= 4'h0;
                cy <= 1'b0;
        end

        assign cy_is_enough = (cy_count == target_cy_count) ? 1'b1 : 1'b0;
        assign target_max = cy_is_enough ? target_cy_num : 4'h9;
        assign cy_count_next = cy_is_enough ? 4'd0 : cy_count + 4'd1;
        assign time_next = (time_data == target_max) ? 4'b0 : time_data + 4'b1;

        always @(posedge clk or negedge rst) begin
                if (rst == 1'b0) begin
                        time_data <= 4'h0;
                        cy <= 1'b0;
                end else begin
                        time_data <= time_next;
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
