
`timescale 1ns/1ns

module exp4_trena_tb;

    reg         clock_in = 0;
    reg         reset_in = 0;
    reg         medir_in = 0;
    reg         echo_in = 0;
    wire        trigger_out;
    wire [6:0]  medida01_out;
    wire [6:0]  medida02_out;
    wire [6:0]  medida03_out;
    wire [11:0] medidatotal_out;
    wire        pronto_out;
    wire        fim_digito_out;
    wire [3:0]  db_estado_out;


    exp4_trena dut (
      .clock(clock_in),
      .reset(reset_in),
      .mensurar(medir_in),
      .echo(echo_in),
      .trigger(trigger_out),
      .saida_serial(        ),
      .medida0(medida01_out),
      .medida1(medida02_out),
      .medida2(medida03_out),
      .medidatotal(medidatotal_out),
      .fim_digito(fim_digito_out),
      .pronto(pronto_out),
      .db_estado(       )
    );

    parameter clockPeriod = 20; // clock de 50MHz
    // Gerador de clock
    always #(clockPeriod/2) clock_in = ~clock_in;

    reg [6:0] vetor_teste [0:3];
    reg [31:0] casos_teste [0:5]; // Usando 32 bits para acomodar o tempo
    integer caso;

    // Largura do pulso
    reg [31:0] larguraPulso; // Usando 32 bits para acomodar tempos maiores


    initial begin
        $display("Inicio das simulacoes");

        // Inicialização do array de casos de teste
        casos_teste[0] = 5882;   // 5882us (100cm)
        casos_teste[1] = 5899;   // 5899us (100,29cm) truncar para 100cm
        casos_teste[2] = 4353;   // 4353us (74cm)

        // Valores iniciais
        medir_in = 0;
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
        for (caso = 1; caso < 4; caso = caso + 1) begin
            // 1) Determina a largura do pulso echo
            $display("Caso de teste %0d: %0dus", caso, casos_teste[caso-1]);
            larguraPulso = casos_teste[caso-1]*1000; // 1us=1000

            // 2) Envia pulso medir
            @(negedge clock_in);
            medir_in = 1;
            #(5*clockPeriod);
            medir_in = 0;

            // 3) Espera por 400us (tempo entre trigger e echo)
            #(400_000); // 400 us

            // 4) Gera pulso de echo
            echo_in = 1;
            #(larguraPulso);
            echo_in = 0;

            // 5) Espera final da medida

            wait (pronto_out == 1'b1);
            $display("Medida Enviada %b %b %b #", medidatotal_out[11:8], medidatotal_out[7:4], medidatotal_out[3:0]);
            $display("Mensagem envidada, Fim do caso %0d", caso);

            // 6) Espera entre casos de teste
            #(100_000); // 100 us
        end

        // Fim da simulação
        $display("Fim das simulacoes");
        caso = 99; 
        $stop;
    end

endmodule