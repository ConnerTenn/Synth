

module Ram(
    Clock,
    Address, Data,
    ReadWrite
);
    input Clock, Reset;
    input [7:0] Address;
    inout [7:0] Data; 
    input ReadWrite;

    reg [7:0] Memory [2**16-1:0];

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

endmodule
