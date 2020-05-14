

module TopLevel(
    Clock,
    Reset,
    Waveform,
    WaveType
);
    parameter WAVE_DEPTH=8;
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    parameter NUM_WAVEFORM_GENS=2;

    input Clock, Reset;
    input [1:0] WaveType;
    output [WAVE_HIGH_BIT:0] Waveform;

    // wire [WAVE_HIGH_BIT:0] wavesigs [NUM_WAVEFORM_GENS-1:0];

    reg [WAVE_HIGH_BIT:0] pulseWidth = 8'h00;

    //Generate loop to automatically hook up multiple waveform generators
    genvar gi;
    for (gi=0; gi<NUM_WAVEFORM_GENS; gi=gi+1) 
    begin:wavegens

        wire [WAVE_HIGH_BIT:0] wavesig;
        wire [WAVE_HIGH_BIT*NUM_WAVEFORM_GENS:0] wavesum;

        //Connect each wavegen block
        WaveGen #( .WAVE_DEPTH(WAVE_DEPTH) ) 
        waveGenn
        (
            .Clock(Clock),
            .Reset(Reset),
            .Incr(8'h0F),
            .WaveType(gi?2'b11:WaveType),//.WaveType((WaveType+gi)%3),
            .PulseWidth(pulseWidth),
            .Waveform(wavesig)
        );

        if (gi == 0)
        begin
            //First wavegen sum is equal to itself; no previous wavegens
            assign wavesum = wavesig;
        end
        else if (gi > 0)
        begin
            //All other wavegens must add the previous wavegen to itself
            assign wavesum = wavesig + wavegens[gi-1].wavesum;
        end
    end

    //Rescale for 8 bit output
    assign Waveform = (wavegens[NUM_WAVEFORM_GENS-1].wavesum >> (NUM_WAVEFORM_GENS-1));//+(WAVE_MAX>>(NUM_WAVEFORM_GENS-1));

    reg pulsedir = 0;
    always @(posedge Clock)
    begin
        if ((pulsedir==0 && pulseWidth==WAVE_MAX-1) || (pulsedir==1 && pulseWidth==1))
        begin
            pulsedir <= ~pulsedir;
        end
        if (pulsedir==0)
        begin
            pulseWidth <= pulseWidth+1;
        end
        else
        begin
            pulseWidth <= pulseWidth-1;
        end
    end

endmodule