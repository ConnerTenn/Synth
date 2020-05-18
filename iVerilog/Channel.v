

module Channel
#(
    parameter ADDR=0
) 
(
    Clock,
    Reset,
    BusAddress, BusData, BusReadWrite, BusClock,
    Waveform
);
    parameter WAVE_MAX = 24'hFFFFFF;


    input Clock, Reset;
    input [15:0] BusAddress; inout [7:0] BusData; input BusReadWrite; input BusClock;
    output [23:0] Waveform;
    
    reg [15:0] addr = ADDR;

    wire [23:0] wavegenout;
    wire [23:0] envelope;
    wire [47:0] mul;

    assign mul = (wavegenout * envelope);
    assign Waveform = (mul>>24) + ((WAVE_MAX/2) - (envelope>>1));


    reg gate = 0;
    wire running;
    reg [23:0] incr = 0;
    reg [1:0] wavetype = 0;
    reg [23:0] pulsewidth = 0;
    reg linear = 0;
    wire [1:0] adsrstate;
    reg [23:0] attack = 0, decay = 0, sustain = 0, releasew = 0;


    WaveGen wavegen (
        .Clock(Clock),
        .Reset(Reset),
        .Run(running),
        .Incr(incr),
        .WaveType(wavetype),//.WaveType((WaveType+gi)%3),
        .PulseWidth(pulsewidth),
        .Waveform(wavegenout)
    );

    ADSR adsr (
        .Clock(Clock),
        .Reset(Reset),
        .Gate(gate),
        .Running(running),
        .Linear(linear),
        .ADSRstate(adsrstate),
        .Attack(attack), .Decay(decay), .Sustain(sustain), .Release(releasew),
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
                    // ADDR+0: busdata <= {7'h00,running};
                    // ADDR+1: busdata <= incr;
                    // ADDR+2: busdata <= {6'h00,wavetype};
                    // ADDR+3: busdata <= pulsewidth;
                    // ADDR+4: busdata <= attack;
                    // ADDR+5: busdata <= decay;
                    // ADDR+6: busdata <= sustain;
                    // ADDR+7: busdata <= releasew;
                    // ADDR+8: busdata <= {7'h00,linear};
                    // ADDR+9: busdata <= {6'h00,adsrstate};
                    default: busdata <= 8'hZZ;
                endcase
            end
            else //Write
            begin
                case(BusAddress) 
                    ADDR+16'h00: gate <= BusData[0:0]; 

                    ADDR+16'h01: incr[7:0] <= BusData;
                    ADDR+16'h02: incr[15:8] <= BusData;
                    ADDR+16'h03: incr[23:16] <= BusData;

                    ADDR+16'h04: wavetype <= BusData[1:0];

                    ADDR+16'h05: pulsewidth[7:0] <= BusData;
                    ADDR+16'h06: pulsewidth[15:8] <= BusData;
                    ADDR+16'h07: pulsewidth[23:16] <= BusData;

                    ADDR+16'h08: attack[7:0] <= BusData;
                    ADDR+16'h09: attack[15:8] <= BusData;
                    ADDR+16'h0A: attack[23:16] <= BusData;

                    ADDR+16'h0B: decay[7:0] <= BusData;
                    ADDR+16'h0C: decay[15:8] <= BusData;
                    ADDR+16'h0D: decay[23:16] <= BusData;

                    ADDR+16'h0E: sustain[7:0] <= BusData;
                    ADDR+16'h0F: sustain[15:8] <= BusData;
                    ADDR+16'h10: sustain[23:16] <= BusData;

                    ADDR+16'h11: releasew[7:0] <= BusData;
                    ADDR+16'h12: releasew[15:8] <= BusData;
                    ADDR+16'h13: releasew[23:16] <= BusData;

                    ADDR+'h14: linear <= BusData[0:0];
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

