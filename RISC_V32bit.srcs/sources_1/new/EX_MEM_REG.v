`timescale 1ns / 1ps

module EX_MEM_REG (
    input         clock,
    input         reset,
    
    // --- Inputs from EX Stage ---
    
    // Control Signals (to be used in MEM/WB)
    input         ex_RegWrite,
    input         ex_MemRead,
    input         ex_MemWrite,
    input  [1:0]  ex_WriteSrc,
    
    // Data
    input  [31:0] ex_alu_result,
    input  [31:0] ex_read_data2, // For 'sw' instruction
    input  [31:0] ex_pc_plus_4,  // For JAL/JALR writeback
    input  [4:0]  ex_rd,         // Destination register
    
    // Flags
    input         ex_zero_flag,
    
    // --- Outputs to MEM Stage ---
    
    // Control Signals
    output reg    mem_RegWrite,
    output reg    mem_MemRead,
    output reg    mem_MemWrite,
    output reg [1:0]  mem_WriteSrc,
    
    // Data
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_read_data2,
    output reg [31:0] mem_pc_plus_4,
    output reg [4:0]  mem_rd,
    
    // Flags
    output reg    mem_zero_flag
);

    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            // Flush with NOP
            mem_RegWrite   <= 1'b0;
            mem_MemRead    <= 1'b0;
            mem_MemWrite   <= 1'b0;
            mem_WriteSrc   <= 2'b00;
            mem_alu_result <= 32'h0;
            mem_read_data2 <= 32'h0;
            mem_pc_plus_4  <= 32'h0;
            mem_rd         <= 5'h0;
            mem_zero_flag  <= 1'b0;
        end
        else begin
            // Pass all signals from EX to MEM
            mem_RegWrite   <= ex_RegWrite;
            mem_MemRead    <= ex_MemRead;
            mem_MemWrite   <= ex_MemWrite;
            mem_WriteSrc   <= ex_WriteSrc;
            mem_alu_result <= ex_alu_result;
            mem_read_data2 <= ex_read_data2;
            mem_pc_plus_4  <= ex_pc_plus_4;
            mem_rd         <= ex_rd;
            mem_zero_flag  <= ex_zero_flag;
        end
    end

endmodule