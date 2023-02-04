module uart_interface
#(
    parameter  N_BITS         = 8
)
(
    input wire                   clk,
    input wire                   reset,
    input wire  [N_BITS-1 : 0]  i_dato_Recv,
    input wire                   i_dato_Recv_valid,

    output wire                  o_tx_start,
    output wire [N_BITS-1 : 0]  o_A,
    output wire [N_BITS-1 : 0]  o_B,
    output wire [N_BITS-1 : 0]  o_OP
    );
  
    localparam  [1 : 0] DATO_A  = 2'b00;
    localparam  [1 : 0] DATO_B  = 2'b01;
    localparam  [1 : 0] DATO_OP = 2'b10;

    reg [1 : 0]         state_reg;
    reg [1 : 0]         state_reg_next;
    reg [N_BITS-1 : 0] A;
    reg [N_BITS-1 : 0] B;    
    reg [N_BITS-1 : 0] OP;

    //Flags de recepcion del dato correspondiente
    reg rec_A;
    reg rec_B;
    reg rec_OP;

    reg tx_start;
    reg tx_start_next;  

    
    //Para recetear el estado o pasar al siguiente
    always @(posedge clk)
    begin
        
        if(reset)
            begin
                state_reg   <=  rec_A;
            end
        else
            begin
                state_reg   <=  state_reg_next;
            end
    
    end




    //Para resetear el valor de A o ponerle valor de entrada
    always @(posedge clk)
    begin
        if(reset)
            A  <=  {N_BITS{1'b0}};
        else if(rec_A)
            A <=   i_dato_Recv;
    end

    //Para resetear el valor de B o ponerle valor de entrada
    always @(posedge clk)
    begin
        if(reset)
            B  <=  {N_BITS{1'b0}};
        else if(rec_B)
            B <=  i_dato_Recv;
    end

    //Para resetear el valor de OP o ponerle valor de entrada
    always @(posedge clk)
    begin
        if(reset)
            OP  <= {N_BITS{1'b0}};
        else if(rec_OP)
            OP <=   i_dato_Recv[N_BITS-1 : 0];
    end

    //Para actualizar el valor si se tiene que trasmitir el resultado o no
    always @(posedge clk)
    begin
        if(reset)
            tx_start    <= 1'b0;
        else 
            tx_start    <= tx_start_next;
    end





    //Maquina que decide el estado
    always @(*)
    begin

        state_reg_next  = state_reg;
        rec_A           =   1'b0;
        rec_B           =   1'b0;
        rec_OP          =   1'b0;
        tx_start_next   =   1'b0;

        case (state_reg)

            DATO_A:
                begin
                    if  (i_dato_Recv_valid)
                        begin
                            state_reg_next  = DATO_B;
                            rec_A = 1'b1;           //Esto habilitar el IF de arriba muy arriba y copia el calor de entrada en el registro A
                        end
                end

            DATO_B:
                begin
                    if  (i_dato_Recv_valid)
                        begin
                            state_reg_next  = DATO_OP;
                            rec_B = 1'b1;           //Esto habilitar el IF de arriba muy arriba y copia el calor de entrada en el registro B
                        end
                end

            DATO_OP:
                begin
                    if  (i_dato_Recv_valid)
                        begin
                            state_reg_next = DATO_A;
                            rec_OP         = 1'b1;  //Esto habilitar el IF de arriba muy arriba y copia el calor de entrada en el registro OP     
                            tx_start_next  = 1'b1;  //Estoy habilita la trasmision y hace que el modulo TX trasmita el valor resultado de la ALU
                        end
                end

            default:
                begin
                    state_reg_next      =  DATO_A;
                end
        endcase
    end

assign  o_A        = A;
assign  o_B        = B;
assign  o_OP       = OP;
assign  o_tx_start = tx_start;    

endmodule

