
module memory_stage(
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] alu_result,
    input wire [31:0] write_data,
    output reg [31:0] read_data_out
);
    // Data Memory
    reg [31:0] data_memory [0:1023];
    
    always @(posedge clk) begin
        if (mem_write) begin
            // Store instruction
            data_memory[alu_result[11:2]] <= write_data;
        end
        
        if (mem_read) begin
            // Load instruction
            read_data_out <= data_memory[alu_result[11:2]];
        end
    end
endmodule
