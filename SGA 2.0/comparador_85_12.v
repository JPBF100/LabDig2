/* -----------------------------------------------------------------
 *  Arquivo   : comparador_85_11.v
 * -----------------------------------------------------------------
 * Descricao : comparador de magnitude de 12 bits 
 *             similar ao CI 7485
 *             baseado em descricao comportamental disponivel em	
 * https://web.eecs.umich.edu/~jhayes/iscas.restore/74L85b.v
 * -----------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     21/12/2023  1.0     Edson Midorikawa  criacao
 *     28/10/2024  1.0     ChatGpt           Adaptação para 12 bits
 * -----------------------------------------------------------------
 */
module comparador_85_12 (ALBi, AGBi, AEBi, A, B, ALBo, AGBo, AEBo);

    input [11:0] A, B;         
    input      ALBi, AGBi, AEBi; 
    output     ALBo, AGBo, AEBo; 
    wire [12:0] CSL, CSG;      

    // Comparação A < B: usando ~A + B + ALBi
    assign CSL  = {1'b0, ~A} + {1'b0, B} + ALBi;
    assign ALBo = ~CSL[12];  

    // Comparação A > B: usando A + ~B + AGBi
    assign CSG  = {1'b0, A} + {1'b0, ~B} + AGBi;
    assign AGBo = ~CSG[12];

    // Comparação A == B
    assign AEBo = ((A == B) && AEBi);

endmodule 
