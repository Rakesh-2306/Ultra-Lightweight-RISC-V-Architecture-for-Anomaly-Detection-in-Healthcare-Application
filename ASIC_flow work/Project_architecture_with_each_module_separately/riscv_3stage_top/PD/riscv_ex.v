`timescale 1ns/1ps
module riscv_ex (
    input  [31:0] id_ex_pc,
    input  [31:0] id_ex_rs1,
    input  [31:0] id_ex_rs2,
    input  [31:0] id_ex_imm,
    input  [4:0]  id_ex_rd,
    input         id_ex_is_load,
    input         id_ex_is_store,
    input         id_ex_alu_src_imm,
    input  [3:0]  id_ex_alu_op,
    input         id_ex_reg_write,
    input  [1:0]  id_ex_wb_sel,
    input         id_ex_valid,
    input  [2:0]  id_ex_funct3,
    input  [6:0]  id_ex_funct7,
    // DMEM interface
    output reg        dmem_en,
    output reg        dmem_we,
    output reg [31:0] dmem_addr,
    output reg [31:0] dmem_wdata,
    input  [31:0]     dmem_rdata,
    // outputs for WB
    output reg [31:0] ex_alu_result,
    output reg [4:0]  ex_wb_rd,
    output reg        ex_wb_reg_write,
    output reg [1:0]  ex_wb_sel,
    // branch outputs
    output reg        branch_taken,
    output reg [31:0] branch_target
);
    // combinational ALU & control
    reg [31:0] alu_in1, alu_in2;
    reg [31:0] alu_res;
    integer kk;

    always @(*) begin
        // defaults
        alu_res = 32'd0;
        branch_taken = 1'b0;
        branch_target = 32'd0;
        dmem_en = 1'b0;
        dmem_we = 1'b0;
        dmem_addr = 32'd0;
        dmem_wdata = 32'd0;
        ex_alu_result = 32'd0;
        ex_wb_rd = id_ex_rd;
        ex_wb_reg_write = id_ex_reg_write;
        ex_wb_sel = id_ex_wb_sel;

        // ALU inputs
        alu_in1 = id_ex_rs1;
        alu_in2 = id_ex_alu_src_imm ? id_ex_imm : id_ex_rs2;

        case (id_ex_alu_op)
            4'd0: alu_res = alu_in1 + alu_in2; // ADD / ADDI
            4'd1: alu_res = alu_in1 & alu_in2;
            4'd2: alu_res = alu_in1 | alu_in2;
            4'd3: alu_res = alu_in1 ^ alu_in2;
            4'd4: alu_res = alu_in1 << (alu_in2[4:0]);
            4'd5: alu_res = alu_in1 >> (alu_in2[4:0]);
            4'd6: alu_res = alu_in1 - alu_in2; // SUB
            4'd7: begin // Branch comparator
                case (id_ex_funct3)
                    3'b000: begin // BEQ
                        if (alu_in1 == alu_in2) begin branch_taken = 1'b1; branch_target = id_ex_pc + id_ex_imm; end
                    end
                    3'b001: begin // BNE
                        if (alu_in1 != alu_in2) begin branch_taken = 1'b1; branch_target = id_ex_pc + id_ex_imm; end
                    end
                    3'b100: begin // BLT (signed)
                        if ($signed(alu_in1) < $signed(alu_in2)) begin branch_taken = 1'b1; branch_target = id_ex_pc + id_ex_imm; end
                    end
                    3'b101: begin // BGE (signed)
                        if ($signed(alu_in1) >= $signed(alu_in2)) begin branch_taken = 1'b1; branch_target = id_ex_pc + id_ex_imm; end
                    end
                    default: begin end
                endcase
            end
            4'd10: alu_res = alu_in1 * alu_in2; // MUL (behavioral)
            default: alu_res = 32'd0;
        endcase

        // memory control if valid
        if (id_ex_valid) begin
            if (id_ex_is_store) begin
                dmem_en = 1'b1;
                dmem_we = 1'b1;
                dmem_addr = alu_res;
                dmem_wdata = id_ex_rs2;
            end else if (id_ex_is_load) begin
                dmem_en = 1'b1;
                dmem_we = 1'b0;
                dmem_addr = alu_res;
            end else begin
                dmem_en = 1'b0;
                dmem_we = 1'b0;
                dmem_addr = 32'd0;
                dmem_wdata = 32'd0;
            end
        end

        // set ALU result for writeback (if MEM selected, top will pick dmem_rdata)
        ex_alu_result = alu_res;
    end

endmodule
