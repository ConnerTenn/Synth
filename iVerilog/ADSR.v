
module ADSR
#(
    parameter WAVE_DEPTH=8,
    parameter ADDR=0
) 
(
    Clock,
    Reset,
    Envolope,
);

    parameter WAVE_MAX = (1<<WAVE_DEPTH)-1;

    input Clock, Reset;
    output reg [WAVE_DEPTH-1:0] Envolope = WAVE_MAX;

    reg [1:0] state = 2'b00;

    reg [2*WAVE_DEPTH-1:0] decrementor = WAVE_MAX;


    always @(posedge Clock)
    begin
        if (Reset==0)
        begin
            case (state)
            2'b00: //Attack
                state <= state + 1;
            2'b01: //Decay
                state <= state + 1;
            2'b10: //Sustain
                state <= state + 1;
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

    always @(Reset)
    begin
        if (Reset==1)
        begin
            Envolope = 0;
            state = 2'b00;
        end
    end
    
endmodule