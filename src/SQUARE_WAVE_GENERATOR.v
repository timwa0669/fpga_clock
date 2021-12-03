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
