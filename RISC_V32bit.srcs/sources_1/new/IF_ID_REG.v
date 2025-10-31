`timescale 1ns / 1ps

module IF_ID_REG (
    input         clock,
    input         reset,
    input         Stall,
    input         Flush,
    
    // --- Inputs from IF Stage ---
    input  [31:0] inst_in,
    input  [31:0] pc_in,
    input  [31:0] pc_plus_4_in,
    
    // --- Outputs to ID Stage ---
    output reg [31:0] inst_out,
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus_4_out
);

    always @(posedge clock or posedge reset)
    begin
        // ASYNCHRONOUS reset
        if (reset) begin
            inst_out      <= 32'h0; // NOP
            pc_out        <= 32'h0;
            pc_plus_4_out <= 32'h0;
        end
        // SYNCHRONOUS logic (on the clock edge)
        else begin
            if (Flush) begin
                // SYNCHRONOUS flush
                inst_out      <= 32'h0; // NOP
                pc_out        <= 32'h0;
                pc_plus_4_out <= 32'h0;
            end
            else if (!Stall) begin
                // Normal operation
                inst_out      <= inst_in;
                pc_out        <= pc_in;
                pc_plus_4_out <= pc_plus_4_in;
            end
            // else (if Stall=1 and Flush=0), do nothing, holding the value.
        end
    end

endmodule