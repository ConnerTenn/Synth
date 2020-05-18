

module TopLevel(
    Clock,
    Reset,
    BusAddress, BusData, BusReadWrite, BusClock,
    Waveform
);
    parameter WAVE_MAX = 24'hFFFFFF;

    parameter NUM_WAVEFORM_GENS=2;

    input Clock, Reset;
    input [15:0] BusAddress; inout [7:0] BusData; input BusReadWrite; input BusClock;
    output [23:0] Waveform;


    reg [23:0] pulseWidth = 8'h00;

    //Generate loop to automatically hook up multiple waveform generators
    genvar gi;
    for (gi=0; gi<NUM_WAVEFORM_GENS; gi=gi+1) 
    begin:channels

        wire [23:0] wavesig;
        wire [24*NUM_WAVEFORM_GENS-1:0] wavesum;

        //Connect each wavegen block
        
        Channel #(.ADDR(16'h0010 + 16'h0020*gi)) channel
        (
            .Clock(Clock),
            .Reset(Reset),
            .BusAddress(BusAddress), .BusData(BusData), .BusReadWrite(BusReadWrite), .BusClock(BusClock),
            .Waveform(wavesig)
        );

        if (gi == 0)
        begin
            //First wavegen sum is equal to itself; no previous channels
            assign wavesum = wavesig;
        end
        else if (gi > 0)
        begin
            //All other channels must add the previous wavegen to itself
            assign wavesum = wavesig + channels[gi-1].wavesum;
        end
    end


    //Rescale for 8 bit output
    assign Waveform = (channels[NUM_WAVEFORM_GENS-1].wavesum >> (NUM_WAVEFORM_GENS-1));//+(WAVE_MAX>>(NUM_WAVEFORM_GENS-1));




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