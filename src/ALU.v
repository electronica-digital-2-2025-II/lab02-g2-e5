`include "/home/davidx025/LAB DIGITAL 2/LAB-2/multiplicador.v"
`include "/home/davidx025/LAB DIGITAL 2/LAB-2/sumador.v"
`include "/home/davidx025/LAB DIGITAL 2/LAB-2/resta.v"
`include "/home/davidx025/LAB DIGITAL 2/LAB-2/not.v"
`include "/home/davidx025/LAB DIGITAL 2/LAB-2/desplazamiento.v"


module ALU_4bit (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] op, // 000=suma, 001=mult, 010=resta, 011=NOT, 100=corrimiento
    output reg  [5:0] Y,
    output reg  Zero,
    output reg  Overflow,
    output reg  done
);

    // Señales internas
    wire [4:0] sum_result;
    wire [4:0] resta_result;
    wire [3:0] not_result;
    wire [7:0] mult_result;
    wire [7:0] corr_result;
    wire mult_done;

    // Instanciación de módulos
    adder_4bit SUMA (
        .A(A),
        .B(B),
        .Cin(1'b0),
        .S(sum_result)
    );

    multiplier_4bit_asm MULT (
        .clk(clk),
        .reset(reset),
        .start(start && (op == 3'b001)), // solo iniciar si op = 001
        .A(A),
        .B(B),
        .P(mult_result),
        .done(mult_done)
    );

    restador_4bits RESTA (
        .a(A),
        .b(B),
        .r(resta_result),
        .bout()
    );

    not_4bit NOT1 (
        .A(A),
        .Y(not_result)
    );

    corrimiento_izquierda_por_B SHIFT (
        .A(A),
        .B(B),
        .Y(corr_result)
    );

    // Definición de estados
    parameter INACTIVO    = 2'd0,
              PROCESANDO  = 2'd1,
              FINALIZADO  = 2'd2;

    reg [1:0] estado, next_estado;

    // Bloque secuencial (control)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado <= INACTIVO;
            Y <= 6'd0;
            Zero <= 0;
            Overflow <= 0;
            done <= 0;
        end else begin
            estado <= next_estado;
            
             case (estado)
            INACTIVO: begin
                if (start) begin
                    case (op)
                        3'b000: begin // SUMA
                            Y = {1'b0, sum_result};
                            Zero = (sum_result == 5'd0);
                            Overflow = 1'b0;
                            next_estado = FINALIZADO;
                        end

                        3'b010: begin // RESTA (con signo)
                            Y = {1'b0, resta_result}; // el MSB de resta_result es el signo
                            Zero = (resta_result[3:0] == 4'd0);
                            Overflow = 1'b0;
                            next_estado = FINALIZADO;
                        end

                        3'b011: begin // NOT
                            Y = {2'b00, not_result};
                            Zero = (not_result == 4'd0);
                            Overflow = 1'b0;
                            next_estado = FINALIZADO;
                        end

                        3'b100: begin // CORRIMIENTO IZQ
                            Y = corr_result[5:0];
                            Zero = (corr_result[5:0] == 6'd0);
                            Overflow = |corr_result[7:6]; // bits perdidos
                            next_estado = FINALIZADO;
                        end

                        3'b001: begin // MULTIPLICACIÓN secuencial
                            next_estado = PROCESANDO;
                        end
                    endcase
                end
            end

            PROCESANDO: begin
                if (mult_done) begin
                    Y = mult_result[5:0];
                    Overflow = |mult_result[7:6];
                    Zero = (mult_result[5:0] == 6'd0);
                    next_estado = FINALIZADO;
                end
            end

            FINALIZADO: begin
                next_estado = INACTIVO;
            end
        endcase

            
            if (estado == FINALIZADO)
                done <= 1'b1;
            else
                done <= 1'b0;
        end
    end      
endmodule

