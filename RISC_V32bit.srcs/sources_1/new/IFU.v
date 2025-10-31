`timescale 1ns / 1ps

module IFU(
    input         clock,
    input         reset,
    input         Stall,
    input  [31:0] Next_PC,          // NEW: The next PC value from PROCESSOR
    output [31:0] Instruction_Code,
    output [31:0] PC_out             // NEW: The *current* PC
);

    reg [31:0] PC; // Program Counter
    
    // Output the current PC so the datapath can use it
    assign PC_out = PC;

    // Instantiate the instruction memory
    INST_MEM instr_mem(
        .PC(PC), // Use the current PC
        .reset(reset),
        .Instruction_Code(Instruction_Code)
    );
    
    // This block is now just a register.
    // It stores the Next_PC on the clock edge.
    always @(posedge clock or posedge reset)
    begin
        if(reset)
            PC <= 32'h0;
        else if (!Stall) //
            PC <= Next_PC;
        // If Stall is 1, the PC holds its value
    end
endmodule