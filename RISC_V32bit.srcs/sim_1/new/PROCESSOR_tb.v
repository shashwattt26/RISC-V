`timescale 1ns / 10ps

module PROCESSOR_tb;

    // --- Testbench signals ---
    reg  clock;
    reg  reset;
    reg  [7:0] sw; // We must declare all inputs as 'reg'
    
    wire [7:0] led;
    wire       zero;
    
    // --- Instantiate the Device Under Test (DUT) ---
    PROCESSOR dut (
        .clock(clock),
        .reset(reset),
        .sw(sw),     // Connect the 'sw' input
        .led(led),
        .zero(zero)
    );

    // 1. Clock Generator
    always begin
        clock = 1'b0; #5; // 5ns low
        clock = 1'b1; #5; // 5ns high (10ns period = 100MHz)
    end

    // 2. Reset, Monitor, and Simulation Control
    initial begin
        // Open a file to dump the waveform
        $dumpfile("processor.vcd");
        // Dump all signals from the testbench and the processor
        $dumpvars(0, PROCESSOR_tb);
        
        // --- SET UP THE MONITOR ---
        // This MUST be inside the initial block.
        $monitor("Time=%0t | PC=%h | Inst(ID)=%h | WB_Reg=%d | WB_Data=%h | LED=%h | Stall=%b | Flush=%b", 
            $time, 
            dut.if_pc_out,          // Current PC in IF Stage
            dut.id_instruction_code,// Instruction in ID Stage
            dut.wb_rd,              // WB destination register
            dut.wb_write_data,      // WB data
            led,                    // LED output
            dut.Stall,              // The Stall signal
            dut.Flush               // The Flush signal
        );
        
        // --- Start the Test Sequence ---
        clock = 1'b0;
        reset = 1'b1; // Assert reset
        sw    = 8'h00;
        #20;           // Wait 20ns (two clock cycles)
        reset = 1'b0;  // De-assert reset
        
        // Let the simulation run for 20000ns
        #20000;
        
        // End the simulation
        $finish;
    end

endmodule