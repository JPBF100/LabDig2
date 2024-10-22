/* --------------------------------------------------------------------
 * Arquivo   : SGA_FD.v
 * Projeto   : Snake Game Arcade
 * --------------------------------------------------------------------
 * Descricao : Fluxo de Dados
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                          Descricao
 *     09/03/2024  1.0     Erick Sousa, João Bassetti                   versao inicial
 *     13/03/2024  1.1     Erick Sousa, João Bassetti, Carlos Engler       Semana 2
 * --------------------------------------------------------------------
*/

module SGA_FD (
    input         clock,
    input [3:0]   buttons,
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
    input         recharge,
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
    output        self_collision_on,
    output        self_collision,
    output        render_finish,
    output [5:0]  db_tamanho,
    output [5:0]  db_apple,
    output [5:0]  db_head,
    output chosen_play_time,
    output end_move,
	  output end_wait_time,
    output chosen_difficulty,
    output played,
    output wall_collision,
    output maca_na_cobra,
	  output comeu_maca,
    output comeu_maca_esp
);

	  wire [5:0] s_size;
    wire [5:0] s_address;
    wire [5:0] s_render_count;
	  wire [5:0] s_position;
    wire [5:0] s_apple;
    wire [5:0] w_new_apple;
    wire [5:0] s_new_apple;
    wire sinal;
    wire [5:0] head;
    wire [5:0] headXsoma;
    wire [5:0] headXsubtrai;
    wire [5:0] headYSoma;
    wire [5:0] headYSubtrai;
    wire [5:0] newHead;
    wire [5:0] dataRAM;
    wire [5:0] addresRAM;
    wire [5:0] renderRAM;
    wire w_end_play_time;
    wire w_end_play_time_half;
    wire w_win_game;
    wire w_win_easy_game;
    wire w_self_collision_on_1;
    wire w_self_collision_on_2;
    wire w_dificuldade;
    wire w_mode;
    wire [5:0] w_apple;
    wire [5:0] s_appleposition;
    wire w_velocity;
    wire w_wall_collision;


    assign sinal = buttons[0] | buttons [1] | buttons[2] | buttons [3];  
    assign chosen_play_time = !w_velocity ? w_end_play_time : w_end_play_time_half;
    assign chosen_difficulty = w_dificuldade ? w_win_game : w_win_easy_game;
    
    // contador_163
    contador_163 snake_size (
      .clock    ( clock ),
      .clr      ( ~clear_size ), 
      .ld       ( ~load_size ),
      .enp      ( count_size ),
      .ent      ( 1'b1 ),
      .D        ( 6'b000001 ), 
      .Q        ( s_size ),
      .rco      ( w_win_game ),
      .half_rco ( w_win_easy_game)
    );

    contador_163 render_component (
      .clock( clock ),
      .clr  ( ~render_clr ), 
      .ld   ( 1'b1 ),
      .enp  ( render_count ),
      .ent  ( 1'b1 ),
      .D    ( 6'd0 ), 
      .Q    ( s_render_count ),
      .rco  (  ),
      .half_rco ( )
    );

     contador_163 apple_counter (
      .clock( clock ),
      .clr  ( ~clr_apple_counter ), 
      .ld   ( 1'b1 ),
      .enp  ( count_apple_counter ),
      .ent  ( 1'b1 ),
      .D    ( 6'd0 ), 
      .Q    ( s_appleposition ),
      .rco  (  ),
      .half_rco ( )
    );

    contador_negativo163 ram_counter (
      .clock( clock ),
      .clr  ( 1'b1 ), 
      .ld   ( ~load_ram ),
      .enp  ( counter_ram ),
      .ent  ( 1'b1 ),
      .D    ( s_size ), 
      .Q    ( s_address ),
      .rco  (  )
    );

    LFSR new_apple(
      .clk(clock),
      .rst(restart),
      .out(s_new_apple)
    );

    contador_m #( .M(8500), .N(20) ) contador_de_jogada (
      .clock  ( clock ),
      .zera_as( restart ),
      .zera_s ( render_count | zera_counter_play_time ),
      .conta  ( count_play_time ),
      .Q      (  ),
      .fim    ( w_end_play_time ),
      .meio   ( w_end_play_time_half ),
      .quarto ()
    );
	 
	  contador_m #( .M(2000), .N(20) ) contador_de_comeu_maca (
      .clock  ( clock ),
      .zera_as( restart ),
      .zera_s ( count_play_time ),
      .conta  ( count_wait_time ),
      .Q      (  ),
      .fim    ( end_wait_time ),
      .meio   (  ),
      .quarto ()
    );

    assign w_new_apple = mux_apple ? s_appleposition : s_new_apple;

    registrador_6 apple_position (
        .clock ( clock ),
        .clear ( reset_apple ),
        .enable ( register_apple ),
        .D ( w_new_apple ),
        .Q ( s_apple )
    );

    registrador_6 head_position (
        .clock ( clock ),
        .clear ( reset_head ),
        .enable ( register_head ),
        .D ( s_position ),
        .Q ( head )
    );

    registrador_1 game_mode (
        .clock ( clock ),
        .clear ( reset_game_parameters ),
        .enable ( register_game_parameters ),
        .D ( mode ),
        .Q ( w_mode )
    );

    registrador_1 eat_apple (
        .clock ( clock ),
        .clear ( reset_eat_apple ),
        .enable ( register_eat_apple ),
        .D ( comeu_maca ),
        .Q ( comeu_maca_esp )
    );
    
    registrador_1 dificuldade (
        .clock ( clock ),
        .clear ( reset_game_parameters ),
        .enable ( register_game_parameters ),
        .D ( difficulty ),
        .Q ( w_dificuldade )
    );

    registrador_1 velocidade (
        .clock ( clock ),
        .clear ( reset_game_parameters ),
        .enable ( register_game_parameters ),
        .D ( velocity ),
        .Q ( w_velocity )
    );

    edge_detector detector (
      .clock( clock ),
      .reset( restart ),
      .sinal( sinal ),
      .pulso( played )
    );
	 
	 // comparador_85
    comparador_85 render_comparator (
      .A   ( s_size ),
      .B   ( s_render_count ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( render_finish )
    );

    comparador_85 ram_comparator (
      .A   ( 6'b000000 ),
      .B   ( s_address ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( end_move )
    );
	 
	 comparador_85 comparador_comeu_maca (
      .A   ( s_apple ),
      .B   ( newHead ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( comeu_maca )
    );

    assign w_apple = render_finish ? newHead : s_position;

    comparador_85 comparador_maca_na_cobra (
      .A   ( s_apple ),
      .B   ( w_apple ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( maca_na_cobra )
    );

    comparador_85 comparator_self_collision_on (
      .A   ( 6'b000100 ),
      .B   ( s_size ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( w_self_collision_on_2), 
      .AGBo(  ),
      .AEBo( w_self_collision_on_1 )
    );

    assign self_collision_on = w_self_collision_on_1 | w_self_collision_on_2;

    comparador_85 comparator_self_collision (
      .A   ( head ),
      .B   ( s_position ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( ), 
      .AGBo( ),
      .AEBo( self_collision )
    );

    wall_coliser detector_collision
    (
      .head(s_position),
      .clock(clock),
      .direction(direction),
      .reset(restart),
      .colide( w_wall_collision )
    );

    assign wall_collision = w_wall_collision & w_mode;

    assign  dataRAM = mux_ram ? s_position : newHead;
    assign  addresRAM = mux_ram_addres ? (s_address + 6'b000001): s_address;
    assign  renderRAM = mux_ram_render ? addresRAM : s_render_count; 

    	 sync_ram_16x4_file #(
        .BINFILE("ram_init.txt")
    ) RAM
    (
			.clk(clock),
			.we( we_ram ),
			.data( dataRAM ),
			.addr( renderRAM ),
			.q( s_position ),
      .head( db_head ),
		  .restart(restart)
    );

    assign headXsoma = {head[5:3] , head[2:0] + 3'b001} ;
    assign headXsubtrai = {head[5:3], head[2:0] - 3'b001} ;
    assign headYSoma = {head[5:3] + 3'b001 , head[2:0]} ;
    assign headYSubtrai = {head[5:3] - 3'b001 , head[2:0]} ;

    mux4x1_n #( .BITS(6) ) mux_zera (
      .D0(headXsoma),
      .D1(headXsubtrai),
      .D2(headYSoma),
      .D3(headYSubtrai),
      .SEL(direction),
      .OUT(newHead)
    );

  assign db_apple = s_apple;
  assign db_tamanho = s_size;

endmodule