/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm_uc-PARCIAL.v
 * --------------------------------------------------------------------------
 *  Descricao : unidade de controle do componente contador_cm
 *              
 *              incrementa contagem de cm a cada sinal de tick enquanto
 *              o pulso de entrada permanece ativo
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

module contador_cm_uc (
    input wire clock,
    input wire reset,
    input wire pulso,
    input wire tick,
    output reg zera_tick,
    output reg conta_tick,
    output reg zera_bcd,
    output reg conta_bcd,
    output reg pronto
);

    // Tipos e sinais
    reg [2:0] Eatual, Eprox; // 3 bits são suficientes para os estados

    // Parâmetros para os estados
    parameter inicial = 3'b000;
    parameter conta_m = 3'b001;
    parameter conta_bcd_circ = 3'b010;
    parameter espera_pulso = 3'b011;
    parameter fim = 3'b100;

    // Memória de estado
    always @(posedge clock, posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial: Eprox = espera_pulso;
            espera_pulso: Eprox = pulso ? conta_m : espera_pulso;
            conta_m: Eprox = pulso ? (tick ? conta_bcd_circ: conta_m) : fim;
            conta_bcd_circ: Eprox = pulso ? conta_m : fim;
            fim: Eprox = inicial;
        endcase
    end

    // Lógica de saída (Moore)
    always @(*) begin
        zera_bcd = (Eatual == inicial) ? 1'b1 : 1'b0;
        zera_tick = (Eatual == inicial) ? 1'b1 : 1'b0;
        conta_tick = (Eatual == conta_m || Eatual == conta_bcd_circ) ? 1'b1 : 1'b0;
        conta_bcd = (Eatual == conta_bcd_circ) ? 1'b1 : 1'b0;
        pronto = (Eatual == fim) ? 1'b1 : 1'b0;
		
    end

endmodule