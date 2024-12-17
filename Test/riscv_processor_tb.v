
module riscv_processor_tb();
    // Testbench signals
    reg clk;
    reg reset;
    
    // Simulation control
    integer cycle_count;
    integer error_count;
    
    integer i;
    // Expected register values (for verification)
    reg [31:0] expected_registers [0:31];
    
    // Instantiate the processor
    riscv_processor dut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test sequence and verification
    initial begin
        // Initialize simulation variables
        clk = 0;
        reset = 1;
        cycle_count = 0;
        error_count = 0;
        
        // Initialize expected register values
        for ( i = 0; i < 32; i = i + 1) begin
            expected_registers[i] = 32'h00000000;
        end
        
        // Preset expected values based on test program
        expected_registers[2] = 32'h00000005;  // x2 should be 5
        expected_registers[3] = 32'h0000000A;  // x3 should be 10
        expected_registers[1] = 32'h0000000F;  // x1 should be 15 (5+10)
        expected_registers[4] = 32'h00000014;  // x4 should be 20 (15+5)
        
        // Reset sequence
        #10 reset = 0;
        
        // Run simulation and verification
        run_test();
    end
    
    // Test execution and verification task
    task run_test();
        begin
            // Wait for some cycles to complete execution
            wait (cycle_count == 10);
            
            // Verify register values
            verify_registers();
            
            // Print test summary
            $display("-----------------------------------");
            $display("Simulation Complete");
            $display("Total Cycles: %0d", cycle_count);
            $display("Errors Detected: %0d", error_count);
            
            // Terminate simulation
            if (error_count == 0)
                $display("TEST PASSED");
            else
                $display("TEST FAILED");
            
            $finish;
        end
    endtask
    
    // Register verification task
    task verify_registers();
        begin
            for ( i = 0; i < 32; i = i + 1) begin
                // Compare actual vs expected for non-zero registers
                if (expected_registers[i] !== 32'h00000000) begin
                    if (dut.decode_stage_inst.registers[i] !== expected_registers[i]) begin
                        $display("ERROR: Register x%0d mismatch", i);
                        $display("  Expected: 0x%h", expected_registers[i]);
                        $display("  Actual:   0x%h", dut.decode_stage_inst.registers[i]);
                        error_count = error_count + 1;
                    end
                end
            end
        end
    endtask
    
    // Cycle counter and debug monitoring
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            
            // Optional: Detailed register monitoring
            $display("Cycle %0d: ", cycle_count);
            $display("  PC: 0x%h", dut.fetch_stage_inst.pc_out);
            $display("  Instruction: 0x%h", dut.fetch_stage_inst.instruction_out);
            $display("  R1: 0x%h, R2: 0x%h, R3: 0x%h, R4: 0x%h", 
                dut.decode_stage_inst.registers[1],
                dut.decode_stage_inst.registers[2],
                dut.decode_stage_inst.registers[3],
                dut.decode_stage_inst.registers[4]
            );
            $display("write back data: 0x%h", dut.writeback_data);
        end
    end
    
    // ModelSim DO script generation
    initial begin
        // Generate DO script for wave analysis
        $display("# ModelSim Wave Script Generation");
        $display("# To use, copy the following commands to a .do file");
        $display("add wave -position insertpoint \\");
        $display("  sim:/riscv_processor_tb/clk \\");
        $display("  sim:/riscv_processor_tb/reset \\");
        $display("  sim:/riscv_processor_tb/dut/fetch_stage_inst/pc_out \\");
        $display("  sim:/riscv_processor_tb/dut/fetch_stage_inst/instruction_out \\");
        $display("  sim:/riscv_processor_tb/dut/decode_stage_inst/registers");
    end
endmodule