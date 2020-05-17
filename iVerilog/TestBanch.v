

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
        
        // $monitor("%g\t:  %b", $time, waveform);

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
        #10000

        //Hold reset for 10[u]
        reset <= 1;
        #10

        $display("Simulation Complete");

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
        
        addr <= 16'h0011; //Incr
        writedata = 8'h0F;
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        addr <= 16'h0012; //WaveType
        writedata = 8'h01; //Square
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        addr <= 16'h0013; //PulseWidth
        writedata = 8'h3F; 
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2
        
        addr <= 16'h0014; //Sustain
        writedata = 8'h7F;
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        addr <= 16'h0010; //Gate
        writedata = 8'h01; //Open
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        #1000

        addr <= 16'h0011; //Incr
        writedata = 8'h05; 
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        addr <= 16'h0013; //PulseWidth
        writedata = 8'h7F; 
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        #3000

        addr <= 16'h0015; //Linear
        writedata = 8'h01;
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2

        #1000

        addr <= 16'h0010; //Gate
        writedata = 8'h00; //Close
        readwrite <= 1;
        busclk <= 1; #2 busclk <= 0; #2
        
        #20

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