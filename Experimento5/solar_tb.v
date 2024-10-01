`timescale 1ns/1ns

module solar_tb;

    // Declaração de sinais
    reg         clock_in = 0;
    reg         reset_in = 0;
    reg         ligar_in = 0;
    reg         echo_in  = 0;
    reg         sel_display_in = 0;
    wire        trigger;
    wire        pwm;
    wire        saida_serial;
    wire        fim_posicao;
    wire        db_echo;
    wire        db_trigger;
    wire        db_pwm;
    wire [2:0]  db_posicao_servo;
    wire        db_reset_sensor;
    wire        db_medir_sensor;
    wire        db_tick_uart;
    wire        db_partida_uart;
    wire        db_saida_serial_uart;
    wire        db_reset_servo;
    wire        db_controle_servo;
    wire [6:0] medida0;
    wire [6:0] medida1;
    wire [6:0] medida2;
    wire [6:0] H3_out;
    wire [6:0] H4_out;
    wire [6:0] H5_out;



    // Componente a ser testado (Device Under Test -- DUT)
    sonar dut (
        .clock          (clock_in),
        .reset          (reset_in),
        .ligar          (ligar_in),
        .echo           (echo_in),
        .trigger        (trigger),
        .pwm            (pwm),
        .saida_serial   (saida_serial),
        .fim_posicao    (fim_posicao),
        .db_echo        (db_echo),
        .db_trigger     (db_trigger),
        .db_pwm         (db_pwm),
        .db_saida_serial_uart(db_saida_serial_uart)
    );



    // Configurações do clock
    parameter clockPeriod = 20; // clock de 50MHz
    // Gerador de clock
    always #(clockPeriod/2) clock_in = ~clock_in;

    // Array de casos de teste (estrutura equivalente em Verilog)
    reg [31:0] casos_teste [0:14]; // Usando 32 bits para acomodar o tempo
    integer caso;

    // Largura do pulso
    reg [31:0] larguraPulso; // Usando 32 bits para acomodar tempos maiores

    // Geração dos sinais de entrada (estímulos)
    initial begin
        $display("Inicio das simulacoes");

        // Inicialização do array de casos de teste
        casos_teste[0]  = 5882;   // 5882us (100cm)
        casos_teste[1]  = 5899;   // 5899us (100,29cm) truncar para 100cm
        casos_teste[2]  = 4353;   // 4353us (74cm)
        casos_teste[3]  = 4399;   // 4399us (74,79cm) arredondar para 75cm
        casos_teste[4]  = 588;    // (10cm)
        casos_teste[5]  = 589;    // (10,08cm) truncar para 10cm
        casos_teste[6]  = 1000;   // (17,1cm) truncar para 17cm
        casos_teste[7]  = 439;    // (7,5cm) truncar para 7cm
        casos_teste[8]  = 5882;   // 5882us (100cm)
        casos_teste[9]  = 5899;   // 5899us (100,29cm) truncar para 100cm
        casos_teste[10] = 4353;   // 4353us (74cm)
        casos_teste[11] = 4399;   // 4399us (74,79cm) arredondar para 75cm
        casos_teste[12] = 588;    // (10cm)
        casos_teste[13] = 5882;   // 5882us (100cm)
        casos_teste[14] = 5899;   // 5899us (100,29cm) truncar para 100cm
        casos_teste[15] = 4353;   // 4353us (74cm)


        // Valores iniciais
        ligar_in = 0;
        echo_in  = 0;

        // Reset
        caso = 0; 
        #(2*clockPeriod);
        reset_in = 1;
        #(2_000); // 2 us
        reset_in = 0;
        @(negedge clock_in);

        // Espera de 100us
        #(100_000); // 100 us

        // Loop pelos casos de teste
        for (caso = 1; caso < 16; caso = caso + 1) begin
            // 1) Determina a largura do pulso echo
            $display("Caso de teste %0d: %0dus", caso, casos_teste[caso-1]);
            larguraPulso = casos_teste[caso-1]*1000; // 1us=1000

            if (caso == 12) begin
                ligar_in = 0;
                #(10000*clockPeriod);
            end
            else begin
                // 2) Liga o circuito
                @(negedge clock_in);
                ligar_in = 1;
                #(150000*clockPeriod);

                // 4) Gera pulso de echo
                echo_in = 1;
                #(larguraPulso);
                echo_in = 0;

                // 5) Espera final da medida
                wait (fim_posicao == 1'b1);
                $display("Fim do caso %0d", caso);

                // 6) Espera entre casos de teste
                #(100); // 100 ns
            end     
        end
        // Fim da simulação
        $display("Fim das simulacoes");
        caso = 99; 
        $stop;
    end
endmodule