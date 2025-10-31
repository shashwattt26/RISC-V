`timescale 1ns / 1ps

module REG_FILE(
    input [4:0] read_reg_num1,
    input [4:0] read_reg_num2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2,
    input regwrite,
    input clock,
    input reset
);

    // 32 memory locations each 32 bits wide
    reg [31:0] reg_memory [31:0]; 
    integer i;

    // Combinational (asynchronous) read logic. This is correct.
    assign read_data1 = reg_memory[read_reg_num1];
    assign read_data2 = reg_memory[read_reg_num2];

    // This ONE block handles ALL writes (reset and normal writes).
    // It is synchronous to the main clock.
    always @(posedge clock)
    begin
        if (reset) begin
            // Your initialization loop, now correctly inside a
            // single, synchronous block.
            for (i = 0; i < 32; i = i + 1) begin
                reg_memory[i] <= i; // Initializes r1 to 1, r2 to 2, etc.
            end
            reg_memory[0] <= 32'h0; // Explicitly set x0 to 0
        end
        else if (regwrite) begin
            // RISC-V spec: register x0 is hardwired to 0.
            // We must ignore any attempts to write to it.
            if (write_reg != 5'b00000) begin
                reg_memory[write_reg] <= write_data;
            end
        end
    end

endmodule