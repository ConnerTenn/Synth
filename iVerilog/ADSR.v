
module ADSR
(
    Clock, 
    Reset,
    Gate,
    Running,
    Linear,
    ADSRstate,
    Attack, Decay, Sustain, Release,
    Envelope
);

    parameter WAVE_MAX = 24'hFFFFFF;

    input Clock, Reset;
    input Gate;
    output reg Running = 0;
    input Linear;
    output reg [1:0] ADSRstate = 2'b00;
    input [23:0] Attack, Decay, Sustain, Release;
    output reg [23:0] Envelope = 0;


    wire [47:0] attackStep = ((WAVE_MAX-Envelope)/Attack);
    wire [47:0] decayStep = ((Envelope-Sustain)/Decay);
    wire [47:0] releaseStep = (Envelope/Release);

    always @(posedge Clock)
    begin
        if (Reset == 0)
        begin
            if (Gate == 1)
            begin
                case (ADSRstate)
                2'b00: //Attack
                    if (Running == 1)
                    begin
                        if (Envelope>=WAVE_MAX-Attack)
                        begin
                            ADSRstate <= 2'b01;
                        end
                        else if (Linear == 1)
                        begin
                            Envelope <= Envelope + Attack;
                        end
                        else 
                        begin
                            Envelope <= Envelope + attackStep + 1;
                        end
                    end
                    
                2'b01: //Decay
                    begin
                        if (Envelope<=Sustain+Decay)
                        begin
                            ADSRstate <= 2'b10;
                        end
                        else if (Linear == 1)
                        begin
                            Envelope <= Envelope - Decay;
                        end
                        else
                        begin
                            Envelope <= Envelope - decayStep - 1;
                        end
                    end
                // 2'b10: //Sustain
                // 2'b11: //Release
                endcase
            end
            else //Release
            begin
                if (Envelope <= 0+Release)
                begin
                    Running <= 0;
                end
                else if (Linear == 1)
                begin
                    Envelope <= Envelope - Release;
                end
                else
                begin
                    Envelope <= Envelope - releaseStep - 1;
                end
            end
        end //If (Reset == 0)
    end

    always @(Reset)
    begin
        if (Reset == 1)
        begin
            Envelope = 0;
            ADSRstate = 2'b00;
        end
    end

    always @(Gate)
    begin
        if (Gate == 1)
        begin
            // Envelope = 0; //Removed so that notes can 'flow' into eachother
            ADSRstate = 2'b00;
            Running = 1;
        end
        else
        begin
            ADSRstate <= 2'b11;
        end
    end

endmodule