
`include "trans.v"
`include "rec.v"
`include "baud.v"
`timescale 1ns / 1ps

module top(
     input   sys_clk,sys_rst_l,xmitH,uart_REC_dataH,
    input   [7:0] xmit_dataH,

    output uart_XMIT_dataH,xmit_doneH,rec_readyH,rec_busy,xmit_active,
    output [7:0] rec_dataH,
        output  uart_clk
    );
    
    baud #(.XTAL_CLK(100000000),.BAUD(2400)) m1(
    .sys_clk(sys_clk),.sys_rst(sys_rst_l),
    .uart_clk(uart_clk)
    );
     
    transmitter #(.WIDTH(8)) m2(
    .sys_rst(sys_rst_l), .uart_clk(uart_clk), .xmitH(xmitH),
    .xmit_dataH(xmit_dataH),
    .uart_XMIT_dataH(uart_XMIT_dataH), .xmit_doneH(xmit_doneH), .xmit_active(xmit_active)
    ); 
      
    receiver #(.WIDTH(8)) m3(
    .sys_rst(sys_rst_l), .uart_clk(uart_clk), .uart_REC_dataH(uart_REC_dataH),
    .rec_readyH(rec_readyH), .rec_busyH(rec_busy),
    .rec_dataH(rec_dataH)
    );
    
    


endmodule

