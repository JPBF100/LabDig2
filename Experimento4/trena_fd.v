/* --------------------------------------------------------------------------
 *  Arquivo   : trena_fd.v
 * --------------------------------------------------------------------------
 *  Descricao : Codigo do fluxo de dados da trena digital 
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      20/09/2024  1.0     Erick Sousa       versao inicial
 * --------------------------------------------------------------------------
 */

module trena_fd (
    input wire clock,
    input wire medir,
    input wire echo,
    input wire pulso,
    input wire zera,
    input wire conta,
    input wire partida,
    output wire saida_serial,
    output wire fim_medida,
    output wire fim_envio,
    output wire fim_digito,
    output wire medida
);

    // Sinais internos
    wire s_sel_letra;
    wire s_trigger;
    wire [11:0] s_medida;
    wire [6:0] s_ascii;

    // Circuito de interface com sensor
    interface_hcsr04 INT (
        .clock    (clock    ),
        .reset    (zera    ),
        .medir    (mensurar),
        .echo     (echo     ),
        .trigger  (s_trigger),
        .medida   (s_medida ),
        .pronto   (fim_medida   ),
        .db_estado( ) // nao precisa
    );

    contador_163 CL (
        .clock(clock),
        .clr(reset),
        .ld(1'b0),
        .ent(conta),
        .enp(1'b1),
        .D(2'b00),
        .Q(s_sel_letra),
        .rco(fim_envio)    
    );

    mux_4x1_n #(
        .BITS(7)
    ) MUX (
        .entrada0 ({3'b011, s_medida[3:0]}),
        .entrada1 ({3'b011, s_medida[7:4]}),
        .entrada2 ({3'b011, s_medida[11:8]}),
        .entrada3 (7'b0100011), // 35 = 23H = "#" 
        .selecao  (s_sel_letra),
        .saida    (s_ascii)
    );

    tx_serial_7O1 TX (
        .clock        (clock),
        .reset        (zera), // zerar depois de enviar um digito? ou zerar junto com o reset/zera?
        .partida      (partida), // ativar no estado de enviar algum digito
        .dados_ascii  (s_ascii       ),
        .saida_serial (saida_serial ),
        .pronto       (fim_digito       ),
        .db_clock     (            ), // (desconectado)
        .db_tick      (            ), // (desconectado)
        .db_partida   (            ), // (desconectado)
        .db_saida_serial (          ), // (desconectado)
        .db_estado    (     ) // (desconectado)
    );

    // Sinais de saída
    assign trigger = s_trigger;
    assign saida_serial = s_trigger;
    assign medida = s_medida;


endmodule