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
//     29/10/2024  3.0     João Bassetti     Contador N bits + RCO  
//------------------------------------------------------------------
//
module contador_163_n #(parameter N = 6, RCO = 10) ( 
    input clock, clr, ld, ent, enp, sub,
    input [N-1:0] D,
    output reg [N-1:0] Q,
    output reg rco,
    output reg half_rco,
    output reg zero_rco
);

    always @ (posedge clock)
        if (~clr)                       Q <= 0;
        else if (~ld)                   Q <= D;
        else if (ent && enp && !sub)    Q <= Q + 1;
        else if (ent && enp && sub)     Q <= Q - 1;
        else                            Q <= Q;
 
    always @ (Q or ent)
        if (ent && (Q == RCO))      rco = 1;
        else                        rco = 0;

    always @ (Q or ent)
        if (ent && (Q == RCO/2-1))  half_rco = 1;
        else                        half_rco = 0;
    
    always @ (Q or ent)
        if (ent && (Q == 0))        zero_rco = 1;
        else                        zero_rco = 0;

endmodule