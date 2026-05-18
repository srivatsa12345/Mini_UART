
`timescale 1ns / 1ps

module transmitter #(parameter WIDTH=8)(
    input sys_rst, uart_clk, xmitH,
    input [WIDTH-1:0] xmit_dataH,
    output reg uart_XMIT_dataH, xmit_doneH, xmit_active
    );
    reg [2:0]c_state,nxt_state;
    reg [3:0] count,word_count;
    reg [WIDTH-1:0]data;
    localparam IDLE=3'b000, START=3'b001, TRANS=3'b010, WAIT=3'b011, STOP=3'b100;
    always @ (posedge uart_clk or negedge sys_rst) begin  
        if (!sys_rst) begin
            c_state<=IDLE;
        end else begin
            c_state<=nxt_state;
        end
    end
    always @ (*) begin
        nxt_state=c_state;
        case(c_state)
            IDLE:begin
                xmit_doneH=1'b1;
                xmit_active=1'b0;
                uart_XMIT_dataH=1'b1;
                if (xmitH) begin
                    nxt_state=START;
                    data=xmit_dataH;
                end
                word_count=WIDTH+1;
            end
            START:begin
                xmit_active=1'b1;
                xmit_doneH=1'b0;
                uart_XMIT_dataH=1'b0;
                nxt_state=WAIT;
            end
            WAIT:begin
                if (word_count==4'd1) begin
                    if (count==4'b1110) nxt_state=STOP;
                    else nxt_state=WAIT;
                end else if(word_count!=4'd0) begin
                    if (count==4'b1110) nxt_state=TRANS;
                    else nxt_state=WAIT;
                end else begin
                    if (count==4'b1110) nxt_state=IDLE;
                    else nxt_state=WAIT;
                end
            end
            TRANS:begin
                uart_XMIT_dataH=data[0];
                data=data>>1;
                word_count=word_count-1'b1;
                nxt_state=WAIT;
            end
            STOP:begin
                uart_XMIT_dataH=1'b1;
                word_count=0;
                nxt_state=WAIT;
            end
            default:nxt_state=IDLE;
        endcase
    end
    always @ (posedge uart_clk or negedge sys_rst) begin 
        if(!sys_rst) begin
            count<=4'b0000;
        end else begin
            if (c_state==WAIT) count<=count+1'b1;
            else count<=4'b0000;
        end
    end
endmodule

