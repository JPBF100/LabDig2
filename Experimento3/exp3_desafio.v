module exp3_desafio (
    input wire        clock,
    input wire        reset,
    input wire        medir,
    input wire        echo,
    input wire  [1:0] posicao,
    output wire       trigger,
    output wire [6:0] hex0,
    output wire [6:0] hex1,
    output wire [6:0] hex2,
    output wire       pronto,
    output wire       db_medir,
    output wire       db_echo,
    output wire       db_trigger,
	 output wire [1:0] db_posicao,
    output wire [6:0] db_estado,
	 output wire       controle
);

    exp3_sensor dut (
    .clock(clock),
    .reset(reset),
    .medir(medir),
    .echo(echo),
    .trigger(trigger),
    .hex0(hex0),
    .hex1(hex1),
    .hex2(hex2),
    .pronto(pronto),
    .db_medir(db_medir),
    .db_echo(db_echo),
    .db_trigger(db_trigger),
    .db_estado(db_estado)
    );

    circuito_pwm #(           
        .conf_periodo(1000000), 
        .largura_00  (0),  
        .largura_01  (50000),  
        .largura_10  (75000),  
        .largura_11  (100000)   
    ) PWM (
        .clock   (clock),
        .reset   (reset),
        .largura (posicao),
        .pwm     (controle)
    );
	 
	 assign db_posicao = posicao;

endmodule