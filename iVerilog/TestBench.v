

module TestBench;

    reg clock = 0, reset = 1;
    reg [1:0] wavetype = 2'b00;
    wire [23:0] waveform, wavebuff;

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
        #100000

        //Hold reset for 10[u]
        reset <= 1;
        #10

        $display("Simulation Complete");

        $finish;
    end



`define SET_REG(a, d) \
    addr <= (a); writedata = (d); \
    readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2

`define SET_REG_24(a, d) \
    addr <= (a); writedata = ((d)>>0) & 8'hFF; \
    readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2 \
    addr <= (a)+1; writedata = ((d)>>8) & 8'hFF; \
    readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2 \
    addr <= (a)+2; writedata = ((d)>>16) & 8'hFF; \
    readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2 \

    initial
    begin
        #50
        

        //Note 1
        `SET_REG_24(16'h0011, 24'h0FFFFF); //Incr

        `SET_REG(16'h0014, 8'h01); //WaveType = Square

        `SET_REG_24(16'h0015, 24'h3FFFFF); //PulseWidth
        
        `SET_REG_24(16'h0018, 24'h000500); //Attack
        `SET_REG_24(16'h001B, 24'h000500); //Decay
        `SET_REG_24(16'h001E, 24'h7FFFFF); //Sustain
        `SET_REG_24(16'h0021, 24'h000500); //Release

        `SET_REG(16'h0024, 8'h01); //Linear

        //Note 2
        `SET_REG_24(16'h0031, 24'h0FFFFF); //Incr

        `SET_REG(16'h0034, 8'h02); //WaveType = Triangle

        `SET_REG_24(16'h0035, 24'h7FFFFF); //PulseWidth
        
        `SET_REG_24(16'h0038, 24'h000500); //Attack
        `SET_REG_24(16'h003B, 24'h000500); //Decay
        `SET_REG_24(16'h003E, 24'h7FFFFF); //Sustain
        `SET_REG_24(16'h0041, 24'h000500); //Release

        //Start Notes

        `SET_REG(16'h0010, 8'h01); //Gate = Open

        `SET_REG(16'h0030, 8'h01); //Gate = Open



        #20000


        addr <= 16'h0030; writedata = 8'h00; //Gate = Close
        readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2

        // addr <= 16'h0011; writedata = 8'h05; //Incr 
        // readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2

        // addr <= 16'h0013; writedata = 8'h7F; //PulseWidth 
        // readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2

        #30000

        addr <= 16'h0010; writedata = 8'h00; //Gate = Close
        readwrite <= 1; busclk <= 1; #2 busclk <= 0; #2

        
        #20

        writedata <= 0;
        readwrite <= 0;
    end

    //Clock Process. Oscillates every 1[u] (resulting in a 2[u] period)
    always begin
        #1 clock = !clock;
    end

    //Allow switching between full scale display test and toplevel waveform output
    assign waveform = scale ? (clock ? 24'hFFFFFF : 0) : wavebuff;

    TopLevel TL (
        .Clock(clock),
        .Reset(reset),
        .BusAddress(addr), .BusData(data), .BusReadWrite(readwrite), .BusClock(busclk),
        .Waveform(wavebuff)
    );

endmodule