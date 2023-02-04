/*RECEPTOR 
    N_BITS constante que indica el numero de bits de datos
    SB_TICK constante que indica el numero de ticks que se necesitan para los bits de stop (16,24,32) para (1, 1.5, 2) bits de stop

    Tres estados mayores start data stop que representan el proceso de start bit, bits de datos, bit de stop
    La "s_tick" signal es el tick habilitador del baudrate generator y hay 16 ticks en un intervalo de 1 bit

    Luego tenemos dos contadores "s" (mantienen un registro de cuenta sobre los ticks) y "n" (realiza un seguimiento de los bits de datos recibidos)
    los bits de datos recuperados se shiftean y de ensamblan en "b" 
    
    rx_done_tick indica cuando ya se tiene el dato completo (todos los bits recibidos)
    
    AGREGAR BIT DE PARIDAD (UN NUEVO ESTADO)
    
    */


module uart_rx
    # ( 
    parameter N_BITS = 8, // # cantidad de bits por dato 
    parameter SB_TICK = 16 // # ticks para stop bits 
    )
    ( 
    input wire clk,
    input wire reset, 
    input wire rx,
    input wire s_tick,
    output reg rx_done_tick, 
    output wire [N_BITS - 1:0] dout 
    );

    //Declaracion de los estados de UART_RX
    localparam [2 : 0] idle   = 3'b000;
    localparam [2 : 0] start  = 3'b001;
    localparam [2 : 0] data   = 3'b010;
    localparam [2 : 0] parity = 3'b011;
    localparam [2 : 0] stop   = 3'b100;
    

    //Declaracion de las seniales
    reg [2 : 0] state_reg;
    reg [2 : 0] state_next; 
    reg [3 : 0] s_reg;
    reg [3 : 0] s_next; 
    reg [2 : 0] n_reg; 
    reg [2 : 0] n_next; 
    reg [N_BITS - 1 : 0] b_reg; 
    reg [N_BITS - 1 : 0] b_next;
    reg pari;

    //maquina de estados para los estados y datos
    always @( posedge clk) begin
        if(reset)
            begin
                state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
            end
        else
            begin
                state_reg <= state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;    
            end
    end

    //maquina de estados para ir al estado siguiente
    always @(*) 
    begin
        state_next = state_reg;
        rx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        
        case (state_reg)
            idle:
                begin
                    if (~rx) 
                        begin
                            state_next = start;
                            s_next = 0;     
                        end
                end
            start:
                begin
                    if (s_tick)                                 
                        begin
                            if (s_reg == ((SB_TICK/2) - 1))           //chequiamos que el tick sea la mitad del muestreo
                                begin
                                    state_next = data;                //si es asi pasamos al estados para recibir los datos
                                    s_next = 0;                       //limpiamos el registro que cuenta los ticks
                                    n_next = 0;                       //limpiamos el registro que lleva la cuenta de los bits recibidos
                                end 
                            else
                                s_next = s_reg + 1;                           //si no seguimos contando los ticks   
                        end
                end
            data:
                begin
                    if (s_reg == (SB_TICK-1) and s_tick)
                        begin
                            n_next = n_reg + 1;                 //si aumentamos el contador que lleva la cuenta de los bits recibidos
                            s_next = 0;                         //tenemos el bit por ende reiniciamos el contador de ticks
                            b_next = {rx, b_reg[N_BITS - 1:1]}; //ponemos el bit en el registro b 
                            if(n_reg == (N_BITS-1))             //chequiamos si es el ultimo bit de lo necesario (8)
                                begin
                                    pari = (^b_next);
                                    state_next = parity;          //si es asi pasamos al estado stop
                                    n_next = 0;
                                end
                        end
                    else
                            
                            s_next = s_reg + 1;                 //si no seguimos contando los ticks
                end 

            parity:
                begin
                    if (s_tick)
                    begin
                        if (s_reg == (SB_TICK - 1))
                            begin
                                s_next = 0;                         //tenemos el bit por ende reiniciamos el contador de ticks
                                if(rx == pari)                  //chequiamos parity
                                    begin
                                        state_next = stop;          //si es asi pasamos al estado stop
                                    end
                                else
                                    state_next = idle;
                            end
                        else
                            s_next = s_reg + 1;     
                    end    
                end

            stop:
                begin
                    if (s_tick)
                        begin
                            if (s_reg == (SB_TICK - 1))                 //corroboramos que los ticks son los necesarios para el bit de stop
                                begin   
                                    state_next = idle;                  //si es asi volvemos a idle
                                    rx_done_tick = 1'b1;                //y ponemos que tenemos el dato completo
                                end
                            else
                                s_next = s_reg + 1;                     //si no seguimos contando los ticks
                        end
                end
            
            
            //Default que agregamos nosotros porque no tenia
            default:
                begin
                    state_next  = idle;
                    b_next      = 0;
                end
        endcase 
    end
    assign dout = b_reg; 
    endmodule 