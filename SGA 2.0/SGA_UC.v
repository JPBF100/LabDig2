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
    input      clock,
    input      restart, 
    input      start,
    input      pause,
    input      chosen_play_time,
    input      render_finish,
    input      left,
    input      right,
    input      up,
    input      down,
    input      played,
    input      end_move,
	input      comeu_maca,
    input      wall_collision,
    input      win_game,
    input      maca_na_cobra,
    input      self_collision_on,
    input      self_collision,
	input      end_wait_time,
    input      fim_digito,
    input      fim_envio,
    output reg load_size,
    output reg clear_size,
    output reg count_size,
    output reg render_clr,
    output reg render_count,
    output reg register_apple,
    output reg reset_apple,
    output reg register_eat_apple,
    output reg reset_eat_apple,
    output reg register_head,
    output reg reset_head,
    output reg finished,
    output reg won,
    output reg lost, 
    output reg count_play_time,
    output reg [5:0] db_state,
    output reg [1:0] direction,
    output reg we_ram,
    output reg mux_ram,
    output reg recharge,
    output reg clr_apple_counter,
    output reg mux_apple,
    output reg count_apple_counter,
    output reg load_ram,
    output reg counter_ram,
    output reg mux_ram_addres,
    output reg zera_counter_play_time,
    output reg register_game_parameters,
    output reg reset_game_parameters,
    output reg mux_ram_render,
	output reg count_wait_time,
	output reg reset_value,
    output reg comeca_transmissao,
    output reg conta_digito
);

    // Define estados
    parameter IDLE                      = 6'b000000;  // 0
    parameter PREPARA                   = 6'b000001;  // 1
    parameter GERA_MACA_INICIAL         = 6'b000010;  // 2
    parameter RENDERIZA                 = 6'b000011;  // 3
    parameter ESPERA                    = 6'b000100;  // 4
    parameter REGISTRA                  = 6'b000101;  // 5
    parameter MOVE                      = 6'b000110;  // 6
    parameter COMPARA                   = 6'b000111;  // 7
    parameter VERIFICA_MACA             = 6'b001000;  // 8
    parameter CRESCE                    = 6'b001001;  // 9
    parameter GERA_MACA                 = 6'b001010;  // A
    parameter PAUSOU                    = 6'b001011;  // B
    parameter FEZ_NADA                  = 6'b001100;  // C
    parameter PERDEU                    = 6'b001101;  // D
    parameter GANHOU                    = 6'b001110;  // E
    parameter PROXIMO_RENDER            = 6'b001111;  // F
    parameter ATUALIZA_MEMORIA          = 6'b010000;  // 10
    parameter ContaRAM                  = 6'b010001;  // 11
    parameter WriteRAM                  = 6'b010010;  // 12
    parameter ComparaRAM                = 6'b010011;  // 13
    parameter RESETMATRIZ               = 6'b010100;  // 14
    parameter COMPARASELF               = 6'b010101;  // 15
    parameter CONTASELF                 = 6'b010110;  // 16
    parameter ATUALIZA_MEMORIASELF      = 6'b010111;  // 17
    parameter COMPARAMACA               = 6'b011000;  // 18
    parameter CONTAMACA                 = 6'b011001;  // 19
    parameter ATUALIZA_MEMORIAMACA      = 6'b011010;  // 1A
    parameter TRANSMITE                 = 6'b011011;  // 1B
	parameter COMEU_MACA_ESPERA         = 6'b011100;  // 1C
    parameter GERA_MACA_NAO_RAN         = 6'b011101;  // 1D
    parameter CONTA_MACA_POS            = 6'b011110;  // 1E
    parameter ESPERA_TRANSMISSAO        = 6'b011111;  // 1F
    parameter CONTA_CARACTERES          = 6'b100000;  // 20

    // Variaveis de estado
    reg [5:0] Ecurrent, Enext;

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
            GERA_MACA_INICIAL:      Enext = RENDERIZA;
            RENDERIZA:              Enext = render_finish ? TRANSMITE : PROXIMO_RENDER;
            PROXIMO_RENDER:         Enext = ATUALIZA_MEMORIA;
            ATUALIZA_MEMORIA:       Enext = RENDERIZA;
            TRANSMITE:               Enext = ESPERA_TRANSMISSAO;
            ESPERA_TRANSMISSAO:      Enext = fim_digito ? CONTA_CARACTERES : ESPERA_TRANSMISSAO;
            CONTA_CARACTERES:        Enext = fim_envio ? ESPERA : TRANSMITE;
            ESPERA:                 Enext = pause ? PAUSOU : (chosen_play_time ? REGISTRA : ESPERA);
            REGISTRA:               Enext = COMPARA;
            COMPARA:                Enext = !wall_collision ? (self_collision_on ? CONTASELF : VERIFICA_MACA) : PERDEU;
            COMPARASELF:            Enext = !self_collision ? (render_finish ? VERIFICA_MACA : CONTASELF) : PERDEU;
            CONTASELF:              Enext = ATUALIZA_MEMORIASELF;
            ATUALIZA_MEMORIASELF:   Enext = COMPARASELF;
		    VERIFICA_MACA:          Enext = !comeu_maca ? MOVE : (win_game ? GANHOU : CRESCE);
		    COMEU_MACA_ESPERA:      Enext = end_wait_time ? GERA_MACA: COMEU_MACA_ESPERA;
		    CRESCE:                 Enext = COMEU_MACA_ESPERA;
		    GERA_MACA:              Enext = COMPARAMACA;
            COMPARAMACA:            Enext = maca_na_cobra ? GERA_MACA_NAO_RAN : (render_finish ? MOVE : CONTAMACA);
            CONTAMACA:              Enext = ATUALIZA_MEMORIAMACA;
            ATUALIZA_MEMORIAMACA:   Enext = COMPARAMACA;
            GERA_MACA_NAO_RAN:      Enext = CONTA_MACA_POS;
            CONTA_MACA_POS:         Enext = COMPARAMACA;
            MOVE:                   Enext = WriteRAM;
            WriteRAM:               Enext = ComparaRAM;
            ComparaRAM:             Enext = end_move ? FEZ_NADA : ContaRAM;
            ContaRAM:               Enext = MOVE;
            PAUSOU:                 Enext = start ? ESPERA : PAUSOU;
            FEZ_NADA:               Enext = RESETMATRIZ;
            RESETMATRIZ:            Enext = RENDERIZA;
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
        recharge                    = (Ecurrent == RESETMATRIZ || Ecurrent == IDLE || Ecurrent == PREPARA || Ecurrent == GERA_MACA_INICIAL) ? 1'b1 : 1'b0;
        render_clr                  = (Ecurrent == IDLE || Ecurrent == ESPERA || Ecurrent == COMPARA || Ecurrent == VERIFICA_MACA || Ecurrent == RESETMATRIZ || Ecurrent == MOVE || Ecurrent == GERA_MACA_NAO_RAN) ? 1'b1 : 1'b0;
        render_count                = (Ecurrent == PROXIMO_RENDER || Ecurrent == CONTASELF || Ecurrent == CONTAMACA) ? 1'b1 : 1'b0;
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
        we_ram                      = (Ecurrent == WriteRAM|| Ecurrent == FEZ_NADA) ? 1'b1 : 1'b0;
        mux_ram                     = (Ecurrent == ContaRAM || Ecurrent == MOVE || Ecurrent == WriteRAM || Ecurrent == ComparaRAM) ? 1'b1 : 1'b0;
        load_ram                    = (Ecurrent == REGISTRA) ? 1'b1 : 1'b0;
        counter_ram                 = (Ecurrent == ContaRAM) ? 1'b1 : 1'b0;
        mux_ram_addres              = (Ecurrent == WriteRAM) ? 1'b1 : 1'b0;
        mux_ram_render              = (Ecurrent == ContaRAM || Ecurrent == MOVE || Ecurrent == WriteRAM || Ecurrent == ComparaRAM) ? 1'b1 : 1'b0;
        zera_counter_play_time      = (Ecurrent == PAUSOU) ? 1'b1 : 1'b0;
        register_game_parameters    = (Ecurrent == PREPARA) ? 1'b1 : 1'b0;
        reset_game_parameters       = (Ecurrent == IDLE) ? 1'b1 : 1'b0;
		reset_value                 = (Ecurrent == PERDEU || Ecurrent == GANHOU) ? 1'b1 : 1'b0;
        clr_apple_counter           = (Ecurrent == ESPERA) ? 1'b1 : 1'b0;
        mux_apple                   = (Ecurrent == GERA_MACA_NAO_RAN || Ecurrent == COMPARAMACA) ? 1'b1 : 1'b0;
        count_apple_counter         = (Ecurrent == CONTA_MACA_POS) ? 1'b1 : 1'b0;
        comeca_transmissao          = (Ecurrent == TRANSMITE) ? 1'b1 : 1'b0;
        conta_digito                = (Ecurrent == CONTA_CARACTERES) ? 1'b1 : 1'b0;


        // Mudança de Posição
        if (restart) begin                      
        direction <= 2'b00;                    
        end else begin
				  if (left && direction != 2'b00 && Ecurrent != PAUSOU)  
						direction <= 2'b01;
				  if (right && direction != 2'b01 && Ecurrent != PAUSOU)  
						direction <= 2'b00;
				  if (up && direction != 2'b10 && Ecurrent != PAUSOU)     
						direction <= 2'b11;                     
				  if (down && direction != 2'b11 && Ecurrent != PAUSOU)     
						direction <= 2'b10;                   
				end
        
        // Saida de depuracao (estado)
        case (Ecurrent)
            IDLE                       : db_state = 6'b000000;  // 00
            PREPARA                    : db_state = 6'b000001;  // 01
            GERA_MACA_INICIAL          : db_state = 6'b000010;  // 02
            RENDERIZA                  : db_state = 6'b000011;  // 03
            ESPERA                     : db_state = 6'b000100;  // 04
            REGISTRA                   : db_state = 6'b000101;  // 05
            MOVE                       : db_state = 6'b000110;  // 06
            COMPARA                    : db_state = 6'b000111;  // 07
            VERIFICA_MACA              : db_state = 6'b001000;  // 08
            CRESCE                     : db_state = 6'b001001;  // 09
            GERA_MACA                  : db_state = 6'b001010;  // 0A
            PAUSOU                     : db_state = 6'b001011;  // 0B
            FEZ_NADA                   : db_state = 6'b001100;  // 0C
            PERDEU                     : db_state = 6'b001101;  // 0D
            GANHOU                     : db_state = 6'b001110;  // 0E
            PROXIMO_RENDER             : db_state = 6'b001111;  // 0F
            ATUALIZA_MEMORIA           : db_state = 6'b010000;  // 10
            ContaRAM                   : db_state = 6'b010001;  // 11
            WriteRAM                   : db_state = 6'b010010;  // 12
            ComparaRAM                 : db_state = 6'b010011;  // 13
            RESETMATRIZ                : db_state = 6'b010100;  // 14
            COMPARASELF                : db_state = 6'b010101;  // 15
            CONTASELF                  : db_state = 6'b010110;  // 16
            ATUALIZA_MEMORIASELF       : db_state = 6'b010111;  // 17
            COMPARAMACA                : db_state = 6'b011000;  // 18
            CONTAMACA                  : db_state = 6'b011001;  // 19
            ATUALIZA_MEMORIAMACA       : db_state = 6'b011010;  // 1A
            TRANSMITE                  : db_state = 6'b011011;  // 1B
			COMEU_MACA_ESPERA          : db_state = 6'b011100;  // 1C
            GERA_MACA_NAO_RAN          : db_state = 6'b011101;  // 1D
            CONTA_MACA_POS             : db_state = 6'b011110;  // 1E
            ESPERA_TRANSMISSAO         : db_state = 6'b011111;  // 1F
            CONTA_CARACTERES           : db_state = 6'b100000;  // 20
            default                    : db_state = 6'b000000;  // 00
        endcase
    end

endmodule