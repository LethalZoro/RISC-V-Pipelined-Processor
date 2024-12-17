
module execute_stage(
    input wire clk,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] instruction,  // Added instruction input
    input wire [2:0] alu_op,
    input wire alu_src,
    input wire [1:0] forward_a,
    input wire [1:0] forward_b,
    input wire [31:0] writeback_data,    // Added writeback_data input
    input wire [31:0] alu_result_mem,    // Added alu_result_mem input
    output reg [31:0] alu_result_out
);
    // Immediate generation
    wire [31:0] immediate;
    
    // Immediate extraction based on instruction type
    assign immediate = (instruction[6:0] == 7'b0010011 || // I-type arithmetic
                        instruction[6:0] == 7'b0000011)   // Load instructions
                       ? {{20{instruction[31]}}, instruction[31:20]} : // Sign-extended 12-bit immediate
                       (instruction[6:0] == 7'b0100011)   // Store instructions
                       ? {{20{instruction[31]}}, instruction[31:25], instruction[11:7]} : // Sign-extended store immediate
                       32'b0;
    
    wire [31:0] forwarded_rs1, forwarded_rs2;
    wire [31:0] alu_operand2;
    
    // Forwarding Multiplexers
    assign forwarded_rs1 = (forward_a == 2'b00) ? rs1_data :
                           (forward_a == 2'b01) ? writeback_data :
                           (forward_a == 2'b10) ? alu_result_mem : rs1_data;
    
    assign forwarded_rs2 = (forward_b == 2'b00) ? rs2_data :
                           (forward_b == 2'b01) ? writeback_data :
                           (forward_b == 2'b10) ? alu_result_mem : rs2_data;
    
    // ALU Operand 2 Selection
    assign alu_operand2 = alu_src ? immediate : forwarded_rs2;
    
    // ALU Operation
    always @(*) begin
        case (alu_op)
            3'b000: alu_result_out = forwarded_rs1 + alu_operand2;  // ADD
            3'b001: alu_result_out = forwarded_rs1 - alu_operand2;  // SUB
            3'b010: alu_result_out = forwarded_rs1 & alu_operand2;  // AND
            3'b011: alu_result_out = forwarded_rs1 | alu_operand2;  // OR
            default: alu_result_out = 32'b0;
        endcase
    end
endmodule