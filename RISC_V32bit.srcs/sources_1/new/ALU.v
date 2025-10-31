`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2025 18:24:38
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
ALU module, which takes two operands of size 32-bits each and a 4-bit ALU_control as input.
Operation is performed on the basis of ALU_control value and output is 32-bit ALU_result. 
If the ALU_result is zero, a ZERO FLAG is set.
*/

/*
ALU Control lines | Function
-----------------------------
        0000    Bitwise-AND
        0001    Bitwise-OR
        0010	Add (A+B)
        0100	Subtract (A-B)
        1000	Set on less than
        0011    Shift left logical
        0101    Shift right logical
        0110    Multiply
        0111    Bitwise-XOR
*/

module ALU (
    input [31:0] in1,in2, 
    input[3:0] alu_control,
    output reg [31:0] alu_result,
    output reg zero_flag
);
always @(*)
    begin
        alu_result = 32'hxxxxxxxx; // Default
        zero_flag = 1'b0;          // Default

        case(alu_control)
            4'b0000: alu_result = in1 & in2;
            4'b0001: alu_result = in1 | in2;
            4'b0010: alu_result = in1 + in2;
            4'b0100: alu_result = in1 - in2;
            4'b1000: alu_result = (in1 < in2) ? 32'd1 : 32'd0; // SLT
            4'b0011: alu_result = in1 << in2;
            4'b0101: alu_result = in1 >> in2;
            4'b0110: alu_result = in1 * in2;
            4'b0111: alu_result = in1 ^ in2;
            
            // --- NEW OPERATIONS ---
            4'b1001: alu_result = (in1 != in2) ? 32'd1 : 32'd0; // BNE
            4'b1010: alu_result = (in1 == in2) ? 32'd1 : 32'd0; // BEQ
            4'b1111: alu_result = in2; // Pass B (for LUI)
            
            default: alu_result = 32'hxxxxxxxx; 
        endcase

        // **IMPORTANT: Fix Zero Flag Logic**
        // The 'zero' flag for branches is based on the *ALU result*,
        // but for BEQ/BNE, the result *is* the flag.
        if (alu_control == 4'b1010) // BEQ
            zero_flag = alu_result[0];
        else if (alu_control == 4'b1001) // BNE
            zero_flag = alu_result[0];
        else // For all other instructions
            zero_flag = (alu_result == 32'h0);
    end
endmodule