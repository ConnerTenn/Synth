

module Filter(
    Clock, 
    Reset,
    WaveIn, WaveOut,
    MemAddr, MemData, MemClk, MemWrite
);

    parameter FILTER_DEPTH = 256;

    parameter SAMPLE_ADDR = 16'h0000;
    parameter FILTER_ADDR = 16'h8000;

    input Clock, Reset;
    input [23:0] WaveIn;
    output [23:0] WaveOut;

    output [15:0] MemAddr; inout [7:0] MemData; output MemClk; output reg MemWrite = 0;
    reg [7:0] memdata = 0; 
    assign MemData = MemWrite ? memdata : 8'hZZ;


    reg [7:0] filterStage = 0;
    reg [2:0] memAccStage = 0;
    reg memAcc = 0;

    reg [15:0] index = 0;

    reg [23:0] filterCoeff = 0;
    reg [23:0] sample = 0;



    assign MemClk = ~Clock;

    always @(posedge Clock)
    begin
        if (index==0)
        begin
            MemWrite <= 1;
            case (memAccStage)
            3'h0: begin memdata <= WaveIn[7:0];     end
            3'h1: begin memdata <= WaveIn[15:8];    end
            3'h2: begin memdata <= WaveIn[23:16];   end
            endcase
        end
        else
        begin
            MemWrite <= 0;
            case (memAccStage)
            3'h0: begin sample[7:0] <= MemData;     end
            3'h1: begin sample[15:8] <= MemData;    end
            3'h2: begin sample[23:16] <= MemData;   end
            endcase
        end
        
        case (memAccStage)
        3'h3: begin filterCoeff[7:0] <= MemData;    end
        3'h4: begin filterCoeff[15:8] <= MemData;   end
        3'h5: begin filterCoeff[23:16] <= MemData;  index <= index+1; end
        endcase

        memAccStage <= memAccStage<5?memAccStage+1:0;

    end

    assign MemAddr = MemAddrSel(memAccStage, index);
    function [15:0] MemAddrSel(
        input [2:0] memstage, 
        input [15:0] idx
    );
        if (memstage<3)
        begin
            if (index==0)
            begin
                case (memstage)
                3'h0: MemAddrSel = SAMPLE_ADDR;
                3'h1: MemAddrSel = SAMPLE_ADDR+1;
                3'h2: MemAddrSel = SAMPLE_ADDR+2;
                endcase
            end
            else
            begin
                case (memstage)
                3'h0: MemAddrSel = (idx<<2)+SAMPLE_ADDR;
                3'h1: MemAddrSel = (idx<<2)+SAMPLE_ADDR+1;
                3'h2: MemAddrSel = (idx<<2)+SAMPLE_ADDR+2;
                endcase
            end
        end
        else
        begin
            case (memstage)
            3'h3: MemAddrSel = (idx<<2)+FILTER_ADDR;
            3'h4: MemAddrSel = (idx<<2)+FILTER_ADDR+1;
            3'h5: MemAddrSel = (idx<<2)+FILTER_ADDR+2;
            endcase
        end
    endfunction

    // always @(negedge Clock)
    // begin
    //     case (memAccStage)
    //     3'h0: MemAddr <= index + SAMPLE_ADDR;
    //     endcase
    // end
    
endmodule