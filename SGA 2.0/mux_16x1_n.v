/*
 *  Arquivo   : mux_16x1_n.v
 * ----------------------------------------------------------------
 *  Descricao : multiplexador 16x1  
 *  > parametro BITS: numero de bits das entradas
 * 
 *  > adaptado a partir do codigo do mux_4x1_n.v do professor
 *   Midorikawa 
 * 
 * ----------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      05/11/2024  5.0     Erick Sousa       versao para 16 entradas
 * ----------------------------------------------------------------
 */

module mux_16x1_n #(
    parameter BITS = 4
) (
    input  [BITS-1:0] D15,
    input  [BITS-1:0] D14,
    input  [BITS-1:0] D13,
    input  [BITS-1:0] D12,
    input  [BITS-1:0] D11,
    input  [BITS-1:0] D10,
    input  [BITS-1:0] D9,
    input  [BITS-1:0] D8,
    input  [BITS-1:0] D7,
    input  [BITS-1:0] D6,
    input  [BITS-1:0] D5,
    input  [BITS-1:0] D4,
    input  [BITS-1:0] D3,
    input  [BITS-1:0] D2,
    input  [BITS-1:0] D1,
    input  [BITS-1:0] D0,
    input  [3:0]      SEL,
    output [BITS-1:0] MUX_OUT
);

    assign MUX_OUT = (SEL == 4'b1111) ? D15 :
                     (SEL == 4'b1110) ? D14 :
                     (SEL == 4'b1101) ? D13 :
                     (SEL == 4'b1100) ? D12 : 
                     (SEL == 4'b1011) ? D11 :
                     (SEL == 4'b1010) ? D10 :
                     (SEL == 4'b1001) ? D9 :
                     (SEL == 4'b1000) ? D8 :
                     (SEL == 4'b0111) ? D7 :
                     (SEL == 4'b0110) ? D6 :
                     (SEL == 4'b0101) ? D5 :
                     (SEL == 4'b0100) ? D4 : 
                     (SEL == 4'b0011) ? D3 :
                     (SEL == 4'b0010) ? D2 :
                     (SEL == 4'b0001) ? D1 :
                     (SEL == 4'b0000) ? D0 :
                     {BITS{1'b1}}; // default 

endmodule

