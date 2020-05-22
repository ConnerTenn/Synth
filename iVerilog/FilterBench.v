

`timescale 1 ms / 10 ns


module FilterBench;

    parameter MIN_STEP = 0.000005;
    parameter TWO_STEP = MIN_STEP*2;

    reg clock = 0;
    reg reset = 1;

    // reg dataclock = 0;
    // reg [15:0] addr = 0;
    // reg [7:0] data = 0;
    // reg rw = 0;
    
    integer fi;

    initial
    begin
        $dumpfile("FilterBench.vcd"); 
        $dumpvars;
        $display("Running Simulation...");

        #TWO_STEP
        reset <= 0;
        
        #10

        $display("Simulation Complete");

        $finish;
    end

    always
    begin
        #MIN_STEP clock = !clock;
    end

    wire write;
    wire memclk;
    wire [15:0] memaddr;
    wire [7:0] dataio; //= write==1 ? data : 8'hZZ;

    Ram ram (
        .Clock(memclk),
        .Address(memaddr),
        .Data(dataio),
        .ReadWrite(write)
    );

    Filter filter(
        .Clock(clock),
        .Reset(reset),
        .WaveIn(24'h090807), .WaveOut(),
        .MemAddr(memaddr), .MemData(dataio), .MemClk(memclk), .MemWrite(write)
    );

endmodule