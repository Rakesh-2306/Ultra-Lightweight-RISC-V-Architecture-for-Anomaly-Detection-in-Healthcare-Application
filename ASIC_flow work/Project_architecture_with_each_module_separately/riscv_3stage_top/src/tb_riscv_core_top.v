`timescale 1ns/1ps
// =========================================================
// Testbench for riscv_core_top (3-stage RISC-V pipeline)
// Compatible with Synopsys, ModelSim, and Icarus Verilog
// =========================================================

module tb_riscv_core_top;

    // -------------------------------
    // Parameters
    // -------------------------------
    localparam MEMSIZE = 128;  // 128 words = 512 bytes

    // -------------------------------
    // Signals
    // -------------------------------
    reg clk;
    reg resetn;

    // IMEM
    wire [31:0] imem_addr;
    reg  [31:0] imem [0:MEMSIZE-1];
    wire [31:0] imem_rdata;

    // DMEM
    wire        dmem_en;
    wire        dmem_we;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;

    // -------------------------------
    // Instantiate the DUT
    // -------------------------------
    riscv_core_top dut (
        .clk(clk),
        .resetn(resetn),
        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .dmem_en(dmem_en),
        .dmem_we(dmem_we),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata)
    );

    // -------------------------------
    // Instantiate internal DMEM (synchronous write, combinational read)
    // -------------------------------
    riscv_dmem_syncram #(.AW(7)) dmem_inst (
        .clk(clk),
        .en(dmem_en),
        .we(dmem_we),
        .addr(dmem_addr[8:2]),  // word address
        .wdata(dmem_wdata),
        .rdata(dmem_rdata)
    );

    // -------------------------------
    // Clock generation
    // -------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period = 100MHz
    end

    // -------------------------------
    // IMEM connection (simple ROM)
    // -------------------------------
    assign imem_rdata = imem[imem_addr[8:2]];  // word addressing

    // -------------------------------
    // Program Memory Initialization
    // -------------------------------
    integer i;
    initial begin
        // initialize memory with NOPs
        for (i = 0; i < MEMSIZE; i = i + 1) begin
            imem[i] = 32'h00000013; // ADDI x0,x0,0 -> NOP
        end

        // Simple program for testing basic arithmetic + memory ops
        // Assembly equivalent:
        // addi x1, x0, 5
        // addi x2, x0, 3
        // add  x3, x1, x2
        // mul  x5, x1, x2
        // sw   x3, 0(x0)
        // lw   x4, 0(x0)
        imem[0] = 32'h00500093; // addi x1, x0, 5
        imem[1] = 32'h00300113; // addi x2, x0, 3
        imem[2] = 32'h002081B3; // add x3, x1, x2
        imem[3] = 32'h022082B3; // mul x5, x1, x2 (funct7=0000001)
        imem[4] = 32'h00302023; // sw x3, 0(x0)
        imem[5] = 32'h00002103; // lw x4, 0(x0)
        imem[6] = 32'h00000013; // nop
        imem[7] = 32'h00000013; // nop
    end

    // -------------------------------
    // Reset logic
    // -------------------------------
    initial begin
        resetn = 0;
        #25;
        resetn = 1;
    end

    // -------------------------------
    // Waveform dump
    // -------------------------------
    initial begin
        $dumpfile("riscv_core.vcd");
        $dumpvars(0, tb_riscv_core_top);
    end

    // -------------------------------
    // Simulation control
    // -------------------------------
    initial begin
        #2000;  // Run simulation for 2000ns
        $display("\n---- Register File Check ----");
        $display("x1 (expected 5)  = %0d", tb_riscv_core_top.dut.u_regfile.regs[1]);
        $display("x2 (expected 3)  = %0d", tb_riscv_core_top.dut.u_regfile.regs[2]);
        $display("x3 (expected 8)  = %0d", tb_riscv_core_top.dut.u_regfile.regs[3]);
        $display("x4 (expected 8)  = %0d", tb_riscv_core_top.dut.u_regfile.regs[4]);
        $display("x5 (expected 15) = %0d", tb_riscv_core_top.dut.u_regfile.regs[5]);
        $display("-------------------------------\n");
        $finish;
    end

endmodule
