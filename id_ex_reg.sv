module ID_EX_reg(
    input  wire        clk,
    input  wire        areset,
    input  wire        stall,
    input  wire        flush,    

    // data
    input  wire [31:0] PC_in,
    input  wire [31:0] RD1_in,
    input  wire [31:0] RD2_in,
    input  wire [31:0] ImmExt_in,
    input  wire [4:0]  Rd_in,       // Instr[11:7]  - destination register
    input  wire [4:0]  Rs1_in,      // Instr[19:15] - kept for later forwarding logic
    input  wire [4:0]  Rs2_in,      // Instr[24:20] - kept for later forwarding logic
    input  wire [2:0]  funct3_in,   // needed to pick beq/bne/blt

    // control
    input  wire        ALUSrc_in,
    input  wire [2:0]  ALUControl_in,
    input  wire        MemWrite_in,
    input  wire        RegWrite_in,
    input  wire        ResultSrc_in,
    input  wire        Branch_in,

    output reg  [31:0] PC_out,
    output reg  [31:0] RD1_out,
    output reg  [31:0] RD2_out,
    output reg  [31:0] ImmExt_out,
    output reg  [4:0]  Rd_out,
    output reg  [4:0]  Rs1_out,
    output reg  [4:0]  Rs2_out,
    output reg  [2:0]  funct3_out,

    output reg          ALUSrc_out,
    output reg  [2:0]   ALUControl_out,
    output reg          MemWrite_out,
    output reg          RegWrite_out,
    output reg          ResultSrc_out,
    output reg          Branch_out
);

    always @(posedge clk or negedge areset) begin
        if (!areset) begin
            PC_out         <= 32'b0;
            RD1_out        <= 32'b0;
            RD2_out        <= 32'b0;
            ImmExt_out     <= 32'b0;
            Rd_out         <= 5'b0;
            Rs1_out        <= 5'b0;
            Rs2_out        <= 5'b0;
            funct3_out     <= 3'b0;
            ALUSrc_out     <= 1'b0;
            ALUControl_out <= 3'b0;
            MemWrite_out   <= 1'b0;
            RegWrite_out   <= 1'b0;
            ResultSrc_out  <= 1'b0;
            Branch_out     <= 1'b0;
        end
        else if (flush) begin
            // bubble: data doesn't matter, but control MUST be inert
            // (RegWrite=0, MemWrite=0, Branch=0 so this "instruction" does nothing)
            Rd_out         <= 5'b0;
            Rs1_out        <= 5'b0;  // Add this
            Rs2_out        <= 5'b0;  // Add this
            ALUSrc_out     <= 1'b0;
            ALUControl_out <= 3'b0;
            MemWrite_out   <= 1'b0;
            RegWrite_out   <= 1'b0;
            ResultSrc_out  <= 1'b0;
            Branch_out     <= 1'b0;
        end
        else if (!stall) begin
            PC_out         <= PC_in;
            RD1_out        <= RD1_in;
            RD2_out        <= RD2_in;
            ImmExt_out     <= ImmExt_in;
            Rd_out         <= Rd_in;
            Rs1_out        <= Rs1_in;
            Rs2_out        <= Rs2_in;
            funct3_out     <= funct3_in;
            ALUSrc_out     <= ALUSrc_in;
            ALUControl_out <= ALUControl_in;
            MemWrite_out   <= MemWrite_in;
            RegWrite_out   <= RegWrite_in;
            ResultSrc_out  <= ResultSrc_in;
            Branch_out     <= Branch_in;
        end
    end

endmodule