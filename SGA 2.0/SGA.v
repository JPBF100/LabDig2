/* --------------------------------------------------------------------
 * Arquivo   : SGA.v
 * Projeto   : Snake Game Arcade
 * --------------------------------------------------------------------
 * Descricao : Circuito completo
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                          Descricao
 *     08/03/2024  1.0     Erick Sousa, João Bassetti                   versao inicial
 *     13/03/2024  1.0     Erick Sousa, João Bassetti, Carlos Engler    Semana 2
 * --------------------------------------------------------------------
*/


module SGA (
 input          clock,
 input          [3:0] buttons,
 input          start,
 input          restart,
 input          pause,
 input          difficulty,
 input          mode,
 input          velocity,
 output         [5:0] db_size, 
 output         [6:0] db_state,
 output         [6:0] db_state2,
 output         [6:0] db_headX,
 output         [6:0] db_headY,
 output         [6:0] db_appleX,
 output         [6:0] db_appleY,
 output         [1:0] direction,
 output         won,
 output         lost,
 output wire    saida_serial,
 output		    comeu_maca
);

wire w_clr_size;
wire w_count_size;
wire w_render_clr;
wire w_render_count;
wire w_render_finish;
wire w_register_apple;
wire w_reset_apple;
wire w_register_head;
wire w_reset_head;
wire w_load_size;
wire w_count_play_time;
wire w_count_wait_time;
wire w_chosen_play_time;
wire w_played;
wire [1:0] w_direction;
wire w_we_ram;
wire w_mux_ram;
wire w_recharge;
wire w_wall_collision;
wire w_win_game;
wire w_maca_na_cobra;

wire [5:0] s_estado;
wire [5:0] s_apple;
wire [5:0] s_head;

wire w_load_ram;
wire w_counter_ram;
wire w_mux_ram_addres;
wire w_mux_ram_render;
wire w_end_move;
wire w_comeu_maca;
wire w_self_collision_on;
wire w_self_collision;
wire w_zera_counter_play_time;
wire w_register_game_parameters;
wire w_reset_game_parameters;
wire w_comeu_maca_esp;
wire w_register_eat_apple;
wire w_reset_eat_apple;
wire w_end_wait_time;
wire w_reset_value;
wire w_clr_apple_counter;
wire w_mux_apple;
wire w_count_apple_counter;
wire s_conta_digito;
wire s_fim_envio;
wire s_fim_digito;
wire s_comeca_transmissao;

// Circuito Principal

	SGA_FD FD(
        .clock(clock),
        .buttons(buttons),
        .restart(restart | w_reset_value),
        .mode(mode),
        .difficulty(difficulty),
        .velocity(velocity),
        .clear_size(w_clr_size),
        .count_size(w_count_size),
        .render_clr(w_render_clr),
        .render_count(w_render_count),
        .render_finish(w_render_finish),
        .register_apple(w_register_apple),
        .reset_apple(w_reset_apple),
        .clr_apple_counter(w_clr_apple_counter),
        .mux_apple(w_mux_apple),
        .count_apple_counter(w_count_apple_counter),
        .register_eat_apple(w_register_eat_apple),
        .reset_eat_apple(w_reset_eat_apple),
        .register_head(w_register_head),
        .reset_head(w_reset_head),
        .db_tamanho(db_size),
		.count_wait_time(w_count_wait_time),
        .load_size(w_load_size),
        .db_apple(s_apple),
        .db_head(s_head),
        .count_play_time(w_count_play_time),
        .played(w_played),
        .we_ram(w_we_ram),
        .mux_ram(w_mux_ram),
        .chosen_play_time(w_chosen_play_time),
		.end_wait_time(w_end_wait_time),
        .direction(w_direction),
        .load_ram(w_load_ram),
        .counter_ram(w_counter_ram),
        .mux_ram_addres(w_mux_ram_addres),
        .mux_ram_render(w_mux_ram_render),
        .end_move(w_end_move),
		.comeu_maca(w_comeu_maca),
        .comeu_maca_esp(w_comeu_maca_esp),
        .wall_collision(w_wall_collision),
        .self_collision(w_self_collision),
        .self_collision_on(w_self_collision_on),
        .chosen_difficulty(w_win_game),
        .zera_counter_play_time(w_zera_counter_play_time),
        .register_game_parameters(w_register_game_parameters),
        .reset_game_parameters(w_reset_game_parameters),
        .maca_na_cobra(w_maca_na_cobra),
        .recharge(w_recharge)
    );

	SGA_UC UC(
        .clock(clock),
        .restart(restart), 
        .start(start),
        .chosen_play_time(w_chosen_play_time),
        .clear_size(w_clr_size),
        .count_size(w_count_size),
        .render_clr(w_render_clr),
        .render_count(w_render_count),
        .render_finish(w_render_finish),
        .register_apple(w_register_apple),
        .reset_apple(w_reset_apple),
        .register_head(w_register_head),
        .reset_head(w_reset_head),
        .finished(finished),
        .clr_apple_counter(w_clr_apple_counter),
        .mux_apple(w_mux_apple),
        .count_apple_counter(w_count_apple_counter),
        .won(won),
        .we_ram(w_we_ram),
		.count_wait_time(w_count_wait_time),
        .mux_ram(w_mux_ram),
        .lost(lost), 
        .load_size(w_load_size),
        .count_play_time(w_count_play_time),
        .db_state(s_estado),
        .left(buttons[3]),
        .right(buttons[0]),
        .up(buttons[2]),
        .down(buttons[1]),
        .played(w_played),
        .direction(w_direction),
		.end_wait_time(w_end_wait_time),
        .load_ram(w_load_ram),
        .counter_ram(w_counter_ram),
        .mux_ram_addres(w_mux_ram_addres),
        .mux_ram_render(w_mux_ram_render),
        .end_move(w_end_move),
        .wall_collision(w_wall_collision),
		.comeu_maca(w_comeu_maca),
        .self_collision(w_self_collision),
        .self_collision_on(w_self_collision_on),
        .win_game(w_win_game),
        .pause(~pause),
        .zera_counter_play_time(w_zera_counter_play_time),
        .register_game_parameters(w_register_game_parameters),
        .reset_game_parameters(w_reset_game_parameters),
        .maca_na_cobra(w_maca_na_cobra),
        .register_eat_apple(w_register_eat_apple),
        .reset_eat_apple(w_reset_eat_apple),
		.reset_value(w_reset_value),
        .recharge(w_recharge),
        .comeca_transmissao(s_comeca_transmissao),
        .fim_digito(s_fim_digito),
        .fim_envio(s_fim_envio),
        .conta_digito(s_conta_digito)
    );

// Fluxo de dados da Saida Serial

    Transmissao_Serial_FD SERIAL (
        .clock(clock),
        .render_clr(w_render_clr),
        .comeca_transmissao(s_comeca_transmissao),
        .conta_digito(s_conta_digito),
        .db_apple(s_apple),
        .db_head(s_head),
        .db_state(s_estado),
        .comeu_maca(w_comeu_maca_esp),
        .mode_out(mode),
        .velocity_out(velocity),
        .difficulty_out(difficulty),
        .fim_digito(s_fim_digito),
        .fim_envio(s_fim_envio),
        .saida_serial(saida_serial)
    );

// Displays da Placa Verilog

    hexa7seg HEX5(
        .hexa({2'b00, s_estado[5:4]}), .display(db_state2)
    );

        hexa7seg HEX4(
        .hexa(s_estado[3:0]), .display(db_state)
    );

        hexa7seg HEX3(
        .hexa({1'b0, s_apple[2:0]}), .display(db_appleX)
    );

        hexa7seg HEX2(
        .hexa({1'b0, s_apple[5:3]}), .display(db_appleY)
    );

        hexa7seg HEX1(
        .hexa({1'b0, s_head[2:0]}), .display(db_headX)
    );

        hexa7seg HEX0(
        .hexa({1'b0, s_head[5:3]}), .display(db_headY)
    );

    assign direction = w_direction;
    assign comeu_maca = w_comeu_maca_esp;

endmodule