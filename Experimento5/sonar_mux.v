module sonar_mux (
    input clock,
    input reset,
    input ligar,
    input echo,
	input silencio,
    input sel_display,
    output wire trigger,
    output wire pwm,
    output wire saida_serial,
    output wire fim_posicao,
    output db_echo,
    output db_trigger,
    output db_pwm,
    output db_saida_serial_uart,
     output [6:0] db_display0,
	 output [6:0] db_display1,
	 output [6:0] db_display2,
     output [6:0] db_display3,
	 output [6:0] db_display4,
	 output [6:0] db_display5
); 

wire s_zera;
wire s_medir;
wire s_conta_digito;
wire s_conta_timeout;
wire s_conta_angulo;
wire s_comeca_transmissao;
wire s_fim_medida;
wire s_fim_envio;
wire s_fim_digito;
wire s_fim_timeout;
wire [23:0] s_mux_displays;
wire [3:0] s_estado;
wire [11:0] s_medida;
wire [11:0] s_angulo;
wire [3:0] s_interface;


sonar_fd_mux FD (
    .clock(clock),
    .zera(s_zera),
    .echo(echo), 
    .medir(s_medir),
    .conta_digito(s_conta_digito),
    .conta_timeout(s_conta_timeout),
    .conta_angulo(s_conta_angulo),
    .comeca_transmissao(s_comeca_transmissao),
    .trigger(trigger),
    .fim_medida(s_fim_medida),
    .fim_envio(s_fim_envio),
    .fim_digito(s_fim_digito),
    .fim_timeout(s_fim_timeout),
    .saida_serial(saida_serial),
    .ultimo_angulo(), // pode usar como debug
    .pwm(pwm),
	 .medida(s_medida),
	 .db_estado(s_interface)
     .angulo(s_angulo)
);

sonar_uc UC (
    .clock(clock),
    .reset(reset),
    .ligar(ligar),
    .fim_medida(s_fim_medida),
    .fim_digito(s_fim_digito),
    .fim_envio(s_fim_envio),
    .fim_timeout(s_fim_timeout),
    .zera(s_zera),
    .conta_digito(s_conta_digito),
    .conta_timeout(s_conta_timeout),
    .conta_angulo(s_conta_angulo),        
    .comeca_transmissao(s_comeca_transmissao),
    .comeca_medida(s_medir),
    .pronto(), // pode usar como debug, ativa no estado finali
    .fim_posicao(fim_posicao),
    .db_estado(s_estado),
	 .silencio(silencio)
);

    mux_4x1_n#(
        .BITS(24)
    )(
        .D3(),
        .D2(),
        .D1({s_medida[3:0], s_medida[7:4], s_medida[11:8], s_angulo[3:0], s_angulo[7:4], s_angulo[11:8]}),
        .D0({s_medida[3:0], s_medida[7:4], s_medida[11:8], 4'b0000, s_interface, s_estado}),
        .SEL(sel_display),
        .MUX_OUT(s_mux_displays)
    )

    hexa7seg H5 (
        .hexa   (s_mux_displays[23:20]), 
        .display(db_display5)
    );
	hexa7seg H4 (
        .hexa   (s_mux_displays[19:16]), 
        .display(db_display4)
    );
    hexa7seg H3 (
        .hexa   (s_mux_displays[15:12]), 
        .display(db_display3)
    );
	hexa7seg H2 (
        .hexa   (s_mux_displays[11:8]), 
        .display(db_display2)
    );
	hexa7seg H1 (
        .hexa   (s_mux_displays[7:4]), 
        .display(db_display1)
    );
	hexa7seg H0 (
        .hexa   (s_mux_displays[3:0]), 
        .display(db_display0)
    );

assign db_echo = echo;
assign db_pwm = pwm;
assign db_trigger = trigger;
assign db_saida_serial_uart = saida_serial;



endmodule