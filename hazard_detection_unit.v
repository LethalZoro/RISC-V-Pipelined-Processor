module hazard_detection_unit (
    input wire id_ex_mem_read,
    input wire [4:0] id_ex_rd,
    input wire [4:0] if_id_rs1,
    input wire [4:0] if_id_rs2,

    output reg stall
);
    // Load-Use Hazard Detection
    always @(*) begin
        // Stall if a load instruction is followed immediately by an instruction 
        // that uses the loaded register
        if (id_ex_mem_read && 
            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end
endmodule