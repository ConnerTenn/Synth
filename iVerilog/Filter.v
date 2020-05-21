

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

    output reg [15:0] MemAddr = 0; inout [7:0] MemData; output MemClk; output reg MemWrite = 0;
    reg [7:0] memdata = 0; 
    assign MemData = MemWrite ? memdata : 8'hZZ;


    reg [7:0] filterStage = 0;
    reg [2:0] memAccStage = 0;
    reg memAcc = 0;

    reg [15:0] index = 0;
    reg writesample = 1;

    reg [23:0] filterCoeff = 0;
    reg [23:0] sample = 0;

    

    assign MemClk = ~Clock;

    always @(posedge Clock)
    begin
        if (index==0 && writesample)
        begin
            MemWrite <= 1;
            case (memAccStage)
            3'h0: begin memdata <= WaveIn[7:0];     MemAddr <= SAMPLE_ADDR;     memAccStage <= 1; end
            3'h1: begin memdata <= WaveIn[15:8];    MemAddr <= SAMPLE_ADDR+1;   memAccStage <= 2; end
            3'h2: begin memdata <= WaveIn[23:16];   MemAddr <= SAMPLE_ADDR+2; writesample <= 0; memAccStage <= 0; end
            endcase
        end
        else
        begin
            MemWrite <= 0;
            case (memAccStage)
            3'h0: begin sample[7:0] <= MemData;         MemAddr <= index+SAMPLE_ADDR;   end
            3'h1: begin sample[15:8] <= MemData;        MemAddr <= index+SAMPLE_ADDR+1; end
            3'h2: begin sample[23:16] <= MemData;       MemAddr <= index+SAMPLE_ADDR+2; end
            3'h3: begin filterCoeff[7:0] <= MemData;    MemAddr <= index+FILTER_ADDR;   end
            3'h4: begin filterCoeff[15:8] <= MemData;   MemAddr <= index+FILTER_ADDR+1; end
            3'h5: begin filterCoeff[23:16] <= MemData;  MemAddr <= index+FILTER_ADDR+2; index <= index+1; end
            endcase
            memAccStage <= memAccStage<5?memAccStage+1:0;
        end

    end

    // always @(negedge Clock)
    // begin
    //     case (memAccStage)
    //     3'h0: MemAddr <= index + SAMPLE_ADDR;
    //     endcase
    // end
    
endmodule