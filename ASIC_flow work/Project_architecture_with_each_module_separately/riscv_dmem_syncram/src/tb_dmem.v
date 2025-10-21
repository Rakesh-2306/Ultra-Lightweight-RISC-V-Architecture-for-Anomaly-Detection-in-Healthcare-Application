`timescale 1ns/1ps
module tb_dmem;
    reg clk;
    reg en, we;
    reg [31:0] wdata;
    reg [6:0] addr;
    wire [31:0] rdata;

    riscv_dmem_syncram #(.AW(7)) uut (.clk(clk), .en(en), .we(we), .wdata(wdata), .addr(addr), .rdata(rdata));

    initial begin clk=0; forever #5 clk = ~clk; end

    initial begin
        $display("Starting DMEM TB");
        en=0; we=0; wdata=0; addr=0;
        #20;
        en=1; we=1; addr=7'd3; wdata=32'hDEADBEEF;
        #10; we=0; addr=7'd3;
        #10 $display("read mem[3]=%h (expect DEADBEEF)", rdata);
        if (rdata !== 32'hDEADBEEF) $display("FAIL DMEM");
        else $display("PASS DMEM");
        $finish;
    end
endmodule
