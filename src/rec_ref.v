
`timescale 1ns / 1ps

module rec_ref #(parameter WIDTH=8)(
    input sys_rst_ref, uart_clk_ref, uart_REC_dataH_ref,
    output reg rec_readyH_ref, rec_busyH_ref,
    output reg [WIDTH-1:0] rec_dataH_ref
    );
    reg [WIDTH-1:0] temp_ref;
    reg [3:0] word_count;
    integer i;
    always begin
        if(!sys_rst_ref) begin
            rec_readyH_ref=1'b1;
            rec_busyH_ref=1'b0;
            temp_ref={WIDTH{1'b0}};
            rec_dataH_ref={WIDTH{1'b0}};
            @(posedge uart_clk_ref);
        end else begin
            if(!uart_REC_dataH_ref) begin
                begin:repeat_block
                    word_count=WIDTH+1;
                    for(i=1;i<=(WIDTH+2);i=i+1) begin
                        if(word_count==WIDTH+1) begin
                            repeat(8) begin
                                @(posedge uart_clk_ref);
                                if(!sys_rst_ref) disable repeat_block;
                            end 
                            if (uart_REC_dataH_ref) disable repeat_block;
                            else begin
                                rec_readyH_ref=1'b0;
                                rec_busyH_ref=1'b1;
                            end
                            word_count=word_count-1;
                        end else if (word_count!=0) begin
                            repeat(16) begin
                                @(posedge uart_clk_ref);
                                if(!sys_rst_ref) disable repeat_block;
                            end 
                            temp_ref={uart_REC_dataH_ref,temp_ref[WIDTH-1:1]};
                            word_count=word_count-1;
                        end else begin
                            repeat(16) begin
                                @(posedge uart_clk_ref);
                                if(!sys_rst_ref) disable repeat_block;
                            end
                            if (uart_REC_dataH_ref) begin
                                rec_dataH_ref=temp_ref; 
                                rec_readyH_ref=1'b1;
                            end else rec_readyH_ref=1'b0;
                            rec_busyH_ref=1'b0;
                            temp_ref={WIDTH{1'b0}};
                        end
                    end
                end
            end else begin
                rec_busyH_ref=1'b0;
                temp_ref={WIDTH{1'b0}};
                if (rec_dataH_ref==={WIDTH{1'bx}}) rec_dataH_ref={WIDTH{1'b0}};
                if (rec_readyH_ref===1'bx) rec_readyH_ref=1'b1;
                @(posedge uart_clk_ref);
            end
        end
    end
endmodule

