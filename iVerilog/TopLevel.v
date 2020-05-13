

module TopLevel(
    Clock,
    Value
    Waveform
);
    parameter WAVE_DEPTH=8;
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock;
    output [7:0] Value;
    output [WAVE_HIGH_BIT:0] Waveform;

    WaveGen 
    #(
        .WAVE_DEPTH(WAVE_DEPTH)
    ) 
    waveGen1
    (
        .Clock(Clock),
        .Frequency(8'h0F),
        .WaveType (2'b10),
        .Waveform(Waveform)
    );
    
endmodule