module multiplier_4bit_asm (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [3:0] A, // multiplicando
    input  wire [3:0] B, // multiplicador
    output reg  [7:0] P, // producto (hasta 8 bits)
    output reg  done
);
    // Definición de estados
    parameter INICIAL        = 3'd0,
              CARGA          = 3'd1,
              REVISION       = 3'd2,
              SUMA           = 3'd3,
              DESPLAZAMIENTO = 3'd4,
              HECHO          = 3'd5;
              
    reg [2:0] state, next_state;

    // Registros internos
    reg [7:0] multiplicando, next_multiplicando;
    reg [3:0] multiplicador, next_multiplicador;
    reg [2:0] count, next_count; 
    reg [7:0] next_P;
    reg next_done; // señal combinacional que luego registramos

    // Bloque secuencial: actualiza registros y done (registrado)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= INICIAL;
            P <= 8'd0;
            multiplicando <= 8'd0;
            multiplicador <= 4'd0;
            count <= 3'd0;
            done <= 1'b0;
        end else begin
            state <= next_state;
            P <= next_P;
            multiplicando <= next_multiplicando;
            multiplicador <= next_multiplicador;
            count <= next_count;
            done <= next_done; // done registrado (estable en flanco)
        end
    end

    // Bloque combinacional
    always @(*) begin
        // valores por defecto
        next_state = state;
        next_P = P;
        next_multiplicando = multiplicando;
        next_multiplicador = multiplicador;
        next_count = count;
        next_done = 1'b0;

        case (state)
            INICIAL: begin
                if (start)
                    next_state = CARGA;
            end

            CARGA: begin
                next_P = 8'd0;
                next_multiplicando = {4'b0000, A}; // A en parte baja
                next_multiplicador = B;
                next_count = 3'd4; // 4 iteraciones
                next_state = REVISION;
            end

            REVISION: begin
                if (multiplicador[0]) 
                    next_state = SUMA;
                else 
                    next_state = DESPLAZAMIENTO;
            end

            SUMA: begin
                next_P = P + multiplicando;
                next_state = DESPLAZAMIENTO;
            end

            DESPLAZAMIENTO: begin
                next_multiplicando = multiplicando << 1; // desplazamiento a la izquierda de A
                next_multiplicador = multiplicador >> 1; // desplazamiento a la derecha de B
                next_count = count - 1;
                if (count == 1)
                    next_state = HECHO;
                else
                    next_state = REVISION;
            end

            HECHO: begin
                next_done = 1'b1; // señalamos que estamos en HECHO
                next_state = INICIAL;
            end
        endcase
    end
endmodule
