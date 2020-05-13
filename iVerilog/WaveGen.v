

module WaveGen(
    Clock,
    Frequency,
    WaveType,
    Waveform
);
    input Clock;
    input [7:0] Frequency;
    input [1:0] WaveType;
    output [7:0] Waveform;

    reg [7:0] counter = 8'h00;

    // //Sawtooth
    // assign Waveform = WaveType==2'b00 ? counter : 8'hZZ;
    // //Square
    // assign Waveform = WaveType==2'b01 ? (counter<=(Frequency>>1) ? 8'h00 : 8'hFF) : 8'hZZ;
    // //Triangle
    // assign Waveform = WaveType==2'b10 ? (counter<=(Frequency>>1) ? counter : (Frequency-counter)+1) : 8'hZZ;

    assign Waveform = WaveTypeSelect(counter, Frequency, WaveType);

    function [7:0] WaveTypeSelect(input [7:0] counter, input [7:0] frequency, input [1:0] wavetype);
        case(wavetype)
            //Sawtooth
            2'b00 : WaveTypeSelect = counter;
            //Square
            2'b01 : WaveTypeSelect = (counter<=(Frequency>>1) ? 8'h00 : 8'hFF);
            //Triangle
            2'b10 : WaveTypeSelect = (counter<=(Frequency>>1) ? counter : (Frequency-counter)+1);
            default : WaveTypeSelect = 2'bZ;
        endcase
    endfunction

    always @ (posedge Clock)
    begin
        if (counter == Frequency) begin
            counter <= 8'h00;
        end
        else begin
            counter <= counter + 1;
        end
    end

endmodule