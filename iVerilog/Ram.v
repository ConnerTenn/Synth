

module Ram(
    Clock, 
    Reset,
    Address, Data,
    ReadWrite
);
    input Clock, Reset;
    input [7:0] Address;
    inout [7:0] Data; 
    input ReadWrite;

endmodule
