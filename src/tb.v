`include "top_dut.v"
`include "top_ref.v"
`timescale 1ns / 1ps

module tb_mini_uart;
    reg         sys_clk;
    reg         sys_rst_l;
    reg         xmitH;
    reg         uart_REC_dataH;
    reg [7:0]   xmit_dataH;

    wire        uart_XMIT_dataH, uart_XMIT_dataH_ref;
    wire        xmit_doneH,xmit_doneH_ref;
    wire        rec_readyH,rec_readyH_ref;
    wire        rec_busy,rec_busyH_ref;
    wire        xmit_active, xmit_active_ref;
    wire [7:0]  rec_dataH,rec_dataH_ref;
    wire        uart_clk;

    integer total_case=0;
    integer pass_case=0;
    integer fail_case=0;

    top m1(
        .sys_clk(sys_clk),
        .sys_rst_l(sys_rst_l),
        .xmitH(xmitH),
        .uart_REC_dataH(uart_REC_dataH),
        .xmit_dataH(xmit_dataH),
        .uart_XMIT_dataH(uart_XMIT_dataH),
        .xmit_doneH(xmit_doneH),
        .rec_readyH(rec_readyH),
        .rec_busy(rec_busy),
        .xmit_active(xmit_active),
        .rec_dataH(rec_dataH),
        .uart_clk(uart_clk)
    );

    top_ref m2(
    .sys_rst_l(sys_rst_l),
    .xmitH(xmitH),
    .uart_REC_dataH(uart_REC_dataH),
    .uart_clk(uart_clk),
    .xmit_dataH(xmit_dataH),
    .uart_XMIT_dataH_ref(uart_XMIT_dataH_ref),
    .xmit_doneH_ref(xmit_doneH_ref),
    .xmit_active_ref(xmit_active_ref),
    .rec_readyH_ref(rec_readyH_ref),
    .rec_busyH_ref(rec_busyH_ref),
    .rec_dataH_ref(rec_dataH_ref)
    );

    initial sys_clk=1'b0;
    always #5 sys_clk=~sys_clk;
    
    initial begin
        repeat(1050) @(posedge uart_clk);
        $display("Assert reset during Transmission");
        xmit_dataH=8'hED;
        xmitH=1'b1;
        @(negedge uart_clk); 
        @(posedge uart_clk);
        @(negedge uart_clk);
        xmitH=1'b0;
        repeat(30) @(posedge uart_clk);
        sys_rst_l=1'b0;
        $display("Test Summary");
        $display("Total uart_clock edges being checked                        = %4d",total_case);
        $display("Total uart_clock edges where the output of DUT is correct   = %4d",pass_case);
        $display("Total uart_clock edges where the output of DUT is incorrect = %4d",fail_case);
        $finish;
    end
    
    initial begin
        repeat(1050) @(posedge uart_clk);
        $display("Assert reset during Reception");
        rec_in(8'hAD);
    end
    
    initial begin
        xmitH=1'b0; xmit_dataH={8{1'b0}};
        $display("Assert de-assert reset");
        sys_rst_l=1'b1; #1;
        sys_rst_l=1'b0; #29;
        sys_rst_l=1'b1;

        $display("Normal Transmission");
        xmit_dataH=8'hAA;
        trans_in;
        repeat(50) @(posedge uart_clk);
        $display("Toggle xmitH during Normal Transmission");
        trans_in;
        repeat(50) @(posedge uart_clk);
        $display("Change input and toggle xmitH during Normal Transmission");
        xmit_dataH=8'h55;
        trans_in;
        repeat(60) @(posedge uart_clk);

        $display("Keep xmitH=1 during Normal Transmission");
        xmit_dataH=8'hAA;
        xmitH=1'b1;
        repeat(100) @(posedge uart_clk);
        $display("Change input and keep xmitH=1 during Normal Transmission");
        xmit_dataH=8'h55;
        repeat(170) @(posedge uart_clk);
        xmitH=1'b0;
        repeat(60) @(posedge uart_clk);

        $display("Continuous Transmission");
        xmit_dataH=8'h00;
        trans_in;
        repeat(160) @(posedge uart_clk);
        xmit_dataH=8'hFF;
        trans_in;
        repeat(160) @(posedge uart_clk);
    end

    initial begin
        uart_REC_dataH=1'b1;
        #30;
        $display("Normal Reception");
        rec_in(8'h55);
        $display("Reset during reception");
        rec_in(8'hF0);
        $display("Give start bit 0 and then change it before 8th clk cycle");
        rec_in_bluff;
        repeat(50) @(posedge uart_clk);
        $display("Give stop bit 1 and then change it 0");
        rec_stop_bit_err(8'hAA);
        $display("Continuous reception");
        rec_in(8'hAA);
        rec_in(8'h00);
        rec_in(8'hFF);
    end

    task rec_in;
        input [7:0]in;
        reg [9:0]data;
        integer i;
        begin
            data={1'b1,in,1'b0};
            for (i=1;i<=10;i=i+1) begin
                repeat(16) @(posedge uart_clk) uart_REC_dataH=data[0];
                data=data>>1;
            end
        end
    endtask

    task rec_in_bluff;
        begin
            uart_REC_dataH=1'b0;
            repeat(4) @(posedge uart_clk);
            uart_REC_dataH=1'b1;
        end
    endtask

    task rec_stop_bit_err;
        input [7:0]in;
        reg [10:0]data;
        integer i;
        begin
            data={1'b1,1'b0,in,1'b0};
            for (i=1;i<=11;i=i+1) begin
                repeat(16) @(posedge uart_clk) uart_REC_dataH=data[0];
                data=data>>1;
            end
        end
    endtask

    task trans_in;
        begin
            xmitH=1'b1;
            @(negedge uart_clk);
            @(posedge uart_clk);
            @(negedge uart_clk);
            xmitH=1'b0;
        end
    endtask

    always @ (posedge uart_clk or negedge sys_rst_l) begin
        if (sys_rst_l) compare_results();
        else compare_rst();
    end

    task compare_results;
        begin
            #1;
            total_case=total_case+1;
            if((uart_XMIT_dataH_ref!=uart_XMIT_dataH)||(xmit_doneH_ref!=xmit_doneH)||(xmit_active_ref!=xmit_active)||(rec_readyH_ref!=rec_readyH)||(rec_busyH_ref!=rec_busy)||(rec_dataH_ref!=rec_dataH)) begin
                fail_case=fail_case+1;
                $display("TIME=%0t [FAIL] sys_rst_l=%0b,xmitH=%0b,uart_REC_dataH=%0b,xmit_dataH=%0h",$time,sys_rst_l,xmitH,uart_REC_dataH,xmit_dataH);
                $display("DUT:     uart_XMIT_dataH=%0b     xmit_doneH=%0b     xmit_active=%0b     rec_readyH=%b      rec_busy=%b     rec_dataH=%h",uart_XMIT_dataH, xmit_doneH, xmit_active, rec_readyH, rec_busy, rec_dataH);
                $display("REF: uart_XMIT_dataH_ref=%0b xmit_doneH_ref=%0b xmit_active_ref=%0b rec_readyH_ref=%b rec_busyH_ref=%b rec_dataH_ref=%h",uart_XMIT_dataH_ref, xmit_doneH_ref, xmit_active_ref, rec_readyH_ref, rec_busyH_ref, rec_dataH_ref);
                $display("-----------------------------------------------------------------------------------------------------------------------------------------");
            end else begin
                pass_case=pass_case+1;
                $display("TIME=%0t [PASS] sys_rst_l=%0b,xmitH=%0b,uart_REC_dataH=%0b,xmit_dataH=%0h",$time,sys_rst_l,xmitH,uart_REC_dataH,xmit_dataH);
                $display("DUT:     uart_XMIT_dataH=%0b     xmit_doneH=%0b     xmit_active=%0b     rec_readyH=%b      rec_busy=%b     rec_dataH=%h",uart_XMIT_dataH, xmit_doneH, xmit_active, rec_readyH, rec_busy, rec_dataH);
                $display("REF: uart_XMIT_dataH_ref=%0b xmit_doneH_ref=%0b xmit_active_ref=%0b rec_readyH_ref=%b rec_busyH_ref=%b rec_dataH_ref=%h",uart_XMIT_dataH_ref, xmit_doneH_ref, xmit_active_ref, rec_readyH_ref, rec_busyH_ref, rec_dataH_ref);
                $display("-----------------------------------------------------------------------------------------------------------------------------------------");
            end
        end
    endtask
    task compare_rst;
        begin
            #1;
            total_case=total_case+1;
            if((uart_XMIT_dataH!=1'b1)||(xmit_doneH!=1'b1)||(xmit_active!=1'b0)||(rec_readyH!=1'b1)||(rec_busy!=1'b0)||(rec_dataH!={8{1'h0}})) begin
                fail_case=fail_case+1;
                $display("TIME=%0t [FAIL-RESET] sys_rst_l=%0b xmitH=%0b uart_REC_dataH=%0b xmit_dataH=%0h",$time,sys_rst_l,xmitH,uart_REC_dataH,xmit_dataH);
                $display("DUT:     uart_XMIT_dataH=%0b     xmit_doneH=%0b     xmit_active=%0b     rec_readyH=%b      rec_busy=%b     rec_dataH=%h",uart_XMIT_dataH, xmit_doneH, xmit_active, rec_readyH, rec_busy, rec_dataH);
                $display("-----------------------------------------------------------------------------------------------------------------------------------------");
            end else begin
                pass_case=pass_case+1;
                $display("TIME=%0t [PASS-RESET] sys_rst_l=%0b xmitH=%0b uart_REC_dataH=%0b xmit_dataH=%0h",$time,sys_rst_l,xmitH,uart_REC_dataH,xmit_dataH);
                $display("DUT:     uart_XMIT_dataH=%0b     xmit_doneH=%0b     xmit_active=%0b     rec_readyH=%b      rec_busy=%b     rec_dataH=%h",uart_XMIT_dataH, xmit_doneH, xmit_active, rec_readyH, rec_busy, rec_dataH);
                $display("-----------------------------------------------------------------------------------------------------------------------------------------");
            end
        end
    endtask
endmodule

