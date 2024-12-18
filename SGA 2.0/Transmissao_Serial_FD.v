  // Trasmissão Serial
 module Transmissao_Serial_FD (
    input clock,
    input clr,
    input comeca_transmissao,
    input conta_digito,
    input [5:0] db_head,
    input [5:0] db_apple,
    input [5:0] db_state,
    input comeu_maca,
    input mode_out,
    input velocity_out,
    input difficulty_out,
    input conta_timeout,
    output fim_digito,
    output fim_envio,
    output saida_serial,
    output fim_timeout
 );

    wire [2:0] s_sel_letra;
    wire [6:0] s_ascii;

  tx_serial_7O1 SERIAL (
    .clock(clock),
    .reset(clr),
    .partida(comeca_transmissao), 
    .dados_ascii(s_ascii),
    .saida_serial(saida_serial), 
    .pronto(fim_digito),
    .db_clock( ), 
    .db_tick( ),
    .db_partida( ),
    .db_saida_serial( ),
    .db_estado( )
  );

  contador_163_n #( .N(3), .RCO(5) ) CONTA_MUX (
    .clock(clock),
    .clr(~clr),
    .ld(1'b1),
    .ent(conta_digito),
    .enp(1'b1),
    .sub(1'b0),
    .D(3'b000),
    .Q(s_sel_letra),
    .rco(fim_envio),
    .half_rco (),
    .zero_rco ()    
  );

  contador_m #( .M(50000), .N(26) ) contador_de_jogada (
    .clock  ( clock ),
    .zera_as( ),
    .zera_s ( clear ),
    .conta  ( conta_timeout ),
    .Q      (  ),
    .fim    ( fim_timeout ),
    .meio   (  )
  ); // Tempo entre transmissão

  mux_8x1_n #(
      .BITS(7)
    ) MUX (
      .D0 (7'b0000010),        // STX: Início de transmissão
      .D1 ({db_head, 1'b1}),   // Head
      .D2 ({db_apple, 1'b1}),  // Apple
      .D3 ({db_state, 1'b1}),  // State
      .D4 ({comeu_maca, difficulty_out, mode_out, velocity_out, 3'b001}), // Modos de jogo 
      .D5 (7'b0001010),       // \n : final da transmissão
      .D6 (),  
      .D7 (), 
      .SEL  (s_sel_letra),
      .MUX_OUT (s_ascii)
    );

endmodule