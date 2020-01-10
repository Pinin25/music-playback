`timescale 1ns/1ns

module z1top #(
    parameter CLOCK_FREQ = 125_000_000,
    /* verilator lint_off REALCVT */
    // Sample the button signal every 500us
    parameter integer B_SAMPLE_COUNT_MAX = 0.0005 * CLOCK_FREQ,
    // The button is considered 'pressed' after 100ms of continuous pressing
    parameter integer B_PULSE_COUNT_MAX = 0.100 / 0.0005
    /* lint_on */
) (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    output aud_pwm,
    output aud_sd
);
    //assign LEDS[5:0] = 6'b11_0001;
    assign aud_sd = 1; // Enable the audio output

    wire [3:0] buttons_pressed;
    wire reset;
    wire [23:0] tone_to_play;
    wire tempo_up;
    wire tempo_down;
    wire pause_button;
    wire reverse_button;
    
    assign reset = buttons_pressed[0];
    assign tempo_up = SWITCHES[1] & buttons_pressed[1];
    assign tempo_down = (~SWITCHES[1]) & buttons_pressed[1];
    assign pause_button = buttons_pressed[2];
    assign reverse_button = buttons_pressed[3];
    
    button_parser #(
        .width(4),
        .sample_count_max(B_SAMPLE_COUNT_MAX),
        .pulse_count_max(B_PULSE_COUNT_MAX)
    ) bp (
        .clk(CLK_125MHZ_FPGA),
        .in(BUTTONS),
        .out(buttons_pressed)
    );

    //// TODO: Instantiate the tone_generator and music_streamer here from lab 4
    //assign aud_pwm = 0; // Comment this out when ready

    tone_generator tg(
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .output_enable(SWITCHES[0]),
        .tone_switch_period(tone_to_play),
        .volume(1'b0),
        .square_wave_out(aud_pwm)
    );

    music_streamer streamer(
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .tempo_up(tempo_up),
        .tempo_down(tempo_down),
        .play_pause(pause_button),
        .reverse(reverse_button),
        .leds(LEDS[2:0]),
        .tone(tone_to_play)
    );
   
endmodule
