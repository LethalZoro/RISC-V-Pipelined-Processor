module writeback_stage (
    input wire clk,
    input wire reset,
    input reg [31:0] registers [0:31];
    input wire [31:0] read_data,
    input wire [31:0] alu_result,
    input wire [4:0] rd,
    input wire reg_write
);
    // Register File (could be shared with decode stage)
    // reg [31:0] registers [0:31];
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset registers if needed
            for ( i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end else begin
            // Writeback logic
            if (reg_write) begin
                // Write back either memory read data or ALU result
                registers[rd] <= (reg_write) ? (rd != 5'b0 ? read_data : alu_result) : registers[rd];
            end
        end
    end
endmodule