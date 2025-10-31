`timescale 1ns / 1ps

module HAZARD_DETECTION_UNIT (
    // --- Inputs from ID/EX Register ---
    input        ex_MemRead,  // Is the instruction in EX a 'lw'?
    input [4:0]  ex_rd,       // What is its destination register?
    
    // --- Inputs from ID Stage ---
    input [4:0]  id_rs1,      // What is rs1 of the *current* instruction?
    input [4:0]  id_rs2,      // What is rs2 of the *current* instruction?
    
    // --- Output Signal ---
    output       Stall        // Stall the IF and ID stages
);

    // Stall if the instruction in EX is a 'lw' (ex_MemRead)
    // AND its destination register (ex_rd) matches
    // either rs1 or rs2 of the instruction in ID.
    // Also, don't stall for x0.
    
    wire load_use_rs1 = ex_MemRead && (ex_rd != 5'b0) && (ex_rd == id_rs1);
    wire load_use_rs2 = ex_MemRead && (ex_rd != 5'b0) && (ex_rd == id_rs2);

    assign Stall = (load_use_rs1 || load_use_rs2);

endmodule