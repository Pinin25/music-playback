module synchronizer #(parameter width = 1) (
    input [width-1:0] async_signal,
    input clk,
    output [width-1:0] sync_signal
);
    // Create your 2 flip-flop synchronizer here
    // This module takes in a vector of 1-bit asynchronous (from different clock domain or not clocked) signals
    // and should output a vector of 1-bit synchronous signals that are synchronized to the input clk
    reg [width-1:0] int_signal, int_signal2;
    
    always @(posedge clk) begin
        int_signal <= async_signal;
        int_signal2 <= int_signal;
    end
    
    // Remove this line once you create your synchronizer
    assign sync_signal = int_signal2;
endmodule
