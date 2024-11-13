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

module SGA_UC (
    input               clock,
    input               restart, 
    input               start,
    input               pause,
    input               chosen_play_time,
    input               render_finish,
    input               left,
    input               right,
    input               up,
    input               down,
    input               end_move,
	input               comeu_maca,
    input               wall_collision,
    input               win_game,
    input               maca_na_cobra,
    input               self_collision,
	input               end_wait_time,
    input [1:0]         interface_direction,
    input               fim_inter,
    output reg          load_size,
    output reg          clear_size,
    output reg          count_size,
    output reg          render_clr,
    output reg          render_count,
    output reg          register_apple,
    output reg          reset_apple,
    output reg          register_eat_apple,
    output reg          reset_eat_apple,
    output reg          register_head,
    output reg          reset_head,
    output reg          finished,
    output reg          won,
    output reg          lost, 
    output reg          count_play_time,
    output reg [5:0]    db_state,
    output reg          we_ram,
    output reg          mux_ram,
    output reg          recharge,
    output reg          clr_apple_counter,
    output reg          mux_apple,
    output reg          count_apple_counter,
    output reg          load_ram,
    output reg          counter_ram,
    output reg          mux_ram_addres,
    output reg          zera_counter_play_time,
    output reg          register_game_parameters,
    output reg          reset_game_parameters,
    output reg          mux_ram_render,
	output reg          count_wait_time,
	output reg          reset_value,
    output reg          inicio_transmissao,
    output reg          medir,
    output reg          reset_interface,
    output reg          libera_alarme,
    output reg          conta_inter,
    output reg          enable_interface,
    output reg          counter_direction
);

    // Define estados
    parameter IDLE                      = 6'b000000;  // 0
    parameter PREPARA                   = 6'b000001;  // 1
    parameter GERA_MACA_INICIAL         = 6'b000010;  // 2
    parameter INICIO_JOGADA             = 6'b000011;  // 3
    parameter ESPERA                    = 6'b000100;  // 4
    parameter REGISTRA                  = 6'b000101;  // 5
    parameter MOVE                      = 6'b000110;  // 6
    parameter COMPARA                   = 6'b000111;  // 7
    parameter VERIFICA_MACA             = 6'b001000;  // 8
    parameter CRESCE                    = 6'b001001;  // 9
    parameter GERA_MACA                 = 6'b001010;  // A
    parameter PAUSOU                    = 6'b001011;  // B
    parameter SALVA_CABECA              = 6'b001100;  // C
    parameter PERDEU                    = 6'b001101;  // D
    parameter GANHOU                    = 6'b001110;  // E
    parameter MUDA_DIRECAO              = 6'b001111;  // F
    parameter REGISTRA_DIRECAO          = 6'b010000;  // 10
    parameter CONTA_RAM                 = 6'b010001;  // 11
    parameter WRITE_RAM                 = 6'b010010;  // 12
    parameter COMPARA_RAM               = 6'b010011;  // 13
    // parameter RESETMATRIZ               = 6'b010100;  // 14
    parameter COMPARA_SELF              = 6'b010101;  // 15
    parameter CONTA_SELF                = 6'b010110;  // 16
    parameter ATUALIZA_MEMORIA_SELF     = 6'b010111;  // 17
    parameter COMPARA_MACA              = 6'b011000;  // 18
    parameter CONTA_MACA                = 6'b011001;  // 19
    parameter ATUALIZA_MEMORIA_MACA     = 6'b011010;  // 1A
    parameter PREPARA_MEDIDA            = 6'b011011;  // 1B
	parameter COMEU_MACA_ESPERA         = 6'b011100;  // 1C
    parameter GERA_MACA_NAO_RAN         = 6'b011101;  // 1D
    parameter CONTA_MACA_POS            = 6'b011110;  // 1E
    parameter AGUARDA_MEDIDA            = 6'b011111;  // 1F
    // parameter CONTA_CARACTERES          = 6'b100000;  // 20

    // Variaveis de estado
    reg [5:0] Ecurrent, Enext;
	 reg flag;

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
            IDLE:                   Enext = start ? PREPARA : IDLE;
            PREPARA:                Enext = GERA_MACA_INICIAL;
            GERA_MACA_INICIAL:      Enext = INICIO_JOGADA;
            INICIO_JOGADA:          Enext = PREPARA_MEDIDA;
            // PROXIMO_RENDER:         Enext = ATUALIZA_MEMORIA;
            // ATUALIZA_MEMORIA:       Enext = RENDERIZA;
            PREPARA_MEDIDA:         Enext = AGUARDA_MEDIDA;
            AGUARDA_MEDIDA:         Enext = fim_inter ? REGISTRA_DIRECAO : AGUARDA_MEDIDA;
            REGISTRA_DIRECAO:       Enext = ESPERA;
            MUDA_DIRECAO:           Enext = REGISTRA;
            ESPERA:                 Enext = pause ? PAUSOU : (chosen_play_time ? MUDA_DIRECAO : ESPERA);
            REGISTRA:               Enext = COMPARA;
            COMPARA:                Enext = !wall_collision ? CONTA_SELF : PERDEU;
            COMPARA_SELF:           Enext = !self_collision ? (render_finish ? VERIFICA_MACA : CONTA_SELF) : PERDEU;
            CONTA_SELF:             Enext = ATUALIZA_MEMORIA_SELF;
            ATUALIZA_MEMORIA_SELF:  Enext = COMPARA_SELF;
            VERIFICA_MACA:          Enext = !comeu_maca ? MOVE : (win_game ? GANHOU : CRESCE);
            COMEU_MACA_ESPERA:      Enext = end_wait_time ? GERA_MACA: COMEU_MACA_ESPERA;
            CRESCE:                 Enext = COMEU_MACA_ESPERA;
            GERA_MACA:              Enext = COMPARA_MACA;
            COMPARA_MACA:           Enext = maca_na_cobra ? GERA_MACA_NAO_RAN : (render_finish ? MOVE : CONTA_MACA);
            CONTA_MACA:             Enext = ATUALIZA_MEMORIA_MACA;
            ATUALIZA_MEMORIA_MACA:  Enext = COMPARA_MACA;
            GERA_MACA_NAO_RAN:      Enext = CONTA_MACA_POS;
            CONTA_MACA_POS:         Enext = COMPARA_MACA;
            MOVE:                   Enext = WRITE_RAM;
            WRITE_RAM:              Enext = COMPARA_RAM;
            COMPARA_RAM:            Enext = end_move ? SALVA_CABECA : CONTA_RAM;
            CONTA_RAM:              Enext = MOVE;
            PAUSOU:                 Enext = start ? ESPERA : PAUSOU;
            SALVA_CABECA:           Enext = INICIO_JOGADA;
            GANHOU:                 Enext = start ? PREPARA : GANHOU;
            PERDEU:                 Enext = start ? PREPARA : PERDEU;
            default:                Enext = IDLE;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        load_size                   = (Ecurrent == IDLE || Ecurrent == PREPARA) ? 1'b1 : 1'b0;
        clear_size                  = (Ecurrent == IDLE) ? 1'b1 : 1'b0;
        count_size                  = (Ecurrent == CRESCE) ? 1'b1 : 1'b0;
        render_clr                  = (Ecurrent == IDLE || Ecurrent == ESPERA || Ecurrent == COMPARA || Ecurrent == VERIFICA_MACA|| Ecurrent == MOVE || Ecurrent == GERA_MACA_NAO_RAN) ? 1'b1 : 1'b0;
        render_count                = (Ecurrent == CONTA_SELF || Ecurrent == CONTA_MACA) ? 1'b1 : 1'b0;
        register_apple              = (Ecurrent == GERA_MACA || Ecurrent == GERA_MACA_INICIAL || Ecurrent == GERA_MACA_NAO_RAN) ? 1'b1 : 1'b0;
        reset_apple                 = (Ecurrent == IDLE || Ecurrent == PREPARA);
        register_eat_apple          = (Ecurrent == VERIFICA_MACA) ? 1'b1 : 1'b0;
        reset_eat_apple             = (Ecurrent == IDLE || Ecurrent == PREPARA || Ecurrent == ESPERA);
        register_head               = (Ecurrent == REGISTRA) ? 1'b1 : 1'b0;
        reset_head                  = (Ecurrent == IDLE);
        finished                    = (Ecurrent == GANHOU || Ecurrent == PERDEU) ? 1'b1 : 1'b0;
        won                         = (Ecurrent == GANHOU) ? 1'b1 : 1'b0;
        lost                        = (Ecurrent == PERDEU) ? 1'b1 : 1'b0;
        count_play_time             = (Ecurrent == ESPERA) ? 1'b1 : 1'b0;
        count_wait_time             = (Ecurrent == COMEU_MACA_ESPERA) ? 1'b1 : 1'b0;
        we_ram                      = (Ecurrent == WRITE_RAM|| Ecurrent == SALVA_CABECA) ? 1'b1 : 1'b0;
        mux_ram                     = (Ecurrent == CONTA_RAM || Ecurrent == MOVE || Ecurrent == WRITE_RAM || Ecurrent == COMPARA_RAM) ? 1'b1 : 1'b0;
        load_ram                    = (Ecurrent == REGISTRA) ? 1'b1 : 1'b0;
        counter_ram                 = (Ecurrent == CONTA_RAM) ? 1'b1 : 1'b0;
        mux_ram_addres              = (Ecurrent == WRITE_RAM) ? 1'b1 : 1'b0;
        mux_ram_render              = (Ecurrent == CONTA_RAM || Ecurrent == MOVE || Ecurrent == WRITE_RAM || Ecurrent == COMPARA_RAM) ? 1'b1 : 1'b0;
        zera_counter_play_time      = (Ecurrent == PAUSOU) ? 1'b1 : 1'b0;
        register_game_parameters    = (Ecurrent == PREPARA) ? 1'b1 : 1'b0;
        reset_game_parameters       = (Ecurrent == IDLE) ? 1'b1 : 1'b0;
        reset_value                 = (Ecurrent == PERDEU || Ecurrent == GANHOU) ? 1'b1 : 1'b0;
        clr_apple_counter           = (Ecurrent == ESPERA) ? 1'b1 : 1'b0;
        mux_apple                   = (Ecurrent == GERA_MACA_NAO_RAN || Ecurrent == COMPARA_MACA) ? 1'b1 : 1'b0;
        count_apple_counter         = (Ecurrent == CONTA_MACA_POS) ? 1'b1 : 1'b0;
        inicio_transmissao          = (Ecurrent == ESPERA || Ecurrent == PAUSOU || Ecurrent == GANHOU || Ecurrent == PERDEU || Ecurrent == IDLE) ? 1'b1 : 1'b0;
        medir                       = (Ecurrent == PREPARA_MEDIDA) ? 1'b1 : 1'b0;
        reset_interface             = (Ecurrent == INICIO_JOGADA) ? 1'b1 : 1'b0;
        conta_inter                 = (Ecurrent == AGUARDA_MEDIDA) ? 1'b1 : 1'b0;
        enable_interface            = (Ecurrent == REGISTRA_DIRECAO) ? 1'b1 : 1'b0;
        counter_direction           = (Ecurrent == MUDA_DIRECAO)  ? 1'b1 : 1'b0;


        // Mudança de Posição
        // Direita 00
        // Esquerda 10 
        // Cima 11
        // Baixo 01
        // interface direction = {dir, esq}
		  
        // Saida de depuracao (estado)
        case (Ecurrent)
            IDLE                       : db_state = 6'b000000;  // 00
            PREPARA                    : db_state = 6'b000001;  // 01
            GERA_MACA_INICIAL          : db_state = 6'b000010;  // 02
            INICIO_JOGADA              : db_state = 6'b000011;  // 03
            ESPERA                     : db_state = 6'b000100;  // 04
            REGISTRA                   : db_state = 6'b000101;  // 05
            MOVE                       : db_state = 6'b000110;  // 06
            COMPARA                    : db_state = 6'b000111;  // 07
            VERIFICA_MACA              : db_state = 6'b001000;  // 08
            CRESCE                     : db_state = 6'b001001;  // 09
            GERA_MACA                  : db_state = 6'b001010;  // 0A
            PAUSOU                     : db_state = 6'b001011;  // 0B
            SALVA_CABECA               : db_state = 6'b001100;  // 0C
            PERDEU                     : db_state = 6'b001101;  // 0D
            GANHOU                     : db_state = 6'b001110;  // 0E
            MUDA_DIRECAO               : db_state = 6'b001111;  // 0F
            REGISTRA_DIRECAO           : db_state = 6'b010000;  // 10
            CONTA_RAM                  : db_state = 6'b010001;  // 11
            WRITE_RAM                  : db_state = 6'b010010;  // 12
            COMPARA_RAM                : db_state = 6'b010011;  // 13
            // RESETMATRIZ                : db_state = 6'b010100;  // 14
            COMPARA_SELF               : db_state = 6'b010101;  // 15
            CONTA_SELF                 : db_state = 6'b010110;  // 16
            ATUALIZA_MEMORIA_SELF      : db_state = 6'b010111;  // 17
            COMPARA_MACA               : db_state = 6'b011000;  // 18
            CONTA_MACA                 : db_state = 6'b011001;  // 19
            ATUALIZA_MEMORIA_MACA      : db_state = 6'b011010;  // 1A
            // TRANSMITE                  : db_state = 6'b011011;  // 1B
            COMEU_MACA_ESPERA          : db_state = 6'b011100;  // 1C
            GERA_MACA_NAO_RAN          : db_state = 6'b011101;  // 1D
            CONTA_MACA_POS             : db_state = 6'b011110;  // 1E
            // ESPERA_TRANSMISSAO         : db_state = 6'b011111;  // 1F
            // CONTA_CARACTERES           : db_state = 6'b100000;  // 20
            default                    : db_state = 6'b000000;  // 00
        endcase
    end

endmodule