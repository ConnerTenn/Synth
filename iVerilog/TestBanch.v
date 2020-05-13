

module TestBench;

    reg clock = 0, reset = 1;
    reg [1:0] wavetype = 2'b00;
    wire [7:0] waveform;

    initial
    begin
        $dumpfile ("TestBench.vcd"); 
        $dumpvars;
        $display("Running Simulation...");
        
        $monitor("%g\t:  %b", $time, waveform);

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

    TopLevel TL (
        .Clock(clock),
        .Reset(reset),
        .WaveType(wavetype),
        .Waveform(waveform)
    );

endmodule