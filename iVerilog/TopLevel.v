

module TopLevel(
    Clock,
    Reset,
    BusAddress, BusData, BusReadWrite, BusClock,
    Waveform,
    WaveType
);
    parameter WAVE_DEPTH=8;
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    parameter NUM_WAVEFORM_GENS=2;

    input Clock, Reset;
    input [15:0] BusAddress; inout [7:0] BusData; input BusReadWrite; input BusClock;
    input [1:0] WaveType;
    output [WAVE_HIGH_BIT:0] Waveform;

    reg gateopen = 0, gateclose = 0;

    // wire [WAVE_HIGH_BIT:0] wavesigs [NUM_WAVEFORM_GENS-1:0];

    reg [WAVE_HIGH_BIT:0] pulseWidth = 8'h00;

    //Generate loop to automatically hook up multiple waveform generators
    genvar gi;
    for (gi=0; gi<NUM_WAVEFORM_GENS; gi=gi+1) 
    begin:wavegens

        wire [WAVE_HIGH_BIT:0] wavesig;
        wire [WAVE_HIGH_BIT*NUM_WAVEFORM_GENS:0] wavesum;

        //Connect each wavegen block
        WaveGen #( .WAVE_DEPTH(WAVE_DEPTH) ) waveGenn
        (
            .Clock(Clock),
            .Reset(Reset),
            .GateOpen(gateopen), .GateClose(gateclose),
            .Incr(8'h0F),
            .WaveType(gi?2'b10:WaveType),//.WaveType((WaveType+gi)%3),
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

    WaveGenController #(.WAVE_DEPTH(WAVE_DEPTH), .ADDR(16'h0010)) wavectl
    (
        .Clock(Clock),
        .Reset(Reset),
        .BusAddress(BusAddress), .BusData(BusData), .BusReadWrite(BusReadWrite), .BusClock(BusClock),
        .Waveform()
    );

    ADSR #(.WAVE_DEPTH(WAVE_DEPTH)) adsr
    (
        .Clock(Clock),
        .Reset(Reset),
        .Envolope()
    );


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


    initial 
    begin
        gateopen <= 1;
        #2;
        gateopen <= 0;

        #100;

        gateclose <= 1;
        #2;
        gateclose <= 0;

        #40;

        gateopen <= 1;
        #2;
        gateopen <= 0;

    end

endmodule