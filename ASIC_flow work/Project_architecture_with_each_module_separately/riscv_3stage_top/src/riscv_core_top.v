`timescale 1ns/1ps
module riscv_core_top (
    input         clk,
    input         resetn,
    // IMEM interface (external ROM)
    output [31:0] imem_addr,
    input  [31:0] imem_rdata,
    // DMEM interface (we instantiate internal syncram, but top exposes ports)
    output        dmem_en,
    output        dmem_we,
    output [31:0] dmem_addr,
    output [31:0] dmem_wdata,
    input  [31:0] dmem_rdata  // if you connect internal mem, this is driven internally
);

    // --------------------------
    // IF/ID pipeline registers
    // --------------------------
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;
    reg        if_id_valid;

    // --------------------------
    // ID/EX pipeline registers
    // --------------------------
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
    reg [2:0]  id_ex_funct3;
    reg [6:0]  id_ex_funct7;

    // PC and imem addr
    reg [31:0] pc;
    wire [31:0] pc_plus4 = pc + 32'd4;
    assign imem_addr = pc;

    // --------------------------
    // Register file instance
    // --------------------------
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    // registered WB signals
    reg        wb_reg_write;
    reg [4:0]  wb_rd;
    reg [31:0] wb_data;

    riscv_regfile u_regfile (
        .clk(clk),
        .resetn(resetn),
        .rs1_addr(if_id_instr[19:15]),
        .rs2_addr(if_id_instr[24:20]),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .we(wb_reg_write),
        .rd_addr(wb_rd),
        .rd_data(wb_data)
    );

    // --------------------------
    // ID module instance
    // --------------------------
    wire [31:0] imm_id;
    wire [3:0]  alu_op_id;
    wire        alu_src_imm_id;
    wire        is_load_id;
    wire        is_store_id;
    wire        reg_write_id;
    wire [1:0]  wb_sel_id;
    wire        is_branch_id;
    wire [31:0] branch_imm_id;

    riscv_id u_id (
        .if_pc(if_id_pc),
        .if_instr(if_id_instr),
        .if_valid(if_id_valid),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_id),
        .alu_op_out(alu_op_id),
        .alu_src_imm_out(alu_src_imm_id),
        .is_load_out(is_load_id),
        .is_store_out(is_store_id),
        .reg_write_out(reg_write_id),
        .wb_sel_out(wb_sel_id),
        .is_branch_out(is_branch_id),
        .branch_imm_out(branch_imm_id)
    );

    // --------------------------
    // EX module instance
    // --------------------------
    wire        ex_dmem_en;
    wire        ex_dmem_we;
    wire [31:0] ex_dmem_addr;
    wire [31:0] ex_dmem_wdata;
    wire [31:0] ex_alu_result;
    wire [4:0]  ex_wb_rd_wire;
    wire        ex_wb_reg_write_wire;
    wire [1:0]  ex_wb_sel_wire;
    wire        branch_taken;
    wire [31:0] branch_target;

    riscv_ex u_ex (
        .id_ex_pc(id_ex_pc),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_imm(id_ex_imm),
        .id_ex_rd(id_ex_rd),
        .id_ex_is_load(id_ex_is_load),
        .id_ex_is_store(id_ex_is_store),
        .id_ex_alu_src_imm(id_ex_alu_src_imm),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_wb_sel(id_ex_wb_sel),
        .id_ex_valid(id_ex_valid),
        .id_ex_funct3(id_ex_funct3),
        .id_ex_funct7(id_ex_funct7),

        .dmem_en(ex_dmem_en),
        .dmem_we(ex_dmem_we),
        .dmem_addr(ex_dmem_addr),
        .dmem_wdata(ex_dmem_wdata),
        .dmem_rdata(dmem_rdata),

        .ex_alu_result(ex_alu_result),
        .ex_wb_rd(ex_wb_rd_wire),
        .ex_wb_reg_write(ex_wb_reg_write_wire),
        .ex_wb_sel(ex_wb_sel_wire),

        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    // --------------------------
    // DMEM instance (local syncram)
    // You can either wire this to external memory or instantiate the module here.
    // Here we expose ports to top (so user may connect an external DMEM), but also
    // declare signals that simply pass-through from EX to top-level outputs so the
    // environment can hook up a memory model (e.g., TB uses its own syncram).
    // --------------------------
    assign dmem_en   = ex_dmem_en;
    assign dmem_we   = ex_dmem_we;
    assign dmem_addr = ex_dmem_addr;
    assign dmem_wdata= ex_dmem_wdata;

    // --------------------------
    // Hazard detection (load-use)
    // --------------------------
    reg stall;
    always @(*) begin
        if (id_ex_valid && id_ex_is_load && (id_ex_rd != 5'd0) &&
           ((id_ex_rd == if_id_instr[19:15]) || (id_ex_rd == if_id_instr[24:20])) && if_id_valid) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end

    // --------------------------
    // Sequential pipeline & WB registration
    // --------------------------
    integer ii;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // reset pipeline
            pc <= 32'd0;
            if_id_pc <= 32'd0;
            if_id_instr <= 32'd0;
            if_id_valid <= 1'b0;

            id_ex_pc <= 32'd0;
            id_ex_rs1 <= 32'd0;
            id_ex_rs2 <= 32'd0;
            id_ex_imm <= 32'd0;
            id_ex_rd <= 5'd0;
            id_ex_is_load <= 1'b0;
            id_ex_is_store <= 1'b0;
            id_ex_alu_src_imm <= 1'b0;
            id_ex_alu_op <= 4'd0;
            id_ex_reg_write <= 1'b0;
            id_ex_wb_sel <= 2'd0;
            id_ex_valid <= 1'b0;
            id_ex_funct3 <= 3'd0;
            id_ex_funct7 <= 7'd0;

            wb_reg_write <= 1'b0;
            wb_rd <= 5'd0;
            wb_data <= 32'd0;
        end else begin
            // PC update: branch or increment (stall holds PC)
            if (branch_taken) begin
                pc <= branch_target;
                if_id_valid <= 1'b0; // flush IF/ID
            end else if (!stall) begin
                pc <= pc_plus4;
            end else begin
                pc <= pc;
            end

            // IF -> ID
            if (!stall) begin
                if_id_pc <= pc;
                if_id_instr <= imem_rdata;
                if_id_valid <= 1'b1;
            end else begin
                if_id_pc <= if_id_pc;
                if_id_instr <= if_id_instr;
                if_id_valid <= if_id_valid;
            end

            // ID -> EX (capture decode outputs & regfile reads)
            if (stall) begin
                id_ex_valid <= 1'b0;
                id_ex_is_load <= 1'b0;
                id_ex_is_store <= 1'b0;
                id_ex_reg_write <= 1'b0;
                id_ex_rd <= 5'd0;
                id_ex_alu_op <= 4'd0;
                id_ex_alu_src_imm <= 1'b0;
                id_ex_wb_sel <= 2'd0;
                id_ex_pc <= 32'd0;
                id_ex_rs1 <= 32'd0;
                id_ex_rs2 <= 32'd0;
                id_ex_imm <= 32'd0;
                id_ex_funct3 <= 3'd0;
                id_ex_funct7 <= 7'd0;
            end else begin
                id_ex_pc <= if_id_pc;
                id_ex_rs1 <= rs1_data;
                id_ex_rs2 <= rs2_data;
                id_ex_imm <= imm_id;
                id_ex_rd <= if_id_instr[11:7];
                id_ex_is_load <= is_load_id;
                id_ex_is_store <= is_store_id;
                id_ex_alu_src_imm <= alu_src_imm_id;
                id_ex_alu_op <= alu_op_id;
                id_ex_reg_write <= reg_write_id;
                id_ex_wb_sel <= wb_sel_id;
                id_ex_valid <= if_id_valid;
                id_ex_funct3 <= if_id_instr[14:12];
                id_ex_funct7 <= if_id_instr[31:25];
            end

            // EX -> WB registration: capture EX outputs for stable regfile write
            // Note: ex_alu_result is combinational based on id_ex_* (captured above)
            wb_reg_write <= ex_wb_reg_write_wire && id_ex_valid;
            wb_rd        <= ex_wb_rd_wire;
            // select mem read vs ALU result for writeback:
            // because DMEM uses combinational read (in our syncram), dmem_rdata is valid here
            if (ex_wb_sel_wire == 2'd1) begin
                wb_data <= dmem_rdata;
            end else begin
                wb_data <= ex_alu_result;
            end
        end
    end

endmodule
