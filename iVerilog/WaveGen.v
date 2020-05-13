

module WaveGen 
#(
    parameter WAVE_DEPTH=8
) 
(
    Clock,
    Reset,
    Frequency,
    WaveType,
    Waveform
);
    parameter WAVE_HIGH_BIT=WAVE_DEPTH-1;
    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input [WAVE_HIGH_BIT:0] Frequency;
    input [1:0] WaveType;
    output [WAVE_HIGH_BIT:0] Waveform;

    reg [WAVE_HIGH_BIT:0] counter = WAVE_DEPTH/2;

    assign Waveform = WaveTypeSelect(counter, Frequency, WaveType);

    function [7:0] WaveTypeSelect(input [WAVE_HIGH_BIT:0] counter, input [WAVE_HIGH_BIT:0] frequency, input [1:0] wavetype);
        case(wavetype)
            //Sawtooth
            2'b00 : WaveTypeSelect = counter;
            //Square
            2'b01 : WaveTypeSelect = (counter<=(Frequency>>1) ? 8'h00 : WAVE_MAX);
            //Triangle
            2'b10 : WaveTypeSelect = (counter<=(Frequency>>1) ? counter : (Frequency-counter)+1);
            default : WaveTypeSelect = 2'bZ;
        endcase
    endfunction

    always @ (posedge Clock)
    begin
        if (Reset==1) begin
            counter <= WAVE_DEPTH/2;
        end
        else begin
            if (counter == Frequency) begin
                counter <= 8'h00;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule