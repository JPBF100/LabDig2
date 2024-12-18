module comparador_proximidade (
    input [11:0]    medida_esq,
    input [11:0]    medida_dir,
    output          dir,
    output          esq
);

    comparador_85_n #( .N(12) ) comparador_prox_esq (
      .A   ( medida_esq ),
      .B   ( 4'd10 ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( esq ), 
      .AGBo( ),
      .AEBo( )
    );

    comparador_85_n #( .N(12) ) comparador_prox_dir (
      .A   ( medida_dir ),
      .B   ( 4'd10 ),
      .ALBi( 1'b0 ), 
      .AGBi( 1'b0 ),
      .AEBi( 1'b1 ),
      .ALBo( dir ), 
      .AGBo( ),
      .AEBo( )
    );

endmodule