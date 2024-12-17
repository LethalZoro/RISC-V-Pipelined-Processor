module fetch_stage(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] next_pc,
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);
    // Program memory (initialized from hex file)
    reg [31:0] program_memory [0:1023];
    
    // Program Counter Register
    reg [31:0] pc_reg;
    
    // Program Counter Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 32'h0;
            pc_out <= 32'h0;
        end else if (!stall) begin
            // Simple static branch prediction: always assume not taken
            pc_reg <= next_pc;
            pc_out <= pc_reg + 4;
            
            // Fetch instruction from program memory
            instruction_out <= program_memory[pc_reg[11:2]];
        end
    end
    
    // Initialize program memory from hex file
    initial begin
        // $readmemh("D:/Lab/CAO Lab/RISC-V Pipelined Processor/program.hex", program_memory);
        program_memory[0] = 32'h00000000;
        program_memory[1] = 32'h00500113;
        program_memory[2] = 32'h00A00193;
        program_memory[3] = 32'h003100B3;
        program_memory[4] = 32'h00208233;
    end
endmodule