`timescale 1ns / 1ps

module ext_signo#(
        parameter NB_EXTEND = 32,
        parameter NB_UNEXTEND = 16
    )
    (
        input [NB_UNEXTEND-1:0] i_unextended,
        output [NB_EXTEND-1:0] o_extended
    );
    /*
    La función de una carga con signo es copiar el signo repetitivamente hasta
    completar el resto del registro, llamado extensión de signo, pero su propósito es cargar
    una representación correcta del número en el registro. La carga sin signo rellena con
    ceros los bits a la izquierda del dato, de modo que el número representado por la
    secuencia de bits no tiene signo.
    */
    //[8-F]XXX -> FFFF [8-F]XXX
    //[0-7]XXX -> 0000 [0-7]XXX
    assign o_extended = {{16{i_unextended[15]}}, i_unextended};

endmodule

