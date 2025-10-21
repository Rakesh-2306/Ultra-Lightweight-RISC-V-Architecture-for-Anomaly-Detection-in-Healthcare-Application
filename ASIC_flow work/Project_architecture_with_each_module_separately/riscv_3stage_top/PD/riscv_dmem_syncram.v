`timescale 1ns/1ps
module riscv_dmem_syncram #(
    parameter AW = 7   // address width -> depth = 2^AW
)(
    input              clk,
    input              en,
    input              we,
    input  [AW-1:0]    addr,
    input  [31:0]      wdata,
    output [31:0]      rdata
);
    // simple memory
    reg [31:0] mem [(1<<AW)-1:0];
    integer ii;

    // synchronous write
    always @(posedge clk) begin
        if (en && we) begin
            mem[addr] <= wdata;
        end
    end

    // combinational read (synthesizable); simple and easy for functional verification
    assign rdata = mem[addr];

    // optional initialize to zeros (synthesis tools ignore initial for FPGA RAMs)
    initial begin
        for (ii=0; ii < (1<<AW); ii = ii + 1) mem[ii] = 32'h0;
    end
endmodule
