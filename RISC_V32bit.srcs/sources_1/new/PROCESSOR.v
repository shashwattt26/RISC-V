`timescale 1ns / 1ps

module PROCESSOR( 
    input         clock, 
    input         reset,
    input  [7:0]  sw,
    output [7:0]  led,
    output        zero
);

//======================================================================
// --- WIRE DECLARATIONS (All Stages) ---
//======================================================================

    // --- Pipeline Control Wires ---
    wire        Stall;
    wire        Flush; // The signal to flush IF/ID and ID/EX

    // --- IF Wires ---
    wire [31:0] if_instruction_code, if_pc_out, if_pc_plus_4, if_next_pc;
    wire [31:0] branch_target, jalr_target;
    
    // --- IF/ID Wires ---
    wire [31:0] id_instruction_code, id_pc, id_pc_plus_4;
    wire [4:0]  id_rs1, id_rs2, id_rd;

    // --- ID Wires ---
    wire [31:0] id_read_data1, id_read_data2, id_imm;
    wire        id_RegWrite, id_ALUSrc, id_MemRead, id_MemWrite, id_Branch, id_Jump;
    wire [3:0]  id_ALUControl;
    wire [1:0]  id_WriteSrc;
    
    // --- ID/EX Wires ---
    wire        ex_RegWrite;
    wire [3:0]  ex_ALUControl;
    wire        ex_ALUSrc;
    wire        ex_MemRead, ex_MemWrite;
    wire [1:0]  ex_WriteSrc;
    wire        ex_Branch, ex_Jump;
    wire [31:0] ex_pc, ex_pc_plus_4, ex_ReadData1, ex_ReadData2, ex_imm;
    wire [4:0]  ex_rs1, ex_rs2, ex_rd;

    // --- EX Wires ---
    wire [1:0]  ForwardA, ForwardB;
    wire [31:0] ex_alu_in1, ex_alu_in2_mux1, ex_alu_in2_final;
    wire [31:0] ex_alu_result;
    
    // --- EX/MEM Wires ---
    wire        mem_RegWrite, mem_MemRead, mem_MemWrite;
    wire [1:0]  mem_WriteSrc;
    wire [31:0] mem_alu_result, mem_read_data2, mem_pc_plus_4;
    wire [4:0]  mem_rd;
    wire        mem_zero_flag;

    // --- MEM Wires ---
    wire [31:0] mem_data_mem_read_data;

    // --- MEM/WB Wires ---
    wire        wb_regwrite;
    wire [1:0]  wb_WriteSrc;
    wire [31:0] wb_alu_result, wb_data_mem_read_data, wb_pc_plus_4, wb_write_data;
    wire [4:0]  wb_rd;

//======================================================================
// STAGE 1: INSTRUCTION FETCH (IF)
//======================================================================
    
    // --- PC Logic ---
    // The branch decision is made in the EX stage.
    wire        Branch_taken = (ex_Branch & zero); // 'zero' is the decision bit
    wire        JALR_taken = (ex_Jump & ex_ALUControl == 4'b0010);
    wire        JAL_taken = (ex_Jump & !JALR_taken);
    
    // The Flush signal is generated if a branch is taken or a jump occurs.
    assign      Flush = Branch_taken | JAL_taken | JALR_taken;
    
    // The Next PC Mux selects the correct PC for the *next* instruction.
    assign      if_next_pc = (JALR_taken) ? jalr_target :
                             (JAL_taken | Branch_taken) ? branch_target :
                             if_pc_plus_4; // Default
    
    assign      if_pc_plus_4 = if_pc_out + 4;
    
    IFU IFU_module(
        .clock(clock), .reset(reset), 
        .Stall(Stall),
        .Next_PC(if_next_pc), 
        .Instruction_Code(if_instruction_code), .PC_out(if_pc_out)
    );

//======================================================================
// IF/ID PIPELINE REGISTER
//======================================================================
    IF_ID_REG if_id_reg_inst (
        .clock(clock), .reset(reset), 
        .Stall(Stall),
        .Flush(Flush), 
        .inst_in(if_instruction_code), .pc_in(if_pc_out),
        .pc_plus_4_in(if_pc_plus_4),
        .inst_out(id_instruction_code), .pc_out(id_pc),
        .pc_plus_4_out(id_pc_plus_4)
    );

//======================================================================
// STAGE 2: INSTRUCTION DECODE (ID)
//======================================================================
    // --- Instruction Decoding ---
    assign id_rs1 = id_instruction_code[19:15];
    assign id_rs2 = id_instruction_code[24:20];
    assign id_rd  = id_instruction_code[11:7];

    // --- Control Unit ---
    CONTROL control_module(
        .opcode(id_instruction_code[6:0]), .funct3(id_instruction_code[14:12]),
        .funct7(id_instruction_code[31:25]), .regwrite(id_RegWrite),
        .alu_control(id_ALUControl), .ALUSrc(id_ALUSrc),
        .MemRead(id_MemRead), .MemWrite(id_MemWrite),
        .WriteSrc(id_WriteSrc), .Branch(id_Branch), .Jump(id_Jump)
    );
    
    // --- Register File Read ---
    REG_FILE reg_file_module(
        .read_reg_num1(id_rs1), .read_reg_num2(id_rs2),
        .write_reg(wb_rd), .write_data(wb_write_data),
        .read_data1(id_read_data1), .read_data2(id_read_data2),
        .regwrite(wb_regwrite), .clock(clock), .reset(reset)
    );

    // --- Immediate Generator ---
    IMM_GEN imm_gen_module (.inst(id_instruction_code), .imm(id_imm));

    // --- Hazard Detection Unit ---
    HAZARD_DETECTION_UNIT hazard_unit (
        .ex_MemRead(ex_MemRead), .ex_rd(ex_rd),
        .id_rs1(id_rs1), .id_rs2(id_rs2),
        .Stall(Stall)
    );

//======================================================================
// ID/EX PIPELINE REGISTER
//======================================================================
    ID_EX_REG id_ex_reg_inst (
        .clock(clock), .reset(reset), 
        .Stall(Stall), 
        .Flush(Flush), 
        
        // Control
        .id_RegWrite(id_RegWrite), .id_ALUControl(id_ALUControl),
        .id_ALUSrc(id_ALUSrc), .id_MemRead(id_MemRead),
        .id_MemWrite(id_MemWrite), .id_WriteSrc(id_WriteSrc),
        .id_Branch(id_Branch), .id_Jump(id_Jump),
        // Data
        .id_pc(id_pc), .id_pc_plus_4(id_pc_plus_4),
        .id_ReadData1(id_read_data1), .id_ReadData2(id_read_data2),
        .id_imm(id_imm), .id_rd(id_rd),
        .id_rs1(id_rs1), .id_rs2(id_rs2),
        
        // Outputs
        .ex_RegWrite(ex_RegWrite), .ex_ALUControl(ex_ALUControl),
        .ex_ALUSrc(ex_ALUSrc), .ex_MemRead(ex_MemRead),
        .ex_MemWrite(ex_MemWrite), .ex_WriteSrc(ex_WriteSrc),
        .ex_Branch(ex_Branch), .ex_Jump(ex_Jump),
        .ex_pc(ex_pc), .ex_pc_plus_4(ex_pc_plus_4),
        .ex_ReadData1(ex_ReadData1), .ex_ReadData2(ex_ReadData2),
        .ex_imm(ex_imm), .ex_rd(ex_rd),
        .ex_rs1(ex_rs1), .ex_rs2(ex_rs2)
    );
    
//======================================================================
// STAGE 3: EXECUTE (EX)
//======================================================================
    // --- ALU Input Muxes (Forwarding) ---
    assign ex_alu_in1 = (ForwardA == 2'b10) ? wb_write_data  : // Forward from MEM/WB
                        (ForwardA == 2'b01) ? mem_alu_result : // Forward from EX/MEM
                        ex_ReadData1;      // No forward
                        
    assign ex_alu_in2_mux1 = (ForwardB == 2'b10) ? wb_write_data  : // Forward from MEM/WB
                             (ForwardB == 2'b01) ? mem_alu_result : // Forward from EX/MEM
                             ex_ReadData2;      // No forward

    // --- ALUSrc Mux ---
    assign ex_alu_in2_final = (ex_ALUSrc) ? ex_imm : ex_alu_in2_mux1;

    // --- Branch/Jump Target Adders ---
    assign branch_target = ex_pc + ex_imm;
    
    // --- ALU ---
    ALU alu_module(
        .in1(ex_alu_in1), .in2(ex_alu_in2_final),
        .alu_control(ex_ALUControl), .alu_result(ex_alu_result),
        .zero_flag(zero) // This 'zero' is our branch decision
    );
    
    // JALR target is calculated by the ALU (rs1 + imm)
    assign jalr_target = ex_alu_result;

//======================================================================
// EX/MEM PIPELINE REGISTER
//======================================================================
    EX_MEM_REG ex_mem_reg_inst (
        .clock(clock), .reset(reset),
        .ex_RegWrite(ex_RegWrite), .ex_MemRead(ex_MemRead),
        .ex_MemWrite(ex_MemWrite), .ex_WriteSrc(ex_WriteSrc),
        .ex_alu_result(ex_alu_result), 
        .ex_read_data2(ex_alu_in2_mux1), // Pass forwarded rs2 data for 'sw'
        .ex_pc_plus_4(ex_pc_plus_4), .ex_rd(ex_rd),
        .ex_zero_flag(zero),
        
        .mem_RegWrite(mem_RegWrite), .mem_MemRead(mem_MemRead),
        .mem_MemWrite(mem_MemWrite), .mem_WriteSrc(mem_WriteSrc),
        .mem_alu_result(mem_alu_result), .mem_read_data2(mem_read_data2),
        .mem_pc_plus_4(mem_pc_plus_4), .mem_rd(mem_rd),
        .mem_zero_flag(mem_zero_flag)
    );

//======================================================================
// STAGE 4: MEMORY (MEM)
//======================================================================
wire [31:0] mem_data_mem_read_data;

    DATA_MEM data_mem_module (
        .clock(clock), .MemRead(mem_MemRead), .MemWrite(mem_MemWrite),
        .address(mem_alu_result), .write_data(mem_read_data2),
        .read_data(mem_data_mem_read_data)
    );

// --- NEW: MEMORY-MAPPED I/O FOR LEDS ---
reg [7:0] led_register;

// Connect the 'led' output port directly to our new register
assign led = led_register; 

// On every clock edge, check if we are writing to the LED address
always @(posedge clock or posedge reset) begin
    if (reset) begin
        led_register <= 8'h00;
    end
    else if (mem_MemWrite && mem_alu_result == 32'h80000000) begin
        // A 'sw' (store word) instruction to 0x80000000
        // will write its data to the LEDs.
        led_register <= mem_read_data2[7:0];
    end
end
// --- END OF NEW LOGIC ---

//======================================================================
// MEM/WB PIPELINE REGISTER
//======================================================================
    MEM_WB_REG mem_wb_reg_inst (
        .clock(clock), .reset(reset),
        .mem_RegWrite(mem_RegWrite), .mem_WriteSrc(mem_WriteSrc),
        .mem_alu_result(mem_alu_result),
        .mem_data_mem_read_data(mem_data_mem_read_data),
        .mem_pc_plus_4(mem_pc_plus_4), .mem_rd(mem_rd),
        
        .wb_RegWrite(wb_regwrite), .wb_WriteSrc(wb_WriteSrc),
        .wb_alu_result(wb_alu_result),
        .wb_data_mem_read_data(wb_data_mem_read_data),
        .wb_pc_plus_4(wb_pc_plus_4), .wb_rd(wb_rd)
    );

//======================================================================
// STAGE 5: WRITE-BACK (WB)
//======================================================================
    // --- Final Write-Back Mux ---
    assign wb_write_data = (wb_WriteSrc == 2'b10) ? wb_pc_plus_4 :
                           (wb_WriteSrc == 2'b01) ? wb_data_mem_read_data :
                           wb_alu_result; // (default 2'b00)

    // --- Output Logic ---
//    assign led = wb_write_data[7:0]; 
    
//======================================================================
// FORWARDING UNIT
//======================================================================
    FORWARDING_UNIT fwd_unit (
        .id_ex_rs1(ex_rs1), .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd), .ex_mem_RegWrite(mem_RegWrite),
        .mem_wb_rd(wb_rd), .mem_wb_RegWrite(wb_regwrite),
        .ForwardA(ForwardA), .ForwardB(ForwardB)
    );

endmodule