`timescale 1ns / 1ps

module DATA_MEM (
    input clock,
    input MemRead,  // From Control
    input MemWrite, // From Control
    input [31:0] address, // From ALU Result
    input [31:0] write_data, // From Datapath (ReadData2)
    output [31:0] read_data   // To Datapath (MemtoReg Mux)
);

    // 32-bit addressable memory, 1024 locations
    // This will be inferred as Block RAM (BRAM)
    reg [31:0] memory [0:1023];

    // Read logic:
    // Combinational (asynchronous) read
    // Read if MemRead is high, otherwise output 0
    assign read_data = (MemRead) ? memory[address[11:2]] : 32'h0;
    
    // Write logic:
    // Synchronous write (on clock edge)
    always @(posedge clock)
    begin
        if (MemWrite) begin
            memory[address[11:2]] <= write_data;
        end
    end
    
endmodule