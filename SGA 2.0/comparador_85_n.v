/* -----------------------------------------------------------------
 *  Arquivo   : comparador_85.v
 *  Projeto   : Experiencia 3 - Um Fluxo de Dados Simples
 * -----------------------------------------------------------------
 * Descricao : comparador de magnitude de N bits 
 *             similar ao CI 7485
 *             baseado em descricao comportamental disponivel em	
 * https://web.eecs.umich.edu/~jhayes/iscas.restore/74L85b.v
 * -----------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     21/12/2023  1.0     Edson Midorikawa  criacao
 *     29/10/2024  2.0     João Bassetti     Comparador de N bits
 * -----------------------------------------------------------------
 */

module comparador_85_n #(parameter N = 6) (ALBi, AGBi, AEBi, A, B, ALBo, AGBo, AEBo);

    input [N-1:0] A, B;
    input      ALBi, AGBi, AEBi;
    output     ALBo, AGBo, AEBo;
    wire [N:0]  CSL, CSG;

    assign CSL  = ~A + B + ALBi;
    assign ALBo = ~CSL[N];
    assign CSG  = A + ~B + AGBi;
    assign AGBo = ~CSG[N];
    assign AEBo = ((A == B) && AEBi);

endmodule 