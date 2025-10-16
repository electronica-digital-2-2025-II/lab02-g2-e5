`timescale 1ns/1ps
`include "/home/davidx025/LAB DIGITAL 2/LAB-2/ALU.v"


module tb_ALU_4bit;

    // Entradas
    reg clk;
    reg reset;
    reg start;
    reg [3:0] A;
    reg [3:0] B;
    reg [2:0] op;

    // Salidas
    wire [5:0] Y;
    wire Zero;
    wire Overflow;
    wire done;

    // Instancia del módulo bajo prueba (UUT)
    ALU_4bit uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .op(op),
        .Y(Y),
        .Zero(Zero),
        .Overflow(Overflow),
        .done(done)
    );

    // Generador de reloj
    always #5 clk = ~clk; // periodo = 10 ns

    initial begin
        // Configuración del VCD
        $dumpfile("ALU_4bit.vcd");
        $dumpvars(0, tb_ALU_4bit);

        // Inicialización
        clk = 0;
        reset = 1;
        start = 0;
        A = 0;
        B = 0;
        op = 0;

        // Liberar reset
        #10 reset = 0;

        // ===== CASO 1: SUMA =====
        A = 4'd5;
        B = 4'd3;
        op = 3'b000;
        start = 1;
        #10 start = 0;
        #40;

        // ===== CASO 2: MULTIPLICACIÓN =====
        A = 4'd4;
        B = 4'd2;
        op = 3'b001;
        start = 1;
        #10 start = 0;
        wait(done);
        #40;

       
        // ===== CASO 3: RESTA =====
        A = 4'd5;
        B = 4'd1;
        op = 3'b010;
        start = 1;
        #10 start = 0;
        #40;

        // ===== CASO 4: NOT =====
        A = 4'b1010;
        B = 4'd0;
        op = 3'b011;
        start = 1;
        #10 start = 0;
        #40;

        // ===== CASO 5: CORRIMIENTO =====
        A = 4'b0011;
        B = 4'd2;
        op = 3'b100;
        start = 1;
        #10 start = 0;
        #40;

// ===== CASO 6: MULTIPLICACIÓN o =====
        A = 4'd15;
        B = 4'd15;
        op = 3'b001;
        start = 1;
        #10 start = 0;
        wait(done);
        #40;

        // ===== CASO 6: MULTIPLICACIÓN zero =====
        A = 4'd15;
        B = 4'd0;
        op = 3'b001;
        start = 1;
        #10 start = 0;
        wait(done);
        #40;

        // Finalización
        #50;
        $finish;
    end

endmodule
