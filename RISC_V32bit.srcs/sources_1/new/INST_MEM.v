`timescale 1ns / 1ps

module INST_MEM(
    input [31:0] PC,
    input reset,
    output [31:0] Instruction_Code
);

    // 32-bit word-addressable memory for 1024 instructions
    // (Vivado will infer this as BRAM)
    reg [31:0] Memory [0:1023];

    // Combinational (asynchronous) read
    // We use PC[11:2] for a 10-bit word address
    assign Instruction_Code = Memory[PC[11:2]];
    
    // Initializing memory:
    // This loads the hex file into the memory at the
    // *start of the simulation*.
    initial
    begin
    $readmemh("C:/Users/shash/RISC_V32bit/program.hex", Memory);
    end

endmodule