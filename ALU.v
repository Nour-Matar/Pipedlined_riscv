module ALU(
    input [31:0] A, B,
    input [2:0] ALUcontrol,
    output reg [31:0] ALU_Out,
    output reg zero,
    output reg signflag
);
    always @(*) begin
        case (ALUcontrol)
            3'b000: ALU_Out = A + B; // ADD
            3'b001: ALU_Out = A << B; // LEFT SHIFT
            3'b010: ALU_Out = A - B; // SUBTRACT
            3'b100: ALU_Out = A ^ B; // XOR
            3'b101: ALU_Out = A >> B; // RIGHT SHIFT
            3'b110: ALU_Out = A | B ; // OR
            3'b111: ALU_Out = A & B ; // AND
            default: ALU_Out = 32'b0;
        endcase

        zero = (ALU_Out == 32'b0) ? 1'b1 : 1'b0;
        signflag = ALU_Out[31];
    end
endmodule    

