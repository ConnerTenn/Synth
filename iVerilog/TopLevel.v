

module TopLevel(
    Clock,
    Reset,
    Waveform,
    WaveType
);
    parameter WAVE_DEPTH=8;
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input [1:0] WaveType;
    output [WAVE_HIGH_BIT:0] Waveform;

    WaveGen 
    #(
        .WAVE_DEPTH(WAVE_DEPTH)
    ) 
    waveGen1
    (
        .Clock(Clock),
        .Reset(Reset),
        .Incr(8'h0F),
        .WaveType(WaveType),
        .Waveform(Waveform)
    );
    
endmodule