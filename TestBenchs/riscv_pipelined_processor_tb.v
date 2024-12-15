`timescale 1ns/1ps

module riscv_pipelined_processor_tb;
    // Testbench signals
    reg clk;
    reg reset;

    integer i;

    // Memory signals
    wire [31:0] instruction_address;
    wire [31:0] instruction_data;
    wire [31:0] data_memory_address;
    wire [31:0] data_memory_write_data;
    wire [31:0] data_memory_read_data;
    wire data_memory_write_enable;

    // Instruction Memory Simulation
    reg [31:0] instruction_memory [0:255];
    assign instruction_data = instruction_memory[instruction_address[9:2]];

    // Data Memory Simulation
    reg [31:0] data_memory [0:255];
    assign data_memory_read_data = data_memory[data_memory_address[9:2]];

    // Device Under Test
    riscv_pipelined_processor dut (
        .clk(clk),
        .reset(reset),
        .instruction_address(instruction_address),
        // .instruction_data(instruction_data),
        .data_memory_address(data_memory_address),
        .data_memory_write_data(data_memory_write_data),
        .data_memory_read_data(data_memory_read_data),
        .data_memory_write_enable(data_memory_write_enable)
    );

    // Clock Generation
    always begin
        #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;

        // Initialize memories
        for (i = 0; i < 256; i = i + 1) begin
            instruction_memory[i] = 32'h0;
            data_memory[i] = 32'h0;
        end

        // Test Scenario 1: Simple arithmetic and data movement
        // Example instructions:
        // ADDI x1, x0, 10   # Load 10 into x1
        // ADDI x2, x0, 20   # Load 20 into x2
        // ADD  x3, x1, x2   # x3 = x1 + x2 = 30
        // instruction_memory[0]  = 32'b000000001010_00000_000_00001_0010011; // ADDI x1, x0, 10
        // instruction_memory[1]  = 32'b000000010100_00000_000_00010_0010011; // ADDI x2, x0, 20
        // instruction_memory[2]  = 32'b0000000_00010_00001_000_00011_0110011; // ADD x3, x1, x2

        // Test Scenario 2: Memory operations
        // SW x1, 100(x0)    # Store x1 to memory address 100
        // LW x4, 100(x0)    # Load from memory address 100 to x4
        // instruction_memory[3]  = 32'b0000000_00001_00000_010_01100_0100011; // SW x1, 100(x0)
        // instruction_memory[4]  = 32'b000000001100_00000_010_00100_0000011; // LW x4, 100(x0)

        // Wait for initial reset
        #10 reset = 0;

        // Run simulation for several clock cycles
        #200;

        // Display results (for simulation)
        $display("Test Completed");
        $display("x1 value: %h", dut.decode_stage_inst.registers[1]);
        $display("x2 value: %h", dut.decode_stage_inst.registers[2]);
        $display("x3 value: %h", dut.decode_stage_inst.registers[3]);
        $display("x4 value: %h", dut.decode_stage_inst.registers[4]);



        $readmemh("D:/Lab/CAO Lab/RISC-V Pipelined Processor/program.hex", instruction_memory);



            $display("Memory initialized. First few instructions:");
            for ( i = 0; i < 8; i = i + 1) begin
                $display("Instruction[%0d]: 0x%h", i, instruction_memory[i]);
            end



        // End simulation
        $finish;
    end


endmodule