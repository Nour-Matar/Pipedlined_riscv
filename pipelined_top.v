module pipelined_top (
    input wire clk,
    input wire rst          // active-low, drives PC_reg.areset and register_file.reset
);

    // ---- internal wires ----
    wire [31:0] PC;
    wire [31:0] Instr_IF;
    wire [31:0] RD1, RD2;
    wire [31:0] ImmExt;
    wire [31:0] SrcB;
    wire [31:0] ALUResult;
    wire [31:0] ReadData;
    wire [31:0] Result;

    wire        RegWrite, ALUSrc, MemWrite, ResultSrc, Branch;
    wire [1:0]  ImmSrc, ALUOp;
    wire [2:0]  ALUControl;
    wire        Zero, sign;
    wire        Halt;

    wire [31:0] Instr_reg;
    wire [31:0] PC_ID;

    wire [31:0] PC_EX;
    wire [31:0] RD1_EX;
    wire [31:0] RD2_EX;
    wire [31:0] ImmExt_EX;
    wire [4:0] Rd_EX;
    wire [4:0] Rs1_EX;
    wire [4:0] Rs2_EX;
    wire [2:0] funct3_EX;
    wire ALUSrc_EX;
    wire [2:0] ALUControl_EX;
    wire MemWrite_EX;
    wire RegWrite_EX;
    wire ResultSrc_EX;
    wire Branch_EX;
    wire [31:0] ALUResult_MEM;
    wire [31:0] WriteData_MEM;
    wire [4:0] Rd_MEM;
    wire MemWrite_MEM;
    wire RegWrite_MEM;
    wire ResultSrc_MEM;
    wire [31:0] ALUResult_WB;
    wire [31:0] ReadData_WB;
    wire [4:0] Rd_WB;
    wire RegWrite_WB;
    wire ResultSrc_WB;
    wire PCSrc_EX;
    wire [31:0] BranchTarget_EX;
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] ForwardedA;
    wire [31:0] ForwardedB;
    wire lwStall;

    assign Halt = (Instr_reg == 32'b0);

    // Select ReadData for loads, ALUResult_MEM for ALU instructions
    wire [31:0] Result_MEM = ResultSrc_MEM ? ReadData : ALUResult_MEM;

    // Updated forwarding multiplexers
    assign ForwardedA = (ForwardA == 2'b10) ? Result_MEM :
                        (ForwardA == 2'b01) ? Result :
                        RD1_EX;

    assign ForwardedB = (ForwardB == 2'b10) ? Result_MEM :
                        (ForwardB == 2'b01) ? Result :
                        RD2_EX;

    PC_reg u_PC_reg (
        .clk         (clk),
        .areset      (rst),
        .en          (~lwStall),
        .PCSrc       (PCSrc_EX),
        .BranchTarget (BranchTarget_EX),
        .PC          (PC)
    );

    instr_mem u_instr_mem (
        .A     (PC),
        .Instr (Instr_IF)
    );

    if_id_reg u_if_id_reg(
        .clk(clk), 
        .reset(rst),
        .stall (lwStall),
        .flush (PCSrc_EX),
        .Instr(Instr_IF),
        .PC (PC),
        .Instr_reg (Instr_reg),
        .PC_ID (PC_ID)
    );

    register_file u_register_file (
        .clk   (clk),
        .reset (rst),
        .A1    (Instr_reg[19:15]),
        .A2    (Instr_reg[24:20]),
        .A3    (Rd_WB),
        .WD3   (Result),
        .WE3   (RegWrite_WB),
        .RD1   (RD1),
        .RD2   (RD2)
    );

    sign_extend u_sign_extend (
        .inst   (Instr_reg),
        .ImmSrc (ImmSrc),
        .ImmExt (ImmExt)
    );
    
    control_unit u_control_unit (
        .op         (Instr_reg[6:0]),
        .funct3     (Instr_reg[14:12]),
        .funct7     (Instr_reg[30]),
        .ImmSrc     (ImmSrc),
        .RegWrite   (RegWrite),
        .ALUSrc     (ALUSrc),
        .MemWrite   (MemWrite),
        .ResultSrc  (ResultSrc),
        .Branch     (Branch),
        .ALUOp      (ALUOp),
        .ALUControl (ALUControl)
    );

    ID_EX_reg u_id_ex_reg (
        .clk           (clk),
        .areset        (rst),
        .stall         (1'b0),
        .flush         (PCSrc_EX || lwStall),   

        .PC_in         (PC_ID),
        .RD1_in        (RD1),
        .RD2_in        (RD2),
        .ImmExt_in     (ImmExt),
        .Rd_in         (Instr_reg[11:7]),
        .Rs1_in        (Instr_reg[19:15]),
        .Rs2_in        (Instr_reg[24:20]),
        .funct3_in     (Instr_reg[14:12]),

        .ALUSrc_in     (ALUSrc),
        .ALUControl_in (ALUControl),
        .MemWrite_in   (MemWrite),
        .RegWrite_in   (RegWrite),
        .ResultSrc_in  (ResultSrc),
        .Branch_in     (Branch),

        .PC_out         (PC_EX),
        .RD1_out        (RD1_EX),
        .RD2_out        (RD2_EX),
        .ImmExt_out     (ImmExt_EX),
        .Rd_out         (Rd_EX),
        .Rs1_out        (Rs1_EX),
        .Rs2_out        (Rs2_EX),
        .funct3_out     (funct3_EX),
        .ALUSrc_out     (ALUSrc_EX),
        .ALUControl_out (ALUControl_EX),
        .MemWrite_out   (MemWrite_EX),
        .RegWrite_out   (RegWrite_EX),
        .ResultSrc_out  (ResultSrc_EX),
        .Branch_out     (Branch_EX)
    );

    hazard_detection_unit u_hazard_unit (
        .ResultSrc_EX (ResultSrc_EX),
        .Rd_EX        (Rd_EX),
        .Rs1_ID       (Instr_reg[19:15]),
        .Rs2_ID       (Instr_reg[24:20]),
        .lwStall      (lwStall)
    );

    forward_unit u_forward_unit (
        .Rs1_EX       (Rs1_EX),
        .Rs2_EX       (Rs2_EX),
        .Rd_MEM       (Rd_MEM),
        .RegWrite_MEM (RegWrite_MEM),
        .Rd_WB        (Rd_WB),
        .RegWrite_WB  (RegWrite_WB),
        .ForwardA     (ForwardA),
        .ForwardB     (ForwardB)
    );

    // ALU operand B select
    mux u_srcb_mux (
        .A  (ForwardedB),
        .B  (ImmExt_EX),
        .S0 (ALUSrc_EX),
        .Z  (SrcB)
    );

    ALU u_ALU (
        .A          (ForwardedA),
        .B          (SrcB),
        .ALUcontrol (ALUControl_EX),
        .ALU_Out    (ALUResult),
        .zero       (Zero),
        .signflag   (sign)
    );

    branch_unit u_branch_unit (
        .Branch_EX      (Branch_EX),
        .funct3_EX      (funct3_EX),
        .Zero           (Zero),
        .sign           (sign),
        .PC_EX          (PC_EX),
        .ImmExt_EX      (ImmExt_EX),
        .PCSrc_EX       (PCSrc_EX),
        .BranchTarget_EX (BranchTarget_EX)
    );

    EX_MEM_reg u_ex_MEM_reg (
        .clk         (clk),
        .areset      (rst),
        .stall       (1'b0),
        .flush       (1'b0),

        .ALUResult_in (ALUResult),
        .WriteData_in (ForwardedB),
        .Rd_in        (Rd_EX),
        .MemWrite_in  (MemWrite_EX),
        .RegWrite_in  (RegWrite_EX),
        .ResultSrc_in (ResultSrc_EX),

        .ALUResult_out (ALUResult_MEM),
        .WriteData_out (WriteData_MEM),
        .Rd_out        (Rd_MEM),
        .MemWrite_out  (MemWrite_MEM),
        .RegWrite_out  (RegWrite_MEM),
        .ResultSrc_out (ResultSrc_MEM)
    );


    data_mem u_data_mem (
        .clk (clk),
        .WE  (MemWrite_MEM),
        .A   (ALUResult_MEM),
        .WD  (WriteData_MEM),
        .RD  (ReadData)
    );

    MEM_WB_reg u_mem_wb_reg (
        .clk         (clk),
        .areset      (rst),
        .stall       (1'b0),
        .flush       (1'b0),

        .ALUResult_in (ALUResult_MEM),
        .ReadData_in  (ReadData),
        .Rd_in        (Rd_MEM),
        .RegWrite_in  (RegWrite_MEM),
        .ResultSrc_in (ResultSrc_MEM),

        .ALUResult_out (ALUResult_WB),
        .ReadData_out  (ReadData_WB),
        .Rd_out        (Rd_WB),
        .RegWrite_out  (RegWrite_WB),
        .ResultSrc_out (ResultSrc_WB)
    );

    // Write-back select
    mux u_result_mux (
        .A  (ALUResult_WB),
        .B  (ReadData_WB),
        .S0 (ResultSrc_WB),
        .Z  (Result)
    );


endmodule
