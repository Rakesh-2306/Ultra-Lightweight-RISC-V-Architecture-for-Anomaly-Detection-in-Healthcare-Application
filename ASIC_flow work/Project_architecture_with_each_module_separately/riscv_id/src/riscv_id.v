`timescale 1ns/1ps
// riscv_id.v - decoder + immediate generator (combinational)
module riscv_id (
    input  [31:0] if_pc,
    input  [31:0] if_instr,
    input         if_valid,
    input  [31:0] rs1_data,
    input  [31:0] rs2_data,
    output [31:0] imm_out,
    output [4:0]  rd_out,
    output [31:0] rs1_out,
    output [31:0] rs2_out,
    output [3:0]  alu_op_out,
    output        alu_src_imm_out,
    output        is_load_out,
    output        is_store_out,
    output        reg_write_out,
    output [1:0]  wb_sel_out,
    output        is_branch_out,
    output [31:0] branch_imm_out
);
    wire [6:0] opcode = if_instr[6:0];
    wire [2:0] funct3 = if_instr[14:12];
    wire [6:0] funct7 = if_instr[31:25];

    reg [31:0] imm;
    reg [3:0]  alu_op;
    reg        alu_src_imm;
    reg        is_load;
    reg        is_store;
    reg        reg_write;
    reg [1:0]  wb_sel;
    reg        is_branch;
    reg [31:0] branch_imm;

    always @(*) begin
        imm = 32'd0;
        alu_op = 4'd0;
        alu_src_imm = 1'b0;
        is_load = 1'b0;
        is_store = 1'b0;
        reg_write = 1'b0;
        wb_sel = 2'd0;
        is_branch = 1'b0;
        branch_imm = 32'd0;
        case (opcode)
            7'b0010011: begin // OP-IMM
                imm = {{20{if_instr[31]}}, if_instr[31:20]};
                alu_src_imm = 1'b1;
                reg_write = 1'b1;
                wb_sel = 2'd0;
                case (funct3)
                    3'b000: alu_op = 4'd0; // ADDI
                    3'b111: alu_op = 4'd1; // ANDI
                    3'b110: alu_op = 4'd2; // ORI
                    3'b100: alu_op = 4'd3; // XORI
                    3'b001: alu_op = 4'd4; // SLLI
                    3'b101: alu_op = 4'd5; // SRLI/SRAI
                    default: alu_op = 4'd0;
                endcase
            end
            7'b0110011: begin // R-type
                alu_src_imm = 1'b0;
                reg_write = 1'b1;
                wb_sel = 2'd0;
                if (funct7 == 7'b0000001) alu_op = 4'd10; // MUL
                else begin
                    case (funct3)
                        3'b000: alu_op = (funct7==7'b0100000) ? 4'd6 : 4'd0; // SUB/ADD
                        3'b111: alu_op = 4'd1; // AND
                        3'b110: alu_op = 4'd2; // OR
                        3'b100: alu_op = 4'd3; // XOR
                        3'b001: alu_op = 4'd4; // SLL
                        3'b101: alu_op = 4'd5; // SRL/SRA
                        default: alu_op = 4'd0;
                    endcase
                end
            end
            7'b0000011: begin // LW
                imm = {{20{if_instr[31]}}, if_instr[31:20]};
                is_load = 1'b1;
                alu_src_imm = 1'b1;
                reg_write = 1'b1;
                wb_sel = 2'd1;
                alu_op = 4'd0;
            end
            7'b0100011: begin // SW
                imm = {{20{if_instr[31]}}, if_instr[31:25], if_instr[11:7]};
                is_store = 1'b1;
                alu_src_imm = 1'b1;
                alu_op = 4'd0;
            end
            7'b1100011: begin // Branch family
                branch_imm = {{19{if_instr[31]}}, if_instr[31], if_instr[7], if_instr[30:25], if_instr[11:8], 1'b0};
                is_branch = 1'b1;
                alu_op = 4'd7; // comparator code (EX uses funct3 to choose type)
            end
            7'b1101111: begin // JAL
                imm = {{11{if_instr[31]}}, if_instr[31], if_instr[19:12], if_instr[20], if_instr[30:21], 1'b0};
                reg_write = 1'b1;
                wb_sel = 2'd0;
            end
            7'b1100111: begin // JALR
                imm = {{20{if_instr[31]}}, if_instr[31:20]};
                reg_write = 1'b1;
                wb_sel = 2'd0;
            end
            default: begin
                // NOP
            end
        endcase
    end

    assign imm_out = imm;
    assign rd_out = if_instr[11:7];
    assign rs1_out = rs1_data;
    assign rs2_out = rs2_data;
    assign alu_op_out = alu_op;
    assign alu_src_imm_out = alu_src_imm;
    assign is_load_out = is_load;
    assign is_store_out = is_store;
    assign reg_write_out = reg_write;
    assign wb_sel_out = wb_sel;
    assign is_branch_out = is_branch;
    assign branch_imm_out = branch_imm;
endmodule
