

module TestBench;

    reg clock = 0;
    reg A = 0, B = 0;
    wire C;

    initial 
    begin
        // clock=0;
        // A=0;
        // B=0;
        $display("Running Simulation...");
        
        $monitor("%b XOR %b = %b   %b", A, B, C, clock);


        A = 0; B = 0;
        #1
        A = 0; B = 1;
        #1
        A = 1; B = 1;
        #1
        A = 1; B = 0;


        $finish;
    end

    always begin
        #1 clock = !clock;
    end

    TopLevel TL (
        A,
        B,
        C
    );

endmodule