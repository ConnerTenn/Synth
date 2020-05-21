

`timescale 1 ms / 1 us

module FilterBench;
    
    reg clock = 0;

    initial
    begin
        $dumpfile("FilterBench.vcd"); 
        $dumpvars;
        $display("Running Simulation...");
        
        #100

        $display("Simulation Complete");

        $finish;
    end

    always
    begin
        #0.0005 clock = !clock;
    end

endmodule