`timescale 1ns / 1ps
`include "parameters.vh"
module mem_controller#(
    parameter NB_DATA = 32,
    parameter NB_TYPE = 3
) 
(   
    input                   i_signed,
    input                   i_write,
    input                   i_read,
    input  [NB_TYPE-1:0]    i_word_size,

    input  [NB_DATA-1:0]    i_write_data,
    input  [NB_DATA-1:0]    i_read_data,

    output [NB_DATA-1:0]    o_write_data,
    output [NB_DATA-1:0]  	o_read_data
);

    reg [NB_DATA-1:0]   write_data;
    reg [NB_DATA-1:0]   read_data;

	always@(*) begin
        // Read
        //  Signada o Sin signar
        if(i_read)begin 
            // Signed
            if(i_signed)begin            
                case(i_word_size)
                    `BYTE_WORD:
                        read_data = {{24{i_read_data[7]}}, i_read_data[7:0]};
                    `HALF_WORD:
                        read_data = {{16{i_read_data[15]}}, i_read_data[15:0]};
                    `COMPLETE_WORD:
                        read_data = i_read_data;

                    default:
                        read_data = 32'b0;
                endcase
            end
            // Sin signar
            else begin
                case(i_word_size)
                    `BYTE_WORD:
                        read_data = {{24'b0}, i_read_data[7:0]};
                    `HALF_WORD:
                        read_data = {{16'b0}, i_read_data[15:0]};
                    `COMPLETE_WORD:
                        read_data = i_read_data;

                    default:
                        read_data = 32'b0;
                endcase
            end
        end
        else
            read_data = 32'b0;
        
        // Write
        if(i_write)begin
            case(i_word_size)
                `BYTE_WORD:
                    write_data = i_write_data[7:0];
                `HALF_WORD:
                    write_data = i_write_data[15:0];
                `COMPLETE_WORD:
                    write_data = i_write_data;

                default:
                    write_data = 32'b0;
            endcase
        end
        else
            write_data = 32'b0;
	end

    assign o_write_data = write_data;
	assign o_read_data  = read_data;

endmodule