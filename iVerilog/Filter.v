

module Filter(
    Clock, 
    Reset,
    WaveIn, WaveOut
);

    parameter FILTER_DEPTH = 256;

    parameter SAMPLE_ADDR = 16'h0000;
    parameter FILTER_ADDR = 16'h8000;

    input Clock, Reset;
    input [23:0] WaveIn;
    output [23:0] WaveOut;


    
endmodule