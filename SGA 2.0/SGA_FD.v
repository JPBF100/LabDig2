/* --------------------------------------------------------------------
 * Arquivo   : SGA_FD.v
 * Projeto   : Snake Game Arcade
 * --------------------------------------------------------------------
 * Descricao : Fluxo de Dados
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                        Descricao
 *     09/03/2024  1.0     Erick Sousa, João Bassetti                   versao inicial
 *     13/03/2024  1.1     Erick Sousa, João Bassetti, Carlos Engler    Semana 2 labdigi1
 *     04/03/2024  2.3     Erick Sousa, João Bassetti, Carlos Engler    Semana 3 labdigi2
 * --------------------------------------------------------------------
*/

module SGA_FD (
    input         clock,
    input         restart,
    input         clear_size,
    input         count_size,
    input         load_size,
    input         render_clr,
    input         render_count,
    input         register_apple,
    input         reset_apple,
    input         count_play_time,
	  input         count_wait_time,
    input         mux_apple,
    input         register_head,
    input         reset_head,
    input  [1:0]  direction,
    input         we_ram,
    input         mux_ram,
    input         load_ram,
    input         counter_ram,
    input         mux_ram_addres,
    input         mux_ram_render,
    input         zera_counter_play_time,
    input         mode,
    input         difficulty,
    input         velocity,
    input         register_game_parameters,
    input         reset_game_parameters,
    input         clr_apple_counter,
    input         count_apple_counter,
    input         register_eat_apple,
    input         reset_eat_apple,
    input         medir,
    input         echo_esq,
    input         echo_dir,
    input         reset_interface,
    input         conta_inter,
    output        self_collision,
    output        render_finish,
    output [5:0]  db_tamanho,
    output [5:0]  db_apple,
    output [5:0]  db_head,
    output        chosen_play_time,
    output        end_move,
	  output        end_wait_time,
    output        chosen_difficulty,
    output        wall_collision,
    output        maca_na_cobra,
	  output        comeu_maca,
    output        comeu_maca_esp,
    output        dir,
    output        esq,
    output        fim_inter,
    output wire   trigger_esq,
    output wire   trigger_dir   
    output wire [5:0]   apples_eaten;
);

    // Fiação

    // 26 bits
    wire [25:0] w_chosen_velocity;
    wire [25:0] w_actual_velocity;

    // 12 bits
    wire [11:0] s_medida_esq;
    wire [11:0] s_medida_dir;

    // 6 bits
	  wire [5:0] s_size;
    wire [5:0] s_address;
    wire [5:0] s_render_count;
	  wire [5:0] s_position;
    wire [5:0] s_apple;
    wire [5:0] w_new_apple;
    wire [5:0] s_new_apple;
    wire [5:0] head;
    wire [5:0] headXsoma;
    wire [5:0] headXsubtrai;
    wire [5:0] headYSoma;
    wire [5:0] headYSubtrai;
    wire [5:0] newHead;
    wire [5:0] dataRAM;
    wire [5:0] addresRAM;
    wire [5:0] renderRAM;
    wire [5:0] w_apple;
    wire [5:0] s_appleposition;

    // 1 bit
    wire sinal;
    wire w_end_play_time;
    wire w_end_play_time_half;
    wire w_win_game;
    wire w_win_easy_game;
    wire w_dificuldade;
    wire w_mode;
    wire w_velocity;
    wire w_wall_collision;
    wire w_reached_velocity;

//--------------------------------------------------------------------------------

// Modos de Jogo e Direção ----------------------------------

    assign chosen_play_time = w_velocity ? w_reached_velocity : w_end_play_time; // Define tempo total do jogo
    assign chosen_difficulty = w_dificuldade ? w_win_game : w_win_easy_game; // Define a dificuldade do jogo

// Contadores -------------------------------------------------------

  // Contador 163 -- Contadores dentro do jogo 

    contador_163_n #( .N(6), .RCO(14) ) snake_size (
      .clock    ( clock ),
      .clr      ( ~clear_size ), 
      .ld       ( ~load_size ),
      .enp      ( count_size ),
      .ent      ( 1'b1 ),
      .sub      ( 1'b0 ),
      .D        ( 6'b000001 ), 
      .Q        ( s_size ),
      .rco      ( w_win_game ),
      .half_rco ( w_win_easy_game ),
      .zero_rco ()
    ); // Tamanho da cobra

    contador_163_n #( .N(6) ) render_component (
      .clock    ( clock ),
      .clr      ( ~render_clr ), 
      .ld       ( 1'b1 ),
      .enp      ( render_count ),
      .ent      ( 1'b1 ),
      .sub      ( 1'b0 ),
      .D        ( 6'd0 ), 
      .Q        ( s_render_count ),
      .rco      (),
      .half_rco (),
      .zero_rco ()
    );

    contador_163_n #( .N(6) ) apple_counter (
      .clock    ( clock ),
      .clr      ( ~clr_apple_counter ), 
      .ld       ( 1'b1 ),
      .enp      ( count_apple_counter ),
      .ent      ( 1'b1 ),
      .sub      ( 1'b0 ),
      .D        ( 6'd0 ), 
      .Q        ( s_appleposition ),
      .rco      (),
      .half_rco (),
      .zero_rco ()
    ); // Quantidade de maças comidas

    assign apples_eaten = s_appleposition;
    
    contador_163_n #( .N(6) ) ram_counter (
      .clock    ( clock ),
      .clr      ( 1'b1 ), 
      .ld       ( ~load_ram ),
      .enp      ( counter_ram ),
      .ent      ( 1'b1 ),
      .sub      ( 1'b1 ),
      .D        ( s_size ), 
      .Q        ( s_address ),
      .rco      (),
      .half_rco (),
      .zero_rco ( end_move )
    ); // Contador da Movimentação
  
  // Contadores M - Contador de tempo

    contador_m #( .M(40000000), .N(26) ) contador_de_jogada (
      .clock  ( clock ),
      .zera_as( restart ),
      .zera_s ( render_count | zera_counter_play_time ),
      .conta  ( count_play_time ),
      .Q      ( w_actual_velocity ),
      .fim    ( w_end_play_time ),
      .meio   ( )
    ); // Tempo de uma rodada
	 
	  contador_m #( .M(2000), .N(20) ) contador_de_comeu_maca (
      .clock  ( clock ),
      .zera_as( restart ),
      .zera_s ( count_play_time ),
      .conta  ( count_wait_time ),
      .Q      (  ),
      .fim    ( end_wait_time ),
      .meio   ()
    ); // Tempo que deixa o sinal comeu_maça ativo

    contador_m #( .M(400000), .N(26) ) contador_interface (
      .clock  ( clock ),
      .zera_as( restart ),
      .zera_s (  ),
      .conta  ( conta_inter ),
      .Q      (  ),
      .fim    ( fim_inter ),
      .meio   ()
    ); // Tempo que deixa o sinal comeu_maça ativo

// Registradores ----------------------------------------------------------------------

    assign w_new_apple = mux_apple ? s_appleposition : s_new_apple;

    registrador_n #( .N(6) ) apple_position (
        .clock ( clock ),
        .clear ( reset_apple ),
        .enable ( register_apple ),
        .D ( w_new_apple ),
        .Q ( s_apple )
    ); // Posição da Maça


    registrador_n #( .N(6) ) head_position (
        .clock ( clock ),
        .clear ( reset_head ),
        .enable ( register_head ),
        .D ( s_position ),
        .Q ( head )
    ); // Posição da Cabeça

    registrador_n #( .N(1) ) game_mode (
        .clock ( clock ),
        .clear ( reset_game_parameters ),
        .enable ( register_game_parameters ),
        .D ( mode ),
        .Q ( w_mode )
    ); // Modo com e sem Parede

    registrador_n #( .N(1) ) eat_apple (
        .clock ( clock ),
        .clear ( reset_eat_apple ),
        .enable ( register_eat_apple ),
        .D ( comeu_maca ),
        .Q ( comeu_maca_esp )
    ); // Registro do pulso comeu maça
    
    registrador_n #( .N(1) ) dificuldade (
        .clock ( clock ),
        .clear ( reset_game_parameters ),
        .enable ( register_game_parameters ),
        .D ( difficulty ),
        .Q ( w_dificuldade )
    ); // Muda a dificuldade do jogo

    registrador_n #( .N(1) ) velocidade (
        .clock ( clock ),
        .clear ( reset_game_parameters ),
        .enable ( register_game_parameters ),
        .D ( velocity ),
        .Q ( w_velocity )
    ); // Muda a velocidade do jogo
	 
// Comparadores -------------------------------------------------------------------------------

    comparador_85_n #( .N(6) ) render_comparator (
      .A   ( s_size ),
      .B   ( s_render_count ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( render_finish )
    ); // Contagem até o tamanho da cobra

  // comparador_85_n #( .N(6) ) ram_comparator (
  //   .A   ( 6'b000000 ),
  //   .B   ( s_address ),
  //   .ALBi( 1'b0 ), 
  //   .AGBi( 1'b0 ),
  //   .AEBi( 1'b1 ),
  //   .ALBo( ), 
  //   .AGBo( ),
  //   .AEBo( end_move )
  // ); // Detecta se o a entrada de endereço da Ram chegou em 0 -> Depois finaliza o movimento
  
	  comparador_85_n #( .N(6) ) comparador_comeu_maca (
      .A   ( s_apple ),
      .B   ( newHead ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( comeu_maca )
    ); // Verifica se a cobra vai comer a maça

    assign w_apple = render_finish ? newHead : s_position; // Compara com as posições, e quando acabar compara com a nova cabeça

    comparador_85_n #( .N(6) ) comparador_maca_na_cobra (
      .A   ( s_apple ),
      .B   ( w_apple ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( maca_na_cobra )
    ); // Deteca se a maça está dentro da cobra

    comparador_85_n #( .N(6) ) comparator_self_collision (
      .A   ( head ),
      .B   ( s_position ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( self_collision )
    ); // // Deteca se a posicao da cabeca da cobra coincide com a posicao de algum segmento do corpo

    comparador_85_n #( .N(26) ) comparador_velocidade (
      .A   ( w_chosen_velocity ),
      .B   ( w_actual_velocity ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( w_reached_velocity )
    ); // Detecta se ja foi esperado o tempo necessario de acordo com a velocidade escolhida 

// Deteca colisão com a parede ------------------------------------------------------

    wall_coliser detector_collision (
      .head( s_position ),
      .clock( clock ),
      .direction( direction ),
      .reset( restart ),
      .colide( w_wall_collision )
    );

    assign wall_collision = w_wall_collision & w_mode; // Modo colisão

// Geração aleatória de maça -------------------------------------------------------

    LFSR new_apple(
      .clk(clock),
      .rst(restart),
      .out(s_new_apple)
    ); // Geração aleatório para um campo de 8x8

// Corpo da Cobra (Memória RAM) --------------------------------------------------

    assign  dataRAM = mux_ram ? s_position : newHead;
    assign  addresRAM = mux_ram_addres ? (s_address + 6'b000001): s_address;
    assign  renderRAM = mux_ram_render ? addresRAM : s_render_count; 

    sync_ram_16x4_file #(.BINFILE("ram_init.txt") ) RAM (
			.clk(clock),
			.we( we_ram ),
			.data( dataRAM ),
			.addr( renderRAM ),
			.q( s_position ),
      .head( db_head ),
		  .restart(restart)
    );

// Define nova posição da cabeça -------------------------------------------------

    assign headXsoma = {head[5:3] , head[2:0] + 3'b001} ;
    assign headXsubtrai = {head[5:3], head[2:0] - 3'b001} ;
    assign headYSoma = {head[5:3] + 3'b001 , head[2:0]} ;
    assign headYSubtrai = {head[5:3] - 3'b001 , head[2:0]} ;

    mux4x1_n #( .BITS(6) ) mux_zera (
      .D0(headXsoma),
      .D1(headYSoma),
      .D2(headXsubtrai),
      .D3(headYSubtrai),
      .SEL(direction),
      .OUT(newHead)
    );

// Define a velocidade da cobra -------------------------------------------------

    mux8x1_n #( .BITS(26) ) mux_velocidade (
      .D0 (26'd40000000), // 40.0E+6
      .D1 (26'd38500000), // 38.5E+6 
      .D2 (26'd37000000), // 37.0E+6
      .D3 (26'd35500000), // 35.5E+6
      .D4 (26'd34000000), // 34.0E+6 
      .D5 (26'd32500000), // 32.5E+6
      .D6 (26'd31000000), // 31.0E+6
      .D8 (26'd29500000), // 29.5E+6
      .D7 (26'd28000000), // 28.0E+6
      .D9 (26'd26500000), // 26.5E+6
      .D10(26'd25000000), // 25.0E+6
      .D11(26'd23500000), // 23.5E+6
      .D12(26'd22000000), // 22.0E+6
      .D13(26'd20000000), // 20.0E+6
      .D14(26'd20000000), // 20.0E+6
      .D15(26'd20000000), // 20.0E+6
      .SEL(s_appleposition[3:0]),
      .OUT(w_chosen_velocity)
    ); // Define a velocidade da cobra a partir do numero de macas comidas (s_appleposition NAO eh posicao da maca)

// Sensor echo ---------------------------------------------
    
    interface_hcsr04 INTESQ (
        .clock    (clock),
        .reset    ( restart | reset_interface ),
        .medir    ( medir ),
        .echo     ( echo_esq ),
        .trigger  ( trigger_esq ),
        .medida   ( s_medida_esq ),
        .pronto   (  ),
        .db_estado(  ) // pode usar como debug
    );
    
    interface_hcsr04 INTDIR (
        .clock    ( clock ),
        .reset    ( restart | reset_interface ),
        .medir    ( medir ),
        .echo     ( echo_dir ),
        .trigger  ( trigger_dir ),
        .medida   ( s_medida_dir ),
        .pronto   (  ),
        .db_estado(  ) // pode usar como debug
    );

    comparador_proximidade PROX (
      .medida_esq( s_medida_esq ),
      .medida_dir( s_medida_dir ),
      .dir( dir ),
      .esq( esq )
    );

// Depuração -----------------------------------------------------

  assign db_apple = s_apple;
  assign db_tamanho = s_size;

endmodule