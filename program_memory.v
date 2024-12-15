module program_memory(
    input [31:0] address,
    output [31:0] instruction
);
    reg [31:0] memory [0:255]; // 256 words of 32-bit memory

    assign instruction = memory[address[31:2]];

    // Load instructions from a file
    initial begin
        $readmemh("program.", memory); // Load in hexadecimal format
        // $readmemb("program.mem", memory); // Use for binary format
    end
endmodule