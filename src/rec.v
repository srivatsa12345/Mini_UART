`timescale 1ns / 1ps

module receiver #(parameter WIDTH=8) (
    input sys_rst, uart_clk, uart_REC_dataH,
    output reg rec_readyH, rec_busyH,
    output reg [WIDTH-1:0] rec_dataH 
    );
    reg [WIDTH-1:0] temp;
    reg [1:0] c_state,nxt_state;
    reg [1:0] ff;
    reg [3:0] word_count,count;
    localparam IDLE=2'b00, WAIT=2'b01, REC=2'b10, STOP=2'b11;
    always @ (posedge uart_clk or negedge sys_rst) begin  
        if (!sys_rst) begin
            c_state<=IDLE;
            ff<=2'b11;
            temp<={WIDTH{1'b0}};
            rec_dataH<={WIDTH{1'b0}};
        end else begin
            c_state<=nxt_state;
            ff[1]<=uart_REC_dataH;
            ff[0]<=ff[1];
        end
    end
    always @ (posedge uart_clk or negedge sys_rst) begin  
        if (!sys_rst) begin
            count<=4'd0;
        end else begin
            if ((c_state==WAIT)||(c_state==STOP)) count<=count+1'b1;
            else count<=4'b0000;
        end
    end
    always @ (*) begin
        nxt_state=c_state;
        case(c_state)
            IDLE:begin
                rec_busyH=1'b0;
                rec_readyH=1'b1;
                if (!uart_REC_dataH) begin
                    nxt_state=WAIT;
                end else nxt_state=IDLE;
                word_count=WIDTH+2;
            end
            WAIT:begin
                if(word_count==WIDTH+2) begin
                    if (count==4'b0110) nxt_state=REC;
                    else nxt_state=WAIT;
                end else if(word_count==4'd1) begin
                    if (count==4'b1110) nxt_state=STOP;
                    else nxt_state=WAIT;
                end else begin
                    if (count==4'b1110) nxt_state=REC;
                    else nxt_state=WAIT;
                end
            end
            REC:begin
                if((word_count==WIDTH+2)&&(ff[0]!=1'b0)) begin
                    nxt_state=IDLE;
                end else begin
                    rec_busyH=1'b1;
                    rec_readyH=1'b0;
                    temp={ff[0],temp[WIDTH-1:1]};
                    word_count=word_count-1'b1;
                    nxt_state=WAIT;
                end
            end
            STOP:begin
                if(ff[0]) rec_dataH=temp;
                temp={WIDTH{1'b0}};
                rec_readyH=1'b1;
                rec_busyH=1'b0;
                nxt_state=IDLE;
            end
            default:nxt_state=IDLE;
        endcase
    end
endmodule
