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

    wire s_estado;

    trena_fd FD (
        .clock(clock),
        .mensurar(mensurar),
        .echo(echo),
        .pulso(trigger),
        .zera(reset),
        .conta(1'b1),
        .registra(1'b1),
        .saida_serial(saida_serial),
        .fim(pronto)
    );
    
    trena_uc UC (
        .clock(clock),
        .reset(reset),
        .mensurar(mensurar),
        .echo(echo),
        .pronto(pronto),
        .fim_digito(trigger),
        .fim_envio(pronto),
        .zera(FD.zera),
        .comeca_medida(FD.mensurar),
        .fim(FD.fim),
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

endmodule