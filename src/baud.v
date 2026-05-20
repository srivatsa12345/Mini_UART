`timescale 1ns / 1ps

module baud #(parameter XTAL_CLK=100000000,BAUD=2400)(
    input sys_clk,sys_rst,
    output reg uart_clk
    );
    reg [$clog2(XTAL_CLK/(BAUD*16*2))-1:0]count;
    always @ (posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            count<=32'b0;
            uart_clk<=0;
        end else if(count==(XTAL_CLK/(BAUD*16*2))) begin
            uart_clk<=~uart_clk;
            count<=32'b0;
        end else begin
            count<=count+1;
            uart_clk<=uart_clk;
        end
    end
endmodule

