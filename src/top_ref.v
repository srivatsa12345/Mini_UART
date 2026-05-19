
`include "trans_ref.v"
`include "rec_ref.v"
`timescale 1ns / 1ps

module top_ref(
    input   sys_rst_l,xmitH,uart_REC_dataH,uart_clk,
    input   [7:0] xmit_dataH,
    output uart_XMIT_dataH_ref,xmit_doneH_ref,xmit_active_ref,rec_readyH_ref,rec_busyH_ref,
    output [7:0] rec_dataH_ref
    );
    trans_ref #(.WIDTH(8)) m2(
        .sys_rst_ref(sys_rst_l), 
        .uart_clk_ref(uart_clk), 
        .xmitH_ref(xmitH),
        .xmit_dataH_ref(xmit_dataH),
        .uart_XMIT_dataH_ref(uart_XMIT_dataH_ref), 
        .xmit_doneH_ref(xmit_doneH_ref), 
        .xmit_active_ref(xmit_active_ref)
    );
    
    rec_ref #(.WIDTH(8)) m3(
    .sys_rst_ref(sys_rst_l), 
    .uart_clk_ref(uart_clk), 
    .uart_REC_dataH_ref(uart_REC_dataH),
    .rec_readyH_ref(rec_readyH_ref), 
    .rec_busyH_ref(rec_busyH_ref),
    .rec_dataH_ref(rec_dataH_ref)
    );
endmodule

