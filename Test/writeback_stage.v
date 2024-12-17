module writeback_stage(
    input wire clk,
    input wire reg_write,
    input wire [1:0] wb_sel,
    input wire [31:0] alu_result,
    input wire [31:0] memory_data,
    output reg [31:0] writeback_data_out
);
    always @(*) begin
        case (wb_sel)
            2'b00: writeback_data_out = alu_result;  // ALU result
            2'b01: writeback_data_out = memory_data; // Memory read data
            default: writeback_data_out = alu_result;
        endcase
    end
endmodule