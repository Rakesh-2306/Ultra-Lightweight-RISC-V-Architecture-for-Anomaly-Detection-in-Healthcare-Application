`timescale 1ns/1ps
module riscv_3stage (
    input         clk,
    input         resetn,      // active-low
    // IMEM interface (simple synchronous ROM read)
    output [31:0] imem_addr,
    input  [31:0] imem_rdata,
    // DMEM interface (simple sync memory)
    output        dmem_en,
    output        dmem_we,
    output [31:0] dmem_addr,
    output [31:0] dmem_wdata,
    input  [31:0] dmem_rdata
);

    // integer for loops (module scope to avoid latch inference)
    integer i;

    // ----------------
    // Program counter
    // ----------------
    reg [31:0] pc;
    wire [31:0] pc_plus4 = pc + 32'd4;
    assign imem_addr = pc;

    // ----------------
    // IF/ID pipeline register
    // ----------------
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;
    reg        if_id_valid;

    // ----------------
    // ID signals
    // ----------------
    wire [6:0]  id_opcode  = if_id_instr[6:0];
    wire [4:0]  id_rd      = if_id_instr[11:7];
    wire [2:0]  id_funct3  = if_id_instr[14:12];
    wire [4:0]  id_rs1     = if_id_instr[19:15];
    wire [4:0]  id_rs2     = if_id_instr[24:20];
    wire [6:0]  id_funct7  = if_id_instr[31:25];

    // immediate generator (ID)
    reg [31:0] imm_id;

    // Register file (32 x 32)
    reg [31:0] regs [0:31];

    // read ports
    wire [31:0] rs1_data_id = (id_rs1==0) ? 32'd0 : regs[id_rs1];
    wire [31:0] rs2_data_id = (id_rs2==0) ? 32'd0 : regs[id_rs2];

    // control signals from ID
    reg id_is_load, id_is_store, id_alu_src_imm, id_reg_write;
    reg [3:0] id_alu_op; // custom small-alucode
    reg [1:0] id_wb_sel; // 0=ALU,1=MEM

    // ----------------
    // ID/EX pipeline registers
    // ----------------
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_rs1;
    reg [31:0] id_ex_rs2;
    reg [31:0] id_ex_imm;
    reg [4:0]  id_ex_rd;
    reg        id_ex_is_load;
    reg        id_ex_is_store;
    reg        id_ex_alu_src_imm;
    reg [3:0]  id_ex_alu_op;
    reg        id_ex_reg_write;
    reg [1:0]  id_ex_wb_sel;
    reg        id_ex_valid;

    // ----------------
    // EX outputs
    // ----------------
    reg [31:0] ex_alu_result;
    reg [31:0] ex_mem_rdata;
    reg        ex_dmem_en;
    reg        ex_dmem_we;
    reg [31:0] ex_dmem_addr;
    reg [31:0] ex_dmem_wdata;
    reg [4:0]  ex_wb_rd;
    reg        ex_wb_reg_write;
    reg [1:0]  ex_wb_sel;

    // wire outputs to top
    assign dmem_en    = ex_dmem_en;
    assign dmem_we    = ex_dmem_we;
    assign dmem_addr  = ex_dmem_addr;
    assign dmem_wdata = ex_dmem_wdata;

    // ----------------
    // Hazard detection (load-use)
    // If previous instr is load and its rd matches current rs1/rs2 -> stall 1 cycle
    // ----------------
    reg stall;
    always @(*) begin
        if (id_ex_valid && id_ex_is_load && (id_ex_rd != 0) &&
           ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2)) && if_id_valid) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end

    // ----------------
    // ID: immediate generation and control decoding (combinational)
    // ----------------
    always @(*) begin
        // default
        imm_id = 32'd0;
        id_is_load = 1'b0;
        id_is_store = 1'b0;
        id_alu_src_imm = 1'b0;
        id_reg_write = 1'b0;
        id_alu_op = 4'd0;
        id_wb_sel = 2'd0;

        case (id_opcode)
            7'b0010011: begin // OP-IMM (ADDI, ANDI, ORI, ...)
                imm_id = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
                id_alu_src_imm = 1'b1;
                id_reg_write = 1'b1;
                id_wb_sel = 2'd0;
                case (id_funct3)
                    3'b000: id_alu_op = 4'd0; // ADDI
                    3'b111: id_alu_op = 4'd1; // ANDI
                    3'b110: id_alu_op = 4'd2; // ORI
                    3'b100: id_alu_op = 4'd3; // XORI
                    3'b001: id_alu_op = 4'd4; // SLLI
                    3'b101: id_alu_op = 4'd5; // SRLI/SRAI
                    default: id_alu_op = 4'd0;
                endcase
            end
            7'b0110011: begin // OP (R-type: ADD,SUB,AND,OR,XOR,MUL)
                id_alu_src_imm = 1'b0;
                id_reg_write = 1'b1;
                id_wb_sel = 2'd0;
                if (id_funct7 == 7'b0000001) begin
                    id_alu_op = 4'd10; // MUL
                end else begin
                    case (id_funct3)
                        3'b000: begin
                            if (id_funct7 == 7'b0100000) id_alu_op = 4'd6; // SUB
                            else id_alu_op = 4'd0; // ADD
                        end
                        3'b111: id_alu_op = 4'd1; // AND
                        3'b110: id_alu_op = 4'd2; // OR
                        3'b100: id_alu_op = 4'd3; // XOR
                        3'b001: id_alu_op = 4'd4; // SLL
                        3'b101: id_alu_op = 4'd5; // SRL/SRA
                        default: id_alu_op = 4'd0;
                    endcase
                end
            end
            7'b0000011: begin // LOAD (LW)
                imm_id = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
                id_is_load = 1'b1;
                id_alu_src_imm = 1'b1; // address = rs1 + imm
                id_reg_write = 1'b1;
                id_wb_sel = 2'd1; // MEM
                id_alu_op = 4'd0; // ADD for address calc
            end
            7'b0100011: begin // STORE (SW)
                imm_id = {{20{if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
                id_is_store = 1'b1;
                id_alu_src_imm = 1'b1;
                id_alu_op = 4'd0;
            end
            7'b1100011: begin // BRANCH (BEQ)
                imm_id = {{19{if_id_instr[31]}}, if_id_instr[31], if_id_instr[7], if_id_instr[30:25], if_id_instr[11:8], 1'b0};
                // We indicate branch by a special alucode (7) so EX can evaluate
                id_alu_op = 4'd7; // compare (used for BEQ)
            end
            7'b1101111: begin // JAL
                imm_id = {{11{if_id_instr[31]}}, if_id_instr[31], if_id_instr[19:12], if_id_instr[20], if_id_instr[30:21], 1'b0};
                id_reg_write = 1'b1;
                id_wb_sel = 2'd0;
                // We implement JAL by using ALU add and writing pc+4 to rd in EX stage if desired
            end
            default: begin
                // NOP or unsupported
            end
        endcase
    end

    // ----------------
    // EX stage: ALU ops, memory, branch decision and writeback data select
    // Combined into a single always block to avoid multiple drivers for branch signals
    // ----------------
    reg [31:0] alu_in1, alu_in2;
    reg [31:0] alu_res;
    reg alu_take_branch;
    reg [31:0] branch_target;

    always @(*) begin
        // defaults
        alu_in1 = id_ex_rs1;
        alu_in2 = id_ex_alu_src_imm ? id_ex_imm : id_ex_rs2;
        alu_res = 32'd0;
        alu_take_branch = 1'b0;
        branch_target = 32'd0;

        case (id_ex_alu_op)
            4'd0: alu_res = alu_in1 + alu_in2; // ADD / ADDI / address calc
            4'd1: alu_res = alu_in1 & alu_in2; // AND
            4'd2: alu_res = alu_in1 | alu_in2; // OR
            4'd3: alu_res = alu_in1 ^ alu_in2; // XOR
            4'd4: alu_res = alu_in1 << (alu_in2[4:0]); // SLL
            4'd5: alu_res = alu_in1 >> (alu_in2[4:0]); // SRL (logical)
            4'd6: alu_res = alu_in1 - alu_in2; // SUB
            4'd7: begin // BEQ comparator -- assume BEQ for this demo
                alu_res = alu_in1 - alu_in2;
                if (alu_in1 == alu_in2) begin
                    alu_take_branch = 1'b1;
                    branch_target = id_ex_pc + id_ex_imm;
                end else begin
                    alu_take_branch = 1'b0;
                    branch_target = 32'd0;
                end
            end
            4'd10: alu_res = alu_in1 * alu_in2; // MUL (behavioral)
            default: alu_res = 32'd0;
        endcase

        // memory control defaults are set in another combinational block below
    end

    // Drive memory control signals from EX stage (combinational)
    always @(*) begin
        ex_dmem_en    = 1'b0;
        ex_dmem_we    = 1'b0;
        ex_dmem_addr  = 32'd0;
        ex_dmem_wdata = 32'd0;
        ex_wb_rd      = id_ex_rd;
        ex_wb_reg_write = id_ex_reg_write;
        ex_wb_sel     = id_ex_wb_sel;

        if (id_ex_valid) begin
            if (id_ex_is_store) begin
                ex_dmem_en   = 1'b1;
                ex_dmem_we   = 1'b1;
                ex_dmem_addr = alu_res;
                ex_dmem_wdata= id_ex_rs2;
            end
            if (id_ex_is_load) begin
                ex_dmem_en   = 1'b1;
                ex_dmem_we   = 1'b0;
                ex_dmem_addr = alu_res;
            end
        end
    end

    // choose write-back data: ALU result or data memory read
    always @(*) begin
        if (ex_wb_sel == 2'd0) begin
            ex_alu_result = alu_res;
        end else begin
            ex_alu_result = dmem_rdata; // MEM -> WB
        end
    end

    // ----------------
    // Sequential pipeline updates
    // ----------------
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            pc <= 32'd0;
            if_id_pc <= 32'd0;
            if_id_instr <= 32'd0;
            if_id_valid <= 1'b0;
            id_ex_valid <= 1'b0;
            // clear registers
            for (i=0;i<32;i=i+1) regs[i] <= 32'd0;
        end else begin
            // PC update: if branch taken in EX, redirect; else increment unless stalled
            if (alu_take_branch) begin
                pc <= branch_target;
                if_id_valid <= 1'b0; // flush IF/ID
            end else if (!stall) begin
                pc <= pc_plus4;
            end else begin
                pc <= pc;
            end

            // IF -> ID
            if (!stall) begin
                if_id_pc    <= pc;
                if_id_instr <= imem_rdata;
                if_id_valid <= 1'b1;
            end else begin
                // keep IF/ID stable during stall
                if_id_pc    <= if_id_pc;
                if_id_instr <= if_id_instr;
                if_id_valid <= if_id_valid;
            end

            // ID -> EX
            if (stall) begin
                // insert bubble into ID/EX
                id_ex_valid <= 1'b0;
                id_ex_is_load <= 1'b0;
                id_ex_is_store <= 1'b0;
                id_ex_reg_write <= 1'b0;
                id_ex_rd <= 5'd0;
            end else begin
                id_ex_pc      <= if_id_pc;
                id_ex_rs1     <= rs1_data_id;
                id_ex_rs2     <= rs2_data_id;
                id_ex_imm     <= imm_id;
                id_ex_rd      <= id_rd;
                id_ex_is_load <= id_is_load;
                id_ex_is_store<= id_is_store;
                id_ex_alu_src_imm <= id_alu_src_imm;
                id_ex_alu_op  <= id_alu_op;
                id_ex_reg_write <= id_reg_write;
                id_ex_wb_sel  <= id_wb_sel;
                id_ex_valid   <= if_id_valid;
            end

            // EX: perform writeback to registers (WB happens here)
            if (ex_wb_reg_write && ex_wb_rd != 5'd0 && id_ex_valid) begin
                regs[ex_wb_rd] <= ex_alu_result;
            end
        end
    end

endmodule
