



module WaveGen 
#(
    parameter WAVE_DEPTH=8
) 
(
    Clock,
    Reset,
    GateOpen, GateClose,
    Incr,
    WaveType,
    PulseWidth,
    Waveform
);
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input GateOpen, GateClose;
    input [WAVE_HIGH_BIT:0] Incr;
    input [1:0] WaveType;
    input [WAVE_HIGH_BIT:0] PulseWidth;
    output [WAVE_HIGH_BIT:0] Waveform;

    reg [WAVE_HIGH_BIT:0] counter = 0;
    reg Gate = 0;

    assign Waveform = WaveTypeSelect(Reset, Gate, WaveType, counter, PulseWidth);
    function automatic [7:0] WaveTypeSelect(
        input reset, gate,
        input [1:0] wavetype,
        input [WAVE_HIGH_BIT:0] cntr,
        input [WAVE_HIGH_BIT:0] pulsewidth
    );
        if (reset==1 || gate == 0)
        begin
            WaveTypeSelect = cntr+(WAVE_MAX>>1);
        end
        else
        begin
            case(wavetype)
                //Raw
                2'b00 : WaveTypeSelect = cntr;
                //Square
                2'b01 : WaveTypeSelect = (cntr>=pulsewidth ? WAVE_MAX : 0);
                //Advanced Triangle (Sawtooth)
                2'b10 : WaveTypeSelect = 
                    (cntr<=pulsewidth ? 
                    ((WAVE_MAX*cntr)/pulsewidth) : // (1/scaling) * x for upwards line
                    (WAVE_MAX*(WAVE_MAX-cntr)/(WAVE_MAX-pulsewidth))); // (1/(1-scaling) * x) for downwards line
                //Sample
                2'b11 : WaveTypeSelect = 0; //TODO: Implement
                //Catch all
                default : WaveTypeSelect = 2'bZ;
            endcase
        end
    endfunction



    always @(posedge Clock or Reset)
    begin
        if (GateClose==1)
        begin
            Gate = 0;
        end
        else if (GateOpen==1)
        begin
            Gate = 1;
        end

        if (Reset==1 || Gate==0) 
        begin
            //Reset counter to midpoint value
            counter <= 0;
        end
        else 
        begin
            //If counter will overflow on this itteration
            if (counter + Incr >= WAVE_MAX)
            begin
                //Reset counter back to bottom
                counter <= 8'h00;
            end
            else
            begin
                //Increment counter by Incr
                counter <= counter + Incr;
            end
        end
    end

endmodule