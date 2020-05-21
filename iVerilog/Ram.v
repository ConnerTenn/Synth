

module Ram(
    Clock,
    Address, Data,
    ReadWrite
);
    parameter RAM_SIZE = 2**16;

    input Clock, Reset;
    input [15:0] Address;
    inout [7:0] Data; 
    input ReadWrite;

    reg [7:0] Memory [0:RAM_SIZE-1];

    reg [7:0] data = 0;
    assign Data = ReadWrite==0 ? data : 8'hZZ;

    always @(posedge Clock)
    begin
        if (ReadWrite==1)
        begin
            Memory[Address] <= Data;
        end
        else
        begin
            data <= Memory[Address];
        end
    end

    //Filter Parameter Initalization
    integer fi;
    initial
    begin
        $readmemh ("FilterVals.txt", Memory);
        // for (fi=0; fi<RAM_SIZE; fi=fi+1)
        // begin
        //     Memory[fi] = sine(fi);
        // end
    end

endmodule
