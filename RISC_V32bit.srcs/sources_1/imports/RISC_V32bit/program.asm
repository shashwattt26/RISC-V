`timescale 1ns / 10ps

module PROCESSOR_tb;

    // --- Testbench signals ---
    reg  clock;
    reg  reset;
    wire [7:0] led;
    wire       zero;
    
    // (The 'sw' input is not used, so we can let it float)

    // --- Instantiate the Device Under Test (DUT) ---
    PROCESSOR dut (
        .clock(clock),
        .reset(reset),
        .led(led),
        .zero(zero)
        // .sw is unconnected
    );

    // 1. Clock Generator
    always begin
        clock = 1'b0; #5; // 5ns low
        clock = 1'b1; #5; // 5ns high (10ns period = 100MHz)
    end

    // 2. Reset and Simulation Control
    initial begin
        // Open a file to dump the waveform (for GTKWave/Vivado)
        $dumpfile("waveform.vcd");
        // Dump all signals from the testbench and the processor
        $dumpvars(0, PROCESSOR_tb);
        
        // --- Start the Test Sequence ---
        reset = 1'b1; // Assert reset
        #20;          // Wait 20ns
        reset = 1'b0; // De-assert reset
        
        // Let the simulation run for 300ns
        // This should be enough for our program
        #300;
        
        // End the simulation
        $finish;
    end
    
    // 3. Monitor (Optional, but very helpful)
    // This will print to the Tcl Console every time the clock ticks
    // We monitor the signals coming out of the *Write-Back Stage*
    // to see what the processor is "committing" to the registers.
    
    // To see these internal signals, we use the full hierarchical path
    // This is a powerful testbench technique.
    $monitor("Time=%0t | PC=%h | Inst=%h | WB Reg=%d | WB Data=%h | LEDs=%h | Zero=%b", 
        $time, 
        dut.if_pc_out,          // Current PC
        dut.id_instruction_code, // Instruction in ID stage
        dut.wb_rd,              // WB destination register
        dut.wb_write_data,      // WB data
        led,                    // LED output (matches WB data)
        zero                    // Zero flag
    );

endmodule