

module WaveGen(
    Clock,
    Frequency,
    WaveType,
    Waveform
);
    input Clock;
    input [7:0] Frequency;
    input [1:0] WaveType;
    output reg [7:0] Waveform = 8'h00;

    always @ (posedge Clock)
    begin
        if (Waveform == Frequency) begin
            Waveform <= 8'h00;
        end
        else begin
            Waveform <= Waveform + 1;
        end
    end

endmodule