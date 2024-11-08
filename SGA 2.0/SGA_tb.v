/* --------------------------------------------------------------------
 * Arquivo   : SGA_tb.v
 * Projeto   : Snake Game Arcade
 * --------------------------------------------------------------------
 * Descricao : testbench Verilog para observar a movimentacao da cobra 
 *
 *             1) plano de teste: 16 casos de teste
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                       Descricao
 *     07/11/2024  1.0     Erick Sousa                versao inicial
 * --------------------------------------------------------------------
*/

`timescale 1ns/1ns

module SGA_tb;

    // Sinais para conectar com o DUT
    // valores iniciais para fins de simulacao (ModelSim)
    reg        clock_in   = 1;
    reg        restart_in   = 0;
    reg        start_in = 0;
    reg        pause_in = 0;
    reg        echo_esq_in = 0;
    reg        echo_dir_in = 0;
    wire       finished_out;
    wire       win_out;
    wire       lost_out;
    wire [6:0]  db_state;
    wire [6:0]  db_state2;
    wire [5:0]  db_size;

    // Configuração do clock
    parameter clockPeriod = 20; // in ns, f=50MHz

    // Identificacao do caso de teste
    reg [31:0] caso = 0;

    // Gerador de clock
    always #((clockPeriod / 2)) clock_in = ~clock_in;

    // instanciacao do DUT (Device Under Test)
    SGA dut (
        .clock(clock_in),
        .start(start_in),
        .restart(restart_in),
        .pause(pause_in),
        .db_state(db_state),
        .db_state2(db_state2),
        .db_appleX(),
        .db_appleY(),
        .db_headX(),
        .db_headY(),
        .won(),
        .lost(),
        .direction(),
        .db_size(db_size),
        .mode(1'b1), // 0 sem parede // 1 com parede
        .difficulty(1'b0), // 0 easy // 1 dificil
        .velocity(1'b0), // 0 para 400ms // 1 para 200ms
        .echo_esq(echo_esq_in),
        .echo_dir(echo_dir_in),
        .dir(),
        .esq(),
        .saida_serial(),
        .comeu_maca(),
        .trigger_esq(),
        .trigger_dir(),
        .saida_pwm(),
        .db_pwm()
    );

    // geracao dos sinais de entrada (estimulos)
    initial begin
      $display("Inicio da simulacao");

      // condicoes iniciais
      caso       = 0;
      clock_in   = 1;
      restart_in = 0;
      start_in = 0;
      echo_esq_in  = 0;
      echo_dir_in  = 0;
      pause_in = 0;
      #(clockPeriod);

      // Teste 1 (resetar circuito)
      caso = 1;
      // gera pulso de reset
      @(negedge clock_in);
      restart_in = 1;
      #(clockPeriod);
      restart_in = 0;
      #(clockPeriod);

      // Teste 2 (Acionar sensor da esquerda)
      caso = 2;
      @(negedge clock_in);
      start_in = 1;
      #(clockPeriod);
      start_in = 0;

      #(100*clockPeriod);
      echo_esq_in = 1;
      #(20587*clockPeriod); // 1cm = 2941 ciclos de clock
      echo_esq_in = 0;
      #(30050*clockPeriod);

      // final dos casos de teste da simulacao
      caso = 99;
      #100;
      $display("Fim da simulacao");
      $stop;
    end

  endmodule
