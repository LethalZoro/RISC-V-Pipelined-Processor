module fetch_stage (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] pc,
    input wire [31:0] instruction,
    
    output reg [31:0] if_id_instruction,
    output reg [31:0] if_id_pc,
    output wire [31:0] instruction_address
);

    assign instruction_address = pc;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_instruction <= 32'h0;
            if_id_pc <= 32'h0;
        end else if (!stall) begin
            if_id_instruction <= instruction;
            if_id_pc <= pc;
        end
    end

endmodule