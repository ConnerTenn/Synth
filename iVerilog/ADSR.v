
module ADSR
#(
    parameter WAVE_DEPTH=8
) 
(
    Clock, 
    Reset,
    Gate,
    Running,
    Sustain,
    Envelope,
);

    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input Gate;
    output reg Running = 0;
    input [WAVE_DEPTH-1:0] Sustain;
    output reg [WAVE_DEPTH-1:0] Envelope = 0;

    reg [1:0] state = 2'b00;

    // reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;
    reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;


    always @(posedge Clock)
    begin
        if (Reset == 0)
        begin
            case (state)
            2'b00: //Attack
                if (Running == 1)
                begin
                    if (Envelope==WAVE_MAX)
                    begin
                        state <= state + 1;
                        decrementor <= WAVE_MAX;
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envelope <= Envelope + 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + (WAVE_MAX-Envelope);
                    end
                end
                
            2'b01: //Decay
                begin
                    if (Envelope==Sustain)
                    begin
                        state <= state + 1;
                        decrementor <= 4*WAVE_MAX;
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envelope <= Envelope - 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + (Envelope-Sustain);
                    end
                end
            2'b10: //Sustain
                begin
                    if (Gate==0)
                    begin
                        state <= state + 1;
                        decrementor <= WAVE_MAX;
                    end
                end
            2'b11: //Release
                begin
                    if (Envelope == 0)
                    begin
                        Running <= 0;
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envelope <= Envelope - 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + (Envelope);
                    end
                end
            endcase
        end
    end

    always @(posedge Gate or Reset)
    begin
        if (Gate == 1 || Reset == 1)
        begin
            Envelope = 0;
            state = 2'b00;
            decrementor = WAVE_MAX;
            if (Gate == 1)
            begin
                Running = 1;
            end
        end
    end

endmodule