


/*
TODO: Modify Counter to reset to 0, while waveform resets to MID
*/

module WaveGen 
#(
    parameter WAVE_DEPTH=8
) 
(
    Clock,
    Reset,
    Incr,
    WaveType,
    Waveform
);
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input [WAVE_HIGH_BIT:0] Incr;
    input [1:0] WaveType;
    output [WAVE_HIGH_BIT:0] Waveform;

    wire [1:0] wavesel;
    assign wavesel = Reset ? 2'b00 : WaveType; //Wavetype is set to 0 when reset

    reg [WAVE_HIGH_BIT:0] counter = WAVE_MAX/2;

    assign Waveform = WaveTypeSelect(counter, Incr, wavesel);
    function [7:0] WaveTypeSelect(input [WAVE_HIGH_BIT:0] counter, input [WAVE_HIGH_BIT:0] incr, input [1:0] wavetype);
        case(wavetype)
            //Sawtooth
            2'b00 : WaveTypeSelect = counter;
            //Square
            2'b01 : WaveTypeSelect = (counter<=(WAVE_MAX>>1) ? 8'h00 : WAVE_MAX);
            //Triangle
            2'b10 : WaveTypeSelect = (counter<=(WAVE_MAX>>1) ? counter : (WAVE_MAX-counter)+1)<<1;// + (WAVE_MAX>>2);
            default : WaveTypeSelect = 2'bZ;
        endcase
    endfunction

    always @ (posedge Clock or Reset)
    begin
        if (Reset==1) 
        begin
            //Reset counter to midpoint value
            counter <= WAVE_MAX/2;
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