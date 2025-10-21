`timescale 1ns/1ps
module tb_riscv_3stage;
    // parameters / constants
    localparam MEMSIZE = 128;

    // loop index at module scope to avoid latch/loop complaints
    integer i;

    reg clk;
    reg resetn;

    // reduced memory size to MEMSIZE words
    reg [31:0] imem [0:MEMSIZE-1];
    reg [31:0] dmem [0:MEMSIZE-1];

    // wiring
    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;
    wire        dmem_en;
    wire        dmem_we;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    reg  [31:0] dmem_rdata;

    // instantiate DUT
    riscv_3stage dut (
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

    // hook instruction read (word-addressed)
    assign imem_rdata = imem[imem_addr[($clog2(MEMSIZE)-1):2]]; // use appropriate bits for indexing

    // simple dmem model (synchronous read)
    always @(posedge clk) begin
        if (dmem_en) begin
            if (dmem_we) begin
                dmem[dmem_addr[($clog2(MEMSIZE)-1):2]] <= dmem_wdata;
            end
            dmem_rdata <= dmem[dmem_addr[($clog2(MEMSIZE)-1):2]];
        end else begin
            dmem_rdata <= 32'd0;
        end
    end

    // small program (machine code)
    initial begin
        // clear memories (MEMSIZE iterations - compile-time constant)
        for (i=0; i<MEMSIZE; i=i+1) begin
            imem[i] = 32'h00000013; // NOP (ADDI x0,x0,0)
            dmem[i] = 32'd0;
        end

        // Program:
        // addi x1, x0, 5   -> 0x00500093
        // addi x2, x0, 3   -> 0x00300113
        // add  x3, x1, x2  -> 0x002081B3
        // mul  x5, x1, x2  -> 0x002082B3
        // sw   x3, 0(x0)   -> 0x00302023
        // lw   x4, 0(x0)   -> 0x00002103

        imem[0] = 32'h00500093;
        imem[1] = 32'h00300113;
        imem[2] = 32'h002081B3;
        imem[3] = 32'h002082B3;
        imem[4] = 32'h00302023;
        imem[5] = 32'h00002103;
    end

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // waveform dump (for simulators)
    initial begin
        $dumpfile("tb_riscv_3stage.vcd");
        $dumpvars(0, tb_riscv_3stage);
    end

    // reset & run
    initial begin
        resetn = 0;
        #20;
        resetn = 1;
        #1000;
        // print some regs (simulation-only, hierarchical access)
        $display("Reg x1 = %0d", dut.regs[1]);
        $display("Reg x2 = %0d", dut.regs[2]);
        $display("Reg x3 = %0d", dut.regs[3]);
        $display("Reg x4 = %0d", dut.regs[4]);
        $display("Reg x5 = %0d", dut.regs[5]);
        $finish;
    end

endmodule
