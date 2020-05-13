

module TopLevel(
    Clock,
    Value
);
    input Clock;
    output [7:0] Value;

    WaveGen waveGen1(
        .Clock(Clock),
        .Frequency(8'h0F),
        .WaveType (),
        .Waveform(Value)
    );
    
endmodule