`timescale 1ns/1ps

module riscv_pipelined_processor (
    input wire clk,
    input wire reset,
    
    // Optional external memory interface
    output wire [31:0] instruction_address,
    // input wire [31:0] instruction_data,
    output wire [31:0] data_memory_address,
    output wire [31:0] data_memory_write_data,
    input wire [31:0] data_memory_read_data,
    output wire data_memory_write_enable
);
    // Instruction memory (for simulation purposes, read instructions from a file)
    reg [31:0] instruction_memory [0:1023]; // Example size, adjust as needed

    integer i;

    // initial begin
    //     $readmemh("D:/Lab/CAO Lab/RISC-V Pipelined Processor/program.hex", instruction_memory);



    //         $display("Memory initialized. First few instructions:");
    //         for ( i = 0; i < 8; i = i + 1) begin
    //             $display("Instruction[%0d]: 0x%h", i, instruction_memory[i]);
    //         end


    // end

    assign instruction_data = instruction_memory[instruction_address[11:2]]; // Word-aligned, 4K instruction memory


    reg [31:0] registers [0:31];


    // Pipeline stage registers
    // IF/ID (Instruction Fetch to Instruction Decode)
    wire [31:0] if_id_instruction;
    wire [31:0] if_id_pc;

    // ID/EX (Instruction Decode to Execute)
    wire [31:0] id_ex_rs1_data;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_immediate;
    wire [4:0]  id_ex_rd;
    wire [6:0]  id_ex_opcode;
    wire [2:0]  id_ex_funct3;
    wire [6:0]  id_ex_funct7;
    wire        id_ex_reg_write;
    wire        id_ex_mem_read;
    wire        id_ex_mem_write;
    wire [1:0]  id_ex_alu_op;
    wire        id_ex_alu_src;

    // EX/MEM (Execute to Memory)
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rs2_data;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;

    // MEM/WB (Memory to Writeback)
    wire [31:0] mem_wb_read_data;
    reg [31:0] mem_wb_alu_result;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;

    // Program Counter
    reg [31:0] pc;

    // Forwarding Unit
    wire [1:0] forward_a, forward_b;

    // Hazard Detection Unit
    wire stall;

    // Instantiate pipeline stage modules
    fetch_stage fetch_stage_inst (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc(pc),
        .instruction(instruction_data),
        .if_id_instruction(if_id_instruction),
        .if_id_pc(if_id_pc),
        .instruction_address(instruction_address)
    );

    decode_stage decode_stage_inst (
        .clk(clk),
        .reset(reset),
        .instruction(if_id_instruction),
        .pc(if_id_pc),
        .registers(registers),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .immediate(id_ex_immediate),
        .rd(id_ex_rd),
        .opcode(id_ex_opcode),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .reg_write(id_ex_reg_write),
        .mem_read(id_ex_mem_read),
        .mem_write(id_ex_mem_write),
        .alu_op(id_ex_alu_op),
        .alu_src(id_ex_alu_src)
    );

    execute_stage execute_stage_inst (
        .clk(clk),
        .reset(reset),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .immediate(id_ex_immediate),
        .rd(id_ex_rd),
        .opcode(id_ex_opcode),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .alu_src(id_ex_alu_src),
        .alu_op(id_ex_alu_op),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_data(mem_wb_alu_result),
        .alu_result(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data)
    );

    memory_stage memory_stage_inst (
        .clk(clk),
        .reset(reset),
        .alu_result(ex_mem_alu_result),
        .rs2_data(ex_mem_rs2_data),
        .rd(ex_mem_rd),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .data_memory_address(data_memory_address),
        .data_memory_write_data(data_memory_write_data),
        .data_memory_read_data(data_memory_read_data),
        .data_memory_write_enable(data_memory_write_enable),
        .read_data(mem_wb_read_data)
    );

    writeback_stage writeback_stage_inst (
        .clk(clk),
        .reset(reset),
        .registers(registers),
        .read_data(mem_wb_read_data),
        .alu_result(mem_wb_alu_result),
        .rd(mem_wb_rd),
        .reg_write(mem_wb_reg_write)
    );

    // Forwarding Unit
    forwarding_unit forwarding_unit_inst (
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .id_ex_rs1(id_ex_rd),
        .id_ex_rs2(id_ex_rd),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Hazard Detection Unit
    hazard_detection_unit hazard_detection_inst (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_instruction[19:15]),
        .if_id_rs2(if_id_instruction[24:20]),
        .stall(stall)
    );

    // Static Branch Prediction (always predict taken)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h0;
        end else if (!stall) begin
            // Simple static branch prediction: always predict taken
            if (id_ex_opcode == 7'b1100011) begin  // Branch instructions
                pc <= pc + {{20{id_ex_immediate[11]}}, id_ex_immediate[11:0], 1'b0};
            end else begin
                pc <= pc + 4;
            end
        end
    end

endmodule