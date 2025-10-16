module corrimiento_izquierda_por_B (
    input  wire [3:0] A,      // valor a desplazar
    input  wire [3:0] B,      // cantidad de posiciones
    output reg  [5:0] Y       // salida desplazada (puede ser más de 4 bits)
);

    always @(*) begin
        Y = A << B;  // Desplazamiento lógico a la izquierda
    end

endmodule