module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = $clog2(sample_count_max),
    parameter saturating_counter_width = $clog2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);
    reg [wrapping_counter_width-1:0] wrapping_counter = 0;
    reg [saturating_counter_width-1:0] saturating_counter [width-1:0];
    reg sample_pulse = 0;
    wire [width-1:0] saturating_counter_enable;
    wire [width-1:0] reset;
    reg [width-1:0] switchOut = 0;
    
    //Initialize 2D register counters
    integer k;
    initial begin
        for (k = 0; k < width; k = k + 1) begin
            saturating_counter[k] = 0;
        end
    end
    
    // Create your debouncer circuit
    // The debouncer takes in a bus of 1-bit synchronized, but glitchy signals
    // and should output a bus of 1-bit signals that hold high when their respective counter saturates
    always @(posedge clk) begin
            if (wrapping_counter == sample_count_max) begin
                wrapping_counter <= 0;
                sample_pulse <= 1;
            end else begin
                wrapping_counter <= wrapping_counter + 1;
                sample_pulse <= 0;
            end
    end

    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:DEBOUNCER
            assign saturating_counter_enable[i] = sample_pulse & glitchy_signal[i];
            assign reset[i] = ~glitchy_signal[i];
            
            always @(posedge clk) begin
                if (reset[i] == 1) begin
                    saturating_counter[i] <= 0;
                    switchOut[i] <= 0;
                end else if (saturating_counter[i] == pulse_count_max) begin
                    saturating_counter[i] <= 0;
                    switchOut[i] <= 1; //output stay high once counter's saturated
                end else if (saturating_counter_enable[i] == 1) begin
                    saturating_counter[i] <= saturating_counter[i] + 1;
                end
            end
        end
    endgenerate
        
    assign debounced_signal = switchOut;
endmodule
