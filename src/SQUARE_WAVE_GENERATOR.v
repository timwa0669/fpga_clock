module SQUARE_WAVE_GENERATOR
        #(
                parameter [31:0] cycle                  // 分频次数
        )
        (
                input clk,
                input rst,
                output reg sw                           // 输出方波信号
        );
        
        wire clk_target;

        localparam [31:0] target_cycle = cycle >> 1;    // 半周期翻转脉冲信号源

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
