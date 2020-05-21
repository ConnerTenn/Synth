

`timescale 1 ms / 1 us


module FilterBench;

    parameter MIN_STEP = 0.0005;
    parameter TWO_STEP = MIN_STEP*2;

    reg clock = 0;

    reg dataclock = 0;
    reg [7:0] addr = 0;
    reg [7:0] data = 0;
    reg rw = 0;
    


    initial
    begin
        $dumpfile("FilterBench.vcd"); 
        $dumpvars;
        $display("Running Simulation...");
        
        #1

        addr <= 1;
        data <= 5;
        rw <= 1;

        dataclock <= 1; #TWO_STEP dataclock <= 0; #TWO_STEP

        addr <= 2;
        data <= 1;
        rw <= 1;

        dataclock <= 1; #TWO_STEP dataclock <= 0; #TWO_STEP

        addr <= 1;
        rw <= 0;

        dataclock <= 1; #TWO_STEP dataclock <= 0; #TWO_STEP

        addr <= 2;
        rw <= 0;

        dataclock <= 1; #TWO_STEP dataclock <= 0; #TWO_STEP

        #1

        $display("Simulation Complete");

        $finish;
    end

    always
    begin
        #MIN_STEP clock = !clock;
    end

    wire [7:0] dataio = rw==1 ? data : 8'hZZ;

    Ram ram (
        .Clock(dataclock),
        .Address(addr),
        .Data(dataio),
        .ReadWrite(rw)
    );

endmodule