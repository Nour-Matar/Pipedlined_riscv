module branch_unit (
    input  wire        Branch_EX,
    input  wire [2:0]  funct3_EX,
    input  wire        Zero,
    input  wire        sign,
    input  wire [31:0] PC_EX,
    input  wire [31:0] ImmExt_EX,
    output wire        PCSrc_EX,
    output wire [31:0] BranchTarget_EX
);

    reg TakeBranch;

    always @(*) begin
        case (funct3_EX)
            3'b000:  TakeBranch = Zero;          // BEQ
            3'b001:  TakeBranch = !Zero;         // BNE
            3'b100:  TakeBranch = sign;          // BLT (signed)
            3'b101:  TakeBranch = !sign;         // BGE (signed)
            default: TakeBranch = 1'b0;
        endcase
    end

    assign BranchTarget_EX = PC_EX + ImmExt_EX;
    assign PCSrc_EX        = Branch_EX & TakeBranch;

endmodule