`timescale 1ns/1ps
// simple synchronous word RAM
module riscv_dmem_syncram #(
    parameter AW = 7, // 2^AW words
    parameter DW = 32
)(
    input               clk,
    input               en,
    input               we,
    input  [DW-1:0]     wdata,
    input  [AW-1:0]     addr,
    output reg [DW-1:0] rdata
);
    reg [DW-1:0] mem [0:(1<<AW)-1];

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                mem[addr] <= wdata;
                rdata <= wdata;
            end else begin
                rdata <= mem[addr];
            end
        end else begin
            rdata <= {DW{1'b0}};
        end
    end
endmodule
