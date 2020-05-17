

module WaveGenController
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
    input Clock, Reset;
    input [15:0] BusAddress; inout [7:0] BusData; input BusReadWrite; input BusClock;
    output [WAVE_DEPTH-1:0] Waveform;

    reg [7:0] busdata = 0;

    reg gateopen = 0, gateclose = 0;
    reg [WAVE_DEPTH-1:0] incr = 0;
    reg [1:0] wavetype = 0;
    reg [WAVE_DEPTH-1:0] pulsewidth = 0;

    WaveGen #( .WAVE_DEPTH(WAVE_DEPTH) ) wavegen
    (
        .Clock(Clock),
        .Reset(Reset),
        .GateOpen(gateopen), .GateClose(gateclose),
        .Incr(incr),
        .WaveType(wavetype),//.WaveType((WaveType+gi)%3),
        .PulseWidth(pulsewidth),
        .Waveform(Waveform)
    );

    always @(posedge Clock or Reset)
    begin
        if (Reset == 1)
        begin
            gateopen = 0; gateclose = 0;
            incr = 0;
            wavetype = 0;
            pulsewidth = 0;

        end
        else
        begin
            if (gateopen==1) begin gateopen <= 0; end
            if (gateclose==1) begin gateclose <= 0; end
        end
    end

    assign BusData = BusReadWrite ? 8'hZZ : busdata;

    always @(posedge BusClock)
    begin
        if (Reset == 0)
        begin
            if (BusReadWrite==0) //Read
            begin
                case(BusAddress)
                    ADDR+0: busdata <= incr;
                    ADDR+1: busdata <= 8'h00;
                    default: busdata <= 8'hZZ;
                endcase
            end
            else //Write
            begin
                case(BusAddress) 
                    ADDR+0: incr <= BusData; 
                    ADDR+1: if (BusData==1) begin gateopen <= 1; end else begin gateclose <= 1; end
                endcase
            end
        end
    end

endmodule