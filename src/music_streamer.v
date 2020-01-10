`define TEMPO_DIFF 23'd100_000

module music_streamer (
    input clk,
    input rst,
    input tempo_up,
    input tempo_down,
    input play_pause,
    input reverse,
    output [2:0] leds,
    output [23:0] tone
);

        
    reg [9:0] addr;
    wire [23:0] read_data;
    wire [9:0] last_addr;
    reg [22:0] clk_counter;
    wire output_enable;   
    reg [22:0] tempo = 23'd5_000_000;
        
// State encoding
    localparam  REGULAR_PLAY = 2'd0,
                PAUSED = 2'd1,
                REVERSE_PLAY = 2'd2,
                STATE_3_PlaceHolder = 2'd3;

//State reg Declarations
    reg [1:0] CurrentState;
    reg [1:0] NextState;
    
//Outputs
    assign tone = (output_enable == 1'b0)? 1'b0 : read_data;
    //leds[0] = regular play; leds[1] = paused; leds[2] = reverse play
    assign leds = (CurrentState == REGULAR_PLAY) | (CurrentState == PAUSED) << 1 | (CurrentState == REVERSE_PLAY) << 2;
    //only output when state is regular or reverse play
    assign output_enable = (CurrentState == REGULAR_PLAY | CurrentState == REVERSE_PLAY);
    
    //sequential statements for addr
    always@(posedge clk) begin       
        if (rst) addr <= 1'b0;
        else case (CurrentState)
                REGULAR_PLAY: begin
                    if (clk_counter == tempo) begin
                        if (addr < last_addr)
                            addr <= addr + 1'b1;
                        else
                            addr <= 1'b0;
                    end
                end
                PAUSED: begin
                    addr <= addr;
                end
                REVERSE_PLAY: begin
                    if (clk_counter == tempo) begin
                        if (addr > 1'b0)
                            addr <= addr - 1'b1;
                        else
                            addr <= last_addr;
                    end                
                end
            endcase
    end    
    
//Synchronous State-Transition always@(posedge Clock) block
    always@(posedge clk) begin
        if (rst) CurrentState <= REGULAR_PLAY;
        else CurrentState <= NextState;
    end    
    
//Conditional State-Transition always@(*) block
    always@(*) begin
        NextState = CurrentState;
        case (CurrentState)
            REGULAR_PLAY: begin
                if (play_pause) NextState = PAUSED;
                else if (reverse) NextState = REVERSE_PLAY;
            end
            PAUSED: begin
                if (play_pause) NextState = REGULAR_PLAY;
            end
            REVERSE_PLAY: begin
                if (reverse) NextState = REGULAR_PLAY;
                else if (play_pause) NextState = PAUSED;
            end
            STATE_3_PlaceHolder: begin
                NextState = REGULAR_PLAY;
            end
        endcase
    end

    
    // Instantiate the ROM here
    rom music_data(
        .address(addr),
        .data(read_data),
        .last_address(last_addr)
    );
    
    always @(posedge clk) begin
        if (rst) clk_counter <= 1'b0;
        else if (clk_counter == tempo) clk_counter <= 1'b0;
        else clk_counter <= clk_counter + 1'b1;
    end
    
    always @(posedge clk) begin
        if (rst) tempo <= 23'd5_000_000; //default tempo is 1/25th second per note
        else if (tempo_up) tempo <= tempo - `TEMPO_DIFF;
        else if (tempo_down) tempo <= tempo + `TEMPO_DIFF;
        else tempo <= tempo;       
    end
    
endmodule
