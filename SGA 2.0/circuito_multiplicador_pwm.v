/*
 * circuito_multiplicador_pwm.v - descrição comportamental
 *
 * gera saída com modulacao pwm conforme parametros do modulo
 * baseado no circuito_pwm.v do professor Edson Midorikawa
 *
 * parametros: valores definidos para clock de 50MHz (periodo=20ns)
 * ------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autores                     Descricao
 *     05/11/2024  1.0     Erick Sousa, Carlos Engler  criacao do componente Verilog 
 * ------------------------------------------------------------------------
 */
 
module circuito_multiplicador_pwm #(    // valores default
    parameter conf_periodo = 1250, // Período do sinal PWM [1250 => f=4KHz (25us)]
    parameter valor_inicial = 50 // Valor inicial da largura do pulso [50 => 1us]
    ) (
    input        clock,
    input        reset,
    input  [2:0] largura,
    output reg   pwm
);

reg [31:0] contagem; // Contador interno (32 bits) para acomodar conf_periodo

always @(posedge clock or posedge reset) begin
    if (reset) begin
        pwm <= 0;
    end else begin

        // Saída PWM
        pwm <= (contagem < ((largura + 3'b001) * valor_inicial)); // Soma um para evitar que o pulso seja zero

        if (contagem == conf_periodo - 1) begin
            contagem <= 0;
        end else begin
            contagem <= contagem + 1;
        end
    end
end

endmodule
