module sign_extend(
    input  [31:0] inst,
    input  [1:0]  ImmSrc,
    output reg [31:0] ImmExt
);
    always @(*) begin
        case (ImmSrc)
            2'b00: ImmExt = {{20{inst[31]}}, inst[31:20]};                                   // I-type
            2'b01: ImmExt = {{20{inst[31]}}, inst[31:25], inst[11:7]};                       // S-type
            2'b10: ImmExt = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};        // B-type
            default: ImmExt = 32'b0;
        endcase
    end
endmodule
