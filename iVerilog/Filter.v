

module Filter(
    Clock, 
    Reset,
    WaveIn, WaveOut
);

    parameter FILTER_DEPTH = 48000*8;

    input Clock, Reset;
    input [23:0] WaveIn;
    output [23:0] WaveOut;


    
endmodule