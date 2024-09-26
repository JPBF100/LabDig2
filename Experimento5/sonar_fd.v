/*
* EXISTE AQUI UMA GRANDE DIFERENÇA EM RELAÇÃO AO PROJETO DA EXP 4,
* POIS AQUI A ENTRADA DO MUX TAMBEM TEM QUE TER A SAIDA DA ROM.
* ACHO QUE O IDEAL EH QUE O MUX TENHA NO MÍNIMO 7 ENTRADAS (3 BITS),
* SENDO QUE 4 DELAS SÃO DA MEDIDA (SAÍDA DO SENSOR DE DISTÂNCIA)
* UMA A VÍRGULA, OUTRA A HASHTAG E UMA A SAÍDA DA ROM. A ÚLTIMA 
* ENTRADA NÃO IMPORTA, PODE SER A HASHTAG MESMO.
*
* TL;DR: O CÓDIGO TÁ ERRADO, PRINCIPALMENTE O MUX E A ROM.
*/




module sonar_fd (
    input clock,
    input zera,
    input echo, 
    input medir,
    input conta_digito,
    input conta_timeout,
    input partida,
    output trigger,
    output fim_medida,
    output fim_envio,
    output fim_digito,
    output fim_timeout,
    output saida_serial,
);

wire [11:0] s_medida;
wire [3:0] s_sel_letra;
wire [6:0] s_ascii;
wire [23:0]s_angulo;

    rom_angulos_8x24 ROM (
        .endereco(),
        .saida()
    );

    contador_m #(
        .M(100000000), // 100000000 = 2s em um clock de 50MHz
        .N(27)
    ) U2 (
        .clock   (clock),
        .zera_as (1'b0 ),
        .zera_s  (zera ),
        .conta   (conta_timeout),
        .Q       (     ), // porta Q em aberto (desconectada)
        .fim     (fim_timeout  ),
        .meio    (     )  // porta meio em aberto (desconectada)
    );

    interface_hcsr04 INT (
        .clock    (clock    ),
        .reset    (zera    ),
        .medir    (medir),
        .echo     (echo     ),
        .trigger  (trigger),
        .medida   (s_medida ),
        .pronto   (fim_medida   ),
        .db_estado( ) // pode usar como debug
    );

    contador_163 CL (
        .clock(clock),
        .clr(~zera),
        .ld(1'b1),
        .ent(conta_digito),
        .enp(1'b1),
        .D(3'b000),
        .Q(s_sel_letra),
        .rco(fim_envio)    
    );

    mux_4x1_n #(
        .BITS(7)
    ) MUX (
        .D6 ({3'b011, s_medida[3:0]}),  
        .D5 ({3'b011, s_medida[7:4]}),  
        .D4 ({3'b011, s_medida[11:8]}),  
        .D3 (7'b0101100), // 44 = 2CH = ","  
        .D2 (7'b0100011), // 35 = 23H = "#"
        .D1 (), // angulo
        .D0 (), // angulo
        .SEL  (s_sel_letra),
        .MUX_OUT    (s_ascii)
    );

    tx_serial_7O1 TX (
        .clock        (clock),
        .reset        (zera), 
        .partida      (partida), 
        .dados_ascii  (s_ascii       ),
        .saida_serial (saida_serial ),
        .pronto       (fim_digito       ),
        .db_clock     (            ), // (desconectado)
        .db_tick      (            ), // (desconectado)
        .db_partida   (            ), // (desconectado)
        .db_saida_serial (          ), // (desconectado)
        .db_estado    (     ) // (desconectado)
    );


endmodule