`timescale 1ns/1ps
module tb_regfile;
    reg clk, resetn;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] wd;
    reg we;
    wire [31:0] r1, r2;

    riscv_regfile uut (
        .clk(clk),
        .resetn(resetn),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rs1_data(r1),
        .rs2_data(r2),
        .we(we),
        .rd_addr(rd),
        .rd_data(wd)
    );

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        $display("Starting regfile TB");
        resetn = 0; we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;
        #20;
        resetn = 1;
        #10;
        // try writing x1=42
        rd = 5'd1; wd = 32'd42; we = 1;
        #10; we = 0;
        #10;
        if (r1 !== 32'd42 && rs1==5'd1) $display("Note: r1 read must be driven by setting rs1.");
        // read back
        rs1 = 5'd1; rs2 = 5'd0;
        #10;
        $display("x1 = %0d (expected 42), x0 = %0d (expected 0)", r1, r2);
        if (r1 !== 32'd42) $display("FAIL: regfile write/read");
        else $display("PASS: regfile");
        $finish;
    end
endmodule
