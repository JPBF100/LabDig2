/* --------------------------------------------------------------------------
 *  Arquivo   : exp4_trena.v
 * --------------------------------------------------------------------------
 *  Descricao : Codigo do componente completo da trena digital 
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      20/09/2024  1.0     Erick Sousa       versao inicial
 * --------------------------------------------------------------------------
 */

module exp4_trena (
    input wire clock,
    input wire reset,
    input wire mensurar,
    input wire echo,
    output wire trigger,
    output wire saida_serial,
    output wire [6:0] medida0,
    output wire [6:0] medida1,
    output wire [6:0] medida2,
    output wire pronto,
    output wire [6:0] db_estado
);

    wire [3:0] s_estado;
    wire [11:0] s_medida;
    wire s_pronto;
    wire s_fim_envio;
    wire s_fim_digito;
    wire s_reset;
    wire s_conta;
    wire s_comeca_medida;
    wire s_partida;

    trena_fd FD (
        .clock(clock),
        .medir(s_comeca_medida),
        .echo(echo),
        .pulso(trigger),
        .zera(s_reset),
        .conta(s_conta),
        .partida(s_partida),
        .saida_serial(saida_serial),
        .fim_medida(s_pronto),
        .fim_envio(s_fim_envio),
        .fim_digito(s_fim_digito),
        .medida(s_medida)
    );
    
    trena_uc UC (
        .clock(clock),
        .reset(reset),
        .mensurar(mensurar),
        .echo(echo),
        .pronto(s_pronto),
        .fim_digito(s_fim_digito),
        .fim_envio(s_fim_envio),
        .zera(s_reset),
        .conta(s_conta),
        .partida(s_partida),
        .comeca_medida(s_comeca_medida),
        .db_estado(s_estado)
    );

    // Displays para medida (4 dígitos BCD)
    hexa7seg H0 (
        .hexa   (s_medida[3:0]), 
        .display(medida0)
    );
    hexa7seg H1 (
        .hexa   (s_medida[7:4]), 
        .display(medida1)
    );
    hexa7seg H2 (
        .hexa   (s_medida[11:8]), 
        .display(medida2)
    );

    // Display para estado da UC
    hexa7seg H3 (
        .hexa   ({1'b0, s_estado}), 
        .display(db_estado)
    );

    assign pronto = s_pronto;

endmodule