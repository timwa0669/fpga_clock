module BEEP_CONTROLLER
        (
                input clk,
                input rst,
                input beep,             // 响铃触发信号
                input beep_enabled,     // 响铃总开关
                output reg beep_port    // 蜂鸣器输出端口
        );

        reg beep_latch;                 // 响铃触发信号锁存器
        wire beep_latch_next;

        assign beep_latch_next = beep | beep_latch;

        initial begin
                beep_port <= 1'b1;
                beep_latch <= 1'b0;
        end

        always @(posedge clk or negedge rst) begin
                if (rst == 0) begin
                        beep_port <= 1'b1;
                end else if (beep_enabled == 1'b0) begin
                        beep_port <= 1'b1;
                end else if (beep_latch == 1'b0) begin
                        beep_port <= 1'b1;
                end else begin
                        beep_port <= ~beep_port;
                end
        end

        always @(posedge clk or negedge rst) begin
                if (rst == 0) begin
                        beep_latch <= 1'b0;
                end else if (beep_enabled == 0) begin
                        beep_latch <= 1'b0;
                end else begin
                        beep_latch <= beep_latch_next;
                end
        end

endmodule
