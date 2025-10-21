`timescale 1ns/1ps
module riscv_regfile (
    input           clk,
    input           resetn,
    // read ports
    input  [4:0]    rs1_addr,
    input  [4:0]    rs2_addr,
    output [31:0]   rs1_data,
    output [31:0]   rs2_data,
    // write port
    input           we,
    input  [4:0]    rd_addr,
    input  [31:0]   rd_data
);
    reg [31:0] regs [0:31];
    integer i;

    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            for (i=0; i<32; i=i+1) regs[i] <= 32'd0;
        end else begin
            if (we && (rd_addr != 5'd0)) begin
                regs[rd_addr] <= rd_data;
            end
        end
    end
endmodule
