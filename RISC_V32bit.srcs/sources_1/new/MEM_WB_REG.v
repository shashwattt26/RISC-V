`timescale 1ns / 1ps

module MEM_WB_REG (
    input         clock,
    input         reset,
    
    // --- Inputs from MEM Stage ---
    
    // Control Signals (for WB stage)
    input         mem_RegWrite,
    input  [1:0]  mem_WriteSrc,
    
    // Data (for WB stage)
    input  [31:0] mem_alu_result,
    input  [31:0] mem_data_mem_read_data, // Data from DATA_MEM
    input  [31:0] mem_pc_plus_4,
    input  [4:0]  mem_rd,
    
    // --- Outputs to WB Stage ---

    // Control Signals
    output reg    wb_RegWrite,
    output reg [1:0]  wb_WriteSrc,
    
    // Data
    output reg [31:0] wb_alu_result,
    output reg [31:0] wb_data_mem_read_data,
    output reg [31:0] wb_pc_plus_4,
    output reg [4:0]  wb_rd
);

    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            // Flush with NOP
            wb_RegWrite   <= 1'b0;
            wb_WriteSrc   <= 2'b00;
            wb_alu_result <= 32'h0;
            wb_data_mem_read_data <= 32'h0;
            wb_pc_plus_4  <= 32'h0;
            wb_rd         <= 5'h0;
        end
        else begin
            // Pass all signals from MEM to WB
            wb_RegWrite   <= mem_RegWrite;
            wb_WriteSrc   <= mem_WriteSrc;
            wb_alu_result <= mem_alu_result;
            wb_data_mem_read_data <= mem_data_mem_read_data;
            wb_pc_plus_4  <= mem_pc_plus_4;
            wb_rd         <= mem_rd;
        end
    end

endmodule