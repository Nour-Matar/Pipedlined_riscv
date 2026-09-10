module control_unit(
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7,     // instr[30]
    output reg [1:0] ImmSrc,
    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemWrite,
    output reg       ResultSrc,
    output reg       Branch,
    output reg [1:0] ALUOp,
    output reg [2:0] ALUControl
);

    always @(*) begin
        case (op)
            7'b0000011: begin // Load
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00; // I-type
                ALUSrc    = 1'b1;
                MemWrite  = 1'b0;
                ResultSrc = 1'b1;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
            end
            7'b0100011: begin // Store
                RegWrite  = 1'b0;
                ImmSrc    = 2'b01; // S-type
                ALUSrc    = 1'b1;
                MemWrite  = 1'b1;
                ResultSrc = 1'b0;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
            end
            7'b0110011: begin // R-type
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;
                Branch    = 1'b0;
                ALUOp     = 2'b10;
            end
            7'b0010011: begin // I-type (addi etc.)
                RegWrite  = 1'b1;
                ImmSrc    = 2'b00; // I-type
                ALUSrc    = 1'b1;
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;
                Branch    = 1'b0;
                ALUOp     = 2'b10;
            end
            7'b1100011: begin // Branch
                RegWrite  = 1'b0;
                ImmSrc    = 2'b10; // B-type
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;
                Branch    = 1'b1;
                ALUOp     = 2'b01;
            end
            default: begin
                RegWrite  = 1'b0;
                ImmSrc    = 2'b00;
                ALUSrc    = 1'b0;
                MemWrite  = 1'b0;
                ResultSrc = 1'b0;
                Branch    = 1'b0;
                ALUOp     = 2'b00;
            end
        endcase
    end

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // ADD (Load / Store)
            2'b01: ALUControl = 3'b010; // SUB (Branch comparison)
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = (op[5] && funct7) ? 3'b010 : 3'b000; // SUB only for R-type with funct7=1
                    3'b001: ALUControl = 3'b001; // SLL
                    3'b100: ALUControl = 3'b100; // XOR
                    3'b101: ALUControl = 3'b101; // SRL
                    3'b110: ALUControl = 3'b110; // OR
                    3'b111: ALUControl = 3'b111; // AND
                    default: ALUControl = 3'b000;
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end

endmodule