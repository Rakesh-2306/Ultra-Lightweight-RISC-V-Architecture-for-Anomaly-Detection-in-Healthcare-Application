`timescale 1ns/1ps
module riscv_id (
    input  [31:0] if_pc,
    input  [31:0] if_instr,
    input         if_valid,
    input  [31:0] rs1_data,
    input  [31:0] rs2_data,

    output reg [31:0] imm_out,
    output reg [3:0]  alu_op_out,
    output reg        alu_src_imm_out,
    output reg        is_load_out,
    output reg        is_store_out,
    output reg        reg_write_out,
    output reg [1:0]  wb_sel_out,
    output reg        is_branch_out,
    output reg [31:0] branch_imm_out
);
    // combinational decode
    always @(*) begin
        // defaults
        imm_out = 32'd0;
        alu_op_out = 4'd0;
        alu_src_imm_out = 1'b0;
        is_load_out = 1'b0;
        is_store_out = 1'b0;
        reg_write_out = 1'b0;
        wb_sel_out = 2'd0;
        is_branch_out = 1'b0;
        branch_imm_out = 32'd0;

        case (if_instr[6:0])
            7'b0010011: begin // OP-IMM
                imm_out = {{20{if_instr[31]}}, if_instr[31:20]};
                alu_src_imm_out = 1'b1;
                reg_write_out = 1'b1;
                wb_sel_out = 2'd0;
                case (if_instr[14:12])
                    3'b000: alu_op_out = 4'd0; // ADDI
                    3'b111: alu_op_out = 4'd1; // ANDI
                    3'b110: alu_op_out = 4'd2; // ORI
                    3'b100: alu_op_out = 4'd3; // XORI
                    3'b001: alu_op_out = 4'd4; // SLLI
                    3'b101: alu_op_out = 4'd5; // SRLI/SRAI
                    default: alu_op_out = 4'd0;
                endcase
            end

            7'b0110011: begin // R-type
                alu_src_imm_out = 1'b0;
                reg_write_out = 1'b1;
                wb_sel_out = 2'd0;
                if (if_instr[31:25] == 7'b0000001) begin
                    alu_op_out = 4'd10; // MUL (custom)
                end else begin
                    case (if_instr[14:12])
                        3'b000: begin
                            if (if_instr[31:25] == 7'b0100000) alu_op_out = 4'd6; // SUB
                            else alu_op_out = 4'd0; // ADD
                        end
                        3'b111: alu_op_out = 4'd1; // AND
                        3'b110: alu_op_out = 4'd2; // OR
                        3'b100: alu_op_out = 4'd3; // XOR
                        3'b001: alu_op_out = 4'd4; // SLL
                        3'b101: alu_op_out = 4'd5; // SRL/SRA
                        default: alu_op_out = 4'd0;
                    endcase
                end
            end

            7'b0000011: begin // LW
                imm_out = {{20{if_instr[31]}}, if_instr[31:20]};
                is_load_out = 1'b1;
                alu_src_imm_out = 1'b1;
                reg_write_out = 1'b1;
                wb_sel_out = 2'd1; // MEM
                alu_op_out = 4'd0; // ADD for address
            end

            7'b0100011: begin // SW
                imm_out = {{20{if_instr[31]}}, if_instr[31:25], if_instr[11:7]};
                is_store_out = 1'b1;
                alu_src_imm_out = 1'b1;
                alu_op_out = 4'd0;
            end

            7'b1100011: begin // BRANCH (BEQ/BNE/BLT/BGE)
                branch_imm_out = {{19{if_instr[31]}}, if_instr[31], if_instr[7], if_instr[30:25], if_instr[11:8], 1'b0};
                is_branch_out = 1'b1;
                alu_op_out = 4'd7; // comparator
            end

            7'b1101111: begin // JAL
                imm_out = {{11{if_instr[31]}}, if_instr[31], if_instr[19:12], if_instr[20], if_instr[30:21], 1'b0};
                reg_write_out = 1'b1;
                wb_sel_out = 2'd0;
            end

            default: begin
                // NOP or unsupported
            end
        endcase
    end

endmodule
