module sonar (
    input clock,
    input reset,
    input ligar,
    input echo,
    output wire trigger,
    output wire pwm,
    output wire saida_serial,
    output wire fim_posicao,
    output db_echo,
    output db_trigger,
    output db_pwm,
    output db_saida_serial_uart,
    output [6:0] db_estado
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
wire [3:0] s_estado;


sonar_fd FD (
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
    .pwm(pwm)
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
    .db_estado(s_estado) 
);

    hexa7seg H5 (
        .hexa   (s_estado), 
        .display(db_estado)
    );

assign db_echo = echo;
assign db_pwm = pwm;
assign db_trigger = trigger;
assign db_saida_serial_uart = saida_serial;



endmodule