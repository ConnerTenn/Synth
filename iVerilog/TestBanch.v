

module TestBench;

    reg clock = 0, reset = 1;
    reg [1:0] wavetype = 2'b00;
    wire [7:0] waveform, wavebuff;

    reg [15:0] addr = 0;
    wire [7:0] data;
    reg [7:0] writedata = 0;
    reg readwrite = 0;
    reg busclk = 0;

    assign data = readwrite == 1 ? writedata : 8'hZZ;

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

    initial
    begin
        #50
        
        addr <= 16'h0001;
        writedata = 8'h3F;
        readwrite <= 1;
        #2
        busclk <= 1;
        #2
        busclk <= 0;

        #150
        
        addr <= 16'h0002;
        writedata = 8'h01;
        readwrite <= 1;
        #2
        busclk <= 1;
        #2
        busclk <= 0;
        
        #2

        writedata <= 0;
        readwrite <= 0;
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
        .BusAddress(addr), .BusData(data), .BusReadWrite(readwrite), .BusClock(busclk),
        .WaveType(wavetype),
        .Waveform(wavebuff)
    );

endmodule