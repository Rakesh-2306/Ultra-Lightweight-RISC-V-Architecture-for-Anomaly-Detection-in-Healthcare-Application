`timescale 1ns/1ps
module tb_id;
    reg [31:0] if_pc, if_instr;
    reg if_valid;
    reg [31:0] rs1_data, rs2_data;
    wire [31:0] imm_out;
    wire [3:0] alu_op;
    wire alu_src_imm, is_load, is_store, reg_write;
    wire [1:0] wb_sel;
    wire is_branch;

    riscv_id uut (
        .if_pc(if_pc), .if_instr(if_instr), .if_valid(if_valid),
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .imm_out(imm_out), .rd_out(), .rs1_out(), .rs2_out(),
        .alu_op_out(alu_op), .alu_src_imm_out(alu_src_imm),
        .is_load_out(is_load), .is_store_out(is_store),
        .reg_write_out(reg_write), .wb_sel_out(wb_sel),
        .is_branch_out(is_branch), .branch_imm_out()
    );

    initial begin
        $display("Starting ID TB");
        if_pc = 0; rs1_data = 0; rs2_data = 0; if_valid = 1;
        // Test ADDI x1,x0,5 = opcode 0010011 funct3=000 imm=5
        if_instr = 32'h00500093; #10;
        $display("ADDI imm=%0d alu_op=%0d src_imm=%b reg_write=%b", imm_out, alu_op, alu_src_imm, reg_write);
        // Test LW (0000011)
        if_instr = 32'h00002103; #10;
        $display("LW imm=%h is_load=%b wb_sel=%0d", imm_out, is_load, wb_sel);
        // Test BEQ example: opcode 1100011
        // Use an example encoding for branch (imm = 4)
        if_instr = 32'b0000000_00010_00001_000_00010_1100011; // random pattern
        #10;
        $display("Branch detected = %b imm=%h", is_branch, imm_out);
        $finish;
    end
endmodule
