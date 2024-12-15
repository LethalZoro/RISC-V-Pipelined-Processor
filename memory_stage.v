module memory_stage (
    input wire clk,
    input wire reset,
    input wire [31:0] alu_result,
    input wire [31:0] rs2_data,
    input wire [4:0] rd,
    input wire mem_read,
    input wire mem_write,

    output wire [31:0] data_memory_address,
    output wire [31:0] data_memory_write_data,
    input wire [31:0] data_memory_read_data,
    output wire data_memory_write_enable,
    output reg [31:0] read_data
);
    // Memory Interface Assignments
    assign data_memory_address = alu_result;
    assign data_memory_write_data = rs2_data;
    assign data_memory_write_enable = mem_write;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            read_data <= 32'h0;
        end else begin
            // Memory read operation
            if (mem_read) begin
                read_data <= data_memory_read_data;
            end else begin
                read_data <= alu_result;
            end
        end
    end
endmodule