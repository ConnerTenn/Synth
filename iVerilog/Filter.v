

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

    reg [23:0] filterCoeff = 0;
    reg [23:0] sample = 0;



    assign MemClk = ~Clock;

    always @(posedge Clock)
    begin
        if (index==0)
        begin
            case (memAccStage)

            3'h0: begin memdata <= WaveIn[7:0];     MemAddr <= SAMPLE_ADDR; MemWrite <= 1;  end
            3'h1: begin memdata <= WaveIn[15:8];    MemAddr <= SAMPLE_ADDR+1; end
            3'h2: begin memdata <= WaveIn[23:16];   MemAddr <= SAMPLE_ADDR+2; end
            3'h3: begin MemWrite <= 0;              MemAddr <= FILTER_ADDR;   end
            3'h4: begin filterCoeff[7:0] <= MemData;    MemAddr <= FILTER_ADDR+1; end
            3'h5: begin filterCoeff[15:8] <= MemData;   MemAddr <= FILTER_ADDR+2; end
            3'h6: begin filterCoeff[23:16] <= MemData;  MemAddr <= (1<<2)+FILTER_ADDR; index <= index+1; end
            endcase
            memAccStage <= memAccStage<6?memAccStage+1:0;
        end
        else
        begin
            case (memAccStage)
            3'h0: begin filterCoeff[7:0] <= MemData;    MemAddr <= (index<<2)+FILTER_ADDR+1; end
            3'h1: begin filterCoeff[15:8] <= MemData;   MemAddr <= (index<<2)+FILTER_ADDR+2; end
            3'h2: begin filterCoeff[23:16] <= MemData;  MemAddr <= (index<<2)+SAMPLE_ADDR;   end
            3'h3: begin sample[7:0] <= MemData;     MemAddr <= (index<<2)+SAMPLE_ADDR+1; end
            3'h4: begin sample[15:8] <= MemData;    MemAddr <= (index<<2)+SAMPLE_ADDR+2; end
            3'h5: begin sample[23:16] <= MemData;   MemAddr <= ((index+1)<<2)+FILTER_ADDR; index <= index+1; end
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