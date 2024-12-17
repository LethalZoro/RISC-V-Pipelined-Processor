
module riscv_processor(
    input wire clk,
    input wire reset
);
    // Interconnect wires between pipeline stages
    wire [31:0] pc_if, pc_id, pc_mem, pc_wb;
    wire [31:0] instruction_if, instruction_id, instruction_ex, instruction_mem, instruction_wb;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_result_ex, alu_result_mem, alu_result_wb;
    wire [31:0] memory_read_data;
    wire [31:0] writeback_data;
    
    // Control signals
    wire [2:0] alu_op;
    wire alu_src, reg_write, mem_read, mem_write;
    wire [1:0] wb_sel;
    
    // Hazard and forwarding control
    wire [1:0] forward_a, forward_b;
    wire stall;
    
    // Pipeline Stage Registers (to hold values between stages)
    reg [31:0] instruction_ex_reg, instruction_mem_reg, instruction_wb_reg;
    
    wire [31:0] pc_ex               ;
    
    // Program Counter Update
    reg [31:0] pc_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 32'b0;
        end else if (!stall) begin
            pc_reg <= pc_if ;  // Assuming a simple increment for the next PC
        end
    end

    assign pc_ex = pc_reg;



    // Fetch Stage
    fetch_stage fetch_stage_inst (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_pc(pc_ex),  // For branch/jump target
        .pc_out(pc_if),
        .instruction_out(instruction_if)
    );
    
    // Instruction Decode Stage
    decode_stage decode_stage_inst (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_if),
        .instruction_in(instruction_if),
        .writeback_data(writeback_data),
        .rs1_data_out(rs1_data),
        .rs2_data_out(rs2_data),
        .alu_op_out(alu_op),
        .alu_src_out(alu_src),
        .reg_write_out(reg_write),
        .mem_read_out(mem_read),
        .mem_write_out(mem_write),
        .wb_sel_out(wb_sel)
    );
    
    // Execute Stage
    execute_stage execute_stage_inst (
        .clk(clk),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .instruction(instruction_id),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .writeback_data(writeback_data),
        .alu_result_mem(alu_result_mem),
        .alu_result_out(alu_result_ex)
    );
    
    // Memory Stage
    memory_stage memory_stage_inst (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_result(alu_result_ex),
        .write_data(rs2_data),
        .read_data_out(memory_read_data)
    );
    
    // Writeback Stage
    writeback_stage writeback_stage_inst (
        .clk(clk),
        .reg_write(reg_write),
        .wb_sel(wb_sel),
        .alu_result(alu_result_mem),
        .memory_data(memory_read_data),
        .writeback_data_out(writeback_data)
    );
    
    // Hazard Detection Unit
    hazard_detection_unit hazard_unit (
        .rs1_id(instruction_id[19:15]),
        .rs2_id(instruction_id[24:20]),
        .rd_ex(instruction_ex[11:7]),
        .rd_mem(instruction_mem[11:7]),
        .rd_wb(instruction_wb[11:7]),
        .reg_write_ex(reg_write_ex),
        .reg_write_mem(reg_write_mem),
        .reg_write_wb(reg_write_wb),
        .mem_read_ex(mem_read_ex),
        .stall_out(stall),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    
    // Pipeline Stage Register Management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_ex_reg <= 32'b0;
            instruction_mem_reg <= 32'b0;
            instruction_wb_reg <= 32'b0;
        end else if (!stall) begin
            instruction_ex_reg <= instruction_id;
            instruction_mem_reg <= instruction_ex_reg;
            instruction_wb_reg <= instruction_mem_reg;
        end
    end
    
    // Assign instruction signals for hazard detection
    assign instruction_ex = instruction_ex_reg;
    assign instruction_mem = instruction_mem_reg;
    assign instruction_wb = instruction_wb_reg;
endmodule