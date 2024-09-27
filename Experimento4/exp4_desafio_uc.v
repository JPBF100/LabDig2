/* --------------------------------------------------------------------------
 *  Arquivo   : trena_uc.v
 * --------------------------------------------------------------------------
 *  Descricao : Codigo da unidade de controle da trena digital 
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      20/09/2024  1.0     Erick Sousa       versao inicial
 * --------------------------------------------------------------------------
 */
 
module exp4_desafio_uc (
    input wire       clock,
    input wire       reset,
    input wire       mensurar,
    input wire       echo,
    input wire       fim_medida,
    input wire       fim_digito,
    input wire       fim_envio,
    input wire       fim_timeout,
    input wire       parar,
    output reg       zera,
    output reg       conta,
    output reg       partida,
    output reg       comeca_medida,
    output reg       pronto,
    output reg       conta_timeout,
    output reg [2:0] db_estado 

);

    // Tipos e sinais
    reg [2:0] Eatual, Eprox;

    // Parâmetros para os estados
    parameter inicial          = 3'b000;
    parameter preparacao       = 3'b001;
    parameter aguarda_medida   = 3'b010;
    parameter transmite        = 3'b011;
	 parameter conta_caracteres = 3'b111;
	 parameter timeout          = 3'b110;
    parameter espera           = 3'b100;
    parameter finali           = 3'b101;

    // Estado
    always @(posedge clock, posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial: Eprox = mensurar ? preparacao : inicial;
            preparacao: Eprox = aguarda_medida;
            aguarda_medida: Eprox = fim_medida ? transmite : aguarda_medida;
            transmite: Eprox = espera;
            espera: Eprox = fim_digito ? conta_caracteres : espera;
			conta_caracteres: Eprox = fim_envio ? timeout : transmite;
            timeout: Eprox = parar ? finali : (fim_timeout ? preparacao : timeout);
            finali: Eprox = inicial;
            default: Eprox = inicial;	
        endcase
    end

    // Saídas de controle
    always @(*) begin
        zera = (Eatual == preparacao || Eatual == inicial) ? 1'b1 : 1'b0;
        comeca_medida = (Eatual == aguarda_medida) ? 1'b1 : 1'b0;
        conta = (Eatual == conta_caracteres) ? 1'b1 : 1'b0;
        partida = (Eatual == transmite) ? 1'b1 : 1'b0;
        pronto = (Eatual == finali) ? 1'b1 : 1'b0;
        conta_timeout = (Eatual == timeout) ? 1'b1 : 1'b0;

        case (Eatual)
            inicial:            db_estado = 3'b000; // 0
            preparacao:         db_estado = 3'b001; // 1
            aguarda_medida:     db_estado = 3'b010; // 2
            transmite:          db_estado = 3'b011; // 3
            espera:             db_estado = 3'b100; // 4
            finali:             db_estado = 3'b101; // 5
            timeout:            db_estado = 3'b110; // 6 
		      conta_caracteres:   db_estado = 3'b111; // 7 
            default:            db_estado = 3'b000; // 0
        endcase
    end

endmodule
