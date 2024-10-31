module comparador_proximidade (
    input [11:0]    medida_esq,
    input [11:0]    medida_dir,
    input           libera_alarme,
    output          dir,
    output          esq
);

  wire s_esq;
  wire s_dir;

    comparador_85_n #( .N(12) ) comparador_prox_esq (
      .A   ( medida_esq ),
      .B   ( 12'h010 ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( s_dir ), 
      .AGBo( ),
      .AEBo( )
    );

    comparador_85_n #( .N(12) ) comparador_prox_dir (
      .A   ( medida_dir ),
      .B   ( 12'h010 ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( s_esq ), 
      .AGBo( ),
      .AEBo( )
    );

  assign dir = s_dir && libera_alarme;
  assign esq = s_esq && libera_alarme;


endmodule