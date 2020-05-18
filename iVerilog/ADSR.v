
module ADSR
#(
    parameter WAVE_DEPTH=8
) 
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

    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    input Gate;
    output reg Running = 0;
    input Linear;
    output reg [1:0] ADSRstate = 2'b00;
    input [WAVE_DEPTH-1:0] Attack, Decay, Sustain, Release;
    output reg [WAVE_DEPTH-1:0] Envelope = 0;


    // reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;
    reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;


    wire [2*WAVE_DEPTH-1:0] attackStep = ((8'hFF-Attack)*(WAVE_MAX-Envelope))>>8;
    wire [2*WAVE_DEPTH-1:0] decayStep = ((8'hFF-Decay)*(Envelope-Sustain))>>8;
    wire [2*WAVE_DEPTH-1:0] releaseStep = ((8'hFF-Release)*Envelope)>>8;

    always @(posedge Clock)
    begin
        if (Reset == 0)
        begin
            case (ADSRstate)
            2'b00: //Attack
                if (Running == 1)
                begin
                    if (Envelope==WAVE_MAX)
                    begin
                        ADSRstate <= 2'b01;
                        decrementor <= WAVE_MAX;
                    end
                    else if (Linear == 1)
                    begin
                        if (decrementor==WAVE_MAX-Attack)
                        begin
                            Envelope <= Envelope + 1;
                            decrementor <= WAVE_MAX;
                        end
                        else begin 
                            decrementor <= decrementor - 1; 
                        end
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envelope <= Envelope + 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + attackStep+1;
                    end
                end
                
            2'b01: //Decay
                begin
                    if (Envelope==Sustain)
                    begin
                        ADSRstate <= 2'b10;
                        decrementor <= 4*WAVE_MAX;
                    end
                    else if (Linear == 1)
                    begin
                        if (decrementor==WAVE_MAX-Decay)
                        begin
                            Envelope <= Envelope - 1;
                            decrementor <= WAVE_MAX;
                        end
                        else begin 
                            decrementor <= decrementor - 1; 
                        end
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envelope <= Envelope - 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + decayStep + 1;
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
                    if (Envelope == 0)
                    begin
                        Running <= 0;
                    end
                    else if (Linear == 1)
                    begin
                        if (decrementor==WAVE_MAX-Release)
                        begin
                            Envelope <= Envelope - 1;
                            decrementor <= WAVE_MAX;
                        end
                        else begin 
                            decrementor <= decrementor - 1; 
                        end
                    end
                    else if (decrementor>=WAVE_MAX)
                    begin
                        Envelope <= Envelope - 1;
                        decrementor <= decrementor - WAVE_MAX/2;
                    end
                    else
                    begin
                        decrementor <= decrementor + releaseStep + 1;
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