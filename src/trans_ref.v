
`timescale 1ns / 1ps

module trans_ref #(parameter WIDTH=8) (
    input sys_rst_ref, uart_clk_ref, xmitH_ref,
    input [WIDTH-1:0] xmit_dataH_ref,
    output reg uart_XMIT_dataH_ref, xmit_doneH_ref, xmit_active_ref
    );
    reg [WIDTH+1:0] data;
    integer i;
    always begin
        if(!sys_rst_ref) begin
            xmit_doneH_ref=1'b1;
            xmit_active_ref=1'b0;
            uart_XMIT_dataH_ref=1'b1;
            @(posedge uart_clk_ref);
        end else begin
            if(xmitH_ref) begin
                begin:repeat_block
                    data={1'b1,xmit_dataH_ref,1'b0};
                    for(i=1;i<=(WIDTH+2);i=i+1) begin
                        repeat(16) begin
                            if(!sys_rst_ref) begin
                                xmit_doneH_ref=1'b1;
                                xmit_active_ref=1'b0;
                                disable repeat_block;
                            end else begin
                                xmit_doneH_ref=1'b0;
                                xmit_active_ref=1'b1;
                                uart_XMIT_dataH_ref=data[0];
                                @(posedge uart_clk_ref);
                            end
                        end
                        data=data>>1;
                    end
                end
            end else begin
                xmit_doneH_ref=1'b1;
                xmit_active_ref=1'b0;
                uart_XMIT_dataH_ref=1'b1;
                @(posedge uart_clk_ref);
            end
        end
    end
endmodule

