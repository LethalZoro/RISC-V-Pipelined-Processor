module tb();

    reg clk=0, rst;
    reg cycle_count = 0;
    always begin
        clk = ~clk;
        #50;
    end

    Pipeline_top dut (.clk(clk), .rst(rst));

    initial begin
        rst <= 1'b0;
        #200;
        rst <= 1'b1;
        #1000;
        $finish;    
    end

always @(posedge clk) begin
        if (rst) begin
            cycle_count = cycle_count + 1;
            
            // Optional: Detailed register monitoring
            $display("Cycle %0d: ", cycle_count);
            $display("  Instruction: 0x%h", dut.Fetch.IMEM.RD);
            $display("  R1: 0x%h, R2: 0x%h, R3: 0x%h, R4: 0x%h", 
                dut.Decode.rf.Register[5],
                dut.Decode.rf.Register[6],
                dut.Decode.rf.Register[7],
                dut.Decode.rf.Register[0]
            );
        end
    end


    // initial begin
    //     $dumpfile("dump.vcd");
    //     $dumpvars(0);
    // end

    
endmodule