module decode_stage (
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    input wire [31:0] pc,
    input reg [31:0] registers [0:31],

    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    output reg [31:0] immediate,
    output reg [4:0] rd,
    output reg [6:0] opcode,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] alu_op,
    output reg alu_src
);

    // Register File
    // reg [31:0] registers [0:31];

    // Instruction Decoding
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all control signals and registers
            rs1_data <= 32'h0;
            rs2_data <= 32'h0;
            immediate <= 32'h0;
            rd <= 5'h0;
            opcode <= 7'h0;
            funct3 <= 3'h0;
            funct7 <= 7'h0;
            reg_write <= 1'b0;
            mem_read <= 1'b0;
            mem_write <= 1'b0;
            alu_op <= 2'b00;
            alu_src <= 1'b0;
        end else begin
            // Extract instruction components
            opcode <= instruction[6:0];
            rd <= instruction[11:7];
            funct3 <= instruction[14:12];
            funct7 <= instruction[31:25];

            // Read register values
            rs1_data <= registers[instruction[19:15]];
            rs2_data <= registers[instruction[24:20]];

            // Immediate generation (simplified)
            case(opcode)
                7'b0010011, 7'b0000011: // I-type
                    immediate <= {{20{instruction[31]}}, instruction[31:20]};
                7'b0100011: // S-type
                    immediate <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                7'b1100011: // B-type
                    immediate <= {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                default: 
                    immediate <= 32'h0;
            endcase

            // Control signal generation
            case(opcode)
                7'b0110011: begin // R-type
                    reg_write <= 1'b1;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    alu_op <= 2'b10;
                    alu_src <= 1'b0;
                end
                7'b0010011: begin // I-type (arithmetic)
                    reg_write <= 1'b1;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    alu_op <= 2'b11;
                    alu_src <= 1'b1;
                end
                7'b0000011: begin // Load
                    reg_write <= 1'b1;
                    mem_read <= 1'b1;
                    mem_write <= 1'b0;
                    alu_op <= 2'b00;
                    alu_src <= 1'b1;
                end
                7'b0100011: begin // Store
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b1;
                    alu_op <= 2'b00;
                    alu_src <= 1'b1;
                end
                7'b1100011: begin // Branch
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    alu_op <= 2'b01;
                    alu_src <= 1'b0;
                end
                default: begin
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    alu_op <= 2'b00;
                    alu_src <= 1'b0;
                end
            endcase
        end
    end

endmodule