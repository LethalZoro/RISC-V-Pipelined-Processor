
module hazard_detection_unit(
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    input wire [4:0] rd_ex,
    input wire [4:0] rd_mem,
    input wire [4:0] rd_wb,
    input wire reg_write_ex,
    input wire reg_write_mem,
    input wire reg_write_wb,
    input wire mem_read_ex,
    output reg stall_out,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    // Forwarding Logic
    always @(*) begin
        // Default: No forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        stall_out = 1'b0;
        
        // EX Hazard Forwarding
        if (reg_write_ex && rd_ex != 0) begin
            if (rd_ex == rs1_id)
                forward_a = 2'b10;
            if (rd_ex == rs2_id)
                forward_b = 2'b10;
        end
        // MEM Hazard Forwarding
        if (reg_write_mem && rd_mem != 0) begin
            if (rd_mem == rs1_id)
                forward_a = 2'b01;
            if (rd_mem == rs2_id)
                forward_b = 2'b01;
        end
        
        // Load-Use Hazard Detection
        if (mem_read_ex && 
            ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall_out = 1'b1;
        end
    end
endmodule