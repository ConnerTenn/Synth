

module Channel
#(
    parameter WAVE_DEPTH=8,
    parameter ADDR=0
) 
(
    Clock,
    Reset,
    BusAddress, BusData, BusReadWrite, BusClock,
    Waveform
);
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;


    input Clock, Reset;
    input [15:0] BusAddress; inout [7:0] BusData; input BusReadWrite; input BusClock;
    output [WAVE_DEPTH-1:0] Waveform;


    wire [WAVE_DEPTH-1:0] wavegenout;
    wire [WAVE_DEPTH-1:0] envelope;
    wire [2*WAVE_DEPTH-1:0] mul;

    assign mul = (wavegenout * envelope);
    assign Waveform = (mul>>8) + ((WAVE_MAX/2) - (envelope>>1));


    reg gate = 0;
    wire run = 0;
    reg [WAVE_DEPTH-1:0] incr = 0;
    reg [1:0] wavetype = 0;
    reg [WAVE_DEPTH-1:0] pulsewidth = 0;
    reg [WAVE_DEPTH-1:0] sustain = 0;
    reg linear = 0;


    WaveGen #( .WAVE_DEPTH(WAVE_DEPTH) ) wavegen
    (
        .Clock(Clock),
        .Reset(Reset),
        .Run(running),
        .Incr(incr),
        .WaveType(wavetype),//.WaveType((WaveType+gi)%3),
        .PulseWidth(pulsewidth),
        .Waveform(wavegenout)
    );

    ADSR #( .WAVE_DEPTH(WAVE_DEPTH) ) adsr
    (
        .Clock(Clock),
        .Reset(Reset),
        .Gate(gate),
        .Running(running),
        .Sustain(sustain),
        .Linear(linear),
        .Envelope(envelope)
    );


    
    reg [7:0] busdata = 0;

    assign BusData = BusReadWrite ? 8'hZZ : busdata;

    always @(posedge BusClock)
    begin
        if (Reset == 0)
        begin
            if (BusReadWrite==0) //Read
            begin
                case(BusAddress)
                    ADDR+0: busdata <= {7'h00,run};
                    ADDR+1: busdata <= incr;
                    ADDR+2: busdata <= {6'h00,wavetype};
                    ADDR+3: busdata <= pulsewidth;
                    ADDR+4: busdata <= sustain;
                    ADDR+5: busdata <= {7'h00,linear};
                    default: busdata <= 8'hZZ;
                endcase
            end
            else //Write
            begin
                case(BusAddress) 
                    ADDR+0: gate <= BusData[0:0]; 
                    ADDR+1: incr <= BusData;
                    ADDR+2: wavetype <= BusData[1:0];
                    ADDR+3: pulsewidth <= BusData;
                    ADDR+4: sustain <= BusData;
                    ADDR+5: linear <= BusData[0:0];
                endcase
            end
        end
    end


     always @(Reset)
    begin
        if (Reset == 1)
        begin
            gate = 0;
            incr = 0;
            wavetype = 0;
            pulsewidth = 0;
            busdata = 0;
            sustain = 0;
        end
    end


endmodule

