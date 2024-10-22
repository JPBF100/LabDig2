//------------------------------------------------------------------
// Arquivo   : contador_163.v
// Projeto   : Experiencia 3 - Um Fluxo de Dados Simples
//------------------------------------------------------------------
// Descricao : Contador binario de 4 bits, modulo 16
//             similar ao componente 74163
//
// baseado no componente Vrcntr4u.v do livro Digital Design Principles 
// and Practices, Fifth Edition, by John F. Wakerly              
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//     13/03/2024  2.0      Carlos Engler    Add Half_rco   
//------------------------------------------------------------------
//
module contador_163_3 ( clock, clr, ld, ent, enp, D, Q, rco );
    input clock, clr, ld, ent, enp;
    input [2:0] D;
    output reg [2:0] Q;
    output reg rco;

    always @ (posedge clock)
        if (~clr)               Q <= 3'd0;
        else if (~ld)           Q <= D;
        else if (ent && enp)    Q <= Q + 3'd1;
        else                    Q <= Q;
 
    always @ (Q or ent)
        if (ent && (Q == 3'd5))   rco = 1;
        else                       rco = 0;
endmodule