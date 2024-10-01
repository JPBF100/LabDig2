module controle_servo_3 (
 input wire clock,
 input wire reset,
 input wire [2:0] posicao,
 output wire controle,
 output wire db_reset,
 output wire [2:0] db_posicao,
 output wire db_controle
);


	circuito_pwm #(           
        .conf_periodo(1000000), 
        .largura_000  (35000),  
        .largura_001  (45700),  
        .largura_010  (56450),  
        .largura_011  (67150),
        .largura_100  (77850),  
        .largura_101  (88550),  
        .largura_110  (99300),  
        .largura_111  (110000)    
    ) PWM (
        .clock   (clock),
        .reset   (reset),
        .largura (posicao),
        .pwm     (controle)
    );
    
    assign db_controle = controle;
    assign db_posicao = posicao;
    assign db_reset = reset;



endmodule