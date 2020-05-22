
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


    // wire [47:0] attackStep = Linear==0 ? ((WAVE_MAX+47'h10000-Envelope)/Attack)+13 : (WAVE_MAX/Attack);
    // wire [47:0] decayStep = Linear==0 ? ((Envelope-Sustain)/Decay)+13 : (WAVE_MAX/Decay);
    // wire [47:0] releaseStep = Linear==0 ? ((Envelope)/Release)+13 : (WAVE_MAX/Release);

    // wire [47:0] numerator;
    // wire [47:0] denomerator;
    // wire [47:0] divres = numerator/denomerator;

    wire [23:0] divres = StepSel(ADSRstate,
       Linear==0?(WAVE_MAX+47'h10000-Envelope):WAVE_MAX, Attack,
       Linear==0?(Envelope-Sustain):WAVE_MAX, Decay,
       Linear==0?Envelope:WAVE_MAX, Release);

    function automatic [47:0] StepSel;
        input [1:0] adsrstate;
        input [47:0] attackNum;  input [47:0] attackDenom;
        input [47:0] decayNum;   input [47:0] decayDenom;
        input [47:0] releaseNum; input [47:0] releaseDenom;
        reg [47:0] num;
        reg [47:0] denom;
        begin
            case (adsrstate)
                2'b00: begin num = attackNum; denom = attackDenom; end
                2'b01: begin num = decayNum; denom = decayDenom; end
                2'b11: begin num = releaseNum; denom = releaseDenom; end
                default: begin num = 0; denom = 1; end
            endcase
            StepSel = num / denom;
        end
    endfunction


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
                        else 
                        begin
                            Envelope <= Envelope + divres + (Linear==0?14:1);
                        end
                    end
                    
                2'b01: //Decay
                    begin
                        if (Envelope<=Sustain+Decay)
                        begin
                            ADSRstate <= 2'b10;
                        end
                        else
                        begin
                            Envelope <= Envelope - divres - (Linear==0?14:1);
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
                else
                begin
                    Envelope <= Envelope - divres - (Linear==0?14:1);
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
            Running = 0;
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