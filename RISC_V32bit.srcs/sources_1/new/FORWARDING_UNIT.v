`timescale 1ns / 1ps

module FORWARDING_UNIT (
    // --- Inputs from ID/EX Register ---
    input [4:0]  id_ex_rs1,     // rs1 for current instruction
    input [4:0]  id_ex_rs2,     // rs2 for current instruction
    
    // --- Inputs from EX/MEM Register ---
    input [4:0]  ex_mem_rd,       // Destination reg of previous instruction
    input        ex_mem_RegWrite, // Did previous instruction write?
    
    // --- Inputs from MEM/WB Register ---
    input [4:0]  mem_wb_rd,       // Destination reg of 2nd-to-last instruction
    input        mem_wb_RegWrite, // Did 2nd-to-last instruction write?

    // --- Outputs to Muxes in EX Stage ---
    output [1:0] ForwardA,      // 00:No forward, 01:From EX/MEM, 10:From MEM/WB
    output [1:0] ForwardB       // 00:No forward, 01:From EX/MEM, 10:From MEM/WB
);

    // Logic for Forwarding to ALU input 'A' (from rs1)
    assign ForwardA = (ex_mem_RegWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1)) ? 2'b01 : // EX hazard
                      (mem_wb_RegWrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1)) ? 2'b10 : // MEM hazard
                      2'b00; // No hazard

    // Logic for Forwarding to ALU input 'B' (from rs2)
    assign ForwardB = (ex_mem_RegWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2)) ? 2'b01 : // EX hazard
                      (mem_wb_RegWrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2)) ? 2'b10 : // MEM hazard
                      2'b00; // No hazard

endmodule