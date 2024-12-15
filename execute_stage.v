module execute_stage (
    input wire clk,
    input wire reset,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] immediate,
    input wire [4:0] rd,
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire alu_src,
    input wire [1:0] alu_op,
    input wire [1:0] forward_a,
    input wire [1:0] forward_b,
    input wire [31:0] ex_mem_alu_result,
    input wire [31:0] mem_wb_write_data,

    output reg [31:0] alu_result,
    output reg [31:0] rs2_data_out
);

    // ALU Operation Codes
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;

    // Forwarding Multiplexers
    wire [31:0] forwarded_rs1, forwarded_rs2;
    assign forwarded_rs1 = (forward_a == 2'b00) ? rs1_data :
                           (forward_a == 2'b01) ? ex_mem_alu_result :
                           (forward_a == 2'b10) ? mem_wb_write_data : rs1_data;

    assign forwarded_rs2 = (forward_b == 2'b00) ? rs2_data :
                           (forward_b == 2'b01) ? ex_mem_alu_result :
                           (forward_b == 2'b10) ? mem_wb_write_data : rs2_data;

    // ALU Operation Decoder
    reg [3:0] alu_control;
    always @(*) begin
        case(alu_op)
            2'b00: alu_control = ALU_ADD;  // Memory operations
            2'b01: alu_control = ALU_SUB;  // Branch operations
            2'b10: begin  // R-type operations
                case({funct7, funct3})
                    10'b0000000_000: alu_control = ALU_ADD;
                    10'b0100000_000: alu_control = ALU_SUB;
                    10'b0000000_001: alu_control = ALU_SLL;
                    10'b0000000_010: alu_control = ALU_SLT;
                    10'b0000000_011: alu_control = ALU_SLTU;
                    10'b0000000_100: alu_control = ALU_XOR;
                    10'b0000000_101: alu_control = ALU_SRL;
                    10'b0100000_101: alu_control = ALU_SRA;
                    10'b0000000_110: alu_control = ALU_OR;
                    10'b0000000_111: alu_control = ALU_AND;
                    default: alu_control = ALU_ADD;
                endcase
            end
            2'b11: begin  // I-type operations
                case(funct3)
                    3'b000: alu_control = ALU_ADD;  // ADDI
                    3'b010: alu_control = ALU_SLT;  // SLTI
                    3'b011: alu_control = ALU_SLTU; // SLTIU
                    3'b100: alu_control = ALU_XOR;  // XORI
                    3'b110: alu_control = ALU_OR;   // ORI
                    3'b111: alu_control = ALU_AND;  // ANDI
                    default: alu_control = ALU_ADD;
                endcase
            end
            default: alu_control = ALU_ADD;
        endcase
    end

    // ALU Implementation
    wire [31:0] alu_input2 = alu_src ? immediate : forwarded_rs2;
    
    always @(*) begin
        case(alu_control)
            ALU_ADD:  alu_result = forwarded_rs1 + alu_input2;
            ALU_SUB:  alu_result = forwarded_rs1 - alu_input2;
            ALU_SLL:  alu_result = forwarded_rs1 << alu_input2[4:0];
            ALU_SLT:  alu_result = $signed(forwarded_rs1) < $signed(alu_input2) ? 32'h1 : 32'h0;
            ALU_SLTU: alu_result = forwarded_rs1 < alu_input2 ? 32'h1 : 32'h0;
            ALU_XOR:  alu_result = forwarded_rs1 ^ alu_input2;
            ALU_SRL:  alu_result = forwarded_rs1 >> alu_input2[4:0];
            ALU_SRA:  alu_result = $signed(forwarded_rs1) >>> alu_input2[4:0];
            ALU_OR:   alu_result = forwarded_rs1 | alu_input2;
            ALU_AND:  alu_result = forwarded_rs1 & alu_input2;
            default:  alu_result = 32'h0;
        endcase

        // Store second operand for store instructions
        rs2_data_out = forwarded_rs2;
    end
endmodule