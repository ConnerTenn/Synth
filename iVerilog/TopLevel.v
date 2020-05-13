

module TopLevel(
    In1, 
    In2, 
    Out
);
    input In1;
    input In2;
    output Out;

    assign Out = In1 ^ In2;
    
endmodule