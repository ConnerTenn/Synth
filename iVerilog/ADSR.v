
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


    // reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;
    reg [47:0] decrementor = WAVE_MAX;


    wire [47:0] attackStep = ((WAVE_MAX-Envelope)/Attack);
    wire [47:0] decayStep = ((Envelope-Sustain)/Decay);
    wire [47:0] releaseStep = (Envelope/Release);

    always @(posedge Clock)
    begin
        if (Reset == 0)
        begin
            case (ADSRstate)
            2'b00: //Attack
                if (Running == 1)
                begin
                    if (Envelope>=WAVE_MAX-Attack)
                    begin
                        ADSRstate <= 2'b01;
                        decrementor <= WAVE_MAX;
                    end
                    else if (Linear == 1)
                    begin
                        Envelope <= Envelope + Attack;
                        decrementor <= WAVE_MAX;
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
                        decrementor <= 4*WAVE_MAX;
                    end
                    else if (Linear == 1)
                    begin
                        Envelope <= Envelope - Decay;
                        decrementor <= WAVE_MAX;
                    end
                    else
                    begin
                        Envelope <= Envelope - decayStep - 1;
                    end
                end
            2'b10: //Sustain
                begin
                    if (Gate==0)
                    begin
                        ADSRstate <= 2'b11;
                        decrementor <= WAVE_MAX;
                    end
                end
            2'b11: //Release
                begin
                    if (Envelope <= 0+Release)
                    begin
                        Running <= 0;
                    end
                    else if (Linear == 1)
                    begin
                        Envelope <= Envelope - Release;
                        decrementor <= WAVE_MAX;
                    end
                    else
                    begin
                        Envelope <= Envelope - releaseStep - 1;
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
            ADSRstate = 2'b00;
            decrementor = WAVE_MAX;
            if (Gate == 1)
            begin
                Running = 1;
            end
        end
    end

endmodule