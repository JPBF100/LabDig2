/*
 * circuito_pwm_3.v - descrição comportamental
 *
 * gera saída com modulacao pwm conforme parametros do modulo
 *
 * parametros: valores definidos para clock de 50MHz (periodo=20ns)
 * ------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     26/09/2021  1.0     Edson Midorikawa  criacao do componente VHDL
 *     17/08/2024  2.0     Edson Midorikawa  componente em Verilog
 *     25/09/2024  3.0     Erick Sousa       versão para 8 larguras (3 bits de entrada)
 * ------------------------------------------------------------------------
 */
 
module circuito_pwm_3 #(    // valores default
    parameter conf_periodo = 1250, // Período do sinal PWM [1250 => f=40KHz (25us)]
    parameter largura_000   = 0,    // Largura do pulso p/ 000 [0 => 0]
    parameter largura_001   = 50,   // Largura do pulso p/ 001 [50 => 1us]
    parameter largura_010   = 100,  // Largura do pulso p/ 010 [100 => 2us]
    parameter largura_011   = 200,  // Largura do pulso p/ 011 [200 => 4us]
    parameter largura_100   = 350,  // Largura do pulso p/ 100 [350 => 7us]
    parameter largura_101   = 500,  // Largura do pulso p/ 101 [500 => 10us]
    parameter largura_110   = 750,  // Largura do pulso p/ 110 [750 => 15us]
    parameter largura_111   = 1000  // Largura do pulso p/ 111 [1000 => 20us]
) (
    input        clock,
    input        reset,
    input  [2:0] largura,
    output reg   pwm
);

reg [31:0] contagem; // Contador interno (32 bits) para acomodar conf_periodo
reg [31:0] largura_pwm;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        contagem <= 0;
        pwm <= 0;
        largura_pwm <= largura_000; // Valor inicial da largura do pulso
    end else begin
        // Saída PWM
        pwm <= (contagem < largura_pwm);

        // Atualização do contador e da largura do pulso
        if (contagem == conf_periodo - 1) begin
            contagem <= 0;
            case (largura)
                3'b000: largura_pwm <= largura_000;
                3'b001: largura_pwm <= largura_001;
                3'b010: largura_pwm <= largura_010;
                3'b011: largura_pwm <= largura_011;
                3'b100: largura_pwm <= largura_100;
                3'b101: largura_pwm <= largura_101;
                3'b110: largura_pwm <= largura_110;
                3'b111: largura_pwm <= largura_111;
                default: largura_pwm <= largura_000; // Valor padrão
            endcase
        end else begin
            contagem <= contagem + 1;
        end
    end
end

endmodule
