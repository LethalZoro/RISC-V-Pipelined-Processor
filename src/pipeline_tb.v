module tb();

    reg clk=0, rst;
    reg [31:0] cycle_count ;
    always begin
        clk = ~clk;
        #50;
    end

    Pipeline_top dut (.clk(clk), .rst(rst));

    initial begin
        rst <= 1'b0;
        cycle_count=0;
        #200;
        rst <= 1'b1;
        #5000;
        $finish;    
    end

always @(posedge clk) begin
        if (rst) begin
            cycle_count = cycle_count + 1;
            
            // Optional: Detailed register monitoring
            $display("Cycle %0d: ", cycle_count);
            $display("  Instruction: 0x%h", dut.Fetch.IMEM.RD);
            $display("  R5: 0x%h, R6: 0x%h, R7: 0x%h, R4: 0x%h", 
                dut.Decode.rf.Register[1],
                dut.Decode.rf.Register[2],
                dut.Decode.rf.Register[3],
                dut.Decode.rf.Register[0]
            );
            // $display("the imm is %h", dut.Decode.extension.Imm_Ext);
        end
    end


    // initial begin
    //     $dumpfile("dump.vcd");
    //     $dumpvars(0);
    // end

    
endmodule