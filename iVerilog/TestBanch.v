

module TestBench;

    reg clock = 0;
    wire [7:0] value;

    initial 
    begin
        $dumpfile ("TestBench.vcd"); 
        $dumpvars;
        $display("Running Simulation...");
        
        $monitor("%g\t:  %b", $time, value);

        #1024

        $finish;
    end

    always begin
        #1 clock = !clock;
    end

    TopLevel TL (
        clock,
        value
    );

endmodule