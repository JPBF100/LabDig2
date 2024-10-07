/* --------------------------------------------------------------------------
 *  Arquivo   : sonar_uc.v
 * --------------------------------------------------------------------------
 *  Descricao : Codigo da unidade de controle do sonar 
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      27/09/2024  1.0     Erick Sousa       versao inicial
 * --------------------------------------------------------------------------
 */
 
module sonar_uc (
    input wire       clock,
    input wire       reset,
    input wire       ligar,
    input wire       fim_medida,
    input wire       fim_digito,
    input wire       fim_envio,
    input wire       fim_timeout,
	 input wire       silencio,
    output reg       zera,
    output reg       conta_digito,
    output reg       conta_timeout,
    output reg       conta_angulo,        
    output reg       comeca_transmissao,
    output reg       comeca_medida,
    output reg       pronto,
    output reg       fim_posicao,
    output reg [3:0] db_estado 

);

    // Tipos e sinais
    reg [3:0] Eatual, Eprox;

    // Parâmetros para os estados
    parameter inicial          = 4'b0000; // 0
    parameter preparacao       = 4'b0001; // 1
    parameter posiciona_servo  = 4'b0010; // 2
    parameter prepara_medida   = 4'b0011; // 3
    parameter reposiciona      = 4'b0100; // 4
	 parameter transmite        = 4'b0101; // 5
	 parameter aguarda_medida   = 4'b1010; // A
    parameter conta_caracteres = 4'b1100; // C
    parameter espera           = 4'b1110; // E
    parameter finali           = 4'b1111; // F

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
            inicial: Eprox = ligar ? preparacao : inicial;
            preparacao: Eprox = posiciona_servo;
            posiciona_servo: Eprox = ligar ? (fim_timeout ? prepara_medida : posiciona_servo) : finali;
            prepara_medida: Eprox = aguarda_medida;
            aguarda_medida: Eprox = fim_medida ? (silencio ? reposiciona : transmite) : aguarda_medida;
            transmite: Eprox = espera;
            espera: Eprox = fim_digito ? conta_caracteres : espera;
			   conta_caracteres: Eprox = fim_envio ? reposiciona : transmite;
            reposiciona: Eprox = posiciona_servo;
            finali: Eprox = inicial;
            default: Eprox = inicial;	
        endcase
    end

    // Saídas de controle
    always @(*) begin
        zera = (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        conta_timeout = (Eatual == posiciona_servo) ? 1'b1 : 1'b0;
        conta_digito = (Eatual == conta_caracteres) ? 1'b1 : 1'b0;
        conta_angulo = (Eatual == reposiciona) ? 1'b1 : 1'b0;
        comeca_medida = (Eatual == aguarda_medida) ? 1'b1 : 1'b0;
        comeca_transmissao = (Eatual == transmite) ? 1'b1 : 1'b0;
        fim_posicao = (Eatual == reposiciona) ? 1'b1 : 1'b0;
        pronto = (Eatual == finali) ? 1'b1 : 1'b0;

        case (Eatual)
            inicial:           db_estado = 4'b0000; // 0
            preparacao:        db_estado = 4'b0001; // 1
            posiciona_servo:   db_estado = 4'b0010; // 2
            prepara_medida:    db_estado = 4'b0011; // 3
            reposiciona:       db_estado = 4'b0100; // 4
            transmite:         db_estado = 4'b0101; // 5
            aguarda_medida:    db_estado = 4'b1010; // A
		      conta_caracteres:  db_estado = 4'b1100; // C 
            espera:            db_estado = 4'b1110; // E 
            finali:            db_estado = 4'b1111; // F 
            default:           db_estado = 4'b1011; // B
        endcase
    end

endmodule
