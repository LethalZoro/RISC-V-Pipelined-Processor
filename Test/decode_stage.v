
module decode_stage(
    input wire clk,
    input wire reset,
    input wire [31:0] pc_in,
    input wire [31:0] instruction_in,
    input wire [31:0] writeback_data,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [2:0] alu_op_out,
    output reg alu_src_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg [1:0] wb_sel_out
);
    // Register File
    reg [31:0] registers [0:31];
    
    // Instruction Decoding and Control Signals
    wire [6:0] opcode = instruction_in[6:0];
    wire [2:0] funct3 = instruction_in[14:12];
    wire [6:0] funct7 = instruction_in[31:25];
    wire [4:0] rs1 = instruction_in[19:15];
    wire [4:0] rs2 = instruction_in[24:20];
    wire [4:0] rd = instruction_in[11:7];

    integer i;

    // Register Write Back
    always @(posedge clk) begin
        if (reset) begin
            // Initialize registers if needed
            for ( i = 0; i < 32; i = i + 1)
                registers[i] = 32'b0;
        end else if (reg_write_out) begin
            // Write back to register file
            registers[rd] <= writeback_data;
        end
    end
    
    // Instruction Decode and Control Logic
    always @(*) begin
        // Default control signal values
        alu_op_out = 3'b000;
        alu_src_out = 1'b0;
        reg_write_out = 1'b0;
        mem_read_out = 1'b0;
        mem_write_out = 1'b0;
        wb_sel_out = 2'b00;
        
        // Read register values
        rs1_data_out = registers[rs1];
        rs2_data_out = registers[rs2];
        
        // Decode instruction based on opcode
        case (opcode)
            7'b0110011: begin  // R-type (arithmetic)
                reg_write_out = 1'b1;
                case ({funct3, funct7})
                    10'b0000000000: alu_op_out = 3'b000; // ADD
                    10'b0000100000: alu_op_out = 3'b001; // SUB
                    10'b0000000111: alu_op_out = 3'b010; // AND
                    10'b0000000110: alu_op_out = 3'b011; // OR
                    default: alu_op_out = 3'b000;
                endcase
            end
            
            7'b0010011: begin  // I-type (immediate arithmetic)
                reg_write_out = 1'b1;
                alu_src_out = 1'b1;
                case (funct3)
                    3'b000: alu_op_out = 3'b000; // ADDI
                    3'b111: alu_op_out = 3'b010; // ANDI
                    3'b110: alu_op_out = 3'b011; // ORI
                    default: alu_op_out = 3'b000;
                endcase
            end
            
            7'b0000011: begin  // Load instructions
                reg_write_out = 1'b1;
                mem_read_out = 1'b1;
                alu_src_out = 1'b1;
                alu_op_out = 3'b000;
                wb_sel_out = 2'b01;
            end
            
            7'b0100011: begin  // Store instructions
                mem_write_out = 1'b1;
                alu_src_out = 1'b1;
                alu_op_out = 3'b000;
            end
            
            default: begin
                // Default no-op state
                alu_op_out = 3'b000;
            end
        endcase
    end
endmodule