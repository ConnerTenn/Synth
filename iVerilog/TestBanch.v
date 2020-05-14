

module TestBench;

    reg clock = 0, reset = 1;
    reg [1:0] wavetype = 2'b00;
    wire [7:0] waveform, wavebuff;

    reg scale = 0;

    initial
    begin
        $dumpfile ("TestBench.vcd"); 
        $dumpvars;
        $display("Running Simulation...");
        
        $monitor("%g\t:  %b", $time, waveform);

        //Force output a full range scale test
        scale <= 0;
        #2
        scale <= 1;
        #2
        scale <= 0;

        //Hold reset for 10[u]
        #10
        reset <= 0;

        //Run for 1000[u]
        #1000

        //Hold reset for 10[u]
        reset <= 1;
        #10

        $finish;
    end

    //Change the wavetypes in parallel while running
    initial
    begin
        #250
        wavetype <= 2'b01;
        #250
        wavetype <= 2'b10;
    end

    //Clock Process. Oscillates every 1[u] (resulting in a 2[u] period)
    always begin
        #1 clock = !clock;
    end

    //Allow switching between full scale display test and toplevel waveform output
    assign waveform = scale ? (clock ? 8'hFF : 0) : wavebuff;

    TopLevel TL (
        .Clock(clock),
        .Reset(reset),
        .WaveType(wavetype),
        .Waveform(wavebuff)
    );

endmodule