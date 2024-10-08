module sonar_fd_mux (
    input clock,
    input zera,
    input echo, 
    input medir,
    input conta_digito,
    input conta_timeout,
    input conta_angulo,
    input comeca_transmissao,
    output trigger,
    output fim_medida,
    output fim_envio,
    output fim_digito,
    output fim_timeout,
    output saida_serial,
    output ultimo_angulo,
    output pwm,
	 output [11: 0] medida,
	 output [3:0] db_estado,
     output [11:0] angulo
);

wire [11:0] s_medida;
wire [2:0] s_sel_letra;
wire [6:0] s_ascii;
wire [2:0] s_end;
wire [23:0] s_angulo;

    rom_angulos_8x24 ROM (
        .endereco(s_end),
        .saida(s_angulo)
    );

    contador_m #(
        .M(100000000), // 100000000 = 2s em um clock de 50MHz
        .N(27)
    ) U2 (
        .clock   (clock),
        .zera_as (1'b0 ),
        .zera_s  (zera ),
        .conta   (conta_timeout),
        .Q       (     ), // porta Q em aberto (desconectada)
        .fim     (fim_timeout  ),
        .meio    (     )  // porta meio em aberto (desconectada)
    );

    controle_servo_3 CS (
        .clock   (clock),
        .reset   (zera), // nunca vai usar, eu acho
        .posicao (s_end),
        .controle(pwm),
        .db_reset(     ), // (desconectado)
        .db_posicao(   ), // (desconectado)
        .db_controle(  ) // (desconectado)
    );

    interface_hcsr04 INT (
        .clock    (clock    ),
        .reset    (zera    ),
        .medir    (medir),
        .echo     (echo     ),
        .trigger  (trigger),
        .medida   (s_medida ),
        .pronto   (fim_medida   ),
        .db_estado( db_estado ) // pode usar como debug
    );

    contador_163 CONTA_MUX (
        .clock(clock),
        .clr(~zera),
        .ld(1'b1),
        .ent(conta_digito),
        .enp(1'b1),
        .D(3'b000),
        .Q(s_sel_letra),
        .rco(fim_envio)    
    );

//    contador_163 CONTA_ANGULO (
//        .clock(clock),
//        .clr(~zera),
//        .ld(1'b1),
//        .ent(conta_angulo),
//        .enp(1'b1),
//        .D(3'b000),
//        .Q(s_end),
//        .rco(ultimo_angulo) // coloquei isso pra servir como debug, acho que nao vai precisar    
//    );
	 
	 contadorg_updown_m #(
        .M(8),
		  .N(3)
    ) CONTA_ANGULO (
			.clock(clock),   
         .zera_as(zera),
         .zera_s(),
         .conta(conta_angulo),
			.Q(s_end),
			.inicio(),
		   .fim(ultimo_angulo),
		   .meio(),
		   .direcao()
	 );

    mux_8x1_n #(
        .BITS(7)
    ) MUX (
        .D0 (s_angulo[23:16]), // primeiro digito do angulo
        .D1 (s_angulo[15:8]), // segundo digito do angulo
        .D2 (s_angulo[7:0]), // terceito digito do angulo
        .D3 (7'b0101100), // 44 = 2CH = ","  
        .D4 ({3'b011, s_medida[11:8]}), // primeiro digito da medida  
        .D5 ({3'b011, s_medida[7:4]}), // segundo digito da medida  
        .D6 ({3'b011, s_medida[3:0]}), // terceiro digito da medida  
        .D7 (7'b0100011), // 35 = 23H = "#"
        .SEL  (s_sel_letra),
        .MUX_OUT    (s_ascii)
    );

    tx_serial_7O1 TX (
        .clock        (clock),
        .reset        (zera), 
        .partida      (comeca_transmissao), 
        .dados_ascii  (s_ascii       ),
        .saida_serial (saida_serial ),
        .pronto       (fim_digito       ),
        .db_clock     (            ), // (desconectado)
        .db_tick      (            ), // (desconectado)
        .db_partida   (            ), // (desconectado)
        .db_saida_serial (          ), // (desconectado)
        .db_estado    (     ) // (desconectado)
    );

assign medida = s_medida;
assign angulo[3:0] = s_angulo[19:16];
assign angulo[7:4] = s_angulo[12:8];
assign angulo[11:8] = s_angulo[3:0];

endmodule