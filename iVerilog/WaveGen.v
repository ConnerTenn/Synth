



module WaveGen
(
    Clock,
    Reset,
    Run,
    Incr,
    WaveType,
    PulseWidth,
    Waveform
);
    parameter WAVE_MAX = 24'hFFFFFF;

    input Clock, Reset;
    input Run;
    input [23:0] Incr;
    input [1:0] WaveType;
    input [23:0] PulseWidth;
    output [23:0] Waveform;

    reg [23:0] counter = 0;
    

    assign Waveform = WaveTypeSelect(Reset, Run, WaveType, counter, PulseWidth);
    function automatic [7:0] WaveTypeSelect(
        input reset, gate,
        input [1:0] wavetype,
        input [23:0] cntr,
        input [23:0] pulsewidth
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



    always @(posedge Clock)
    begin

        if (Reset==0 && Run==1)
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

    always @(Reset or Run)
    begin
        if (Reset==1 || Run==0) 
        begin
            //Reset counter to midpoint value
            counter <= 0;
        end
    end

endmodule