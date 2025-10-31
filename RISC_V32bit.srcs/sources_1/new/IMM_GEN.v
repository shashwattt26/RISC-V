
`timescale 1ns / 1ps

// Generates the correct sign-extended immediate based on the instruction
module IMM_GEN (
    input [31:0] inst,
    output reg [31:0] imm
);

    wire [6:0] opcode = inst[6:0];
    
    // Opcode constants
    localparam OPCODE_I_ALU  = 7'b0010011;
    localparam OPCODE_I_LOAD = 7'b0000011;
    localparam OPCODE_I_JALR = 7'b1100111;
    localparam OPCODE_S      = 7'b0100011;
    localparam OPCODE_B      = 7'b1100011;
    localparam OPCODE_U_LUI  = 7'b0110111;
    localparam OPCODE_J      = 7'b1101111;

    always @(*) begin
        case (opcode)
            // I-type (ALU, Load, JALR)
            OPCODE_I_ALU, OPCODE_I_LOAD, OPCODE_I_JALR:
                imm = {{20{inst[31]}}, inst[31:20]};
                
            // S-type (Store)
            OPCODE_S:
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                
            // B-type (Branch)
            OPCODE_B:
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
                
            // U-type (LUI)
            OPCODE_U_LUI:
                imm = {inst[31:12], 12'b0};
                
            // J-type (JAL)
            OPCODE_J:
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
                
            default: // R-type or unknown
                imm = 32'hxxxxxxxx; // Don't care
        endcase
    end

endmodule