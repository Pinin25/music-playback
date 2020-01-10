`timescale 1ns/1ns
module tone_generator (
    input clk,
    input rst,
    input output_enable,
    input [23:0] tone_switch_period,
    input volume,
    output square_wave_out
);

    reg [23:0] clk_counter;
    reg square_wave = 1'b0;
    wire duty_cycle;
    
    always @(posedge clk) begin
        if (rst) begin
            clk_counter <= 1'b0;
            square_wave <= 1'b0;
        end else if (tone_switch_period == 1'b0) begin
            square_wave <= 1'b0;
        end else if (clk_counter == tone_switch_period) begin
            clk_counter <= 1'b0;
            square_wave <= ~square_wave;
        end else begin
            clk_counter <= clk_counter + 1'b1;
            square_wave <= square_wave;
        end
    end
        
    //volume = 0, duty_cycle = 25%
    //volume = 1, duty_cycle = 50%
    assign duty_cycle = (volume == 1'b0)? (clk_counter[0] & clk_counter[1]) : (clk_counter[0]);
    
    assign square_wave_out = (output_enable == 0)? 1'b0: (square_wave & duty_cycle);
endmodule
