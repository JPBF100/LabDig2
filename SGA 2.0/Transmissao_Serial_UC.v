//------------------------------------------------------------------
// Arquivo   : SGA_UC.v
// Projeto   : Snake Game Arcade
//------------------------------------------------------------------
// Descricao : Unidade de controle            
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor                                          Descricao
//     08/03/2024  1.0     Erick Sousa, João Basseti                    versao inicial
//     13/03/2024  1.1     Erick Sousa, João Bassetti, Carlos Engler       Semana 2
//------------------------------------------------------------------
//

module Transmissao_Serial_UC (
    input      clock,
	input      restart,
    input      inicio, 
    input      fim_digito,
    input      fim_envio,
    input      fim_timeout,
    output reg [2:0] db_state,
    output reg comeca_transmissao,
    output reg conta_digito,
    output reg clear,
    output reg conta_timeout
);

    parameter IDLE                      = 3'b000;  // 0
    parameter TRANSMITE                 = 3'b001;  // 1
    parameter ESPERA_TRANSMISSAO        = 3'b010;  // 2
    parameter CONTA_CARACTERES          = 3'b011;  // 3
    parameter TIMEOUT                   = 3'b100;  // 4

    // Variaveis de estado
    reg [2:0] Ecurrent, Enext;

    // Memoria de estado
    always @(posedge clock or posedge restart) begin
        if (restart)
            Ecurrent <= IDLE;
        else
            Ecurrent <= Enext;
    end

    // Logica de proximo estado
    always @* begin
        case (Ecurrent)
            IDLE:                   Enext = inicio ? TRANSMITE : IDLE;
            TRANSMITE:              Enext = ESPERA_TRANSMISSAO;
            ESPERA_TRANSMISSAO:     Enext = fim_digito ? CONTA_CARACTERES : ESPERA_TRANSMISSAO;
            CONTA_CARACTERES:       Enext = fim_envio ? TIMEOUT : TRANSMITE;
            TIMEOUT:                Enext = fim_timeout ? IDLE : TIMEOUT;
            default:                Enext = IDLE;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        comeca_transmissao          = (Ecurrent == TRANSMITE) ? 1'b1 : 1'b0;
        conta_digito                = (Ecurrent == CONTA_CARACTERES) ? 1'b1 : 1'b0;
        clear                       = (Ecurrent == IDLE) ? 1'b1 : 1'b0;
        conta_timeout               = (Ecurrent == TIMEOUT) ? 1'b1 : 1'b0;
        
        // Saida de depuracao (estado)
        case (Ecurrent)
            IDLE                       : db_state = 3'b000;  // 0
            TRANSMITE                  : db_state = 3'b001;  // 1
            ESPERA_TRANSMISSAO         : db_state = 3'b010;  // 2
            CONTA_CARACTERES           : db_state = 3'b011;  // 3
            TIMEOUT                    : db_state = 3'b100;  // 4
            default                    : db_state = 3'b000;  // 0
        endcase
    end

endmodule