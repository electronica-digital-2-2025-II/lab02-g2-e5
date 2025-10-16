// Sumador completo de 1 bit
module full_adder (
    input  A,         // Bit del operando A
    input  B,         // Bit del operando B
    input  Cin,       // Carry de entrada
    output S,         // Resultado de la suma
    output Cout       // Carry de salida
);
    assign S    = A ^ B ^ Cin;              // XOR para la suma
    assign Cout = (A & B) | (Cin & (A ^ B));// Carry de salida
endmodule


// Sumador estructural de 4 bits
module adder_4bit (
    input  [3:0] A,     // Operando A (4 bits)
    input  [3:0] B,     // Operando B (4 bits)
    input        Cin,   // Carry de entrada inicial (normalmente 0)
    output [4:0] S      // Resultado de la suma (5 bits: incluye el carry out)
);

    // Señales internas para los carries intermedios
    wire C1, C2, C3, C4;

    // Instanciación de los sumadores completos (1 bit cada uno)
    full_adder FA0 (.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(C1));
    full_adder FA1 (.A(A[1]), .B(B[1]), .Cin(C1),  .S(S[1]), .Cout(C2));
    full_adder FA2 (.A(A[2]), .B(B[2]), .Cin(C2),  .S(S[2]), .Cout(C3));
    full_adder FA3 (.A(A[3]), .B(B[3]), .Cin(C3),  .S(S[3]), .Cout(C4));

    // El bit más significativo de la salida S[4] es el carry final
    assign S[4] = C4;

endmodule
