/*
 * circuito_pwm.v - descrição comportamental
 *
 * gera saída com modulacao pwm conforme parametros do modulo
 *
 * parametros: valores definidos para clock de 50MHz (periodo=20ns)
 * ------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     26/09/2021  1.0     Edson Midorikawa  criacao do componente VHDL
 *     17/08/2024  2.0     Edson Midorikawa  componente em Verilog
 * ------------------------------------------------------------------------
 */
 
module circuito_pwm #(    // valores default
    parameter conf_periodo = 1250, // Período do sinal PWM [1250 => f=4KHz (25us)]
    parameter valor_inicial = 50 // Valor inicial da largura do pulso [50 => 1us]
    ) (
    input        clock,
    input        reset,
    input  [1:0] largura,
    output reg   pwm
);

reg [31:0] contagem; // Contador interno (32 bits) para acomodar conf_periodo

always @(posedge clock or posedge reset) begin
    if (reset) begin
        pwm <= 0;
    end else begin

        // Saída PWM
        pwm <= (contagem < (largura * valor_inicial)); 

        end else begin
            contagem <= contagem + 1;
        end
    end
end

endmodule
