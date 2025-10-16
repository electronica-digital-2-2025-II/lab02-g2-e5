module restador_4bits (
    input  [3:0] a,     // Minuendo
    input  [3:0] b,     // Sustraendo
    output [4:0] r,     // Resultado con signo [4]=signo, [3:0]=magnitud
    output       bout   // Borrow de salida
);

    wire [3:0] b_comp;      // Complemento a 2 de B
    wire [4:0] suma;        // Resultado intermedio (A + (-B))
    wire signo;             // Bit de signo
    wire [3:0] magnitud;    // Magnitud del resultado

    // Complemento a 2 de B (invertir bits y sumar 1)
    assign b_comp = ~b + 1'b1;

    // Sumar A + (-B)
    assign suma = {1'b0, a} + {1'b0, b_comp};

    // Borrow (1 si A < B)
    assign bout = ~suma[4];
    assign signo = bout; // signo = 1 si el resultado es negativo

    // Magnitud: si A < B, invertimos la resta para obtener valor absoluto
    assign magnitud = (signo) ? (b - a) : (a - b);

    // Resultado final con signo
    assign r = {signo, magnitud};

endmodule
