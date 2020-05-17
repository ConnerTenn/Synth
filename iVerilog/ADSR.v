
module ADSR
#(
    parameter WAVE_DEPTH=8
) 
(
    Clock,
    Gate,
    Sustain,
    Envolope,
);

    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock;
    input Gate;
    input [WAVE_DEPTH-1:0] Sustain;
    output reg [WAVE_DEPTH-1:0] Envolope = 0*WAVE_MAX;

    reg [1:0] state = 2'b00;

    // reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;
    reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;


    always @(posedge Clock)
    begin
        if (Gate==1)
        begin
            case (state)
            2'b00: //Attack
                begin
                    if (Envolope==WAVE_MAX)
                    begin
                        state <= state + 1;
                        decrementor <= WAVE_MAX;
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envolope <= Envolope + 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + (WAVE_MAX-Envolope);
                    end
                end
                
            2'b01: //Decay
                begin
                    if (Envolope==Sustain)
                    begin
                        state <= state + 1;
                        decrementor <= 4*WAVE_MAX;
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envolope <= Envolope - 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + (Envolope-Sustain);
                    end
                end
            2'b10: //Sustain
                begin
                    decrementor <= decrementor - 1;
                    if (decrementor==0)
                    begin
                        state <= state + 1;
                        decrementor <= WAVE_MAX;
                    end
                end
            2'b11: //Release
                begin
                    if (decrementor>=WAVE_MAX)
                    begin
                        Envolope <= Envolope - 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + (Envolope);
                    end
                end
            endcase
        end
    end

    always @(Gate)
    begin
        if (Gate==0)
        begin
            Envolope = 0;
            state = 2'b00;
            decrementor = WAVE_MAX;
        end
    end

endmodule