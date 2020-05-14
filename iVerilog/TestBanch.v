

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

        scale <= 0;

        #2

        scale <= 1;

        #2

        scale <= 0;

        #10

        reset <= 0;

        #1000

        reset <= 1;

        #10

        $finish;
    end

    initial
    begin
        #250
        wavetype <= 2'b01;
        #250
        wavetype <= 2'b10;
    end

    always begin
        #1 clock = !clock;
    end

    assign waveform = scale ? (clock ? 8'hFF : 0) : wavebuff;

    TopLevel TL (
        .Clock(clock),
        .Reset(reset),
        .WaveType(wavetype),
        .Waveform(wavebuff)
    );

endmodule