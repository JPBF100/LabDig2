//------------------------------------------------------------------
// Arquivo   : contador_163.v
//------------------------------------------------------------------
// Descricao : Contador binario de 3 bits, modulo 8
//             similar ao componente 74163
//
// baseado no componente Vrcntr4u.v do livro Digital Design Principles 
// and Practices, Fifth Edition, by John F. Wakerly              
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//     14/12/2023  2.0     Erick Sousa       versao para 3 bits
//------------------------------------------------------------------
//
module contador_163 ( clock, clr, ld, ent, enp, D, Q, rco );
    input clock, clr, ld, ent, enp;
    input [2:0] D;
    output reg [2:0] Q;
    output reg rco;

    always @ (posedge clock)
        if (~clr)               Q <= 3'd0;
        else if (~ld)           Q <= D;
        else if (ent && enp)    Q <= Q + 1;
        else                    Q <= Q;
 
    always @ (Q or ent)
        if (ent && (Q == 3'd7))   rco = 1;
        else                       rco = 0;
endmodule