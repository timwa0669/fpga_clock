module TIMER                                    // 分频器
        #(
                parameter [31:0] cycle,         // 分频次数
                parameter [31:0] rel = 32'd0    // 初始分频偏移数
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
