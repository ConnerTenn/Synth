

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

    wire [WAVE_HIGH_BIT:0] counterHalfShifted;
    wire [WAVE_HIGH_BIT:0] counterQuarterShifted;
    wire [WAVE_HIGH_BIT:0] counterPulseShifted;

    assign counterHalfShifted = counter+(WAVE_MAX>>1);
    assign counterQuarterShifted = counter+(WAVE_MAX>>2);
    //Ranges from  WAVE_MAX/4 When PulseWidth is near minimum, to WAVE_MAX/2 when PulseWidth is half maximum, to WAVE_MAX/4 when PulseWidth is at maximum
    assign counterPulseShifted = counter+(PulseWidth>(WAVE_MAX>>1) ? 8'd127*PulseWidth/WAVE_MAX : 8'd127*(WAVE_MAX-PulseWidth)/WAVE_MAX);

    assign Waveform = WaveTypeSelect(counterHalfShifted, counterQuarterShifted, counterPulseShifted, Reset?2'b00:WaveType, PulseWidth);
    function [7:0] WaveTypeSelect(
        input [WAVE_HIGH_BIT:0] countHalfShft,
        input [WAVE_HIGH_BIT:0] countQuartShft,
        input [WAVE_HIGH_BIT:0] countPulseShft,
        input [1:0] wavetype,
        input [WAVE_HIGH_BIT:0] pw
    );
        case(wavetype)
            //Sawtooth
            2'b00 : WaveTypeSelect = countHalfShft;
            //Square
            2'b01 : WaveTypeSelect = (countHalfShft>=(WAVE_MAX>>1) ? WAVE_MAX : 0);
            //Triangle
            2'b10 : WaveTypeSelect = (countQuartShft<=(WAVE_MAX>>1) ? countQuartShft : (WAVE_MAX-countQuartShft))<<1;// + (WAVE_MAX>>2);
            //Advanced Triangle
            2'b11 : WaveTypeSelect = (countPulseShft<=pw ? 
                    ((WAVE_MAX*countPulseShft)/pw) : // (1/scaling) * x for upwards line
                    (WAVE_MAX*(WAVE_MAX-countPulseShft)/(WAVE_MAX-pw)) // (1/(1-scaling) * x) for downwards line
                    );
            //Sample
            // 2'b11 : WaveTypeSelect = 0; //TODO: Implement
            //Catch all
            default : WaveTypeSelect = 2'bZ;
        endcase
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