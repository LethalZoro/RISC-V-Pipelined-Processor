module forwarding_unit (
    input wire ex_mem_reg_write,
    input wire mem_wb_reg_write,
    input wire [4:0] ex_mem_rd,
    input wire [4:0] mem_wb_rd,
    input wire [4:0] id_ex_rs1,
    input wire [4:0] id_ex_rs2,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    // Forwarding Logic
    always @(*) begin
        // Forward A
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b01;  // Forward from EX/MEM stage
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b10;  // Forward from MEM/WB stage
        end else begin
            forward_a = 2'b00;  // No forwarding
        end

        // Forward B
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b01;  // Forward from EX/MEM stage
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b10;  // Forward from MEM/WB stage
        end else begin
            forward_b = 2'b00;  // No forwarding
        end
    end
endmodule