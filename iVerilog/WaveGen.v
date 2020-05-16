



module WaveGen 
#(
    parameter WAVE_DEPTH=8
) 
(
    Clock,
    Reset,
    Incr,
    WaveType,
    PulseWidth,
    Waveform
);
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input [WAVE_HIGH_BIT:0] Incr;
    input [1:0] WaveType;
    input [WAVE_HIGH_BIT:0] PulseWidth;
    output [WAVE_HIGH_BIT:0] Waveform;

    reg [WAVE_HIGH_BIT:0] counter = 0;

    wire [WAVE_HIGH_BIT:0] counterHalfShifted = counter+(WAVE_MAX>>1);
    //Ranges from  WAVE_MAX/4 When PulseWidth is near minimum, to WAVE_MAX/2 when PulseWidth is half maximum, to WAVE_MAX/4 when PulseWidth is at maximum
    wire [WAVE_HIGH_BIT:0] counterPWShifted = counter+(PulseWidth>(WAVE_MAX>>1) ? 8'd127*PulseWidth/WAVE_MAX : 8'd127*(WAVE_MAX-PulseWidth)/WAVE_MAX);


    assign Waveform = WaveTypeSelect(Reset, WaveType, counter, counterHalfShifted, counterPWShifted, PulseWidth);
    function automatic [7:0] WaveTypeSelect(
        input reset,
        input [1:0] wavetype,
        input [WAVE_HIGH_BIT:0] cntr,
        input [WAVE_HIGH_BIT:0] cntrHalfShift,
        input [WAVE_HIGH_BIT:0] cntrPWShift,
        input [WAVE_HIGH_BIT:0] pulsewidth
    );
        if (reset==1)
        begin
            WaveTypeSelect = cntrHalfShift;
        end
        else
        begin
            case(wavetype)
                //Raw
                2'b00 : WaveTypeSelect = cntr;
                //Square
                2'b01 : WaveTypeSelect = (cntrHalfShift>=pulsewidth ? WAVE_MAX : 0);
                //Advanced Triangle (Sawtooth)
                2'b10 : WaveTypeSelect = 
                    (cntrPWShift<=pulsewidth ? 
                    ((WAVE_MAX*cntrPWShift)/pulsewidth) : // (1/scaling) * x for upwards line
                    (WAVE_MAX*(WAVE_MAX-cntrPWShift)/(WAVE_MAX-pulsewidth))); // (1/(1-scaling) * x) for downwards line
                //Sample
                2'b11 : WaveTypeSelect = 0; //TODO: Implement
                //Catch all
                default : WaveTypeSelect = 2'bZ;
            endcase
        end
    endfunction


    

    always @(posedge Clock or Reset)
    begin
        if (Reset==1) 
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