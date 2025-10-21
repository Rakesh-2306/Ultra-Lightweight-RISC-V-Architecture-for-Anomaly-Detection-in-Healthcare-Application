`timescale 1ns/1ps
module tb_ex;
    reg [31:0] pc, rs1, rs2, imm;
    reg [3:0] alu_op;
    reg alu_src_imm, is_load, is_store, reg_write;
    reg [1:0] wb_sel;
    reg valid;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire dmem_en, dmem_we;
    wire [31:0] dmem_addr, dmem_wdata;
    reg [31:0] dmem_rdata;
    wire [31:0] ex_res;
    wire [4:0] ex_rd;
    wire ex_we;
    wire [1:0] ex_wb_sel;
    wire branch_taken;
    wire [31:0] branch_target;

    riscv_ex uut (
        .id_ex_pc(pc), .id_ex_rs1(rs1), .id_ex_rs2(rs2), .id_ex_imm(imm),
        .id_ex_rd(5'd1), .id_ex_is_load(is_load), .id_ex_is_store(is_store),
        .id_ex_alu_src_imm(alu_src_imm), .id_ex_alu_op(alu_op),
        .id_ex_reg_write(reg_write), .id_ex_wb_sel(wb_sel), .id_ex_valid(valid),
        .id_ex_funct3(funct3), .id_ex_funct7(funct7),
        .dmem_en(dmem_en), .dmem_we(dmem_we), .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata),
        .ex_alu_result(ex_res), .ex_wb_rd(ex_rd), .ex_wb_reg_write(ex_we),
        .ex_wb_sel(ex_wb_sel), .branch_taken(branch_taken), .branch_target(branch_target)
    );

    initial begin
        $display("Starting EX TB");
        // ADD
        pc=0; rs1=10; rs2=20; imm=0; alu_op=4'd0; alu_src_imm=0; valid=1;
        #10 $display("ADD res=%0d (expect 30)", ex_res);
        // ADDI
        alu_src_imm=1; imm=5; alu_op=4'd0; #10 $display("ADDI res=%0d (expect 15)", ex_res);
        // BEQ taken
        alu_src_imm=0; alu_op=4'd7; funct3=3'b000; rs1=5; rs2=5; imm=32'd8; #10 $display("BEQ taken=%b target=%0d", branch_taken, branch_target);
        // BNE
        rs2=6; funct3=3'b001; #10 $display("BNE taken=%b", branch_taken);
        // MUL
        alu_op=4'd10; rs1=3; rs2=4; alu_src_imm=0; #10 $display("MUL res=%0d (expect 12)", ex_res);
        // LOAD address calc
        alu_op=4'd0; alu_src_imm=1; imm=32'd12; is_load=1; #10 $display("dmem_addr=%0d dmem_en=%b", dmem_addr, dmem_en);
        $finish;
    end
endmodule
