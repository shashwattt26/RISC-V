`timescale 1ns / 1ps

module ID_EX_REG (
    input         clock,
    input         reset,
    input         Stall,
    input         Flush,
    
    // --- Inputs from ID Stage ---
    input         id_RegWrite,
    input  [3:0]  id_ALUControl,
    input         id_ALUSrc,
    input         id_MemRead,
    input         id_MemWrite,
    input  [1:0]  id_WriteSrc,
    input         id_Branch,
    input         id_Jump,
    input  [31:0] id_pc,
    input  [31:0] id_pc_plus_4,
    input  [31:0] id_ReadData1,
    input  [31:0] id_ReadData2,
    input  [31:0] id_imm,
    input  [4:0]  id_rd,
    input  [4:0]  id_rs1,
    input  [4:0]  id_rs2,
    
    // --- Outputs to EX Stage ---
    output reg    ex_RegWrite,
    output reg [3:0]  ex_ALUControl,
    output reg    ex_ALUSrc,
    output reg    ex_MemRead,
    output reg    ex_MemWrite,
    output reg [1:0]  ex_WriteSrc,
    output reg    ex_Branch,
    output reg    ex_Jump,
    output reg [31:0] ex_pc,
    output reg [31:0] ex_pc_plus_4,
    output reg [31:0] ex_ReadData1,
    output reg [31:0] ex_ReadData2,
    output reg [31:0] ex_imm,
    output reg [4:0]  ex_rd,
    output reg [4:0]  ex_rs1,
    output reg [4:0]  ex_rs2
);

    always @(posedge clock or posedge reset)
    begin
        // ASYNCHRONOUS reset
        if (reset) begin
            ex_RegWrite   <= 1'b0;
            ex_ALUControl <= 4'b0010;
            ex_ALUSrc     <= 1'b0;
            ex_MemRead    <= 1'b0;
            ex_MemWrite   <= 1'b0;
            ex_WriteSrc   <= 2'b00;
            ex_Branch     <= 1'b0;
            ex_Jump       <= 1'b0;
            ex_pc         <= 32'h0;
            ex_pc_plus_4  <= 32'h0;
            ex_ReadData1  <= 32'h0;
            ex_ReadData2  <= 32'h0;
            ex_imm        <= 32'h0;
            ex_rd         <= 5'h0;
            ex_rs1        <= 5'h0;
            ex_rs2        <= 5'h0;
        end
        // SYNCHRONOUS logic (on the clock edge)
        else begin
            if (Stall || Flush) begin
                // SYNCHRONOUS Stall/Flush: Load NOP
                ex_RegWrite   <= 1'b0;
                ex_ALUControl <= 4'b0010;
                ex_ALUSrc     <= 1'b0;
                ex_MemRead    <= 1'b0;
                ex_MemWrite   <= 1'b0;
                ex_WriteSrc   <= 2'b00;
                ex_Branch     <= 1'b0;
                ex_Jump       <= 1'b0;
                ex_pc         <= 32'h0;
                ex_pc_plus_4  <= 32'h0;
                ex_ReadData1  <= 32'h0;
                ex_ReadData2  <= 32'h0;
                ex_imm        <= 32'h0;
                ex_rd         <= 5'h0;
                ex_rs1        <= 5'h0;
                ex_rs2        <= 5'h0;
            end
            else begin // Normal Operation
                // SYNCHRONOUS Load
                ex_RegWrite   <= id_RegWrite;
                ex_ALUControl <= id_ALUControl;
                ex_ALUSrc     <= id_ALUSrc;
                ex_MemRead    <= id_MemRead;
                ex_MemWrite   <= id_MemWrite;
                ex_WriteSrc   <= id_WriteSrc;
                ex_Branch     <= id_Branch;
                ex_Jump       <= id_Jump;
                ex_pc         <= id_pc;
                ex_pc_plus_4  <= id_pc_plus_4;
                ex_ReadData1  <= id_ReadData1;
                ex_ReadData2  <= id_ReadData2;
                ex_imm        <= id_imm;
                ex_rd         <= id_rd;
                ex_rs1        <= id_rs1;
                ex_rs2        <= id_rs2;
            end
        end
    end

endmodule