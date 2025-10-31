`timescale 1ns / 1ps

module CONTROL(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7, 
    
    // --- Outputs ---
    output reg regwrite,
    output reg [3:0] alu_control, 
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg [1:0] WriteSrc,  // 00:ALU, 01:Mem, 10:PC+4
    output reg Branch,
    output reg Jump
);

    always @(*)
    begin
        // --- STEP 1: Set default values ---
        regwrite    = 1'b0;
        alu_control = 4'b0010; // ADD
        ALUSrc      = 1'b0;
        MemRead     = 1'b0;
        MemWrite    = 1'b0;
        WriteSrc    = 2'b00; // Default to writing ALU result
        Branch      = 1'b0;
        Jump        = 1'b0;
        
        // --- STEP 2: Decode the opcode ---
        case (opcode)
        
            // R-type: (add, sub, mul, slt, xor, srl, or, and)
            7'b0110011: begin 
                regwrite = 1'b1;
                ALUSrc   = 1'b0; // Use rs2
                WriteSrc = 2'b00; // Write ALU result
                
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_control = 4'b0100; // SUB
                        else if (funct7 == 7'b0000001)
                            alu_control = 4'b0110; // MUL
                        else
                            alu_control = 4'b0010; // ADD
                    end
                    3'b001: alu_control = 4'b0011; // SLL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b100: alu_control = 4'b0111; // XOR
                    3'b101: alu_control = 4'b0101; // SRL
                    3'b110: alu_control = 4'b0001; // OR
                    3'b111: alu_control = 4'b0000; // AND
                    default: alu_control = 4'bxxxx;
                endcase
            end

            // I-type (ALU): (addi, slti, xori, ori, andi, slli, srli)
            7'b0010011: begin 
                regwrite = 1'b1;
                ALUSrc   = 1'b1; // Use Immediate
                WriteSrc = 2'b00; // Write ALU result
                case (funct3)
                    3'b000: alu_control = 4'b0010; // ADDI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b100: alu_control = 4'b0111; // XORI
                    3'b110: alu_control = 4'b0001; // ORI
                    3'b111: alu_control = 4'b0000; // ANDI
                    3'b001: alu_control = 4'b0011; // SLLI
                    3'b101: alu_control = 4'b0101; // SRLI
                    default: alu_control = 4'bxxxx;
                endcase
            end
            
            // I-type (Load): (lw)
            7'b0000011: begin 
                regwrite = 1'b1;
                ALUSrc   = 1'b1;
                alu_control = 4'b0010; // ADD (for address calc)
                MemRead  = 1'b1;
                WriteSrc = 2'b01; // Write data from Memory
            end

            // S-type (Store): (sw)
            7'b0100011: begin 
                ALUSrc   = 1'b1;
                alu_control = 4'b0010; // ADD (for address calc)
                MemWrite = 1'b1;
                // regwrite, MemRead, WriteSrc are 0 (default)
            end
            
            // B-type (Branch): (beq, bne)
            7'b1100011: begin 
                ALUSrc   = 1'b0;
                alu_control = 4'b0100; // SUB (for comparison)
                Branch   = 1'b1;
                // Note: JALR also uses funct3=0, but opcode is different
                // For BEQ/BNE, we need to check funct3
                if (funct3 == 3'b001) // BNE
                    alu_control = 4'b1001; // BNE (New ALU op)
                else // BEQ
                    alu_control = 4'b1010; // BEQ (New ALU op)
            end
            
            // U-type (LUI)
            7'b0110111: begin
                regwrite = 1'b1;
                ALUSrc   = 1'b1;
                alu_control = 4'b1111; // Pass B (Immediate)
                WriteSrc = 2'b00; // Write ALU result
            end

            // J-type (JAL)
            7'b1101111: begin
                regwrite = 1'b1;
                Jump     = 1'b1;
                WriteSrc = 2'b10; // Write PC+4
                // We will use the Branch_target adder for PC + imm
            end
            
            // I-type (JALR)
            7'b1100111: begin
                regwrite = 1'b1;
                Jump     = 1'b1; 
                ALUSrc   = 1'b1;
                alu_control = 4'b0010; // ADD (rs1 + imm)
                WriteSrc = 2'b10; // Write PC+4
            end
            
            default: begin
                // All signals are 0 (default)
            end
        endcase
    end

endmodule