

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
    wire [WAVE_HIGH_BIT:0] counterPulseShifted;

    assign counterHalfShifted = counter+(WAVE_MAX>>1);
    //Ranges from  WAVE_MAX/4 When PulseWidth is near minimum, to WAVE_MAX/2 when PulseWidth is half maximum, to WAVE_MAX/4 when PulseWidth is at maximum
    assign counterPulseShifted = counter+(PulseWidth>(WAVE_MAX>>1) ? 8'd127*PulseWidth/WAVE_MAX : 8'd127*(WAVE_MAX-PulseWidth)/WAVE_MAX);

    //Reset Behaviour
    assign Waveform = Reset==1 ? counterHalfShifted : {WAVE_DEPTH{1'bZ}};
    //Raw
    assign Waveform = (Reset==0 && WaveType==2'b00) ? (counter) : {WAVE_DEPTH{1'bZ}};
    //Square
    assign Waveform = (Reset==0 && WaveType==2'b01) ? (counterHalfShifted>=PulseWidth ? WAVE_MAX : 0) : {WAVE_DEPTH{1'bZ}};
    //Advanced Triangle (Sawtooth)
    assign Waveform = (Reset==0 && WaveType==2'b10) ?
        (counterPulseShifted<=PulseWidth ? 
        ((WAVE_MAX*counterPulseShifted)/PulseWidth) : // (1/scaling) * x for upwards line
        (WAVE_MAX*(WAVE_MAX-counterPulseShifted)/(WAVE_MAX-PulseWidth))) // (1/(1-scaling) * x) for downwards line
            : {WAVE_DEPTH{1'bZ}};
    //Unused
    assign Waveform = (Reset==0 && WaveType==2'b11) ? 0 : {WAVE_DEPTH{1'bZ}};
    

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