module not_4bit (
    input  [3:0] A,
    output [3:0] Y
);
    assign Y = ~A;
endmodule